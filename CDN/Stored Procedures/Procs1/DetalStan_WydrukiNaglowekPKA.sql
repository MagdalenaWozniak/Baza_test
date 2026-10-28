CREATE PROCEDURE [CDN].[DetalStan_WydrukiNaglowekPKA]
@receiptId int
AS
BEGIN
SET NOCOUNT ON
SELECT max(b.DSTrN_NumerPelny),
max(b.DSTrN_DataDok),
max(b.DSTrN_TS_Zal),
max(a.DSKnt_Nazwa1),
max(a.DSKnt_Nazwa2),
max(a.DSKnt_Nazwa3),
max(a.DSKnt_Ulica),
max(a.DSKnt_Miasto),
max(a.DSKnt_KodPocztowy),
max(a.DSKnt_NrDomu),
max(a.DSKnt_NrLokalu),
max(a.DSKnt_NipE),
max(a.DSKnt_Kod),
max(a.DSKnt_EAN),
max(c.DSOpe_Nazwisko),
max(b.DSTrN_OsobaOdbierajaca),
sum(d.DSPlD_KwotaZaplacona),
max(b.DSTrN_Rabat),
max(b.DSTrN_Opis),
max(a.DSKnt_Pesel)
 FROM CDN.DetalStanTraNag b
left join CDN.DetalStanKontrahenci a ON b.DSTrN_PodID = a.DSKnt_DSKntId
left join CDN.DetalStanOperatorzy c ON b.DSTrN_OpeID = c.DSOpe_DSOpeID
left join CDN.DetalStanPlatnosciDokumentu d ON d.DSPlD_DSTrNId = b.DSTrN_DSTrNID
WHERE b.DSTrN_DSTrNID = @receiptId
SET NOCOUNT OFF
END
