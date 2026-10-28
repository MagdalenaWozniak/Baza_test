CREATE FUNCTION CDN.JpkCodeExistOnVatNag_Tab(@code nvarchar(30))
RETURNS @Result TABLE( 

    VaNId       int,
	Uniqueifier INT NOT NULL IDENTITY(1,1),
	PRIMARY KEY (Vanid, Uniqueifier))

AS
BEGIN
	
	insert into @Result
	select distinct DKV7_ParentID FROM CDN.DokKodyJPKV7 join CDN.KodyJPKV7 on (DKV7_KV7ID = KV7_KV7ID ) where KV7_Kod=@code and DKV7_ParentTyp=2
	
	return;
END
