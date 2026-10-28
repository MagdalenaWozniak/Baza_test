CREATE FUNCTION CDN.PrzeliczIloscWgPrzelicznikow(@ilosc DECIMAL(20,4), @orgJm VARCHAR(20), @jm VARCHAR(20) ,@przelicznikL DECIMAL(15,2), @przelicznikM DECIMAL(15,2))
RETURNS DECIMAL(20,4)
AS
BEGIN
 IF lower(@jm) = lower(@orgJm) RETURN @ilosc
 IF @przelicznikL = @przelicznikM RETURN @ilosc
 DECLARE @wynik DECIMAL(20,4)
 SET @wynik = Convert( DECIMAL(20,4),
   CASE @przelicznikM WHEN 0 THEN
    @ilosc
   ELSE
    (@ilosc * @przelicznikL/@przelicznikM)
   END)
 RETURN @wynik
END
