CREATE FUNCTION CDN.StringValueCondition (@valueIfTrue nvarchar(max), @valueIfFalse nvarchar(max), @confitions int)
RETURNS nvarchar(max)
AS
BEGIN
 DECLARE @result nvarchar(max);
 if @confitions <> 0
  set @result = @valueIfTrue;
 else
  set @result = @valueIfFalse;
 RETURN @result
END
