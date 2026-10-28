CREATE FUNCTION cdn.FromClarionDate(@clarionDateTime INT)
RETURNS DATETIME
AS
BEGIN
DECLARE @Data0 DATETIME
IF( @clarionDateTime is NULL OR @clarionDateTime = 0 )
 SET @Data0 = CONVERT ( DATETIME, '1899-12-30 00:00:00' , 120 )
ELSE
 SET @Data0 = CONVERT ( DATETIME, @clarionDateTime - 36163, 120 )
RETURN @Data0
END
