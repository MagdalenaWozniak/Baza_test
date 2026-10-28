create procedure CDN.ZUS_IMIR (@rok int, @miesiac int, @praid int, @parametr int)
as
begin
 if @parametr = 1
  with C as(
   select distinct WPS_WpeId, year(WPS_DataDo) as Year from cdn.WypSkladniki ws
    join cdn.Wyplaty w
     on w.WPL_WplId = ws.WPS_WplId
    join cdn.ListyPlac lp
     on w.WPL_LplId = lp.LPL_LplId
    --where WPS_WplId in(
    -- select WPL_WplId from cdn.Wyplaty where WPL_LplId in(
    --  select LPL_LplId from cdn.ListyPlac where LPL_Rok =  @rok and LPL_Miesiac =  @miesiac
    -- )
    where
     lp.LPL_Rok = @rok and
     ( WPL_PraId =   @praid
      or WPL_PraId in (select PRA_PraId from cdn.PracKod where PRA_ParentId = @praid)
     )
     and lp.LPL_Miesiac = @miesiac
     and year(WPS_DataDo) != @rok
  ), D as(
  select distinct isnull(sum(WPE_PodstEmer), 0)+isnull(
   (select
    sum(WPE_Wartosc)
   from cdn.WypElementy we
   join cdn.Wyplaty wyp on wyp.WPL_WplId = we.WPE_WplId
   join cdn.ListyPlac lp on wyp.WPL_LplId = lp.LPL_LplId
   where WPE_TwpId in (select TWP_TwpId from cdn.TypWyplata where TWP_SklZUS = 2)
    and WPE_Wartosc < 0
    and WPE_PraId = @praid
    and lp.LPL_Rok = @rok
    and lp.LPL_Miesiac = @miesiac
    and c.Year in (
     select year(WPS_DataDo) from cdn.WypSkladniki ws
     where
      we.WPE_WpeId = ws.WPS_WpeId
    )
    and (select count(distinct year(wss.WPS_DataDo)) from cdn.WypSkladniki wss where wss.WPS_WplId = we.WPE_WplId) > 1
   )
   , 0
  ) as Suma, c.Year as Yr from C c
  left join cdn.WypElementy a
   on c.WPS_WpeId = a.WPE_WpeId
   and WPE_TyUb not like '1240%'
   and WPE_TyUb not like '1211%'
  group by c.Year)
  select case when Suma < 0 then 0 else Suma end as Suma, Yr from D
  order by Yr desc;
 if @parametr = 2
  with C as(
   select distinct WPS_WpeId, year(WPS_DataDo) as Year from cdn.WypSkladniki ws
    join cdn.Wyplaty w
     on w.WPL_WplId = ws.WPS_WplId
    join cdn.ListyPlac lp
     on w.WPL_LplId = lp.LPL_LplId
    --where WPS_WplId in(
    -- select WPL_WplId from cdn.Wyplaty where WPL_LplId in(
    --  select LPL_LplId from cdn.ListyPlac where LPL_Rok =  @rok and LPL_Miesiac =  @miesiac
    -- )
    where
     lp.LPL_Rok = @rok and
     ( WPL_PraId =   @praid
      or WPL_PraId in (select PRA_PraId from cdn.PracKod where PRA_ParentId = @praid)
     )
     and lp.LPL_Miesiac = @miesiac
     and year(WPS_DataDo) != @rok
  ), D as(
  select distinct isnull(sum(WPE_PodstWypad) - sum(WPE_PodstEmer), 0)+isnull(
   (select
    sum(WPE_Wartosc)
   from cdn.WypElementy we
   join cdn.Wyplaty wyp on wyp.WPL_WplId = we.WPE_WplId
   join cdn.ListyPlac lp on wyp.WPL_LplId = lp.LPL_LplId
   where WPE_TwpId in (select TWP_TwpId from cdn.TypWyplata where TWP_SklZUS = 2)
    and WPE_Wartosc < 0
    and WPE_PraId = @praid
    and lp.LPL_Rok = @rok
    and lp.LPL_Miesiac = @miesiac
    and c.Year in (
     select year(WPS_DataDo) from cdn.WypSkladniki ws
     where
      we.WPE_WpeId = ws.WPS_WpeId
    )
    and (select count(distinct year(wss.WPS_DataDo)) from cdn.WypSkladniki wss where wss.WPS_WplId = we.WPE_WplId) > 1
   )
   , 0
  ) as Suma, c.Year as Yr from C c
  left join cdn.WypElementy a
   on c.WPS_WpeId = a.WPE_WpeId
  and WPE_TyUb not like '1240%'
  and WPE_TyUb not like '1211%'
  and WPE_PodstWypad > WPE_PodstEmer
  group by c.Year)
  select case when Suma < 0 then 0 else Suma end as Suma, Yr from D
  order by Yr desc;
 if @parametr = 3
  select isnull(sum(WPE_Wartosc), 0) as Suma from cdn.WypElementy where WPE_WpeId in (
   select WPS_WpeId from cdn.WypSkladniki where WPS_WplId in(
    select WPL_WplId from cdn.Wyplaty where WPL_LplId in(
     select LPL_LplId from cdn.ListyPlac where LPL_Rok =  @rok and LPL_Miesiac =  @miesiac
    ) and
     ( WPL_PraId =   @praid
      or WPL_PraId in (select PRA_PraId from cdn.PracKod where PRA_ParentId = @praid)
     )
     and WPE_PodstEmer = 0
   )
   and year(WPS_DataDo) = @rok
  )
  and WPE_TwpId in (select TWP_TwpId from cdn.TypWyplata where TWP_WykazZUSRPA = 1)
 if @parametr = 4
  with C as(
   select distinct WPS_WpeId, year(WPS_DataDo) as Year from cdn.WypSkladniki
    where WPS_WplId in(
     select WPL_WplId from cdn.Wyplaty where WPL_LplId in(
      select LPL_LplId from cdn.ListyPlac where LPL_Rok =  @rok and LPL_Miesiac =  @miesiac
     ) and
     ( WPL_PraId =   @praid
      or WPL_PraId in (select PRA_PraId from cdn.PracKod where PRA_ParentId = @praid)
     )
     and year(WPS_DataDo) != @rok
    )
  )
  select distinct isnull(sum(WPE_Wartosc), 0) as Suma, c.Year as Yr from C c
  left join cdn.WypElementy a
   on c.WPS_WpeId = a.WPE_WpeId
  and WPE_PodstEmer = 0
  and WPE_TwpId in (select TWP_TwpId from cdn.TypWyplata where TWP_WykazZUSRPA = 1)
  group by c.Year order by c.Year desc;
end
--////////////////////////////////////////////////////////////////////////////////////////////////////////
