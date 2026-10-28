CREATE PROCEDURE [CDN].[DetalStan_UaktualnijOperatora]
@Pass NVARCHAR(30),
@CodeDF NVARCHAR(10),
@OpeId int,
@PosId int
AS
BEGIN
SET NOCOUNT ON
UPDATE CDN.DetalStanOperatorzy SET DSOpe_Haslo = @Pass, DSOpe_KodDlaDF = @CodeDF
 WHERE DSOpe_DSOpeID = @OpeId AND DSOpe_StanDetalID = @PosId
SET NOCOUNT OFF
END
