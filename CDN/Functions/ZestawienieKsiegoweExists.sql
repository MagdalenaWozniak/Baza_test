CREATE FUNCTION CDN.ZestawienieKsiegoweExists(@symbol nvarchar(255))
RETURNS int
AS
BEGIN
 declare @Result int = 0;
 select @Result = COUNT(*) from CDN.ZestKsiNag where ZKN_Symbol = @symbol;
 return @Result
END
