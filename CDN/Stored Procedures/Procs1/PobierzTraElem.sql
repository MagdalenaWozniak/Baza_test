CREATE PROCEDURE CDN.PobierzTraElem @TrnOrgId INT
AS
BEGIN
  SET NOCOUNT ON
  DECLARE @OrgId INT
  DECLARE @ZwrId INT
  DECLARE @Bufor SMALLINT
  DECLARE @TypNB SMALLINT
  DECLARE @Rodzaj INT
  --Pobranie danych z faktury (TraNag)
  SELECT @ZwrId = TrN_ZwrId, @TypNB = TrN_TypNB, @Rodzaj = TrN_Rodzaj FROM CDN.TraNag WHERE TrN_TrNId = @TrNOrgId
  --Dla RO/ZD wyliczamy ile towaru już zostało wydane
  CREATE TABLE #TraElemROZD (TrE_TrEIdROZD INT PRIMARY KEY, TrE_IloscWydana NUMERIC(15,4))
  INSERT INTO #TraElemROZD (TrE_TrEIdROZD,  TrE_IloscWydana)
  SELECT TrS_TrEID,ABS(ISNULL(sum(TrS_Ilosc),0)) FROM CDN.TraElem
    Join CDN.TraSElem ON TrS_TrEID = TrE_TrEId
   WHERE TrE_TrNId =@TrNOrgId AND TRS_TrEIdWydania <>0
   GROUP BY TrS_TrEID
  --Deklaracja tabeli pomocniczej, zawierającej informacje o stanie przed korektą
  CREATE TABLE #TraElemExt (TrE_TrEIdOrg INT PRIMARY KEY, TrE_WartoscOrg NUMERIC(15,2),TrE_WartoscWalOrg NUMERIC(15,2), TrE_WartoscZakOrg NUMERIC(15,2), TrE_IloscOrg NUMERIC(15,4), TrE_IloscJmOrg NUMERIC(15,4), TrE_CenaTOrg NUMERIC(17,4), TrE_CenaWOrg NUMERIC(17,4), TrE_CenaWWDOrg NUMERIC(17,4), TrE_Cena0WDOrg NUMERIC(17,4), TrE_StawkaVatOrg NUMERIC(5,2), TrE_FlagaVatOrg SMALLINT, TrE_ZrodlowaOrg NUMERIC(5,2),TrE_WyborDostawOrg   SMALLINT)
  --Akcja zależna od rodzaju edytowanej faktury
  IF @ZwrId IS NOT NULL  --Dla faktury korygującej wypełniamy tabelę pomocniczą zawierającą dane sprzed korekty
    BEGIN
      DECLARE ElementyKorekty CURSOR LOCAL FAST_FORWARD FOR
        SELECT TrE_TrEId, TrE_ZwrId FROM CDN.TraElem WHERE TrE_TrNId = @TrnOrgId
      DECLARE @TrEIdOrg      INT
      DECLARE @TrEIdZwr      INT
      DECLARE @TrELastId     INT
      DECLARE @WartoscOrg    NUMERIC(15,2)
      DECLARE @WartoscWalOrg NUMERIC(15,2)
      DECLARE @WartoscZakOrg NUMERIC(15,2)
      DECLARE @IloscOrg      NUMERIC(15,4)
      DECLARE @IloscJmOrg    NUMERIC(15,4)
      DECLARE @CenaTOrg      NUMERIC(17,4)
      DECLARE @CenaWOrg      NUMERIC(17,4)
      DECLARE @CenaWWDOrg      NUMERIC(17,4)
      DECLARE @Cena0WDOrg      NUMERIC(17,4)
      DECLARE @StawkaVatOrg  NUMERIC(5,2)
      DECLARE @FlagaVatOrg   SMALLINT
      DECLARE @ZrodlowaOrg   NUMERIC(5,2)
   DECLARE @WyborDostawOrg   SMALLINT
      --Liczenie stanu przed korektą dla każdego elementu faktury korygującej
      OPEN ElementyKorekty
      WHILE 1 = 1
        BEGIN
          FETCH NEXT FROM ElementyKorekty INTO @TrEIdOrg, @TrEIdZwr
          IF @@FETCH_STATUS <> 0 BREAK
          --Pobranie wartości przed korektą za pomocą funkcji CDN.TraElemKorekta
          SELECT
            @WartoscOrg    = CASE @TypNB WHEN 1 THEN WartoscNOrg ELSE WartoscBOrg END,
            @WartoscWalOrg = CASE @TypNB WHEN 1 THEN WartoscNWalOrg ELSE WartoscBWalOrg END,
            @WartoscZakOrg = WartoscZakOrg,
            @IloscOrg      = IloscOrg,
            @IloscJmOrg    = IloscJmOrg,
            @CenaTOrg      = CenaTOrg,
            @CenaWOrg      = CenaWOrg,
            @CenaWWDOrg      = CenaWWDOrg,
            @Cena0WDOrg      = Cena0WDOrg,
            @StawkavatOrg  = StawkavatOrg,
            @FlagaVatOrg   = FlagaVatOrg,
            @ZrodlowaOrg   = ZrodlowaOrg,
   @WyborDostawOrg = WyborDostawOrg
          FROM CDN.TraElemKorekta(@TrEIdOrg)
          --Dodanie wiersza z danymi przed korektą do tabeli pomocniczej
          INSERT INTO #TraElemExt (TrE_TrEIdOrg,  TrE_WartoscOrg,  TrE_WartoscWalOrg,  TrE_WartoscZakOrg,  TrE_IloscOrg,  TrE_IloscJmOrg,  TrE_CenaTOrg,  TrE_CenaWOrg,TrE_CenaWWDOrg,TrE_Cena0WDOrg,  TrE_StawkaVatOrg,  TrE_FlagaVatOrg,  TrE_ZrodlowaOrg, TrE_WyborDostawOrg)
                      VALUES      (@TrEIdOrg,     @WartoscOrg,     @WartoscWalOrg,     @WartoscZakOrg,     @IloscOrg,     @IloscJmOrg,     @CenaTOrg,     @CenaWOrg, @CenaWWDOrg,@Cena0WDOrg,    @StawkaVatOrg,     @FlagaVatOrg,     @ZrodlowaOrg  ,@WyborDostawOrg)
        END
      CLOSE ElementyKorekty
    END
 IF @ZwrId IS NULL and @Rodzaj = 302200  --Dla faktury zaliczkowej w buforze musimy miec kwote maksymalna dla zaliczki
    BEGIN
  INSERT INTO #TraElemExt (TrE_TrEIdOrg,  TrE_WartoscWalOrg)
  SELECT TrE_TrEID,TrE_FakZalKwotaMax FROM CDN.TraElem
  WHERE TrE_TrNId =@TrNOrgId
    END
  --Procedura zwraca recordset niezbędny do zainicjalizowania faktury
  SET NOCOUNT OFF
  SELECT CDN.TraElem.*,
  (Select IsNull(TrN_Korekta,0) FROM Cdn.TraNag Where TrN_TrNID=TrE_TrNID) as TrE_Korekta,
  TrE_WartoscOrg, case when @Rodzaj = 302202 then - TrE_WartoscWalOrg else TrE_WartoscWalOrg end as TrE_WartoscWalOrg, TrE_WartoscZakOrg,  TrE_IloscOrg,  TrE_IloscJmOrg,  TrE_CenaTOrg, TrE_CenaWOrg, TrE_CenaWWDOrg,TrE_Cena0WDOrg,TrE_StawkaVatOrg,  TrE_FlagaVatOrg, TrE_ZrodlowaOrg, Tre_IloscWydana, Tre_WyborDostawOrg
  FROM CDN.TraElem
  LEFT OUTER JOIN #TraElemExt ON TrE_TrEId = TrE_TrEIdOrg
  LEFT OUTER JOIN #TraElemROZD ON TrE_TrEId = TrE_TrEIdROZD
  WHERE TrE_TrNId = @TrNOrgId
  ORDER BY TrE_TrNId, TrE_Lp
END
