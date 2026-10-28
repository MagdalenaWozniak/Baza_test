CREATE FUNCTION CDN.VATZD_DeklaracjeVat7_Wyslana(@RokMiesiac int)
RETURNS int
AS
BEGIN
 declare @result int = 0;
 if exists(select * from CDN.DeklNag where DkN_TypDeklar = 1 and DkN_RokMiesiac = @RokMiesiac and DkN_Finalna = 1 and DkN_Zablokowana = 1 and DkN_EDekl_Status in (301,302,303) )
  set @result = 1;
 else
 begin
  declare @miesiac int = @RokMiesiac % 100;
  declare @rok int = @RokMiesiac / 100;
  if @miesiac between 1 and 3
   set @RokMiesiac = 100 * @rok + 3;
  else if  @miesiac between 4 and 6
   set @RokMiesiac = 100 * @rok + 6;
  else if  @miesiac between 7 and 9
   set @RokMiesiac = 100 * @rok + 9;
  else if  @miesiac between 10 and 12
   set @RokMiesiac = 100 * @rok + 12;
  if exists(select * from CDN.DeklNag  join CDN.DeklElem on (DkN_DkNID = DkE_DkNID) where DkN_TypDeklar = 1 and DkN_RokMiesiac = @RokMiesiac and DkN_Finalna = 1 and DkN_Zablokowana = 1 and DkN_EDekl_Status in (301,302,303)  and DkE_Numer = 10008 and DkE_WartoscL <> 0)
   set @result = 1;
 end
 return @result;
END
