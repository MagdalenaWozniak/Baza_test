create PROCEDURE [CDN].[PobierzAwizoTowary]
  @TrN_List  TEXT
AS
SET NOCOUNT ON
declare
@DeA_DeAIdNag int,
@DeA_DeAIdelem int
select @DeA_DeAIdNag = DeA_DeAId from cdn.DefAtrybuty where DeA_kod = 'ULTIMATECUSTOMERGLN' and dea_typ = 4
select @DeA_DeAIdelem = DeA_DeAId from cdn.DefAtrybuty where DeA_kod = 'ULTIMATECUSTOMERGLN' and dea_typ = 1
select MAX(NrZamowienia) as NrZamowienia,
MAX(DataZamowienia) as DataZamowienia,
Max(NrOdbiorca) as NrOdbiorca,
TrEId as TrEId,
MAX(TwrID) AS TwrID,
MAX(TwrKod) AS TwrKod,
MAX(TwrNazwa) AS TwrNazwa,
MAX(TwrEAN) AS TwrEAN,
Max(IloscCalkowita) - SUM(ISNULL(AWO_TwrIlosc,0))  as IloscDoSpakuj,
Max(IloscCalkowita) as IloscCalkowita,
MAX(Jm) as Jm,
MAX(NrRO) AS NrRO,
SUM(ISNULL(AWO_TwrIlosc,0)) as IloscZapakowana
from (
select MAX(RO.TrN_NumerObcy) as NrZamowienia,
MAX(RO.TrN_DataOpe) as DataZamowienia,
Max(case when ISNULL(TrA_Wartosc,'') = '' then ISNULL(DAt_WartoscTxt,'')else TrA_Wartosc end) as NrOdbiorca,
ROElem.tre_treid as TrEId,
MAX(ROElem.tre_twrid) AS TwrID,MAX(ROElem.TrE_TwrKod) AS TwrKod,
MAX(ROElem.TrE_TwrNazwa) AS TwrNazwa,
MAX(ROElem.TrE_TwrEAN) AS TwrEAN,
 ABS(ISNULL(sum(TrS_Ilosc),0)) * MAX(ROElem.TrE_JMPrzelicznikM) / MAX(ROElem.TrE_JMPrzelicznikL) as IloscCalkowita,
 MAX(ROElem.TrE_Jm) as Jm, MAX(RO.TrN_NumerPelny) AS NrRO  from cdn.TraElem ROElem
join cdn.TraNag RO on RO.TrN_TrNID = ROElem.TrE_TrNId
join cdn.TraElemRelacje on ROElem.TrE_TrEID = TeR_ParentId and TeR_ChildTyp = 306
join cdn.TraElem WZElem on WZElem.TrE_TrEID = TeR_ChildId
Join CDN.TraSElem ON TrS_TrEID = ROElem.TrE_TrEID  and TrS_TrEIdWydania = WZElem.TrE_TrEID
join cdn.TraNag WZ on WZElem.TrE_TrNId = WZ.TrN_TrNID
left outer join cdn.TraElemAtr on TrA_TrEId = ROElem.TrE_TrEID and  TrA_DeAId = @DeA_DeAIdElem
left outer join cdn.DokAtrybuty on DaT_TrNId = ROElem.TrE_TrNID and  DaT_DeAId = @DeA_DeAIdNag
where ROElem.TrE_TrNId in(select NextIdInt from  CDN.Text2TableInt ( @TrN_List )) and WZ.TrN_Bufor = 0 and ROElem.TrE_TwrTyp = 1
group by ROElem.tre_treid
having ABS(ISNULL(sum(TrS_Ilosc),0)) * MAX(ROElem.TrE_JMPrzelicznikM) / MAX(ROElem.TrE_JMPrzelicznikL) > 0)  A
left outer join cdn.AwizoOpakowania on AWO_TrEID = treid
group by treid
