CREATE PROCEDURE [CDN].[DetalStan_PobierzTowary]
@PosId INT,
@OnlyActive tinyint
AS
BEGIN
SET NOCOUNT ON
IF @OnlyActive = 1
BEGIN
 SELECT a.*, DSKnt_Kod, CONVERT(DECIMAL(15,2), 1) AS JMPrzelicznikL, CONVERT(DECIMAL(7,0), 1) AS JMPrzelicznikM FROM CDN.DetalStanTowary a
 left join CDN.DetalStanKontrahenci ON DSTwr_KntId = DSKnt_OptimaId
 WHERE DSTwr_NieAktywny = 0 AND DSTwr_StanDetalID = @PosId
END
ELSE
BEGIN
 SELECT a.*, DSKnt_Kod, CONVERT(DECIMAL(15,2), 1) AS JMPrzelicznikL, CONVERT(DECIMAL(7,0), 1) AS JMPrzelicznikM FROM CDN.DetalStanTowary a
 left join CDN.DetalStanKontrahenci ON DSTwr_KntId = DSKnt_OptimaId
 WHERE DSTwr_StanDetalID = @PosId
END
SET NOCOUNT OFF
END
