CREATE PROCEDURE [CDN].[DetalStan_PobierzZamknieteZmiany]
@PosId int
AS
BEGIN
SET NOCOUNT ON
 SELECT DSZ_DSZID
      ,DSZ_StanDetalID
      ,DSZ_NumerNr
      ,DSZ_NumerPelny
      ,DSZ_OpeIdOtw
      ,DSZ_OpeIdZamk
      ,DSZ_Bufor
      ,DSZ_DataOtw
      ,DSZ_DataZamk
      ,DSZ_IloscAnulowanychParagonow
      ,DSZ_StanKasy
      ,DSZ_KPOtw
      ,DSZ_KWZamk
      ,DSZ_KwotaZPrzeniesienia FROM CDN.DetalStanZmiany WHERE DSZ_StanDetalID = @PosId AND DSZ_Bufor = 0
SET NOCOUNT OFF
END
