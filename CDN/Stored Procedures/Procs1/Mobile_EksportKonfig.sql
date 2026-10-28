CREATE PROCEDURE[CDN].[Mobile_EksportKonfig]
AS
BEGIN
DECLARE @Slownik TABLE (Klucz NVARCHAR(100), Wartosc NVARCHAR(256))
INSERT INTO @Slownik
SELECT 'SposobLiczeniaMarzy', CONVERT(NVARCHAR(100),RTRIM(Fir_Wartosc))
FROM CDN.Firma WHERE Fir_Numer=1624
INSERT INTO @Slownik
SELECT 'SynchReceivables', 1
INSERT INTO @Slownik
SELECT 'SynchPayables', 1
SELECT * FROM @Slownik
END
