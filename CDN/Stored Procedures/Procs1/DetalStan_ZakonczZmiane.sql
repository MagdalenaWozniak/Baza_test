CREATE PROCEDURE [CDN].[DetalStan_ZakonczZmiane]
@IdZmiany int,
@OpeIdZamk int,
@KWZamk decimal(15,2),
@DataZamk datetime
AS
BEGIN
SET NOCOUNT ON
 UPDATE CDN.DetalStanZmiany SET
      DSZ_DataZamk = @DataZamk
      ,DSZ_Bufor = 0
      ,DSZ_OpeIdZamk = @OpeIdZamk
      ,DSZ_KWZamk = @KWZamk
 WHERE DSZ_DSZID = @IdZmiany
SET NOCOUNT OFF
END
