CREATE FUNCTION CDN.Varchar2Decimal_18_4(@textVal NVARCHAR(1024), @defaultValue DECIMAL(18,4))
RETURNS    DECIMAL(18,4)
AS
BEGIN
    DECLARE @maxLen INT
 SET @maxLen = 1024
 DECLARE @wartoscDecimal DECIMAl(18,4), @decimalSeparator VARCHAR, @commaSeparator VARCHAR, @onlyNumbers NVARCHAR(1024)
 SET @decimalSeparator = '.'
 SET @commaSeparator = ','
 IF CHARINDEX(@decimalSeparator, @textVal) < 1   -- jeżeli nie ma kropki
  SET @textVal = REPLACE(@textVal, N',', N'.')
 SELECT @onlyNumbers = LTRIM(RTRIM(LEFT(SUBSTRING(@textval, PATINDEX('%[0-9.-]%', @textval), @maxLen),
           PATINDEX('%[^0-9.-]%', SUBSTRING(@textval, PATINDEX('%[0-9.-]%', @textval), @maxLen) + 'X') -1)))
 IF @onlyNumbers IS NULL OR @onlyNumbers = '' OR @onlyNumbers = '.' OR ISNUMERIC(LTRIM(RTRIM(@onlyNumbers))) = 0
  SET @wartoscDecimal = @defaultValue
 ELSE
  SET @wartoscDecimal = CONVERT(DECIMAL(18,4), @onlyNumbers)
    RETURN @wartoscDecimal
END
