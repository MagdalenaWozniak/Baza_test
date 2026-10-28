create PROCEDURE CDN.GUSlista @DataOd DATETIME, @DataDo DATETIME
AS
BEGIN
SET NOCOUNT ON
IF @DataOd IS NULL OR @DataDo IS NULL
 BEGIN
  SET @DataOd = '1899-12-30 00:00:00'
  SET @DataDo = '1899-12-30 00:00:00'
 END
 ELSE
 BEGIN
  SET @DataOd = CONVERT(DATETIME, CAST(DATEPART(year ,@DataOd) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@DataOd) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@DataOd) AS NVARCHAR)+' 00:00:000', 120)
  SET @DataDo = CONVERT(DATETIME, CAST(DATEPART(year ,@DataDo) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@DataDo) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@DataDo) AS NVARCHAR)+' 00:00:000', 120)
 END
select E.PRE_Nazwisko+' '+E.PRE_Imie1 + ' ['+ E.PRE_Kod +']' Pracownik,
case pri_nadrzedny when 1 then '+ ' else case isnull(pri_parentid,0) when 0 then '' else '- ' end  end as Ozn,
 case when not (E.PRE_ETAEtatL*P.PRE_ETAEtatM<P.PRE_ETAEtatL*E.PRE_ETAEtatM and E.PRE_DataOd between @DataOd and @DataDo and
P.PRE_ZatrudnionyDo>P.PRE_DataDo and E.PRE_ETAEtatL<E.PRE_ETAEtatM)
 then E.PRE_ZatrudnionyDo else P.PRE_DataDo end Data,
 case when not (E.PRE_ETAEtatL*P.PRE_ETAEtatM<P.PRE_ETAEtatL*E.PRE_ETAEtatM and E.PRE_DataOd between @DataOd and @DataDo and
P.PRE_ZatrudnionyDo>P.PRE_DataDo and E.PRE_ETAEtatL<E.PRE_ETAEtatM)
 then DKM_Nazwa else 'Zmiejszenie wymiaru etatu na niepełny' end Opis
from CDN.PracEtaty E
left join CDN.DaneKadMod on DKM_DkmId = E.PRE_ETADkmIdWypowPowod
join CDN.Pracidx on PRI_PraId = PRE_PraId
left outer join CDN.PracEtaty P on P.PRE_PraId=E.PRE_PraId and P.PRE_DataDo=E.PRE_DataOd-1 and P.PRE_HDKGUSGlowneMiejscePracy=1
where (E.PRE_ZatrudnionyDo between @DataOd and @DataDo and ((Left(E.PRE_UbzTyuID,1)=1 or (E.PRE_UbzTyuID = 800) or Left(E.PRE_UbzTyuID,1)=2)) and
E.PRE_HDKGUSGlowneMiejscePracy=1 and E.PRE_ETAEtatL>=E.PRE_ETAEtatM
and not exists(select * from CDN.PracEtaty N where N.PRE_PraId=E.Pre_PraId and N.Pre_DataOd=E.Pre_DataDo+1 and N.Pre_ZatrudnionyOd=E.Pre_ZatrudnionyOd))
or
(E.PRE_ETAEtatL*P.PRE_ETAEtatM<P.PRE_ETAEtatL*E.PRE_ETAEtatM and E.PRE_DataOd between @DataOd and @DataDo and
P.PRE_ZatrudnionyDo>P.PRE_DataDo and E.PRE_ETAEtatL<E.PRE_ETAEtatM)
union
select PRE_Nazwisko+' '+PRE_Imie1,
case pri_nadrzedny when 1 then '+ ' else case isnull(pri_parentid,0) when 0 then '' else '- ' end  end as Ozn,
(select max(N.PNB_OkresOd)-1 from CDN.PracNieobec N
  left outer join CDN.PracNieobec P on P.PNB_PraId=N.PNB_PraId and N.PNB_Tryb<>1 and P.PNB_Tryb<>1
  and P.PNB_TnbId=N.PNB_TnbId and
P.PNB_OkresDo=dateadd(day,-1,N.PNB_OkresOd)
 inner join CDN.TypNieobec on TNB_TnbId=N.PNB_TnbId
  where TNB_PdzId in (111,112, 121, 122) and
N.PNB_PraId=PRE_PraId and
  N.PNB_OkresOd<=@DataDo and P.PNB_OkresDo is null
), (
select TNB_Nazwa from CDN.PracNieobec
 inner join CDN.TypNieobec on TNB_TnbId=PNB_TnbId
 where PNB_PraId=PRE_PraId and PNB_Tryb<>1 and @DataDo between PNB_OkresOd and PNB_OkresDo
)
from CDN.PracEtaty
join CDN.Pracidx on PRI_PraId = PRE_PraId
where isNull((datediff(day, (
 select max(N.PNB_OkresOd) from CDN.PracNieobec N
 left outer join CDN.PracNieobec P on P.PNB_PraId=N.PNB_PraId and N.PNB_Tryb<>1 and P.PNB_Tryb<>1
 and P.PNB_TnbId=N.PNB_TnbId and
P.PNB_OkresDo=dateadd(day,-1,N.PNB_OkresOd)
 inner join CDN.TypNieobec on TNB_TnbId=N.PNB_TnbId
  where TNB_PdzId in (111,112, 121, 122) and
N.PNB_PraId=PRE_PraId and
  N.PNB_OkresOd<=@DataDo and P.PNB_OkresDo is null
),(
 select min(N.PNB_OkresDo) from CDN.PracNieobec N
 left outer join CDN.PracNieobec P on P.PNB_PraId=N.PNB_PraId and N.PNB_Tryb<>1 and P.PNB_Tryb<>1
 and P.PNB_TnbId=N.PNB_TnbId and
P.PNB_OkresOd=dateadd(day,1,N.PNB_OkresDo)
 inner join CDN.TypNieobec on TNB_TnbId=N.PNB_TnbId
 where TNB_PdzId in (111,112, 121, 122) and N.PNB_PraId=PRE_PraId and
  N.PNB_OkresDo>=@DataDo and P.PNB_OkresOd is null
))+1 ),0) >90
 and (
 select max(N.PNB_OkresOd)-1 from CDN.PracNieobec N
  left outer join CDN.PracNieobec P on P.PNB_PraId=N.PNB_PraId and N.PNB_Tryb<>1 and P.PNB_Tryb<>1
  and P.PNB_TnbId=N.PNB_TnbId and
P.PNB_OkresDo=dateadd(day,-1,N.PNB_OkresOd)
 inner join CDN.TypNieobec on TNB_TnbId=N.PNB_TnbId
  where TNB_PdzId in (111,112, 121, 122) and
N.PNB_PraId=PRE_PraId and
  N.PNB_OkresOd<=@DataDo and P.PNB_OkresDo is null
) >= @dataOd
 and ((PRE_UbzTyuID<>120 and Left(PRE_UbzTyuID,1)<>4  and
Left(PRE_UbzTyuID,1)<>5 and Len(PRE_UbzTyuID)=3)
 and (PRE_UbzTyuID<>20000) and (PRE_UbzTyuID<>200) or (PRE_UbzTyuID =
800))
 and PRE_HDKGUSGlowneMiejscePracy=1 and ((Left(PRE_UbzTyuID,1)=1 or Left(PRE_UbzTyuID,1)=2))
and @DataDo between PRE_DataOd
and PRE_DataDo
 and @DataDo between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo and
PRE_ETAEtatL>=PRE_ETAEtatM
END
