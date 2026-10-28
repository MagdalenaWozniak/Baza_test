CREATE PROCEDURE CDN.KntScal_Inne
 @KntNadID AS INT, -- ID kontrahenta nadrzędnego (głównego)
 @KntPodID AS INT  -- ID kontrahenta podrzędnego (duplikata)
AS
 SET NOCOUNT ON
 EXEC cdn.KntScal_SprawdzPodmioty @KntNadID, @KntPodID, 0
 IF @@ERROR <> 0 RETURN
 DECLARE @KntNadKod NVARCHAR(20)
 DECLARE @KntPodKod NVARCHAR(20)
 SELECT @KntNadKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntNadID
 SELECT @KntPodKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntPodID
 INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
      SELECT 'cdn.DokPodmioty', A.DoP_DoPId, (SELECT DoN_NumerPelny FROM cdn.DokNag WHERE DoN_DoNID = A.DoP_DoNID), @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
  FROM cdn.DokPodmioty A
   WHERE A.DoP_PodmiotTyp = 1 AND DoP_PodmiotID = @KntPodID AND NOT EXISTS (SELECT * FROM cdn.DokPodmioty B WHERE B.DoP_DoNID = A.DoP_DoNID AND B.DoP_PodmiotTyp = A.DoP_PodmiotTyp AND B.DoP_PodmiotID = @KntNadID)
 ALTER TABLE cdn.DokPodmioty DISABLE TRIGGER ALL
 INSERT INTO cdn.DokPodmioty (DoP_DoNID, DoP_PodmiotTyp, DoP_PodmiotID)
  SELECT A.DoP_DoNID, A.DoP_PodmiotTyp, @KntNadID
  FROM cdn.DokPodmioty A
   WHERE A.DoP_PodmiotTyp = 1 AND DoP_PodmiotID = @KntPodID AND NOT EXISTS (SELECT * FROM cdn.DokPodmioty B WHERE B.DoP_DoNID = A.DoP_DoNID AND B.DoP_PodmiotTyp = A.DoP_PodmiotTyp AND B.DoP_PodmiotID = @KntNadID)
 ALTER TABLE cdn.DokPodmioty ENABLE TRIGGER ALL
 INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
      SELECT 'cdn.FormyPlatnosci', FPl_FPlID, FPl_Nazwa, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
  FROM cdn.FormyPlatnosci WHERE FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @KntPodID
 ALTER TABLE cdn.FormyPlatnosci DISABLE TRIGGER ALL
 UPDATE cdn.FormyPlatnosci SET FPl_PodmiotID = @KntNadID WHERE FPl_PodmiotTyp = 1 AND FPl_PodmiotID = @KntPodID
 ALTER TABLE cdn.FormyPlatnosci ENABLE TRIGGER ALL
 INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
      SELECT 'cdn.SchematPlatnosci', SPl_SPlId, SPL_RachunekNr, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
  FROM cdn.SchematPlatnosci WHERE SPl_OdbPodmiotTyp = 1 AND SPl_OdbPodmiotID = @KntPodID
 ALTER TABLE cdn.SchematPlatnosci DISABLE TRIGGER ALL
 UPDATE cdn.SchematPlatnosci SET SPl_OdbPodmiotID = @KntNadID WHERE SPl_OdbPodmiotTyp = 1 AND SPl_OdbPodmiotID = @KntPodID
 ALTER TABLE cdn.SchematPlatnosci ENABLE TRIGGER ALL
 INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
      SELECT 'cdn.Towary', Twr_TwrId, Twr_Kod, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
  FROM cdn.Towary WHERE Twr_KntId = @KntPodID
 ALTER TABLE cdn.Towary DISABLE TRIGGER ALL
 UPDATE cdn.Towary SET Twr_KntId = @KntNadID WHERE Twr_KntId = @KntPodID
 ALTER TABLE cdn.Towary ENABLE TRIGGER ALL
 ALTER TABLE cdn.KntAtrybuty ENABLE TRIGGER ALL
 INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
      SELECT 'cdn.TwrKntAtrybuty', A.TKA_TKAID, (SELECT DeA_Kod FROM cdn.TwrAtrybuty JOIN cdn.DefAtrybuty ON DeA_DeAId = TwA_DeAId WHERE TwA_TwAId = A.TKA_TwAId), @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
  FROM cdn.TwrKntAtrybuty A
   WHERE A.TKA_PodmiotTyp = 1 AND A.TKA_PodmiotId = @KntPodID
    AND NOT EXISTS (SELECT * FROM cdn.TwrKntAtrybuty B WHERE B.TKA_PodmiotTyp = 1 AND B.TKA_PodmiotId = @KntNadID AND B.TKA_TwAId = A.TKA_TwAId)
 ALTER TABLE cdn.TwrKntAtrybuty DISABLE TRIGGER ALL
 INSERT INTO cdn.TwrKntAtrybuty (TKA_PodmiotTyp, TKA_PodmiotId, TKA_TwAId, TKA_WartoscTxt)
  SELECT 1, @KntNadID, A.TKA_TwAId, A.TKA_WartoscTxt
  FROM cdn.TwrKntAtrybuty A
   WHERE A.TKA_PodmiotTyp = 1 AND A.TKA_PodmiotId = @KntPodID
    AND NOT EXISTS (SELECT * FROM cdn.TwrKntAtrybuty B WHERE B.TKA_PodmiotTyp = 1 AND B.TKA_PodmiotId = @KntNadID AND B.TKA_TwAId = A.TKA_TwAId)
 ALTER TABLE cdn.TwrKntAtrybuty ENABLE TRIGGER ALL
 SET NOCOUNT OFF
