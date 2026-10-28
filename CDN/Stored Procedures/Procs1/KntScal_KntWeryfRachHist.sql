CREATE PROCEDURE CDN.KntScal_KntWeryfRachHist
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
      SELECT 'cdn.KntWeryfRachHist', A.KWRH_KWRHID, A.KWRH_NIP + ', ' + A.KWRH_RachunekNr, @KntPodID, @KntPodKod, @KntNadID, @KntNadKod
  FROM cdn.KntWeryfRachHist A
   WHERE A.KWRH_KntID = @KntPodID
 -- Jeśli na kontrahencie głównym jest już zapis w historii z tym samym nipem, numerem rachunku i datą sprawdzenia, to nie przenosimy takiego zapisu bo byłaby duplikacja indeksu.
 -- Zostawiamy taki zapis na karcie duplikata bo jest to info, którego nie chcemy tracić - teoretycznie wynik sprawdzenia na karcie głównej tej smej pary (nip, nrRach) w tej samej dacie może być inny.
 UPDATE cdn.KntWeryfRachHist SET KWRH_KntID = @KntNadID FROM cdn.KntWeryfRachHist A WHERE A.KWRH_KntID = @KntPodID
  AND NOT EXISTS (SELECT * FROM cdn.KntWeryfRachHist B WHERE B.KWRH_KntID = @KntNadID AND B.KWRH_Nip = A.KWRH_Nip AND B.KWRH_RachunekNr = A.KWRH_RachunekNr AND B.KWRH_Data = A.KWRH_Data)
 --DELETE cdn.KntWeryfRachHist WHERE KWRH_KntID = @KntPodID
 SET NOCOUNT OFF
