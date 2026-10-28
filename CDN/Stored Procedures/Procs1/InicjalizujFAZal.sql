CREATE PROCEDURE CDN.InicjalizujFAZal  @OrgId INT, @OverflowTest INT, @Wynik INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON
  DECLARE @Rodzaj INT
  SET @Wynik = 0
  --Pobranie danych z nagłówka
  SELECT @Rodzaj = TrN_Rodzaj
    FROM CDN.TraNag
    WHERE TrN_TrNId = @OrgId
  -- inny select dla faktur zaliczkowych - wierna kopia z Pro-Formy lub z dokumentu pierwotnego (suma wartości)
  IF @Rodzaj IN (320000, 320200, 302200,320009)
    BEGIN
     DECLARE @TraElem_FWtor TABLE ( TrE_Lp INT , TrE_WartoscBrutto DECIMAL (15,2), TrE_WartoscBruttoWal DECIMAL(15,2))
     IF @Rodzaj IN ( 320000, 320200,320009 )
     INSERT INTO @TraElem_FWtor ( TrE_Lp, TrE_WartoscBrutto, TrE_WartoscBruttoWal )
       SELECT TrE_Lp=ISNULL(TrE_Lp,0), TrE_WartoscBrutto = SUM(ISNULL(TrE_WartoscBrutto,0)), TrE_WartoscBruttoWal = SUM(ISNULL(TrE_WartoscBruttoWal,0))
         FROM cdn.TraElem
           JOIN cdn.TraNag ON TrE_TrNId = TrN_TrNId
           JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId
         WHERE  TrR_FaId = @OrgId AND TrN_TypDokumentu = 302 AND TrR_Flaga = 1
           AND TrN_Bufor <> - 1
         GROUP BY TrE_Lp
     IF @Rodzaj IN ( 302200 )
     INSERT INTO @TraElem_FWtor ( TrE_Lp, TrE_WartoscBrutto, TrE_WartoscBruttoWal )
       SELECT TrE_Lp=ISNULL(TrE_Lp,0), TrE_WartoscBrutto = -SUM(ISNULL(TrE_WartoscBrutto,0)), TrE_WartoscBruttoWal = -SUM(ISNULL(TrE_WartoscBruttoWal,0))
         FROM cdn.TraElem
           JOIN cdn.TraNag ON TrE_TrNId = TrN_TrNId
         WHERE  TrN_ZwrId = @OrgId AND TrN_TypDokumentu = 302
           AND TrN_Bufor <> - 1
         GROUP BY TrE_Lp
      SELECT FPier.*,
        TrE_WartoscOrg    = FPier.TrE_WartoscBrutto    - ISNULL(FWtor.TrE_WartoscBrutto,   0),
        TrE_WartoscWalOrg = FPier.TrE_WartoscBruttoWal - ISNULL(FWtor.TrE_WartoscBruttoWal,0),
        TrE_WartoscNOrg    = FPier.TrE_WartoscBrutto    - ISNULL(FWtor.TrE_WartoscBrutto,   0),
        TrE_WartoscNWalOrg = FPier.TrE_WartoscBruttoWal - ISNULL(FWtor.TrE_WartoscBruttoWal,0),
        TrE_WartoscZakOrg = 0,
        TrE_IloscOrg      = FPier.TrE_Ilosc,
        TrE_IloscJmOrg    = FPier.TrE_IloscJm,
        TrE_CenaTOrg      = FPier.TrE_CenaT,
        TrE_CenaWOrg      = FPier.TrE_CenaW,
        TrE_CenaWWDOrg    = FPier.TrE_CenaWWD,
        TrE_Cena0WDOrg    = FPier.TrE_Cena0WD,
        TrE_StawkaVatOrg  = FPier.TrE_Stawka,
        TrE_FlagaVatOrg   = FPier.TrE_Flaga,
        TrE_ZrodlowaOrg   = FPier.TrE_Zrodlowa
      INTO #TraElemFaZal
      FROM cdn.TraElem FPier
      LEFT OUTER JOIN @TraElem_FWtor AS FWtor ON FWtor.TrE_Lp = FPier.TrE_Lp
      WHERE TrE_TrNId = @OrgId
        AND FPier.TrE_WartoscBruttoWal - ISNULL(FWtor.TrE_WartoscBruttoWal,0) <> 0
      IF @Rodzaj = 302200
        UPDATE #TraElemFaZal SET
         TrE_Ilosc            = -TrE_Ilosc,
         TrE_IloscJM          = -TrE_IloscJM,
         TrE_WartoscNetto     = -TrE_WartoscNetto,
         TrE_WartoscNettoWal  = -TrE_WartoscNettoWal,
         TrE_WartoscBrutto    = -TrE_WartoscBrutto,
         TrE_WartoscBruttoWal = -TrE_WartoscBruttoWal,
         TrE_KosztUslugi      = -TrE_KosztUslugi,
         TrE_IloscOrg         = -TrE_IloscOrg,
         TrE_IloscJmOrg       = -TrE_IloscJmOrg,
         TrE_WartoscOrg       = -TrE_WartoscOrg,
         TrE_WartoscWalOrg    = -TrE_WartoscWalOrg
      /* UPDATE #TraElemFaZal SET
         TrE_Rabat            = 0,
         TrE_Cena0            = TrE_WartoscBrutto / TrE_IloscJM,
         TrE_CenaW            = TrE_WartoscBrutto / TrE_IloscJM,
         TrE_Cena0WD          = TrE_WartoscBruttoWal / TrE_IloscJM,
         TrE_CenaWWD          = TrE_WartoscBruttoWal / TrE_IloscJM,
         TrE_CenaT            = TrE_WartoscBrutto / TrE_IloscJM
      */
      IF @OverflowTest = 1
        BEGIN
          IF EXISTS ( SELECT * FROM #TraElemFaZal WHERE TrE_WartoscOrg < 0 OR TrE_WartoscWalOrg < 0 )
            SET @Wynik = 1
          SET NOCOUNT OFF
          RETURN
        END
      IF EXISTS ( SELECT * FROM #TraElemFaZal )
        SELECT * FROM #TraElemFaZal
       ELSE
         BEGIN
           RAISERROR('##OPT34456##', 16, 1)
           SET NOCOUNT OFF
           RETURN
         END
     END
END
SET NOCOUNT OFF
