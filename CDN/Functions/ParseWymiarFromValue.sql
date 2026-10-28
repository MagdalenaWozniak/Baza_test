CREATE FUNCTION CDN.ParseWymiarFromValue(@Value nvarchar(1024))
RETURNS nvarchar(255)
AS
BEGIN
 declare @Result nvarchar(255) = @Value;
 declare @index int =CHARINDEX('/', @value);
 if @index > 0
  set @Result = SUBSTRING ( @Value ,0 , @index );
 return @Result
END
