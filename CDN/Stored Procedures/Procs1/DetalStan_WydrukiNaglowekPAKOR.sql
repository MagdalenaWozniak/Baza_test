CREATE PROCEDURE CDN.DetalStan_WydrukiNaglowekPAKOR
@receiptId int
AS
BEGIN
SET NOCOUNT ON
SELECT max(b.DSTrN_NumerPelny),
max(b.DSTrN_DataDok),
max(b.DSTrN_RazemBrutto),
max(c.DSOpe_Nazwisko),
sum(d.DSPlD_KwotaZaplacona),
MAX(b.DSTrN_Rabat),
max(b.DsTrN_Opis),
max(b.DSTrN_OsobaOdbierajaca)
FROM CDN.DetalStanTraNag b
left join CDN.DetalStanKontrahenci a ON b.DSTrN_PodID = a.DSKnt_DSKntId
left join CDN.DetalStanOperatorzy c ON b.DSTrN_OpeID = c.DSOpe_DSOpeID
left join CDN.DetalStanPlatnosciDokumentu d ON d.DSPlD_DSTrNId = b.DSTrN_DSTrNID
WHERE b.DSTrN_DSTrNID = @receiptId
SET NOCOUNT OFF
END
