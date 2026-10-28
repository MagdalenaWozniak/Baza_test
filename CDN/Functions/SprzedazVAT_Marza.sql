
--* gSkrypt.sOpis = $Tworzenie funkcji CDN.SprzedazVAT_Marza$
-->
CREATE FUNCTION CDN.SprzedazVAT_Marza(@VaNId int)
RETURNS decimal(15,2)
AS
BEGIN

    declare @result decimal(15,2) = 0;	  
    select @result = SUM(VaT_NettoDoVat) from CDN.VatTab join cdn.VatNag on (VaN_VaNID=VaT_VaNId) 
    where 
    VaN_Wewnetrzna=0 and
    (CDN.JpkCodeExistOnVatNag( VaN_VaNId, 'MR_T') = 1 or CDN.JpkCodeExistOnVatNag( VaN_VaNId, 'MR_UZ') = 1)
    --VAN_Rodzaj=2 and (CDN.JpkCodeExistOnVatNag( VaN_VaNId, 'MR_T') = 1 or CDN.JpkCodeExistOnVatNag( VaN_VaNId, 'MR_UZ') = 1)
    --CDN.JpkCodeExistOnVatNag( VaN_VaNId, 'WEW') = 1 and VAN_Rodzaj=2 and (CDN.JpkCodeExistOnVatNag( VaN_VaNId, 'MR_T') = 1 or CDN.JpkCodeExistOnVatNag( VaN_VaNId, 'MR_UZ') = 1)
    and VaT_Stawka = 0 and VaT_Flaga = 4 and VaT_VaNID = @VaNId;


    return @result;
END
