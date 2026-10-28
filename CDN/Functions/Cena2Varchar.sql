CREATE FUNCTION CDN.Cena2Varchar( @wartoscDecimal DECIMAl(20,4), @cenaZCzteremaMiejscami INT, @decimalSeparator VARCHAR )
RETURNS    NVARCHAR(22)
AS
BEGIN
    DECLARE @wynik NVARCHAR(22), @decimal2 DECIMAl(20,2), @decimal4 DECIMAl(20,4)
 IF @cenaZCzteremaMiejscami = 1
 BEGIN
  SET @decimal4 = ROUND(@wartoscDecimal, 4)
  SET @wynik = Convert(NVARCHAR(22), @decimal4)
 END
 ELSE
 BEGIN
  SET @decimal2 = ROUND(@wartoscDecimal, 2)
  SET @wynik = Convert(NVARCHAR(22), @decimal2)
 END
    IF @decimalSeparator = ','
       SET @wynik = REPLACE(@wynik, N'.', N',')
    RETURN @wynik
END
