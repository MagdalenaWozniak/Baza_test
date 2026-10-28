CREATE FUNCTION CDN.VATZD_DeklaracjeVatZD(@RokMiesiac int, @DeklaracjaKwartalna int)
RETURNS @Result TABLE(DkNID int)
AS
BEGIN
 declare @offset int = 0;
 if @DeklaracjaKwartalna = 0
 begin
    select @offset = case when DkE_WartoscL=0 then 0 else 2 end from CDN.DeklNag join CDN.DeklElem on (DkN_DkNID = DkE_DkNID)
    where
    DkN_TypDeklar = 1 and DkN_Finalna = 1 and Dkn_RokMiesiac = @RokMiesiac
    and DkE_Numer = 10008
  end
  else
  begin
    set @offset = 2;
  end
 insert into @Result (DkNID)
 select DkN_DkNId from CDN.DeklNag
 where DkN_TypDeklar = 403 and DkN_Finalna = 1 and Dkn_RokMiesiac between (@RokMiesiac-@offset) and @RokMiesiac;
 return;
END
