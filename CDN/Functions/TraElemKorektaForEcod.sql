CREATE  FUNCTION CDN.TraElemKorektaForEcod (@TrEId INT)
RETURNS @TraElemKor TABLE (
                          TrEId         INT PRIMARY KEY,
                          WartoscNOrg   NUMERIC(15,2),
                          WartoscBOrg   NUMERIC(15,2),
     WartoscNWalOrg NUMERIC(15,2),
     WartoscBWalOrg NUMERIC(15,2),
                          WartoscZakOrg NUMERIC(15,2),
                          IloscOrg      NUMERIC(15,4),
                          IloscJMOrg    NUMERIC(15,4),
                          CenaTOrg      NUMERIC(15,2),
                          CenaWOrg      NUMERIC(15,2),
              CenaWWDOrg      NUMERIC(15,2),
              Cena0WDOrg      NUMERIC(15,2),
                          StawkaVatOrg  NUMERIC(5,2),
                          FlagaVatOrg   SMALLINT,
                          ZrodlowaOrg   NUMERIC(5,2)
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
  DECLARE @CenaTOrg      NUMERIC(15,2)
  DECLARE @CenaWOrg      NUMERIC(15,2)
  DECLARE @CenaWWDOrg      NUMERIC(15,2)
  DECLARE @Cena0WDOrg      NUMERIC(15,2)
  DECLARE @StawkaVatOrg  NUMERIC(5,2)
  DECLARE @FlagaVatOrg   SMALLINT
  DECLARE @ZrodlowaOrg   NUMERIC(5,2)
  DECLARE @Rodzaj       NUMERIC (10)
  SET @Rodzaj = 0
  SELECT @ZwrId = TrE_ZwrId FROM CDN.TraElem WHERE TrE_TrEId = @TrEId
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
     (CDN.TraElem B JOIN CDN.TraNag  C ON B.TrE_TrNId = C.TrN_TrNId AND C.TrN_Korekta<>5 AND C.TrN_Bufor<>1)
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
      @LastId        = CASE WHEN MAX(IsNull(B.TrE_TrEId,0)) > A.TrE_TrEId THEN MAX(IsNull(B.TrE_TrEId,0)) ELSE A.TrE_TrEId END
    FROM CDN.TraElem A LEFT OUTER JOIN
     (CDN.TraElem B JOIN CDN.TraNag  C ON B.TrE_TrNId = C.TrN_TrNId AND C.TrN_Korekta<>5 AND C.TrN_Bufor<>1)
     ON A.TrE_TrEId = B.TrE_ZwrId AND B.TrE_Aktywny = 1 AND B.TrE_TrEId < @TrEId
    WHERE A.TrE_TrEId = @ZwrId
    GROUP BY A.TrE_TrEId, A.TrE_WartoscNetto, A.TrE_WartoscBrutto, A.TrE_WartoscNettoWal, A.TrE_WartoscBruttoWal, A.TrE_WartoscZakupu, A.TrE_Ilosc, A.TrE_IloscJm
  --Pobranie danych z ostatniej faktury
 IF (@Rodzaj = 317001 and @IloscJmOrg =0) or (@Rodzaj <> 317001 and (@IloscJmOrg =0 OR NOT EXISTS (SELECT * FROM cdn.TraNag JOIN cdn.TraElem ON TrE_TrNId = TrN_TrNId WHERE TrE_TrEId = @LastId AND TrN_Korekta = 2 )))
      BEGIN
       SELECT
         @Cena0WDOrg = cdn.Round2(TrE_Cena0WD),
         @CenaWWDOrg= cdn.Round2(TrE_CenaWWD),
         @CenaTOrg= cdn.Round2(TrE_CenaT),
         @CenaWOrg= cdn.Round2(TrE_CenaW),
         @StawkaVatOrg = TrE_Stawka,
         @FlagaVatOrg = TrE_Flaga,
         @ZrodlowaOrg = TrE_Zrodlowa
      FROM CDN.TraElem
      WHERE TrE_TrEId = @LastId
    END
  ELSE
    BEGIN
       SELECT
        @CenaTOrg = CASE WHEN TrN_TypNB=1 THEN cdn.Round2((@WartoscNWalOrg / @IloscJmOrg)*TrN_KursL / TrN_KursM) ELSE cdn.Round2((@WartoscBWalOrg / @IloscJmOrg)*TrN_KursL / TrN_KursM) END,
        @CenaWOrg = CASE WHEN TrN_TypNB=1 THEN cdn.Round2((@WartoscNWalOrg / @IloscJmOrg)*TrN_KursL / TrN_KursM* TrE_KursM / TrE_KursL) ELSE cdn.Round2((@WartoscBWalOrg / @IloscJmOrg)*TrN_KursL / TrN_KursM* TrE_KursM / TrE_KursL) END,
        @CenaWWDOrg = CASE WHEN TrN_TypNB=1 THEN cdn.Round2(@WartoscNWalOrg/ @IloscJmOrg) ELSE cdn.Round2(@WartoscBWalOrg/ @IloscJmOrg) END,
        @Cena0WDOrg = CASE WHEN TrN_TypNB=1 THEN cdn.Round2(@WartoscNWalOrg/ @IloscOrg) ELSE cdn.Round2(@WartoscBWalOrg/ @IloscOrg) END,
        @StawkaVatOrg = TrE_Stawka,
        @FlagaVatOrg = TrE_Flaga,
        @ZrodlowaOrg = TrE_Zrodlowa
      FROM CDN.TraElem
      JOIN CDN.TraNag on TrE_TrNId=TrN_TrNId
      WHERE TrE_TrEId = @LastId
    END
  --Dodanie wiersza do tabeli zwracanej przez funkcję
  INSERT INTO @TraElemKor
    (TrEId,  WartoscNOrg,  WartoscBOrg,  WartoscNWalOrg, WartoscBWalOrg,WartoscZakOrg,  IloscOrg,  IloscJMOrg,  CenaTOrg,  CenaWOrg, CenaWWDOrg,Cena0WDOrg, StawkaVatOrg,  FlagaVatOrg,  ZrodlowaOrg)
  VALUES
    (@TrEId, @WartoscNOrg, @WartoscBOrg, @WartoscNWalOrg, @WartoscBWalOrg, @WartoscZakOrg, @IloscOrg, @IloscJMOrg, @CenaTOrg, @CenaWOrg, @CenaWWDOrg,@Cena0WDOrg, @StawkaVatOrg, @FlagaVatOrg, @ZrodlowaOrg)
  RETURN
END
