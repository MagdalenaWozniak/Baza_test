CREATE  FUNCTION CDN.TraElemKorekta (@TrEId INT)
RETURNS @TraElemKor TABLE (
                          TrEId         INT PRIMARY KEY,
                          WartoscNOrg   NUMERIC(15,2),
                          WartoscBOrg   NUMERIC(15,2),
                          WartoscNWalOrg NUMERIC(15,2),
                          WartoscBWalOrg NUMERIC(15,2),
                          WartoscZakOrg NUMERIC(15,2),
                          IloscOrg      NUMERIC(15,4),
                          IloscJMOrg    NUMERIC(15,4),
                          CenaTOrg      NUMERIC(17,4),
                          CenaWOrg      NUMERIC(17,4),
                          CenaWWDOrg      NUMERIC(17,4),
                          Cena0WDOrg      NUMERIC(17,4),
                          StawkaVatOrg  NUMERIC(5,2),
                          FlagaVatOrg   SMALLINT,
                          ZrodlowaOrg   NUMERIC(5,2),
                          CenaTOrgAvg  NUMERIC(17,4),
                          CenaWOrgAvg  NUMERIC(17,4),
        WyborDostawOrg   SMALLINT
                          )
AS
BEGIN
  DECLARE @ZwrId         INT
  DECLARE @LastId        INT
  DECLARE @WartoscNOrg   NUMERIC(15,2)
  DECLARE @WartoscBOrg   NUMERIC(15,2)
  DECLARE @WartoscNWalOrg   NUMERIC(15,2)
  DECLARE @WartoscBWalOrg   NUMERIC(15,2)
  DECLARE @WartoscZakOrg NUMERIC(15,2)
  DECLARE @IloscOrg      NUMERIC(15,4)
  DECLARE @IloscJMOrg    NUMERIC(15,4)
  DECLARE @CenaTOrg      NUMERIC(17,4)
  DECLARE @CenaWOrg      NUMERIC(17,4)
  DECLARE @CenaWWDOrg    NUMERIC(17,4)
  DECLARE @Cena0WDOrg    NUMERIC(17,4)
  DECLARE @CenaTOrgAve   NUMERIC(17,4)
  DECLARE @CenaWOrgAve   NUMERIC(17,4)
  DECLARE @StawkaVatOrg  NUMERIC(5,2)
  DECLARE @FlagaVatOrg   SMALLINT
  DECLARE @ZrodlowaOrg   NUMERIC(5,2)
  DECLARE @Rodzaj        NUMERIC (10)
  DECLARE @TrN_TypNB  INT
  DECLARE @TrN_KursL     NUMERIC(15,4)
  DECLARE @TrN_KursM     NUMERIC(15,2)
  DECLARE @ZaokraglajDo  SMALLINT
  DECLARE @WyborDostawOrg SMALLINT
  SET @Rodzaj = 0
  SELECT @ZwrId = TrE_ZwrId , @TrN_TypNB= TrN_TypNB , @TrN_KursL = TrN_KursL , @TrN_KursM = TrN_KursM, @ZaokraglajDo = case when TrE_CenaZCzteremaMiejscami = 1 then 4 else 2 end FROM CDN.TraElem
  JOIN CDN.TraNag on TrE_TrNId=TrN_TrNId
  WHERE TrE_TrEId = @TrEId
  SELECT top 1 @TrN_KursL = TrN_KursL , @TrN_KursM = TrN_KursM FROM CDN.TraElem
  JOIN CDN.TraNag on TrE_TrNId=TrN_TrNId
  WHERE  (TrE_ZwrId = @ZwrId or Tre_trEId = @ZwrId or TrE_ZwrId = @TrEId) and TrE_TrEID != @TrEId and TrN_Bufor = 0 and TrN_Korekta <> 5 order by tre_treid desc
  --Pobranie danych sumarycznych oryginału i wszystkich dotychczasowych korekt
  IF @ZwrId IS NULL -- Pobranie danych z faktury oryginalnej, obliczenie całkowitej korekty dla tej faktury
    SELECT
      @WartoscNOrg   = A.TrE_WartoscNetto  + SUM(IsNull(B.TrE_WartoscNetto,0)),
      @WartoscBOrg   = A.TrE_WartoscBrutto + SUM(IsNull(B.TrE_WartoscBrutto,0)),
      @WartoscNWalOrg   = A.TrE_WartoscNettoWal  + SUM(IsNull(B.TrE_WartoscNettoWal,0)),
      @WartoscBWalOrg   = A.TrE_WartoscBruttoWal + SUM(IsNull(B.TrE_WartoscBruttoWal,0)),
      @WartoscZakOrg = A.TrE_WartoscZakupu + SUM(IsNull(B.TrE_WartoscZakupu,0)),
      @IloscOrg      = A.TrE_Ilosc         + SUM(IsNull(B.TrE_Ilosc,0)),
      @IloscJmOrg    = A.TrE_IloscJm       + SUM(IsNull(B.TrE_IloscJm,0)),
      @Rodzaj        = max(IsNull(C.TrN_Rodzaj,0)),
      @LastId        = CASE WHEN MAX(IsNull(B.TrE_TrEId,0)) > A.TrE_TrEId THEN MAX(IsNull(B.TrE_TrEId,0)) ELSE A.TrE_TrEId END
    FROM CDN.TraElem A LEFT OUTER JOIN
     (CDN.TraElem B JOIN CDN.TraNag  C ON B.TrE_TrNId = C.TrN_TrNId AND C.TrN_Korekta<>5 AND C.TrN_Bufor<>1 AND TrN_Rodzaj not in (306061,306071,306072))
     ON A.TrE_TrEId = B.TrE_ZwrId AND B.TrE_Aktywny = 1
    WHERE A.TrE_TrEId = @TrEId
    GROUP BY A.TrE_TrEId, A.TrE_WartoscNetto, A.TrE_WartoscBrutto, A.TrE_WartoscNettoWal, A.TrE_WartoscBruttoWal, A.TrE_WartoscZakupu, A.TrE_Ilosc, A.TrE_IloscJm
  ELSE  --Pobranie danych dla faktury korygującej - stan przed wykonaniem tej korekty
    SELECT
      @WartoscNOrg   = A.TrE_WartoscNetto  + SUM(IsNull(B.TrE_WartoscNetto,0)),
      @WartoscBOrg   = A.TrE_WartoscBrutto + SUM(IsNull(B.TrE_WartoscBrutto,0)),
      @WartoscNWalOrg   = A.TrE_WartoscNettoWal  + SUM(IsNull(B.TrE_WartoscNettoWal,0)),
      @WartoscBWalOrg   = A.TrE_WartoscBruttoWal + SUM(IsNull(B.TrE_WartoscBruttoWal,0)),
      @WartoscZakOrg = A.TrE_WartoscZakupu + SUM(IsNull(B.TrE_WartoscZakupu,0)),
      @IloscOrg      = A.TrE_Ilosc         + SUM(IsNull(B.TrE_Ilosc,0)),
      @IloscJmOrg    = A.TrE_IloscJm       + SUM(IsNull(B.TrE_IloscJm,0)),
      @Rodzaj        = max(IsNull(C.TrN_Rodzaj,0)),
      @LastId        = CASE WHEN MAX(IsNull(B.TrE_TrEId,0)) > A.TrE_TrEId THEN MAX(IsNull(B.TrE_TrEId,0)) ELSE A.TrE_TrEId END,
   @WyborDostawOrg =  max(A.TrE_WyborDostaw)
    FROM CDN.TraElem A LEFT OUTER JOIN
     (CDN.TraElem B JOIN CDN.TraNag  C ON B.TrE_TrNId = C.TrN_TrNId AND C.TrN_Korekta<>5 AND C.TrN_Bufor<>1 )
     ON A.TrE_TrEId = B.TrE_ZwrId AND B.TrE_Aktywny = 1 AND B.TrE_TrEId < @TrEId
    WHERE A.TrE_TrEId = @ZwrId
    GROUP BY A.TrE_TrEId, A.TrE_WartoscNetto, A.TrE_WartoscBrutto, A.TrE_WartoscNettoWal, A.TrE_WartoscBruttoWal, A.TrE_WartoscZakupu, A.TrE_Ilosc, A.TrE_IloscJm
  --Pobranie danych z ostatniej faktury
