
--* gSkrypt.sOpis = $Tworzenie funkcji CDN.ZakupVAT_Marza$
-->
CREATE FUNCTION CDN.ZakupVAT_Marza(@VaNId1 int, @VaNId2 int)
RETURNS decimal(15,2)
AS
BEGIN

    declare @result decimal(15,2) = 0;	  
    declare @sum1 decimal(15,2) = 0;	  
    declare @sum2 decimal(15,2) = 0;	  

    select @sum1 = SUM(VaT_NettoDoVat) from CDN.VatTab where VaT_Stawka = 0 and VaT_Flaga = 4 and VaT_VaNID = @VaNId1;
    select @sum2 = SUM(VaT_NettoDoVat) from CDN.VatTab where VaT_Stawka = 0 and VaT_Flaga = 4 and VaT_VaNID = @VaNId2;

    set @result = @sum1 + @sum2;

    return @result;
END
