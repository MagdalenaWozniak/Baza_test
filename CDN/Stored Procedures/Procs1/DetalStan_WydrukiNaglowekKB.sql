CREATE PROCEDURE [CDN].[DetalStan_WydrukiNaglowekKB]
@recordId int
AS
BEGIN
SET NOCOUNT ON
SELECT b.DSZKB_NumerPelny,
b.DSZKB_DataDok,
a.DSKnt_Nazwa1,
a.DSKnt_Nazwa2,
a.DSKnt_Nazwa3,
a.DSKnt_Ulica,
a.DSKnt_Miasto,
a.DSKnt_KodPocztowy,
a.DSKnt_NrDomu,
a.DSKnt_NrLokalu,
a.DSKnt_NipE,
a.DSKnt_Kod,
a.DSKnt_EAN,
c.DSOpe_Nazwisko,
b.DSZKB_RazemBrutto,
d.DSFPl_Nazwa,
b.DSZKB_Opis,
a.DSKnt_Pesel
 FROM CDN.DetalStanZapisyKB b
left join CDN.DetalStanKontrahenci a ON b.DSZKB_PodID = a.DSKnt_DSKntId
left join CDN.DetalStanOperatorzy c ON b.DSZKB_OpeID = c.DSOpe_DSOpeID
left join CDN.DetalStanFormyPlatnosci d ON b.DSZKB_DSFPlId = d.DSFPl_DSFPlId
WHERE b.DSZKB_DSZKBID = @recordId
SET NOCOUNT OFF
END
