CREATE FUNCTION CDN.VATZD_ZapisKorekcyjnyKwotaVat( @Rok int, @Miesiac int)
RETURNS decimal(15,2)
AS
BEGIN
 declare @Result decimal(15, 2); Set @Result = 0;
 declare @RokMiesiac int; Set @RokMiesiac = 100 * @Rok + @Miesiac;
 if exists(
 select * from cdn.VatNag where VaN_VaNId in (
  select DkE_WartoscL from cdn.DeklElem join cdn.DeklNag on (DkN_DkNId = DkE_DkNId)
  where
  DkN_Finalna = 1
  and DkN_RokMiesiac = @RokMiesiac
  and DkN_TypDeklar = 402 and DkE_Numer = 1
  union
  select VaZ_VaNId_ZK from cdn.DeklNag join CDN.VatZD on (DkN_DkNId = VaZ_DkNId)
  where
  DkN_Finalna = 1
  and DkN_RokMiesiac = @RokMiesiac
  and DkN_TypDeklar = 402 and VaZ_VaNId_ZK is Not Null
  )
 )
  select @Result = sum(DkE_WartoscL) from cdn.DeklElem join cdn.DeklNag on (DkN_DkNId = DkE_DkNId)
  where
  DkN_Finalna = 1
  and DkN_RokMiesiac = @RokMiesiac
  and DkN_TypDeklar = 402 and DKe_Numer = 116;
 else
  select @Result = 0;
 return @Result
END
