CREATE FUNCTION CDN.FormatDecimalAmount(@amount decimal(15,2))
RETURNS nvarchar(24)
AS
BEGIN
 DECLARE @amountString nvarchar(128)
 SELECT @amountString = CASE WHEN @amount IS NULL THEN '0,00' ELSE REPLACE(CONVERT(nvarchar, @amount), '.', ',') END
 IF (CHARINDEX(',', @amountString) = 0) SET @amountString = @amountString + ',00'
 DECLARE @amountStringFormatted nvarchar(128)
 SET @amountStringFormatted = RIGHT(@amountString, 3)
 SET @amountString = SUBSTRING(@amountString, 1, LEN(@amountString) - 3)
 WHILE LEN(@amountString) > 0
 BEGIN
  IF LEN(@amountString) <= 3
   BEGIN
    SET @amountStringFormatted = @amountString + @amountStringFormatted
    BREAK
   END
  ELSE
   BEGIN
    SET @amountStringFormatted = ' ' + RIGHT(@amountString, 3) + @amountStringFormatted
    SET @amountString = SUBSTRING(@amountString, 1, LEN(@amountString) - 3)
   END
 END
 RETURN @amountStringFormatted
END
