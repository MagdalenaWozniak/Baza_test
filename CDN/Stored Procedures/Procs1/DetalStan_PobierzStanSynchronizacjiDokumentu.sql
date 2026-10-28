CREATE PROCEDURE [CDN].[DetalStan_PobierzStanSynchronizacjiDokumentu]
@Id int
AS
BEGIN
SET NOCOUNT ON
SELECT DSTrN_StanSynchronizacji FROM CDN.DetalStanTraNag WHERE DSTrN_DSTrNID = @Id
SET NOCOUNT OFF
END
