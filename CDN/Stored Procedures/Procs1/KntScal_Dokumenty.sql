CREATE PROCEDURE CDN.KntScal_Dokumenty
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
      SELECT 'cdn.CRMKontakty', CRK_CRKID, CRK_NumerPelny, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
  FROM cdn.CRMKontakty WHERE CRK_PodmiotTyp = 1 AND CRK_PodID = @KntPodID
 ALTER TABLE cdn.CRMKontakty DISABLE TRIGGER ALL
 UPDATE cdn.CRMKontakty SET CRK_PodID = @KntNadID WHERE CRK_PodmiotTyp = 1 AND CRK_PodID = @KntPodID
 ALTER TABLE cdn.CRMKontakty ENABLE TRIGGER ALL
 INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
      SELECT 'cdn.SenditZleceniePrzesylki', SZL_SZLId, SZL_NumerPelny, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
  FROM cdn.SenditZleceniePrzesylki WHERE SZL_OdbiorcaTyp = 1 AND SZL_OdbID = @KntPodID
 ALTER TABLE cdn.SenditZleceniePrzesylki DISABLE TRIGGER ALL
 UPDATE cdn.SenditZleceniePrzesylki SET SZL_OdbID = @KntNadID WHERE SZL_OdbiorcaTyp = 1 AND SZL_OdbID = @KntPodID
 ALTER TABLE cdn.SenditZleceniePrzesylki ENABLE TRIGGER ALL
 INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
      SELECT 'cdn.SrsCyklNag', SrW_SrWId, SrW_Kod, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
  FROM cdn.SrsCyklNag WHERE SrW_OdbiorcaTyp = 1 AND SrW_OdbID = @KntPodID OR SrW_PodmiotTyp = 1 AND SrW_PodmiotId = @KntPodID
 ALTER TABLE cdn.SrsCyklNag DISABLE TRIGGER ALL
 UPDATE cdn.SrsCyklNag SET SrW_OdbID = @KntNadID WHERE SrW_OdbiorcaTyp = 1 AND SrW_OdbID = @KntPodID
 UPDATE cdn.SrsCyklNag SET SrW_PodmiotId = @KntNadID WHERE SrW_PodmiotTyp = 1 AND SrW_PodmiotId = @KntPodID
 ALTER TABLE cdn.SrsCyklNag ENABLE TRIGGER ALL
 INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
      SELECT 'cdn.SrsUrzadzenia', SrU_SrUId, SrU_Kod, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
  FROM cdn.SrsUrzadzenia WHERE SrU_OdbiorcaTyp = 1 AND SrU_OdbID = @KntPodID OR SrU_PodmiotTyp = 1 AND SrU_PodmiotId = @KntPodID
 ALTER TABLE cdn.SrsUrzadzenia DISABLE TRIGGER ALL
 UPDATE cdn.SrsUrzadzenia SET SrU_OdbID = @KntNadID WHERE SrU_OdbiorcaTyp = 1 AND SrU_OdbID = @KntPodID
 UPDATE cdn.SrsUrzadzenia SET SrU_PodmiotId = @KntNadID WHERE SrU_PodmiotTyp = 1 AND SrU_PodmiotId = @KntPodID
 ALTER TABLE cdn.SrsUrzadzenia ENABLE TRIGGER ALL
 INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
      SELECT 'cdn.SrsZlecenia', SrZ_SrZId, SrZ_NumerPelny, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
  FROM cdn.SrsZlecenia WHERE SrZ_OdbiorcaTyp = 1 AND SrZ_OdbID = @KntPodID OR SrZ_PodmiotTyp = 1 AND SrZ_PodmiotId = @KntPodID
 ALTER TABLE cdn.SrsZlecenia DISABLE TRIGGER ALL
 UPDATE cdn.SrsZlecenia SET SrZ_OdbID = @KntNadID WHERE SrZ_OdbiorcaTyp = 1 AND SrZ_OdbID = @KntPodID
 UPDATE cdn.SrsZlecenia SET SrZ_PodmiotId = @KntNadID WHERE SrZ_PodmiotTyp = 1 AND SrZ_PodmiotId = @KntPodID
 ALTER TABLE cdn.SrsZlecenia ENABLE TRIGGER ALL
 INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
      SELECT 'cdn.WindykacjaLog', WiL_WiLId, WiL_NumerDok, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
  FROM cdn.WindykacjaLog WHERE WiL_PodmiotTyp = 1 AND WiL_PodmiotId = @KntPodID
 ALTER TABLE cdn.WindykacjaLog DISABLE TRIGGER ALL
 UPDATE cdn.WindykacjaLog SET WiL_PodmiotId = @KntNadID WHERE WiL_PodmiotTyp = 1 AND WiL_PodmiotId = @KntPodID
 ALTER TABLE cdn.WindykacjaLog ENABLE TRIGGER ALL
 INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
      SELECT 'cdn.ZajeciaWynagr', ZaW_ZaWId, ZAW_Nazwa, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
  FROM cdn.ZajeciaWynagr WHERE ZaW_KntId = @KntPodID
 ALTER TABLE cdn.ZajeciaWynagr DISABLE TRIGGER ALL
 UPDATE cdn.ZajeciaWynagr SET ZaW_KntId = @KntNadID WHERE ZaW_KntId = @KntPodID
 ALTER TABLE cdn.ZajeciaWynagr ENABLE TRIGGER ALL
 SET NOCOUNT OFF
