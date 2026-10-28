CREATE PROCEDURE cdn.AktualizujWpisCdnFirma(@FirNumer INT, @FirOpis NVARCHAR(256), @FirWartosc NVARCHAR(256))
AS
BEGIN
 IF EXISTS (SELECT * FROM CDN.Firma WHERE Fir_Numer = @FirNumer)
  UPDATE CDN.Firma SET Fir_Wartosc = @FirWartosc WHERE Fir_Numer = @FirNumer
 ELSE
  INSERT INTO CDN.Firma (Fir_Numer, Fir_Opis, Fir_Wartosc) VALUES (@FirNumer, @FirOpis, @FirWartosc)
END
