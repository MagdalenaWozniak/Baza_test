CREATE PROCEDURE CDN.KntScal_KntWeryfStatHist
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
      SELECT 'cdn.KntWeryfStatHist', A.KWSH_KWSHID, A.KWSH_NIP, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
  FROM cdn.KntWeryfStatHist A
   WHERE A.KWSH_KntID = @KntPodID
 UPDATE cdn.KntWeryfStatHist SET KWSH_KntID = @KntNadID WHERE KWSH_KntID = @KntPodID
 SET NOCOUNT OFF
