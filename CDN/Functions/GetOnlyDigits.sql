CREATE FUNCTION CDN.GetOnlyDigits( @source NVARCHAR(MAX) )
RETURNS NVARCHAR(MAX)
AS
BEGIN
 RETURN  cdn.StripCharacters(@source, '^0-9')
END
