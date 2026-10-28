CREATE   PROCEDURE CDN.InicjalizujFSK @TrnOrgId INT
AS
BEGIN
  SET NOCOUNT ON
  DECLARE @OrgId INT
  DECLARE @ZwrId INT
  DECLARE @Bufor SMALLINT
  DECLARE @TypNB SMALLINT
  DECLARE @Rodzaj INT
  DECLARE @DopuscIloscZero INT
  --Sprawdzenie czy na korektach ilosciowych moze byc zero
  --if exists(select trr_trrid from cdn.tranagrelacje where trr_faid = @TrnOrgId and trr_trntyp in (302,301,305) and trr_fatyp in (306,307))
  -- set @DopuscIloscZero = 0
  --else
 SELECT @DopuscIloscZero=Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1759
  --Pobranie danych z nagłówka
  SELECT @OrgId = TrN_TrNId, @ZwrId = TrN_ZwrId, @TypNB = TrN_TypNB, @Bufor = TrN_Bufor, @Rodzaj = TrN_Rodzaj FROM CDN.TraNag WHERE TrN_TrNId = @TrNOrgId
  IF @OrgId IS NULL
    BEGIN
      RAISERROR('##OPT34425##', 16, 1)
      SET NOCOUNT OFF
      RETURN
    END
  --Sprawdzenie, czy faktura jest fakturą korygującą, wówczas poszukujemy oryginału
  IF @ZwrId IS NOT NULL
    BEGIN
      SET @TrnOrgId = @ZwrId
      SELECT @OrgId = TrN_TrNId, @ZwrId = TrN_ZwrId, @TypNB = TrN_TypNB, @Bufor = TrN_Bufor, @Rodzaj = TrN_Rodzaj FROM CDN.TraNag WHERE TrN_TrNId = @TrNOrgId
      IF @OrgId IS NULL
        BEGIN
          RAISERROR('##OPT34425##', 16, 1)
          SET NOCOUNT OFF
          RETURN
        END
    END
  --Sprawdzenie, czy faktura jest w buforze
  IF @Bufor <> 0
    BEGIN
    IF @Bufor = 1
      BEGIN
        RAISERROR('##OPT34426##', 16, 1)
        SET NOCOUNT OFF
        RETURN
      END
    IF @Bufor = -1
      BEGIN
        RAISERROR('##OPT34427##', 16, 1)
        SET NOCOUNT OFF
        RETURN
      END
    ELSE
      BEGIN
        RAISERROR('##OPT34428##', 16, 1)
        SET NOCOUNT OFF
        RETURN
      END
    END
    --dla PWP moze byc 0 dla ilosci elementu
    IF @Rodzaj = 317000 SET @DopuscIloscZero=1
  -- 7.6.1. Faktury zaliczkowe
  -- inny select dla faktur zaliczkowych - wierna kopia z Pro-Formy
  -- lub z dokumentu pierwotnego z odjętymi wartościami z zestawu faktur zaliczkowych
  IF @Rodzaj IN (320000, 320200, 302200,320009)
    BEGIN
      DECLARE @Wynik INT
      EXEC CDN.InicjalizujFAZal @OrgId, 0, @Wynik OUTPUT
    END
  ELSE
  BEGIN
    --Deklaracja tabeli pomocniczej, zawierającej informacje o stanie przed korektą
    CREATE TABLE #TraElemExt (TrE_TrEIdOrg INT PRIMARY KEY, TrE_WartoscOrg NUMERIC(15,2),TrE_WartoscWalOrg NUMERIC(15,2), TrE_WartoscZakOrg NUMERIC(15,2), TrE_IloscOrg NUMERIC(15,4), TrE_IloscJmOrg NUMERIC(15,4), TrE_CenaTOrg NUMERIC(17,4), TrE_CenaWOrg NUMERIC(17,4), TrE_CenaWWDOrg NUMERIC(17,4),TrE_Cena0WDOrg NUMERIC(17,4), TrE_StawkaVatOrg NUMERIC(5,2), TrE_FlagaVatOrg SMALLINT, TrE_ZrodlowaOrg NUMERIC(5,2), TrE_WartoscNOrg NUMERIC(15,2), TrE_WartoscNWalOrg NUMERIC(15,2))
    --
    DECLARE ElementyKorekty CURSOR LOCAL FAST_FORWARD FOR
    SELECT TrE_TrEId FROM CDN.TraElem WHERE TrE_TrNId = @TrnOrgId
    DECLARE @TrEIdOrg      INT
    DECLARE @WartoscOrg    NUMERIC(15,2)
    DECLARE @WartoscNOrg   NUMERIC(15,2)
    DECLARE @WartoscNWalOrg NUMERIC(15,2)
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
    --Przejście po wszystkich elementach faktury i obliczenie dla nich stanu przed korektą
    OPEN ElementyKorekty
    WHILE 1 = 1
      BEGIN
        FETCH NEXT FROM ElementyKorekty INTO @TrEIdOrg
        IF @@FETCH_STATUS <> 0 BREAK
        --Pobranie stanu przed korektą
        SELECT
          @WartoscOrg    = CASE @TypNB WHEN 1 THEN WartoscNOrg ELSE WartoscBOrg END,
          @WartoscNOrg   = WartoscNOrg,
          @WartoscNWalOrg = WartoscNWalOrg,
          @WartoscWalOrg    = CASE @TypNB WHEN 1 THEN WartoscNWalOrg ELSE WartoscBWalOrg END,
          @WartoscZakOrg = WartoscZakOrg,
          @IloscOrg      = IloscOrg,
          @IloscJmOrg    = IloscJmOrg,
          @CenaTOrg      = CenaTOrg,
          @CenaWOrg      = CenaWOrg,
          @CenaWWDOrg      = CenaWWDOrg,
          @Cena0WDOrg      = Cena0WDOrg,
          @StawkavatOrg  = StawkavatOrg,
          @FlagaVatOrg   = FlagaVatOrg,
          @ZrodlowaOrg   = ZrodlowaOrg
        FROM CDN.TraElemKorekta(@TrEIdOrg)
        --Jeśli element został zwrócony - nie dodajemy go do korekty
        IF @DopuscIloscZero=0 AND (@IloscOrg = 0 OR @IloscJmOrg = 0) CONTINUE
        INSERT INTO #TraElemExt (TrE_TrEIdOrg, TrE_WartoscOrg, TrE_WartoscWalOrg, TrE_WartoscZakOrg, TrE_IloscOrg, TrE_IloscJmOrg, TrE_CenaTOrg, TrE_CenaWOrg,TrE_CenaWWDOrg, TrE_Cena0WDOrg, TrE_StawkaVatOrg,  TrE_FlagaVatOrg, TrE_ZrodlowaOrg, TrE_WartoscNOrg, TrE_WartoscNWalOrg)
                    VALUES      (@TrEIdOrg,    @WartoscOrg,    @WartoscWalOrg,    @WartoscZakOrg,    @IloscOrg,    @IloscJmOrg,    @CenaTOrg,    @CenaWOrg,    @CenaWWDOrg, @Cena0WDOrg,@StawkaVatOrg,     @FlagaVatOrg,    @ZrodlowaOrg,  @WartoscNOrg,  @WartoscNWalOrg)
      END
    CLOSE ElementyKorekty
    --Jeśli wszystkie elementy zostały całkowicie zwrócone - nie mozna korygować faktury
    --DM!35512
    --IF NOT EXISTS (SELECT * FROM CDN.TraElem JOIN #TraElemExt ON TrE_TrEId = TrE_TrEIdOrg WHERE TrE_TrNId = @TrNOrgId)
    IF @DopuscIloscZero=0
      IF NOT EXISTS (SELECT * FROM CDN.TraElem JOIN #TraElemExt ON TrE_TrEId = TrE_TrEIdOrg WHERE TrE_TrNId = @TrNOrgId and tre_iloscorg>0)
        BEGIN
          RAISERROR('##OPT34429##', 16, 1)
          SET NOCOUNT OFF
          RETURN
        END
    SET NOCOUNT OFF
    --Procedura zwraca recordset niezbędny do zainicjalizowania faktury
    SELECT CDN.TraElem.*, TrE_WartoscOrg, TrE_WartoscWalOrg, TrE_WartoscZakOrg, TrE_IloscOrg, TrE_IloscJmOrg, TrE_CenaTOrg, TrE_CenaWOrg,TrE_CenaWWDOrg, TrE_Cena0WDOrg,TrE_StawkaVatOrg, TrE_FlagaVatOrg, TrE_ZrodlowaOrg, TrE_WartoscNOrg, TrE_WartoscNWalOrg
    FROM CDN.TraElem JOIN #TraElemExt ON TrE_TrEId = TrE_TrEIdOrg
    WHERE TrE_TrNId = @TrNOrgId and TrE_Kaucja <> 1
    ORDER BY TrE_TrNId, TrE_Lp
  END
END
