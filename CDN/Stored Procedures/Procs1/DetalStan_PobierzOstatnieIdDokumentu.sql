CREATE PROCEDURE [CDN].[DetalStan_PobierzOstatnieIdDokumentu]
@Type int,
@PosId int
AS
BEGIN
SET NOCOUNT ON
SELECT ISNULL(MAX(DSTrN_DSTrNID),0) FROM CDN.DetalStanTraNag WHERE DSTrN_TypDokumentu = @Type AND DSTrN_StanDetalID = @PosId
SET NOCOUNT OFF
END
