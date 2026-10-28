CREATE PROCEDURE CDN.KntScal_KRD
 @KntNadID AS INT, -- ID kontrahenta nadrzędnego (głównego)
 @KntPodID AS INT  -- ID kontrahenta podrzędnego (duplikata)
AS
 SET NOCOUNT ON
 EXEC cdn.KntScal_SprawdzPodmioty @KntNadID, @KntPodID, 0
 IF @@ERROR <> 0 RETURN
 IF EXISTS (SELECT * FROM cdn.KRD WHERE KRD_KntId = @KntPodID AND KRD_DataOdczytuStatusu > (SELECT IsNull(MAX(A.KRD_DataOdczytuStatusu), 0) FROM CDN.KRD A WHERE A.KRD_KntId = @KntNadID ))
 BEGIN
  DECLARE @KntNadKod NVARCHAR(20)
  DECLARE @KntPodKod NVARCHAR(20)
  SELECT @KntNadKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntNadID
  SELECT @KntPodKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntPodID
  DECLARE @DataOdczytuStatusuNad DATETIME
  SELECT @DataOdczytuStatusuNad = KRD_DataOdczytuStatusu FROM cdn.KRD WHERE KRD_KntId = @KntNadID
  DECLARE @DataOdczytuStatusuPod DATETIME
  SELECT @DataOdczytuStatusuPod = KRD_DataOdczytuStatusu FROM cdn.KRD WHERE KRD_KntId = @KntPodID
  IF @DataOdczytuStatusuPod Is Not Null
   IF @DataOdczytuStatusuNad Is Null
   BEGIN
    INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
         SELECT 'cdn.KRD', A.KRD_KRDID, A.KRD_RaportId, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
     FROM cdn.KRD A
     WHERE A.KRD_KntId = @KntPodID
    INSERT INTO cdn.KRD (KRD_KntID, KRD_DataOdczytuStatusu, KRD_Status, KRD_Monitoring, KRD_MonitoringConditionId, KRD_RaportId, KRD_Regulamin)
     SELECT
      --TOP 1
      @KntNadID, A.KRD_DataOdczytuStatusu, A.KRD_Status, A.KRD_Monitoring, A.KRD_MonitoringConditionId, A.KRD_RaportId, A.KRD_Regulamin
     FROM cdn.KRD A
     WHERE A.KRD_KntId = @KntPodID
   END
   ELSE IF @DataOdczytuStatusuPod > @DataOdczytuStatusuNad  -- IF @DataOdczytuStatusuNad Is NOT Null
   BEGIN
    INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod)
         SELECT 'cdn.KRD', A.KRD_KRDID, A.KRD_RaportId, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
     FROM cdn.KRD A
     WHERE A.KRD_KntId = @KntPodID
    UPDATE cdn.KRD SET KRD_DataOdczytuStatusu = A.KRD_DataOdczytuStatusu, KRD_Status = A.KRD_Status,
      KRD_Monitoring = A.KRD_Monitoring, KRD_MonitoringConditionId = A.KRD_MonitoringConditionId, KRD_RaportId = A.KRD_RaportId, KRD_Regulamin = A.KRD_Regulamin
     FROM (SELECT A.KRD_DataOdczytuStatusu, A.KRD_Status, A.KRD_Monitoring, A.KRD_MonitoringConditionId, A.KRD_RaportId, A.KRD_Regulamin FROM cdn.KRD A WHERE A.KRD_KntId = @KntPodID) A
     WHERE KRD_KntId = @KntNadID
   END
  ALTER TABLE cdn.KRD ENABLE TRIGGER ALL
 END
 SET NOCOUNT OFF
