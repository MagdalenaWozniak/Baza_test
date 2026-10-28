CREATE PROCEDURE CDN.OkresyObrachunkowe
@dtFrom datetime,
@dtTo datetime
as
begin
 select
 case when @dtFrom > OOb_DataOtw then @dtFrom else OOb_DataOtw end as dateBegin,
 case when @dtTo < OOb_DataKoncowa then @dtTo else OOb_DataKoncowa end as dateEnd,
 OOb_Symbol,
 OOb_OObID
 from cdn.okresyobrach
 where
 @dtFrom between OOb_DataOtw and OOb_DataKoncowa
 or OOb_DataOtw between @dtFrom and @dtTo
 or OOb_DataKoncowa between @dtFrom and @dtTo
end
