CREATE PROCEDURE CDN.AktualizujAkordyHist @PraId INT
AS
SET NOCOUNT ON
DECLARE @OkresTmp DATETIME, @OkresOd DATETIME, @OkresDo DATETIME, @AkrId INT, @AkhId INT, @AkrTmpId INT
-- Sprawdzenie i aktualizacja OkresOd w pierwszym rekordzie
DECLARE AkordyNag CURSOR LOCAL FAST_FORWARD FOR SELECT AKR_AkrId FROM CDN.Akordy WHERE Akr_PraId = @PraId
OPEN AkordyNag
WHILE 1=1
 BEGIN
   FETCH NEXT FROM AkordyNag INTO @AkrId
   IF @@FETCH_STATUS <> 0 BREAK
   SET @OkresTmp = CONVERT (datetime, '1900-01-01', 120)
   SELECT TOP 1 @AkhId = AKH_AkhId, @OkresOd = AKH_OkresOd FROM CDN.AkordyHist WHERE AKH_AkrId = @AkrId ORDER BY AKH_OkresOd
   IF NOT (@OkresOd = @OkresTmp)
     UPDATE CDN.AkordyHist SET AKH_OkresOd = @OkresTmp WHERE AKH_AkhId = @AkhId
 END
CLOSE AkordyNag
DEALLOCATE AkordyNag
-- Sprawdzenie i aktualizacja OkresDo w całej historii
DECLARE AkordyElem CURSOR LOCAL FAST_FORWARD FOR
  SELECT AKH_AkrId, AKH_AkhId, AKH_OkresOd, AKH_OkresDo FROM CDN.AkordyHist JOIN CDN.Akordy ON AKR_AkrId = AKH_AkrId WHERE AKR_PraId = @PraId ORDER BY AKH_AkrId, AKH_OkresOd DESC
OPEN AkordyElem
SET @AkrTmpId = 0
WHILE 1=1
 BEGIN
   FETCH NEXT FROM AkordyElem INTO @AkrId, @AkhId, @OkresOd, @OkresDo
   IF @@FETCH_STATUS <> 0 BREAK
   IF NOT (@AkrId = @AkrTmpId) SET @OkresTmp = CONVERT (datetime, '2999-12-31', 120)
   IF NOT (@OkresDo = @OkresTmp)
      UPDATE CDN.AkordyHist SET AKH_OkresDo = @OkresTmp WHERE AKH_AkhId = @AkhId
   SET @OkresTmp = DATEADD(day, -1, @OkresOd)
   SET @AkrTmpId = @AkrId
 END
CLOSE AkordyElem
DEALLOCATE AkordyElem
SET NOCOUNT OFF
