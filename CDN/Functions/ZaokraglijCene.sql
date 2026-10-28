CREATE FUNCTION CDN.ZaokraglijCene(@podstawa decimal(17,4), @precyzja decimal(7,4), @offset decimal(7,4),@zaokraglenie int)
RETURNS DECIMAL(17,4)
AS
BEGIN
 DECLARE @wynik DECIMAL(17,4)
 IF @precyzja Is NULL and @zaokraglenie= 2  SET @precyzja = 0.01
 IF @precyzja Is NULL and @zaokraglenie= 4  SET @precyzja = 0.0001
 IF @offset Is NULL SET @offset = 0.00
 IF @precyzja=1
 BEGIN
  SET @wynik = Round(@podstawa, 0)
  GOTO KONIEC
 END
 IF @precyzja=0.1
 BEGIN
  SET @wynik = Round(10 * @podstawa, 0) / 10
  GOTO KONIEC
 END
 IF @precyzja=0.01 OR @precyzja=0
 BEGIN
  SET @wynik = Round(100 * @podstawa, 0) / 100
  GOTO KONIEC
 END
 IF @precyzja=0.001 OR @precyzja=0
 BEGIN
  SET @wynik = Round(1000 * @podstawa, 0) / 1000
  GOTO KONIEC
 END
  IF @precyzja=0.0001 OR @precyzja=0
 BEGIN
  SET @wynik = Round(10000 * @podstawa, 0) / 10000
  GOTO KONIEC
 END
 SET @wynik = @precyzja * Round(@podstawa/@precyzja, 0)
KONIEC:
 IF @offset <> 0
  SET @wynik = @wynik + @offset
 RETURN @wynik
END
