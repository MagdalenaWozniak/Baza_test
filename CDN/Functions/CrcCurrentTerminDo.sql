CREATE FUNCTION cdn.CrcCurrentTerminDo(@CrKId INT, @treshold DATETIME, @terminDo DATETIME)
RETURNS DATETIME
AS
BEGIN
 DECLARE @date DATETIME
 SELECT TOP 1 @date = CRC_TerminDo FROM cdn.CrmKontaktyCykl WHERE CrC_CrKId = @CrKId AND CRC_TerminOd >= @treshold AND CRC_Aktywny = 1 AND CRC_Bufor = 1 ORDER BY CRC_CRCId
 IF @date IS NULL SET @date = @terminDo
 RETURN @date
END
