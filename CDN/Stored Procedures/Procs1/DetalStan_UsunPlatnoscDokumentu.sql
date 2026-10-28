CREATE PROCEDURE [CDN].[DetalStan_UsunPlatnoscDokumentu]
@DocumentId int,
@PaymentModeId int
AS
BEGIN
SET NOCOUNT ON
DELETE FROM CDN.DetalStanPlatnosciDokumentu
 WHERE DSPlD_DSTrNId = @DocumentId AND
   DSPlD_DSFPlId = @PaymentModeId
SET NOCOUNT OFF
END
