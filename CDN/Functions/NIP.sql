CREATE FUNCTION CDN.NIP
(
@KodKraju NVARCHAR(5),
@NIP  NVARCHAR(20)
)
RETURNS NVARCHAR(25)
AS
BEGIN
 declare @result nvarchar(25) = ltrim(rtrim(@KodKraju)) + ltrim(rtrim(@NIP))
 set @result = REPLACE(@result, '-', '')
 RETURN RTRIM(LTRIM(@result))
END
