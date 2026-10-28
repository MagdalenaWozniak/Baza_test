CREATE FUNCTION CDN.SFTypJednostkiId(@Symbol nvarchar(255))
RETURNS int
AS
BEGIN
 declare @Result int = null;
 select @Result = id from CDN.SFJednostki() where kod = @Symbol;
 return @Result;
END