IF (@Rodzaj = 317001 and @IloscJmOrg =0) or (@Rodzaj <> 317001 and (@IloscJmOrg =0 OR (NOT EXISTS (SELECT * FROM cdn.TraNag JOIN cdn.TraElem ON TrE_TrNId = TrN_TrNId WHERE TrE_TrEId = @LastId  AND TrN_Korekta = 2 AND TrN_Bufor != -1  and @IloscJmOrg    != TrE_IloscJMKW )
 AND NOT EXISTS (SELECT * FROM cdn.TraNag JOIN cdn.TraElem ON TrE_TrNId = TrN_TrNId WHERE TrE_TrEId = @TrEId  AND TrN_Korekta = 2 AND TrN_Bufor != - 1 and @IloscJmOrg    != TrE_IloscJMKW ))))
      BEGIN
       SELECT
         @Cena0WDOrg=TrE_Cena0WD,
         @CenaWWDOrg=TrE_CenaWWD,
         @CenaTOrg=TrE_CenaT,
         @CenaWOrg=TrE_CenaW,
         @StawkaVatOrg = TrE_Stawka,
         @FlagaVatOrg = TrE_Flaga,
         @ZrodlowaOrg = TrE_Zrodlowa,
   @CenaTOrgAve = round(CASE WHEN @IloscJmOrg = 0 THEN 0 ELSE CASE WHEN @TrN_TypNB=1 THEN (@WartoscNOrg / @IloscJmOrg )ELSE (@WartoscBOrg / @IloscJmOrg) END END,@ZaokraglajDo),
   @CenaWOrgAve = round(CASE WHEN @IloscJmOrg = 0 THEN 0 ELSE CASE WHEN @TrN_TypNB=1 THEN( @WartoscNWalOrg / @IloscJmOrg )  ELSE (@WartoscBWalOrg / @IloscJmOrg) END END,@ZaokraglajDo)
      FROM CDN.TraElem
      WHERE TrE_TrEId = @LastId
    END
  ELSE
    BEGIN
       SELECT
        @CenaTOrg = round(CASE WHEN @TrN_TypNB=1 THEN (@WartoscNWalOrg / @IloscJmOrg)*@TrN_KursL / @TrN_KursM ELSE (@WartoscBWalOrg / @IloscJmOrg)*@TrN_KursL / @TrN_KursM END,@ZaokraglajDo),
        @CenaTOrgAve = @CenaTOrg,
        @CenaWOrg = round(CASE WHEN @TrN_TypNB=1 THEN(@WartoscNWalOrg / @IloscJmOrg)*@TrN_KursL / @TrN_KursM* TrE_KursM / TrE_KursL ELSE (@WartoscBWalOrg / @IloscJmOrg)*@TrN_KursL / @TrN_KursM* TrE_KursM / TrE_KursL END,@ZaokraglajDo),
        @CenaWOrgAve = @CenaWOrg,
        @CenaWWDOrg = round(CASE WHEN @TrN_TypNB=1 THEN @WartoscNWalOrg/ @IloscJmOrg ELSE @WartoscBWalOrg/ @IloscJmOrg END,@ZaokraglajDo),
        @Cena0WDOrg = round(CASE WHEN @TrN_TypNB=1 THEN @WartoscNWalOrg/ @IloscOrg ELSE @WartoscBWalOrg/ @IloscOrg END,@ZaokraglajDo),
        @StawkaVatOrg = TrE_Stawka,
        @FlagaVatOrg = TrE_Flaga,
        @ZrodlowaOrg = TrE_Zrodlowa
      FROM CDN.TraElem
      WHERE TrE_TrEId = @LastId
    END
  --Dodanie wiersza do tabeli zwracanej przez funkcję
  INSERT INTO @TraElemKor
    (TrEId,  WartoscNOrg,  WartoscBOrg,  WartoscNWalOrg, WartoscBWalOrg,WartoscZakOrg,  IloscOrg,  IloscJMOrg,  CenaTOrg,  CenaWOrg, CenaWWDOrg,Cena0WDOrg, StawkaVatOrg,  FlagaVatOrg,  ZrodlowaOrg , CenaTOrgAvg , CenaWOrgAvg, WyborDostawOrg)
  VALUES
    (@TrEId, @WartoscNOrg, @WartoscBOrg, @WartoscNWalOrg, @WartoscBWalOrg, @WartoscZakOrg, @IloscOrg, @IloscJMOrg, @CenaTOrg, @CenaWOrg, @CenaWWDOrg,@Cena0WDOrg, @StawkaVatOrg, @FlagaVatOrg, @ZrodlowaOrg, @CenaTOrgAve ,@CenaWOrgAve, @WyborDostawOrg)
  RETURN
END
