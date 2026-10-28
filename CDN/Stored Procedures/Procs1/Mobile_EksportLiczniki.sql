CREATE Procedure [CDN].[Mobile_EksportLiczniki]
@TypLicznika INT, -- 1 -> Towary, 2 -> Kontrahenci, 3 -> Limity kontrahentów, 4 -> Grupy towarowe
@ID    INT, -- ID stanowiska mobilnego
@TypEksportu INT -- Typ eksportu (0 - różnicowy, 1 - pełny)
AS
BEGIN
SET NOCOUNT ON;
-- Tabela z wynikami
CREATE TABLE #Liczniki
(
 Licznik INT
)
-- Tabela pomocnicza z towarami
CREATE TABLE #Towary
(
 TowarID INT
)
-- Zmienne
DECLARE @DSta_TS_SynchroTwr  DATETIME
DECLARE @DSta_TS_SynchroKNT  DATETIME
DECLARE @GrupaTowarow INT
DECLARE @KntGrupa NVARCHAR(20)
-- Błąd nieprawidłowego ID stanowiska mobilnego
IF NOT EXISTS (select dsta_dstaid from cdn.detalstanowiska where dsta_dstaid = @ID)
 BEGIN
  --RAISERROR('Nie znaleziono Stanowiska w konfiguracji Optimy ', 16, 1)
     EXEC CDN.RaiseOptimaException 34166
  ROLLBACK
 SET NOCOUNT OFF;
 RETURN
 END
IF @TypLicznika = 1 -- Towary
 BEGIN
  SELECT @DSta_TS_SynchroTwr = DSta_TS_SynchroTwrPotw FROM CDN.DetalStanowiska  WHERE DSta_DStaId = @ID
  SELECT @GrupaTowarow = DSta_TwGGIDNumer FROM CDN.DetalStanowiska WHERE DSta_DStaId = @ID
  INSERT INTO #Towary(TowarID)
  SELECT Twr_TwrId FROM CDN.Towary
   WHERE Twr_TS_Mod > CASE WHEN @TypEksportu=0 THEN @DSta_TS_SynchroTwr ELSE 0 END AND Twr_NieAktywny = 0
   AND EXISTS(SELECT GrONumer FROM CDN.TwrGrupyESklep (@GrupaTowarow) WHERE GIDTyp = 16 AND GIDNumer = Twr_TwrId)
  INSERT INTO #Towary(TowarID)
  SELECT TrE_TwrId FROM CDN.DetalStanowiska
   JOIN CDN.TraNag ON TrN_MagDocId = DSta_MagId AND ISNULL(TrN_GIDNumer,0) = 0
   JOIN CDN.TraElem ON TrE_TrNId = TrN_TrNID
    WHERE DSta_DStaId = @ID and TrN_MagDocId = DSta_MagId
    AND TrN_TypDokumentu = 312 and TrN_Bufor = 0
 INSERT INTO #Liczniki (Licznik)
 SELECT COUNT(DISTINCT(TowarID)) FROM #Towary
 SELECT Licznik FROM #Liczniki
 END
IF @TypLicznika = 2 -- Kontrahenci
 BEGIN
  SELECT @DSta_TS_SynchroKnt = DSta_TS_SynchroKntPotw, @KntGrupa = DSta_KntGrupa
   FROM CDN.DetalStanowiska WHERE DSta_DStaId = @ID
  IF @KntGrupa = ''
   BEGIN
    INSERT INTO #Liczniki (Licznik)
    SELECT COUNT(*) FROM CDN.Kontrahenci
     WHERE Knt_NieAktywny = 0
     AND Knt_TS_Mod > CASE WHEN @TypEksportu=0 THEN @DSta_TS_SynchroKnt ELSE 0 END
    SELECT Licznik FROM #Liczniki
   END
   ELSE
   BEGIN
    INSERT INTO #Liczniki (Licznik)
    SELECT COUNT(*) FROM CDN.Kontrahenci
     WHERE Knt_NieAktywny=0
      AND Knt_TS_Mod > CASE WHEN @TypEksportu=0 THEN @DSta_TS_SynchroKnt ELSE 0 END
      AND (Knt_Grupa = @KntGrupa or Knt_KntId = 1)
    SELECT Licznik FROM #Liczniki
   END
 END
IF @TypLicznika = 3 -- Limity kontrahentów
 BEGIN
  SELECT @DSta_TS_SynchroKnt = DSta_TS_SynchroKntPotw, @KntGrupa = DSta_KntGrupa
   FROM CDN.DetalStanowiska WHERE DSta_DStaId = @ID
  IF @KntGrupa = ''
   BEGIN
    INSERT INTO #Liczniki (Licznik)
    SELECT COUNT(*) FROM
    CDN.Kontrahenci
     LEFT JOIN CDN.DetalFormyPlatnosci ON Knt_FplId = DFPl_FPlId and @ID = DFPl_DStaId
     LEFT JOIN CDN.FormyPlatnosci ON DFPl_FPlId = FPl_FPlId
      WHERE Knt_NieAktywny=0
    SELECT Licznik FROM #Liczniki
   END
   ELSE
   BEGIN
    INSERT INTO #Liczniki (Licznik)
    SELECT COUNT(*) FROM CDN.Kontrahenci
      WHERE Knt_NieAktywny=0 AND Knt_Grupa = @KntGrupa
    SELECT Licznik FROM #Liczniki
   END
 END
IF @TypLicznika = 4 -- Grupy towarowe
 BEGIN
  INSERT INTO #Liczniki (Licznik)
  SELECT COUNT(*) FROM CDN.TwrGrupy
   JOIN CDN.DetalStanowiska ON DSta_DStaId = @ID
     WHERE (TwG_GIDTyp = -16 AND EXISTS(SELECT * FROM CDN.TwrGrupy WHERE TwG_GIDTyp = -16  AND DATEADD( SECOND, TwG_CzasModyfikacji,CONVERT(DATETIME,'1990-01-01',120)) > CASE WHEN @TypEksportu = 0 THEN DSta_TS_SynchrogrupPotw ELSE 0 END ))
     OR (TwG_GIDTyp = 16 AND TwG_GIDNumer > 0
     AND DATEADD( SECOND, TwG_CzasModyfikacji,CONVERT(DATETIME,'1990-01-01',120)) > CASE WHEN @TypEksportu = 0 THEN DSta_TS_SynchrogrupPotw ELSE 0 END)
  SELECT Licznik FROM #Liczniki
 END
SET NOCOUNT OFF;
END
