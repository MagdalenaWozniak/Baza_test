CREATE PROCEDURE [CDN].DetalStan_AktualizujMaxRabatOperatora
@userId INT,
@maxRabat decimal(15,4)
AS
BEGIN
SET NOCOUNT ON
 UPDATE CDN.DetalStanOperatorzy SET DSOPe_MaxRabat = @maxRabat
 WHERE DSOpe_DSOpeID = @userId
SET NOCOUNT OFF
END
