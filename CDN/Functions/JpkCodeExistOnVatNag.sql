
--* gSkrypt.sOpis = $Tworzenie funkcji CDN.JpkCodeExistOnVatNag$
-->
CREATE FUNCTION CDN.JpkCodeExistOnVatNag( @VaNId int, @code nvarchar(30))
RETURNS int
AS
BEGIN

	declare @result int = 0;	
	if exists(select * FROM CDN.DokKodyJPKV7 join CDN.KodyJPKV7 on (DKV7_KV7ID = KV7_KV7ID ) where KV7_Kod=@code and DKV7_ParentID  = @VaNId and DKV7_ParentTyp=2)
		set @result = 1;

	return @result;
END
