create PROCEDURE [CDN].[ProcentPodatkuMiesiac] @PrcId INT, @Dochod DECIMAL(15,4), @Rok INT, @miesiac INT
AS
SET NOCOUNT ON
BEGIN
SELECT CDN.fnProcentPodatkuMiesiac(@PrcId, @Dochod, @Rok, @miesiac) AS Procent
END
