CREATE FUNCTION cdn.DateAndTimeToDisplay(@dateTime DATETIME, @tylkoKreski INT)
RETURNS VARCHAR(22)
AS
BEGIN
 DECLARE @kreski VARCHAR(22)
 SET @kreski = REPLICATE(' ', 5) + REPLICATE('-', 5)
 IF( @dateTime is NULL OR @dateTime = 0 OR @tylkoKreski = 1) RETURN @kreski
 RETURN Convert(VARCHAR(10), @dateTime, 120) + SPACE(3) + '|' + SPACE(3) + SUBSTRING(Convert(VARCHAR(16),@dateTime, 120),12,5)
END
