
--* gSkrypt.sOpis = $Tworzenie funkcji CDN.PlikJpkSkorygowany$
-->
CREATE FUNCTION CDN.PlikJpkSkorygowany(@JpkId int)
RETURNS int
AS
BEGIN

	declare @result int = 0;	
	if exists(select * FROM CDN.PlikiJPK where Jpk_SourceJpkId=@JpkId)
		set @result = 1;

	return @result;
END
