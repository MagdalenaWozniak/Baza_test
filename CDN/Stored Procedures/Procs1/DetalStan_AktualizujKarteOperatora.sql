CREATE PROCEDURE [CDN].[DetalStan_AktualizujKarteOperatora]
@opeKod NVARCHAR(20),
@karta NVARCHAR(254)
AS
BEGIN
SET NOCOUNT ON
 UPDATE CDN.DetalStanOperatorzy SET DSOPe_Karta = @karta
 WHERE DSOpe_Kod = @opeKod
SET NOCOUNT OFF
END
