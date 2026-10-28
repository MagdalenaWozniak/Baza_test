CREATE PROCEDURE [CDN].[DetalStan_PobierzSchematyOpakowan]
@PosId INT,
@OnlyActive tinyint -- tylko aktywne
AS
BEGIN
SET NOCOUNT ON
IF @OnlyActive = 1
BEGIN
 SELECT * FROM CDN.DetalStanOpakNag
 WHERE DSON_Nieaktywny = 0 AND DSON_StanDetalID = @PosId
END
ELSE
BEGIN
 SELECT * FROM CDN.DetalStanOpakNag
 WHERE DSON_StanDetalID = @PosId
END
SET NOCOUNT OFF
END
