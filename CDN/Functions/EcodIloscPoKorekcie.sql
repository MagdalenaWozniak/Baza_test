CREATE FUNCTION CDN.EcodIloscPoKorekcie(@TrEId AS INT, @Korekta AS INT,
@TrEIloscJM AS DECIMAL(15,4),
@TrEIloscJMKW AS DECIMAL(15,4))
RETURNS DECIMAL(15,4)
AS
BEGIN
 DECLARE @Wynik DECIMAL(15,4)
 SET @Wynik = 0.0000
 IF @Korekta = 1 -- korekta ilości
  SET @Wynik = CDN.EcodIloscPrzedKorekta(@TrEId, 1) + @TrEIloscJm
 ELSE
 BEGIN
  IF @Korekta = 2 OR @Korekta = 3
      SET @Wynik = @TrEIloscJMKW
  ELSE
   SET @Wynik = @TrEIloscJM
 END
 RETURN @Wynik
END
