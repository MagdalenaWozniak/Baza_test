CREATE FUNCTION CDN.KorektaPodatku_UstalCzyRozliczonoWDanymRoku(@BZd_BZdID INTEGER, @Rok INTEGER)
RETURNS INTEGER
AS
BEGIN
 DECLARE @IloscRozliczonychWDanymRoku INTEGER
 SELECT @IloscRozliczonychWDanymRoku = COUNT(*) FROM CDN.BnkRozKwoty
 WHERE (BRK_LDokTyp = 1 AND BRK_LDokID = @BZd_BZdID) OR (BRK_PDokTyp = 1 AND BRK_PDokID = @BZd_BZdID) AND YEAR(BRK_DataDok) = @Rok
 RETURN @IloscRozliczonychWDanymRoku
END
