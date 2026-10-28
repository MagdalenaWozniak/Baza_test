CREATE PROCEDURE [CDN].[DetalStan_PobierzSymbolStawkiVat]
@PosId int,
@Stawka decimal(5, 2),
@Flaga smallint
AS
BEGIN
SET NOCOUNT ON
SELECT DSSVAT_DFSymbol FROM CDN.DetalStanStawkiVAT
WHERE DSSVAT_Stawka = @Stawka AND DSSVAT_Flaga = @Flaga AND DSSVAT_StanDetalID = @PosId
SET NOCOUNT OFF
END
