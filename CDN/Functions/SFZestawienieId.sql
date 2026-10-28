CREATE FUNCTION CDN.SFZestawienieId(@Symbol nvarchar(255))
RETURNS int
AS
BEGIN
 declare @Result int = null;
 select @Result = id from CDN.SFZestawienia() where kod = @Symbol;
 return @Result;
END
