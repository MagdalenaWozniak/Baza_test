CREATE PROCEDURE CDN.UpustyKontrahenta
@KntID            AS INT
AS
BEGIN
SELECT knu_kntlp AS UpustLp, twr_kod AS Kod, twr_nazwa AS Nazwa,
CASE WHEN knu_symbol <> '' THEN convert(NVARCHAR(20), knu_upust) + ' [' + knu_symbol + '] (' +
knu_flagaNB + ')' ELSE convert(NVARCHAR(20), knu_upust) + ' %' END AS Upust FROM CDN.KntUpusty
JOIN CDN.Kontrahenci ON knu_kntNumer = knt_gidnumer AND knu_knttyp = knt_gidtyp AND
knu_kntfirma = knt_gidfirma JOIN cdn.towary ON knu_twgnumer = twr_gidNumer AND
knu_twgtyp = twr_gidtyp AND knu_twgfirma = twr_gidfirma WHERE knt_kntid = @KntId
UNION SELECT knu_kntlp AS UpustLp, twg_kod AS Kod, twr_nazwa AS Nazwa,
CASE WHEN knu_symbol <> '' THEN convert(NVARCHAR(20), knu_upust) + ' [' + knu_symbol + '] (' +
knu_flagaNB + ')' ELSE convert(NVARCHAR(20), knu_upust) + ' %' END AS Upust FROM CDN.twrgrupy
JOIN cdn.kntupusty ON twg_gronumer = knu_twgnumer join cdn.towary ON
twg_gidnumer = twr_gidNumer AND twg_gidfirma = twr_gidfirma JOIN cdn.kontrahenci ON
knu_kntNumer = knt_gidnumer AND knu_knttyp = knt_gidtyp AND knu_kntfirma = knt_gidfirma
WHERE twg_groTyp = -16 AND knt_kntid = @KntID
END
