CREATE PROCEDURE CDN.AktualizujPracEtaty @PraId INT
AS
SET NOCOUNT ON
DECLARE @DataTmp DATETIME, @DataOd DATETIME, @DataDo DATETIME, @PreId INT
-- Sprawdzenie i aktualizacja DataOd w pierwszym rekordzie
SET @DataTmp = CONVERT (datetime, '1900-01-01', 120)
SELECT TOP 1 @PreId = PRE_PreId, @DataOd = PRE_DataOd FROM CDN.PracEtaty WHERE PRE_PraId = @PraId ORDER BY PRE_PraId, PRE_DataOd
IF NOT (@DataOd = @DataTmp)
  UPDATE CDN.PracEtaty SET PRE_DataOd = @DataTmp WHERE PRE_PreId = @PreId
-- Sprawdzenie i aktualizacja DataDo w całej historii
DECLARE Historia CURSOR LOCAL FAST_FORWARD FOR
  SELECT PRE_PreId, PRE_DataOd, PRE_DataDo FROM CDN.PracEtaty WHERE PRE_PraId = @PraId ORDER BY PRE_PraId, PRE_DataOd DESC
OPEN Historia
SET @DataTmp = CONVERT (datetime, '2999-12-31', 120)
WHILE 1=1
 BEGIN
   FETCH NEXT FROM Historia INTO @PreId, @DataOd, @DataDo
   IF @@FETCH_STATUS <> 0 BREAK
   IF NOT (@DataDo = @DataTmp)
      UPDATE CDN.PracEtaty SET PRE_DataDo = @DataTmp WHERE PRE_PreId = @PreId
   SET @DataTmp = DATEADD(day, -1, @DataOd)
 END
CLOSE Historia
DEALLOCATE Historia
SET NOCOUNT OFF
