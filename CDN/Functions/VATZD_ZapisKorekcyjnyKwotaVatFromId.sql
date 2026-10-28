CREATE FUNCTION CDN.VATZD_ZapisKorekcyjnyKwotaVatFromId( @VaNId int)
RETURNS decimal(15,2)
AS
BEGIN
 declare @Result decimal (15,2)
 select @Result = sum(VaT_VatDoVat) from cdn.VatTab
 where
 VaT_VaNID = @VaNId and VaT_Odliczenia = 0
 Set @Result = IsNull(@Result,0)
 return @Result
END
