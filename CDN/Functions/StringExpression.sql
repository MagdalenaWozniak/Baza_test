CREATE FUNCTION CDN.StringExpression (@expression nvarchar(max), @operator nvarchar(max), @toAddExpression nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN
 DECLARE @result nvarchar(max);
 if len(IsNull(@expression, '')) = 0
  set @result = @toAddExpression
 else
  set @result = @expression + @operator + @toAddExpression
 RETURN @result
END
