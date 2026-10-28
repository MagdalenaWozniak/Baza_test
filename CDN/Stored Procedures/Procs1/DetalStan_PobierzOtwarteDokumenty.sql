CREATE PROCEDURE [CDN].[DetalStan_PobierzOtwarteDokumenty]
@PosId int,
@OpeId int
AS
BEGIN
SET NOCOUNT ON
IF @OpeId > 0
BEGIN
 SELECT DSTrN_DSTrNID FROM CDN.DetalStanTraNag
  WHERE DSTrN_Bufor = 1 AND
    DSTrN_OpeID = @OpeId AND
    DSTrN_StanDetalID = @PosId
END
ELSE
BEGIN
 SELECT DSTrN_DSTrNID FROM CDN.DetalStanTraNag
  WHERE DSTrN_Bufor = 1 AND
    DSTrN_StanDetalID = @PosId
END
SET NOCOUNT OFF
END
