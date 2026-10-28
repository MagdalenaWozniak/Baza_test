CREATE  PROCEDURE [CDN].[ESKLEP_EksportRabaty]
  @ID INT      -- ID e-sklepu
AS
BEGIN
declare
@ESSID  INT
select @ESSID = ESS_ESSID from cdn.eSklepStanowiska where ESS_IdISklep = @ID
select * into #aaa
from
(
select Rab_Typ , rab_rabid, 2 as typ,  ISNULL(rab_twrid,0) as rab_podmiotid, 1 as rabattyp, 0 as rabatprog, Rab_RabatISklep as rabat from cdn.Rabaty
join Cdn.eSklepKntRelacje on Rab_PodmiotId = ESK_KntOptimaID
where
Rab_Typ = 2 and Rab_RabatISklep > 0 and Rab_PodmiotTyp = 1 and ESK_eSklepID = @ESSID
union all
select Rab_Typ ,rab_rabid, 1 as typ, ESK_KnteSklepID , NULL as rabattyp, NULL as rabatprog, NULL as rabat
from cdn.Rabaty
join Cdn.eSklepKntRelacje on Rab_PodmiotId = ESK_KntOptimaID
where
Rab_Typ = 2 and Rab_RabatISklep > 0 and Rab_PodmiotTyp = 1 and ESK_eSklepID = @ESSID
union all
select  Rab_Typ , rab_rabid, 3 as typ,  ISNULL(rab_twrid,0) as rab_podmiotid, 1 as rabattyp, 0 as rabatprog, Rab_RabatISklep as rabat
from cdn.Rabaty
join Cdn.eSklepKntRelacje on Rab_PodmiotId = ESK_KntOptimaID
where
Rab_Typ = 5 and Rab_RabatISklep > 0 and Rab_PodmiotTyp = 1 and ESK_eSklepID = @ESSID
union all
select Rab_Typ ,rab_rabid, 1 as typ, ESK_KnteSklepID , NULL as rabattyp, NULL as rabatprog, NULL as rabat
from cdn.rabaty
join Cdn.eSklepKntRelacje on Rab_PodmiotId = ESK_KntOptimaID
where
Rab_Typ = 5 and Rab_RabatISklep > 0 and Rab_PodmiotTyp = 1 and ESK_eSklepID = @ESSID
union all
select  Rab_Typ , rab_rabid, 2 as typ,  ISNULL(rab_twrid,0) as rab_podmiotid, 1 as rabattyp, 0 as rabatprog, Rab_RabatISklep as rabat
from cdn.rabaty
join Cdn.eSklepKntRelacje on Rab_PodmiotId = ESK_KntOptimaID
join cdn.towary  on Rab_TwrId = Twr_TwrId
LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
where
Rab_Typ = 6 and  Rab_RabatISklep > 0 and Twes_Udostepnij =1 and Rab_PodmiotTyp = 1 and ESK_eSklepID = @ESSID
union all
select Rab_Typ ,rab_rabid, 1 as typ, ESK_KnteSklepID , NULL as rabattyp, NULL as rabatprog, NULL as rabat
from cdn.rabaty
join Cdn.eSklepKntRelacje on Rab_PodmiotId = ESK_KntOptimaID
join cdn.towary  on Rab_TwrId = Twr_TwrId
LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
where
Rab_Typ = 6 and  Rab_RabatISklep > 0 and Twes_Udostepnij = 1 and Rab_PodmiotTyp = 1 and ESK_eSklepID = @ESSID
union all
select  Rab_Typ , rab_rabid, 1 as typ,  ISNULL(rab_podmiotid,0) as rab_podmiotid, NULL as rabattyp, NULL as rabatprog, NULL as rabat
from cdn.rabaty
where
Rab_Typ = 7 and  Rab_RabatISklep > 0
union all
select Rab_Typ ,rab_rabid, 3 as typ,  rab_twrid, 1 as rabattyp, 0 as rabatprog, Rab_RabatISklep as rabat
from cdn.rabaty
where
Rab_Typ = 7 and  Rab_RabatISklep > 0
union all
select  Rab_Typ , rab_rabid, 1 as typ,  ISNULL(rab_podmiotid,0) as rab_podmiotid, NULL as rabattyp, NULL as rabatprog, NULL as rabat from cdn.Rabaty
join cdn.towary  on Rab_TwrId = Twr_TwrId
LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
where
Rab_Typ = 8 and  Rab_RabatISklep > 0 and Twes_Udostepnij = 1
union all
select Rab_Typ ,rab_rabid, 2 as typ, rab_twrid , 1 as rabattyp, 0 as rabatprog, Rab_RabatISklep as rabat
from cdn.Rabaty
join cdn.towary  on Rab_TwrId = Twr_TwrId
LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
where
Rab_Typ = 8 and  Rab_RabatISklep > 0 and Twes_Udostepnij = 1
) as RBT
--select *  from #aaa --as RBT FOR XML AUTO
select rab_rabid AS '@ID',1 AS '@Typ',0 AS '@Godziny', 1 AS '@Priorytet', 0 AS '@Pomin',
(select rab_rabid as [@ID], typ as [@Typ], rab_podmiotid as [@GIDNumer], rabattyp as [@RabatTyp], rabatprog as [@RabatProg], rabat as [@Rabat] from #aaa as AAA where AAA.Rab_RabId = rbt.Rab_RabId
FOR XML PATH('RBE'), ROOT ('RBTE'), type)
from #aaa as RBT
group by rab_rabid
FOR XML PATH('RBT'), ROOT ('RBTI')
drop table #aaa
END
