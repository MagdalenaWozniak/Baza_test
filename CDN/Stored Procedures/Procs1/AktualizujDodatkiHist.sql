CREATE PROCEDURE CDN.AktualizujDodatkiHist @PraId INT
AS
SET NOCOUNT ON
DECLARE @OkresTmp DATETIME, @OkresOd DATETIME, @OkresDo DATETIME, @DodId INT, @DoHId INT, @DodTmpId INT
-- Sprawdzenie i aktualizacja OkresOd w pierwszym rekordzie
DECLARE DodatkiNag CURSOR LOCAL FAST_FORWARD FOR SELECT DOD_DodId FROM CDN.Dodatki WHERE Dod_PraId = @PraId
OPEN DodatkiNag
WHILE 1=1
 BEGIN
   FETCH NEXT FROM DodatkiNag INTO @DodId
   IF @@FETCH_STATUS <> 0 BREAK
   SET @OkresTmp = CONVERT (datetime, '1900-01-01', 120)
   SELECT TOP 1 @DoHId = DOH_DoHId, @OkresOd = DOH_OkresOd FROM CDN.DodatkiHist WHERE DOH_DodId = @DodId ORDER BY DOH_OkresOd
   IF NOT (@OkresOd = @OkresTmp)
     UPDATE CDN.DodatkiHist SET DOH_OkresOd = @OkresTmp WHERE DOH_DoHId = @DoHId
 END
CLOSE DodatkiNag
DEALLOCATE DodatkiNag
-- Sprawdzenie i aktualizacja OkresDo w całej historii
DECLARE DodatkiElem CURSOR LOCAL FAST_FORWARD FOR
  SELECT DOH_DodId, DOH_DoHId, DOH_OkresOd, DOH_OkresDo FROM CDN.DodatkiHist JOIN CDN.Dodatki ON DOD_DodId = DOH_DodId WHERE DOD_PraId = @PraId ORDER BY DOH_DodId, DOH_OkresOd DESC
OPEN DodatkiElem
SET @DodTmpId = 0
WHILE 1=1
 BEGIN
   FETCH NEXT FROM DodatkiElem INTO @DodId, @DoHId, @OkresOd, @OkresDo
   IF @@FETCH_STATUS <> 0 BREAK
   IF NOT (@DodId = @DodTmpId) SET @OkresTmp = CONVERT (datetime, '2999-12-31', 120)
   IF NOT (@OkresDo = @OkresTmp)
      UPDATE CDN.DodatkiHist SET DOH_OkresDo = @OkresTmp WHERE DOH_DoHId = @DoHId
   SET @OkresTmp = DATEADD(day, -1, @OkresOd)
   SET @DodTmpId = @DodId
 END
CLOSE DodatkiElem
DEALLOCATE DodatkiElem
SET NOCOUNT OFF
