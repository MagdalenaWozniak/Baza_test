CREATE PROCEDURE [CDN].[DetalStan_SprawdzCzyParagonMaKorektyWDetalu]
@receiptId int
AS
BEGIN
SET NOCOUNT ON
 SELECT count(DSTrN_DSTrNID)
 FROM CDN.DetalStanTraNag
 WHERE DSTrN_ZwrId = @receiptId
SET NOCOUNT OFF
END
