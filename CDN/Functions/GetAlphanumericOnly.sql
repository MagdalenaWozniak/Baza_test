CREATE FUNCTION CDN.GetAlphanumericOnly( @source NVARCHAR(MAX) )
RETURNS NVARCHAR(MAX)
AS
BEGIN
 RETURN cdn.StripCharacters(@source, '^a-z0-9')
END
