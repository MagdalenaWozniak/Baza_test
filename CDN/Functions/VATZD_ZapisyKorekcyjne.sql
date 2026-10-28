CREATE FUNCTION CDN.VATZD_ZapisyKorekcyjne(@DataOd DateTime, @DataDo DateTime)
RETURNS @Result TABLE(VaNId int, SrcVaNId int)
AS
BEGIN
 declare @RokMiesMin int = 100 * Year(@DataOd) + Month(@DataOd);
 declare @RokMiesMax int = 100 * Year(@DataDo) + Month(@DataDo);
 declare @rokMiesiac int = @RokMiesMin;
 declare @y int = Year(@DataOd);
 declare @m int = Month(@DataOd);
 while (@rokMiesiac <= @RokMiesMax)
 begin
  set @y = @rokMiesiac / 100;
  set @m = @rokMiesiac % 100;
  if exists(
   select * from cdn.VatNag where VaN_VaNId in (
   select DkE_WartoscL from cdn.DeklElem join cdn.DeklNag on (DkN_DkNId = DkE_DkNId)
   where
    DkN_RokMiesiac = @rokMiesiac
   and DkN_TypDeklar = 402 and DkE_Numer = 1 )
  )
   insert into @Result(VaNId)
   select DkE_WartoscL from cdn.DeklElem join cdn.DeklNag on (DkN_DkNId = DkE_DkNId)
   where
   DkN_RokMiesiac = @rokMiesiac and DkN_TypDeklar = 402 and DKe_Numer = 1;
  if exists(
   select * from cdn.VatNag where VaN_VaNId in (
   select  VaZ_VaNId_ZK from cdn.DeklNag join CDN.VatZD on (DkN_DkNId = VaZ_DkNId)
   where
    DkN_RokMiesiac = @rokMiesiac
   and DkN_TypDeklar = 402 and VaZ_VaNId_ZK is Not Null )
  )
   insert into @Result(VaNId, SrcVaNId)
   select distinct VaZ_VaNId_ZK, VaZ_VaNId from cdn.DeklNag join CDN.VatZD on (DkN_DkNId = VaZ_DkNId)
   where
   DkN_RokMiesiac = @rokMiesiac and DkN_TypDeklar = 402 and VaZ_VaNId_ZK is Not Null;
  if (@m = 12)
  begin
   set @y = @y + 1;
   set @m = 1;
  end
  set @rokMiesiac = @rokMiesiac + 1
 end;
 return;
END
