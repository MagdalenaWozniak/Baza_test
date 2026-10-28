CREATE FUNCTION CDN.NazwaFirmy
(
@Nazwa1 NVARCHAR(256),
@Nazwa2  NVARCHAR(256),
@Nazwa3 NVARCHAR(256)
)
RETURNS NVARCHAR(256)
AS
BEGIN
 declare @result nvarchar(256) = ltrim(rtrim(@Nazwa1)) + ' ' + ltrim(rtrim(@Nazwa2)) + ' ' + ltrim(rtrim(@Nazwa3))
 set @result = replace(@result, char(31), '');
 RETURN RTRIM(LTRIM(@result))
END
