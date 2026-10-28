CREATE PROCEDURE [CDN].[DetalStan_PobierzOperatoraZKarta]
@karta NVARCHAR(254)
AS
BEGIN
SET NOCOUNT ON
 SELECT DSOpe_OptimaId FROM CDN.DetalStanOperatorzy
 WHERE DSOpe_Karta = @karta AND DSOpe_OpeNieAktywny = 0
SET NOCOUNT OFF
END
