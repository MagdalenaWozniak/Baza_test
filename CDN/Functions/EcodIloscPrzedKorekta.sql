CREATE FUNCTION CDN.EcodIloscPrzedKorekta(@TrEId AS INT, @Korekta AS INT)
RETURNS DECIMAL(15,4)
AS
BEGIN
 DECLARE @Wynik DECIMAL(15,4)
 SET @Wynik = 0
 IF @Korekta = 2 OR @Korekta = 3
  SELECT TOP 1 @Wynik = IsNull(TrE_IloscJMKW, 0) FROM CDN.TraElem WHERE TrE_TrEId = @TrEId
 ELSE
  SELECT TOP 1 @Wynik = IsNull(IloscJmOrg, 0.00) FROM CDN.TraElemKorektaForEcod(@TrEId)
 RETURN @Wynik
END
