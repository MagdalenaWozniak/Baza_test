CREATE FUNCTION CDN.PieczatkaNazwaDlaLogowania(@id INT, @dataOd DATETIME, @dataDo DATETIME)
RETURNS VARCHAR(64)
AS
BEGIN
 DECLARE @retVal VARCHAR(64)
 SELECT @retVal = '[ID:' + RTRIM(CONVERT(VARCHAR(64), @id)) + '] Ważna '
 IF YEAR(@DataOd) = 1900 AND YEAR(@DataDo) = 2999
  SELECT @retVal = @retVal + 'bezterminowo'
 ELSE IF YEAR(@DataOd) <> 1900 AND YEAR(@DataDo) = 2999
  SELECT @retVal = @retVal + ('od ' + SUBSTRING(CONVERT(VARCHAR(10), @dataOd, 120), 1, 10))
 ELSE IF YEAR(@DataOd) = 1900 AND YEAR(@DataDo) <> 2999
  SELECT @retVal = @retVal + ('do ' + SUBSTRING(CONVERT(VARCHAR(10), @dataDo, 120), 1, 10))
 ELSE IF YEAR(@DataOd) <> 1900 AND YEAR(@DataDo) <> 2999
  SELECT @retVal = @retVal + ('od ' + SUBSTRING(CONVERT(VARCHAR(10), @dataOd, 120), 1, 10) + ' do ' + SUBSTRING(CONVERT(VARCHAR(10), @dataDo, 120), 1, 10))
 RETURN @retVal
END
