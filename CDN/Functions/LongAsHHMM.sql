CREATE FUNCTION CDN.LongAsHHMM( @timeAsLong INT )
RETURNS    NVARCHAR(21)
AS
BEGIN
 IF @timeAsLong = 0
  RETURN '0:00'
 DECLARE @hh INT, @mi INT, @wynik NVARCHAR(21)
 SET @wynik = 0
 SET @hh = @timeAsLong / 60
 SET @mi = @timeAsLong % 60
 SET @wynik = LTrim(Str(@hh)) + ':'
 IF @mi = 00
  SET @wynik = @wynik + '00'
 ELSE
 IF @mi < 10
  SET @wynik = @wynik + '0' + LTrim(Str(@mi,2,0))
 ELSE
  SET @wynik = @wynik + LTrim(Str(@mi,2,0))
 RETURN @wynik
END
