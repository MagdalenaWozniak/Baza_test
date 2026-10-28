CREATE PROCEDURE [CDN].[DetalStan_AktualizujCzasLogowaniaOperatora]
@opeId int,
@date datetime
AS
BEGIN
SET NOCOUNT ON
 UPDATE CDN.DetalStanOperatorzy SET DSOPe_DataLogowania = @date
 WHERE DSOpe_DSOpeID = @opeId
SET NOCOUNT OFF
END
