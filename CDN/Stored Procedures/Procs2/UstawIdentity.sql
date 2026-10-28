CREATE PROCEDURE CDN.UstawIdentity
 @NewIdentity int
AS
BEGIN
 SET NOCOUNT ON
 If @NewIdentity Is Not Null
  Begin
   Create Table #IdentityTmp ( id_field INT Identity )
   Set Identity_Insert #IdentityTmp On
   Insert InTo #IdentityTmp (id_field) Values (@NewIdentity)
   Set Identity_Insert #IdentityTmp Off
   Drop Table #IdentityTmp
  End
 SET NOCOUNT OFF
END
