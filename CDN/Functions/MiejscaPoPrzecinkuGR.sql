CREATE FUNCTION [CDN].[MiejscaPoPrzecinkuGR] (@amount decimal(16,4), @msc_po_przecinku int)
RETURNS nvarchar(24)
AS
BEGIN
DECLARE @amountString nvarchar(128)
DECLARE @msc int
SELECT @amountString =
 CASE @msc_po_przecinku
       WHEN 1 THEN
             CASE
                    WHEN @amount IS NULL THEN '0,0000'
                    ELSE REPLACE(CONVERT(nvarchar, @amount), '.', ',')
                    END
       ELSE
             CASE
                    WHEN @amount IS NULL THEN '0,00'
                    ELSE SUBSTRING(REPLACE(CONVERT(nvarchar, @amount), '.', ','), 1, LEN(REPLACE(CONVERT(nvarchar, @amount), '.', ','))-2)
                    END
       END,
       @msc =
       CASE @msc_po_przecinku
             WHEN 1 THEN  5
             ELSE 3
       END
IF (CHARINDEX(',', @amountString) = 0) SET @amountString = @amountString + ',00'
DECLARE @amountStringFormatted nvarchar(128)
SET @amountStringFormatted = RIGHT(@amountString, @msc)
SET @amountString = SUBSTRING(@amountString, 1, LEN(@amountString) - @msc)
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
