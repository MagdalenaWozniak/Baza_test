CREATE PROCEDURE [CDN].[DetalStan_UaktualnijFormePlatnosci]
@Id int,
@DFNr int,
@PosId int
AS
BEGIN
SET NOCOUNT ON
UPDATE CDN.DetalStanFormyPlatnosci SET DSFPl_DFNr = @DFNr
 WHERE DSFPl_DSFPlId = @Id AND DSFPl_StanDetalID = @PosId
SET NOCOUNT OFF
END
