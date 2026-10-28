CREATE FUNCTION CDN.Decimal2Varchar( @wartoscDecimal DECIMAl(18,4), @decimalSeparator VARCHAR )
RETURNS    NVARCHAR(22)
AS
BEGIN
 DECLARE @wynik NVARCHAR(22)
 SET @wynik = Convert(NVARCHAR(22), @wartoscDecimal)
 IF @decimalSeparator = ','
    SET @wynik = REPLACE(@wynik, N'.', N',')
 RETURN @wynik
END
