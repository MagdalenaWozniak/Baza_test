CREATE PROCEDURE [CDN].[DetalStan_FormyPlatnosciZestawienie]
@PosId int
AS
BEGIN
SET NOCOUNT ON
 SELECT DSFPl_DSFPlId, DSFPl_Nazwa, DSFPl_Nieaktywny FROM CDN.DetalStanFormyPlatnosci
  WHERE DSFPl_StanDetalID = @PosId
SET NOCOUNT OFF
END
