CREATE PROCEDURE [CDN].[DetalStan_WydrukiPlatnosci]
@receiptId int
AS
BEGIN
SET NOCOUNT ON
select b.DSFPl_Nazwa,
a.DSPlD_Kwota,
a.DSPlD_DataPlatnosci,
a.DSPlD_Termin,
b.DSFPl_Gotowka,
b.DSFPl_BnkNazwa,
b.DSFPl_RachunekNr FROM CDN.DetalStanPlatnosciDokumentu a
left join CDN.DetalStanFormyPlatnosci b on a.DSPlD_DSFPlId = b.DSFPl_DSFPlId
WHERE a.DSPlD_DSTrNId = @receiptId
SET NOCOUNT OFF
END
