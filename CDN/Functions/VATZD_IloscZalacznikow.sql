CREATE FUNCTION CDN.VATZD_IloscZalacznikow( @RokMiesiac int, @DeklaracjaKwartalna int)
RETURNS INT
AS
BEGIN
 declare @result INT = 0;
 if exists(
  select DkE_WartoscL from cdn.DeklElem join cdn.DeklNag on (DkN_DkNId = DkE_DkNId) join CDN.VATZD_DeklaracjeVatZD(@RokMiesiac, @DeklaracjaKwartalna) on (DkN_DkNId = DkNId)
  where
  DkN_Finalna = 1
  and DkN_TypDeklar = 403 and DkE_Numer = 1 and IsNull(DkE_WartoscL, 0) <> 0
  union
  select VaZ_VaNId_ZK from cdn.DeklNag join CDN.VatZD on (DkN_DkNId = VaZ_DkNId) join CDN.VATZD_DeklaracjeVatZD(@RokMiesiac, @DeklaracjaKwartalna) on (DkN_DkNId = DkNId)
  where
  DkN_Finalna = 1
  and DkN_TypDeklar = 403 and VaZ_VaNId_ZK is Not Null
 )
  select @result = Sum(Zalaczniki.DkE_WartoscL)
  from
  cdn.DeklNag
  join CDN.VATZD_DeklaracjeVatZD(@RokMiesiac, @DeklaracjaKwartalna) on (DkN_DkNId = DkNId)
  join CDN.DeklElem Zalaczniki on (DkN_DkNId = Zalaczniki.DkE_DkNId and Zalaczniki.DkE_Numer = 90)
  where DkN_Finalna = 1 and DkN_TypDeklar = 403
 RETURN IsNull(@result, 0)
END
