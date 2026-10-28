CREATE PROCEDURE [CDN].[DetalStan_PobierzKwotyPlatnosciZamknietychDokumentowKB]
@PosId int,
@PaymentModeId int
AS
BEGIN
SET NOCOUNT ON
SELECT DSZKB_RazemBrutto, DSZKB_TypDokumentu, DSZKB_DataDok, DSZKB_OpeID FROM CDN.DetalStanZapisyKB
 WHERE DSZKB_StanDetalID = @PosId AND
   DSZKB_DSFPlId = @PaymentModeId AND
   DSZKB_Bufor = 0
SET NOCOUNT OFF
END
