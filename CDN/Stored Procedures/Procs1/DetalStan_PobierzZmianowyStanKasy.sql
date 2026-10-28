CREATE PROCEDURE [CDN].[DetalStan_PobierzZmianowyStanKasy]
@PosId int
AS
BEGIN
SET NOCOUNT ON
SELECT  ISNULL(DSZ_StanKasy,convert(decimal(15,2),0)) +
  ISNULL(DSZ_KwotaZPrzeniesienia,convert(decimal(15,2),0)) +
  ISNULL(DSZ_KPOtw,convert(decimal(15,2),0)) -
  ISNULL(DSZ_KWZamk,convert(decimal(15,2),0)) FROM CDN.DetalStanZmiany
 WHERE DSZ_StanDetalID = @PosId AND DSZ_Bufor = 0 AND
 DSZ_DSZID =
 (SELECT ISNULL(MAX(DSZ_DSZID),1) FROM CDN.DetalStanZmiany
  WHERE DSZ_StanDetalID = @PosId AND DSZ_Bufor = 0)
SET NOCOUNT OFF
END
