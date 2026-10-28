CREATE FUNCTION CDN.DeklaracjeVat7WOkresie(@dateOd DateTime, @dateDo DateTime)
RETURNS @Result TABLE(DkNId int, Kwartalnie int, RokMiesiacOd int, RokMiesiacDo int, DataOd DateTime, DataDo DateTime)
AS
BEGIN
 declare @rmOd int = 100 * Year(@dateOd) + Month(@dateOd)
 declare @rmDo int = 100 * Year(@dateDo) + Month(@dateDo)
 insert into @Result (DkNId, Kwartalnie, RokMiesiacOd, RokMiesiacDo)
 select * from (
  select DkN_DkNId, DkE_WartoscL as Kwartalnie,
  (Case when DkE_WartoscL <> 0 then DkN_RokMiesiac - 2 else DkN_RokMiesiac end) as  RokMiesiacOd,
  DkN_RokMiesiac as RokMiesiacDo
  from cdn.DeklNag join CDN.DeklElem On(DkE_DkNID = DkN_DkNId)
  where DkN_Finalna=1 and DkN_TypDeklar = 1 and DkE_Numer = 10008
  and @rmOd <= (Case when DkE_WartoscL <> 0 then DkN_RokMiesiac - 2 else DkN_RokMiesiac end) and @rmDo >= (Case when DkE_WartoscL <> 0 then DkN_RokMiesiac - 2 else DkN_RokMiesiac end)
  Union
  select DkN_DkNId, DkE_WartoscL as Kwartalnie,
  (Case when DkE_WartoscL <> 0 then DkN_RokMiesiac - 2 else DkN_RokMiesiac end) as  RokMiesiacOd,
  DkN_RokMiesiac as RokMiesiacDo
  from cdn.DeklNag join CDN.DeklElem On(DkE_DkNID = DkN_DkNId)
  where DkN_Finalna=1 and DkN_TypDeklar = 1 and DkE_Numer = 10008
  and @rmOd <= (Case when DkE_WartoscL <> 0 then DkN_RokMiesiac - 1 else DkN_RokMiesiac end) and @rmDo >= (Case when DkE_WartoscL <> 0 then DkN_RokMiesiac - 2 else DkN_RokMiesiac end)
  Union
  select DkN_DkNId, DkE_WartoscL as Kwartalnie,
  (Case when DkE_WartoscL <> 0 then DkN_RokMiesiac - 2 else DkN_RokMiesiac end) as  RokMiesiacOd,
  DkN_RokMiesiac as RokMiesiacDo
  from cdn.DeklNag join CDN.DeklElem On(DkE_DkNID = DkN_DkNId)
  where DkN_Finalna=1 and DkN_TypDeklar = 1 and DkE_Numer = 10008
  and @rmOd <= DkN_RokMiesiac and @rmDo >= DkN_RokMiesiac
 ) as deklaracje
 update @Result Set DataOd = DATEADD(year, RokMiesiacOd/100-1900, DATEADD(month, RokMiesiacOd%100-1, DATEADD(day, 1-1, 0))),
      DataDo = DATEADD(year, RokMiesiacDo/100-1900, DATEADD(month, RokMiesiacDo%100-1, DATEADD(day, 1-1, 0)))
 update @Result Set DataDo = DATEADD(day, -1, DATEADD(month, 1, DataDo))
 return
END
