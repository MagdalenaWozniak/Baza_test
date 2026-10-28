CREATE PROCEDURE cdn.CzyscWpisCdnFirma(@FirNumer INT)
AS
BEGIN
 IF EXISTS (SELECT * FROM CDN.Firma WHERE Fir_Numer = @FirNumer)
  UPDATE CDN.Firma SET Fir_Wartosc = '' WHERE Fir_Numer = @FirNumer
END
