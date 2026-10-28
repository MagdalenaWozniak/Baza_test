create PROCEDURE [CDN].[ProcentPodatku] @PrcId INT, @Dochod DECIMAL(15,4), @Rok INT
AS
SET NOCOUNT ON
BEGIN
SELECT CONVERT(INT, CDN.fnProcentPodatkuMiesiac(@PrcId, @Dochod, @Rok, NULL)) AS Procent
END
