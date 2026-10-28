CREATE PROCEDURE [CDN].[DetalStan_AktualizujZmiane]
@IdZmiany int,
@StanKasy decimal(15,2),
@KPOtw decimal(15,2),
@IloscAnulowanychParagonow int
AS
BEGIN
SET NOCOUNT ON
 UPDATE CDN.DetalStanZmiany SET
      DSZ_IloscAnulowanychParagonow = @IloscAnulowanychParagonow
      ,DSZ_StanKasy = @StanKasy
      ,DSZ_KPOtw = @KPOtw
 WHERE DSZ_DSZID = @IdZmiany
SET NOCOUNT OFF
END
