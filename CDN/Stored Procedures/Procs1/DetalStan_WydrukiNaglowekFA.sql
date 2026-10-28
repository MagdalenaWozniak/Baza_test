CREATE PROCEDURE [CDN].[DetalStan_WydrukiNaglowekFA]
@receiptId int
AS
BEGIN
SET NOCOUNT ON
SELECT max(d.DSTrN_NumerPelny),
max(d.DSTrN_DataDok),
max(d.DSTrN_TS_Zal),
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
max(b.DSTrN_NumerPelny),
max(b.DSTrN_DataDok),
max(d.DSTrN_OsobaOdbierajaca),
max(d.DSTrN_RazemBrutto),
sum(e.DSPlD_KwotaZaplacona),
max(d.DSTrN_Rabat),
max(d.DSTrN_Opis),
max(a.DSKnt_Pesel),
max(a.DSKnt_Poczta) FROM CDN.DetalStanTraNag d left join CDN.DetalStanTraNag b
ON d.DSTrN_DSTrNID = b.DSTrN_FAId left join CDN.DetalStanKontrahenci a
ON d.DSTrN_PodID = a.DSKnt_DSKntId left join CDN.DetalStanOperatorzy c
ON d.DSTrN_OpeID = c.DSOpe_DSOpeID left join CDN.DetalStanPlatnosciDokumentu e
ON e.DSPlD_DSTrNId = b.DSTrN_DSTrNID WHERE b.DSTrN_DSTrNID = @receiptId
SET NOCOUNT OFF
END
