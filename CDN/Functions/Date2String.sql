CREATE FUNCTION CDN.Date2String(@Date DateTime, @Format INT = 120, @AddApostrophes SMALLINT = 1)
RETURNS NVARCHAR(255)
AS
BEGIN
 declare @result nvarchar(255)
 set @result = 'Convert(DateTime, ''' + Convert(nvarchar, @Date, @Format) + ''', ' + Convert(nvarchar, @Format) + ')'
 if @AddApostrophes = 1 Set @result = ''''+@result+''''
 return @result
END
