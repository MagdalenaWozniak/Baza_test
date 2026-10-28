CREATE PROCEDURE [CDN].[DetalStan_UsunPlatnosciDokumentu]
@DocumentId int
AS
BEGIN
SET NOCOUNT ON
DELETE FROM CDN.DetalStanPlatnosciDokumentu WHERE DSPlD_DSTrNId = @DocumentId
SET NOCOUNT OFF
END
