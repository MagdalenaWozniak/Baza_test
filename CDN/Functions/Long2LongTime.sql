CREATE FUNCTION CDN.Long2LongTime( @timeAsLong INT )
RETURNS    INT
AS
BEGIN
 DECLARE @hh INT, @mi INT, @wynik INT
 SET @wynik = 0
 SET @hh = @timeAsLong / 60
 SET @mi = @timeAsLong % 60
 SET @wynik = 100 * @hh + @mi
 RETURN @wynik
END
