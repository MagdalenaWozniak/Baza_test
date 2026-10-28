create proc cdn.UrlopMacierzOkres @Okres_Od DATETIME, @Okres_Do DATETIME, @Typ INT
AS
SET NOCOUNT ON
 if @Typ = 0
 begin
 CREATE TABLE #UrlopMac2
 (
 Id Int)
 insert into #UrlopMac2 select PNB_PraId
  FROM cdn.PracNieobec join CDn.TypNieobec on PNB_TnbId = TNB_TnbId join CDN.PracEtaty on PRE_PreId = (Select MAX(PRE_PreId) from CDN.PracEtaty where
 PRE_PraId = PNB_PraId) and PNB_PracaRodzic <> 1 and
 (PNB_OkresOd BETWEEN @Okres_Od and @Okres_Do
 and  PNB_OkresDo BETWEEN @Okres_Od and @Okres_Do)
   AND TNB_Standardowy = 402 group by PNB_PraId
 --2
  insert into #UrlopMac2 select PNB_PraId
  FROM cdn.PracNieobec join CDn.TypNieobec on PNB_TnbId = TNB_TnbId join CDN.PracEtaty on PRE_PreId = (Select MAX(PRE_PreId) from CDN.PracEtaty where
 PRE_PraId = PNB_PraId) and PNB_PracaRodzic <> 1 and
 (PNB_OkresOd not BETWEEN @Okres_Od and @Okres_Do
 and  PNB_OkresDo BETWEEN @Okres_Od and @Okres_Do)
   AND TNB_Standardowy = 402 group by PNB_PraId
 --3
  insert into #UrlopMac2 select PNB_PraId
  FROM cdn.PracNieobec join CDn.TypNieobec on PNB_TnbId = TNB_TnbId join CDN.PracEtaty on PRE_PreId = (Select MAX(PRE_PreId) from CDN.PracEtaty where
 PRE_PraId = PNB_PraId) and PNB_PracaRodzic <> 1 and
 (PNB_OkresOd  BETWEEN @Okres_Od and @Okres_Do
 and  PNB_OkresDo not BETWEEN @Okres_Od and @Okres_Do)
   AND TNB_Standardowy = 402 group by PNB_PraId
 --4
 insert into #UrlopMac2 select PNB_PraId
  FROM cdn.PracNieobec join CDn.TypNieobec on PNB_TnbId = TNB_TnbId join CDN.PracEtaty on PRE_PreId = (Select MAX(PRE_PreId) from CDN.PracEtaty where
 PRE_PraId = PNB_PraId) and PNB_PracaRodzic <> 1 and
 (PNB_OkresOd  not  BETWEEN @Okres_Od and @Okres_Do and PNB_OkresOd  < @Okres_Od
 and  PNB_OkresDo not BETWEEN @Okres_Od and @Okres_Do and PNB_OkresDo  > @Okres_Do)
   AND TNB_Standardowy = 402 group by PNB_PraId
 select * from #UrlopMac2
 end
 else
 begin
 CREATE TABLE #UrlopMac(
 Stopien Decimal,
 Suma Decimal (15,7))
 insert into #UrlopMac select cast(PRE_StNiepelnosp as DECIMAL (15,7)),sum(Cast(Round(((cast(cast(PRE_ETAEtatL as float)/cast(PRE_ETAEtatM as float) as decimal(10,2))) *
 ((cast(DATEDIFF(day,@Okres_Od,@Okres_Do)+1 as float) - cast(DATEDIFF(day,PNB_OkresOd,PNB_OkresDo) + 1 as float))/(cast(DATEDIFF(day,@Okres_Od,@Okres_Do)+1 as float)))),4,1)
  as decimal(18,3)))
  FROM cdn.PracNieobec join CDn.TypNieobec on PNB_TnbId = TNB_TnbId join CDN.PracEtaty on PRE_PreId = (Select MAX(PRE_PreId) from CDN.PracEtaty where
 PRE_PraId = PNB_PraId) and PNB_PracaRodzic <> 1 and
 (PNB_OkresOd BETWEEN @Okres_Od and @Okres_Do
 and  PNB_OkresDo BETWEEN @Okres_Od and @Okres_Do)
   AND TNB_Standardowy = 402 group by PRE_StNiepelnosp
 --2
  insert into #UrlopMac  select cast(PRE_StNiepelnosp as DECIMAL (15,7)),sum(Cast(Round(((cast(cast(PRE_ETAEtatL as float)/cast(PRE_ETAEtatM as float) as decimal(10,2))) *
 ((cast(DATEDIFF(day,@Okres_Od,@Okres_Do)+1 as float) - cast(DATEDIFF(day,@Okres_Od,PNB_OkresDo) + 1 as float))/(cast(DATEDIFF(day,@Okres_Od,@Okres_Do)+1 as float)))),4,1)
  as decimal(18,3)))
  FROM cdn.PracNieobec join CDn.TypNieobec on PNB_TnbId = TNB_TnbId join CDN.PracEtaty on PRE_PreId = (Select MAX(PRE_PreId) from CDN.PracEtaty where
 PRE_PraId = PNB_PraId) and PNB_PracaRodzic <> 1 and
 (PNB_OkresOd not BETWEEN @Okres_Od and @Okres_Do
 and  PNB_OkresDo BETWEEN @Okres_Od and @Okres_Do)
   AND TNB_Standardowy = 402 group by PRE_StNiepelnosp
 --3
  insert into #UrlopMac  select cast(PRE_StNiepelnosp as DECIMAL (15,7)),sum(Cast(Round(((cast(cast(PRE_ETAEtatL as float)/cast(PRE_ETAEtatM as float) as decimal(10,2))) *
 ((cast(DATEDIFF(day,@Okres_Od,@Okres_Do)+1 as float) - cast(DATEDIFF(day,PNB_OkresOd,@Okres_Do) + 1 as float))/(cast(DATEDIFF(day,@Okres_Od,@Okres_Do)+1 as float)))),4,1)
  as decimal(18,3)))
  FROM cdn.PracNieobec join CDn.TypNieobec on PNB_TnbId = TNB_TnbId join CDN.PracEtaty on PRE_PreId = (Select MAX(PRE_PreId) from CDN.PracEtaty where
 PRE_PraId = PNB_PraId) and PNB_PracaRodzic <> 1 and
 (PNB_OkresOd  BETWEEN @Okres_Od and @Okres_Do
 and  PNB_OkresDo not BETWEEN @Okres_Od and @Okres_Do)
   AND TNB_Standardowy = 402 group by PRE_StNiepelnosp
 --4
   insert into #UrlopMac  select cast(PRE_StNiepelnosp as DECIMAL (15,7)), CAST (0 as decimal (19,3))
  FROM cdn.PracNieobec join CDn.TypNieobec on PNB_TnbId = TNB_TnbId join CDN.PracEtaty on PRE_PreId = (Select MAX(PRE_PreId) from CDN.PracEtaty where
 PRE_PraId = PNB_PraId) and PNB_PracaRodzic <> 1 and
 (PNB_OkresOd  not  BETWEEN @Okres_Od and @Okres_Do and PNB_OkresOd  < @Okres_Od
 and  PNB_OkresDo not BETWEEN @Okres_Od and @Okres_Do and PNB_OkresDo  > @Okres_Do)
   AND TNB_Standardowy = 402 group by PRE_StNiepelnosp
 select * from #UrlopMac
 end
