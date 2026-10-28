
--* gSkrypt.sOpis = $Tworzenie funkcji CDN.UjemnyVat_Marza$
-->
CREATE FUNCTION CDN.UjemnyVat_Marza_Tab()
RETURNS @Result TABLE( 

    VaNId       int,
	Uniqueifier INT NOT NULL IDENTITY(1,1),
	PRIMARY KEY (Vanid, Uniqueifier))
AS
BEGIN
	
	insert into @Result
	select distinct vat_Vanid from CDN.VatNag join CDN.VatTab ON VaT_VaNID = VaN_VaNID
	where
	VaN_Rodzaj = 5 AND VaN_RazemNetto = 0 AND VaN_RazemVAT = 0 AND VaT_Netto < 0 AND VaT_StawkaSymbol != 'NP'     
    return
END
