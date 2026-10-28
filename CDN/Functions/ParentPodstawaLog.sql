create function cdn.ParentPodstawaLog(@praid int, @from datetime, @to datetime, @wepid int, @wpspracarodzic int)
 returns int
as
begin
 declare @retval int
 if(@wpspracarodzic is null)
 begin
  select top 1 @retval = max(A.WEP_WepId)
   from cdn.WypElementyPodstawa A
   where A.WEP_PraId = @praid and (A.WEP_RodzajElem = 10 or A.WEP_RodzajElem = 11) and A.WEP_WliczMetoda <> 13 and A.WEP_OkresDo <= @to
   and A.WEP_WepId < @wepid
   group by WEP_WepId, WEP_OkresDo
   order by WEP_OkresDo desc, WEP_WepId desc
   if (@retval is null)
   begin
    select top 1 @retval = max(A.WEP_WepId)
     from cdn.WypElementyPodstawa A
     where A.WEP_PraId = @praid and (A.WEP_RodzajElem = 10 or A.WEP_RodzajElem = 11) and A.WEP_WliczMetoda = 13 and A.WEP_OkresDo <= @to
     and A.WEP_WepId < @wepid
     group by WEP_WepId, WEP_OkresDo
     order by WEP_OkresDo asc, WEP_WepId desc
   end
  return @retval
 end
 if(@wpspracarodzic < 2)
 begin
  select top 1 @retval = max(A.WEP_WepId)
  from cdn.WypElementyPodstawa A join cdn.WypElementy B on A.WEP_WpeId = B.WPE_WpeId join cdn.WypSkladniki C on C.WPS_WpeId = B.WPE_WpeId
  where A.WEP_PraId = @praid and (A.WEP_RodzajElem = 10 or A.WEP_RodzajElem = 11) and A.WEP_WliczMetoda <> 13 and A.WEP_OkresDo < @to
  and A.WEP_WepId < @wepid and C.WPS_PracaRodzic in (0, 1)
  group by WEP_WepId, WEP_OkresDo
  order by WEP_OkresDo desc, WEP_WepId desc
  if (@retval is null)
  begin
   select top 1 @retval = max(A.WEP_WepId)
    from cdn.WypElementyPodstawa A join cdn.WypElementy B on A.WEP_WpeId = B.WPE_WpeId join cdn.WypSkladniki C on C.WPS_WpeId = B.WPE_WpeId
    where A.WEP_PraId = @praid and (A.WEP_RodzajElem = 10 or A.WEP_RodzajElem = 11) and A.WEP_WliczMetoda = 13 and A.WEP_OkresDo < @to
    and A.WEP_WepId < @wepid and C.WPS_PracaRodzic in (0, 1)
    group by WEP_WepId, WEP_OkresDo
    order by WEP_OkresDo asc, WEP_WepId desc
  end
 end
 else
 begin
  select top 1 @retval = max(A.WEP_WepId)
  from cdn.WypElementyPodstawa A join cdn.WypElementy B on A.WEP_WpeId = B.WPE_WpeId join cdn.WypSkladniki C on C.WPS_WpeId = B.WPE_WpeId
  where A.WEP_PraId = @praid and (A.WEP_RodzajElem = 10 or A.WEP_RodzajElem = 11) and A.WEP_WliczMetoda <> 13 and A.WEP_OkresDo < @to
  and A.WEP_WepId < @wepid and C.WPS_PracaRodzic = 2
  group by WEP_WepId, WEP_OkresDo
  order by WEP_OkresDo desc, WEP_WepId desc
  if (@retval is null)
  begin
   select top 1 @retval = max(A.WEP_WepId)
    from cdn.WypElementyPodstawa A join cdn.WypElementy B on A.WEP_WpeId = B.WPE_WpeId join cdn.WypSkladniki C on C.WPS_WpeId = B.WPE_WpeId
    where A.WEP_PraId = @praid and (A.WEP_RodzajElem = 10 or A.WEP_RodzajElem = 11) and A.WEP_WliczMetoda = 13 and A.WEP_OkresDo < @to
    and A.WEP_WepId < @wepid and C.WPS_PracaRodzic = 2
    group by WEP_WepId, WEP_OkresDo
    order by WEP_OkresDo asc, WEP_WepId desc
  end
 end
 return @retval
end
