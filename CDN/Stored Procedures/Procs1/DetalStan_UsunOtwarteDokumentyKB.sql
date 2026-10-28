CREATE PROCEDURE [CDN].[DetalStan_UsunOtwarteDokumentyKB]
@PosId int,
@OpeId int
AS
BEGIN
SET NOCOUNT ON
DELETE FROM CDN.DetalStanZapisyKB
 WHERE DSZKB_Bufor = 1 AND
   DSZKB_StanDetalID = @PosId AND
   DSZKB_OpeID = @OpeId
SET NOCOUNT OFF
END
