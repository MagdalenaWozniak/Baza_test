CREATE PROCEDURE [CDN].[DetalStan_UsunOtwarteDokumenty]
@PosId int,
@OpeId int
AS
BEGIN
SET NOCOUNT ON
IF @OpeId > 0
BEGIN
 UPDATE CDN.DetalStanTraNag SET DSTrN_FaId = 0 WHERE DSTrN_FaId IN
 (SELECT DSTrN_DSTrNID FROM cdn.DetalStanTraNag
  WHERE DSTrN_Bufor = 1 AND
   DSTrN_OpeID = @OpeId AND
   DSTrN_StanDetalID = @PosId)
 DELETE FROM CDN.DetalStanTraNag
  WHERE DSTrN_Bufor = 1 AND
    DSTrN_OpeID = @OpeId AND
    DSTrN_StanDetalID = @PosId
END
ELSE
BEGIN
 UPDATE CDN.DetalStanTraNag SET DSTrN_FaId = 0 WHERE DSTrN_FaId IN
 (SELECT DSTrN_DSTrNID FROM cdn.DetalStanTraNag
  WHERE DSTrN_Bufor = 1 AND
   DSTrN_StanDetalID = @PosId)
 DELETE FROM CDN.DetalStanTraNag
  WHERE DSTrN_Bufor = 1 AND
    DSTrN_StanDetalID = @PosId
END
SET NOCOUNT OFF
END
