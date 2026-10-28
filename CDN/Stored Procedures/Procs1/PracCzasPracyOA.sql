--szczególny przypadek procedury PracCzasPracySP (parametr Typ = 3)
CREATE PROCEDURE CDN.PracCzasPracyOA @Id int, @DataOd datetime, @DataDo datetime
AS
SET NOCOUNT ON
if @DataOd is null set @DataOd=GETDATE()
if @DataDo is null or @DataDo<@DataOd set @DataDo=@DataOd
declare @MaByc int
declare @Jest int
set @MaByc = DATEDIFF(day,@DataOd,@DataDo)+1
declare @UndefId int
select @UndefId=DST_DstId from CDN.DefinicjeStref where DST_Standardowy=99
create table #CzasPracy
(
  Typ smallint default 2,
  Data datetime,
  TypDnia int default 1,
  Nieobec int default null,
  TypNieob int default null,
  GodzOd datetime default CONVERT(datetime,'1899.12.30',102),
  GodzDo datetime default CONVERT(datetime,'1899.12.30',102),
  Strefa int,
  Dzial int default 1,
  Projekt int default 1,
  Zestaw tinyint,
  OdbNadg tinyint default 0,
  PracaRodzic smallint default 0
 )
declare @Baza datetime
 set @Baza = CONVERT(datetime,'1899.12.30',102)
if @DataOd is null or @DataDo is null
  return
 if @DataDo<@DataOd
  set @DataDo=@DataOd
 declare
  @GodzinaOd datetime,
  @GodzinaDo datetime,
  @GodzinaZero datetime
 set @GodzinaOd = convert(datetime, '1899-12-30 07:00:00.000', 120)
 set @GodzinaDo = convert(datetime, '1899-12-30 15:00:00.000', 120)
 set @GodzinaZero = convert(datetime, '1899-12-30 00:00:00.000', 120)
 declare
  @StrefaNiezdefiniowanaId int,
  @StrefaPodstawowaId int
 select @StrefaNiezdefiniowanaId = DST_DstId from CDN.DefinicjeStref where DST_Standardowy = 99
 select @StrefaPodstawowaId = DST_DstId from CDN.DefinicjeStref where DST_Standardowy = 1
 --wypełnianie tablicy domyślnymi wartościami
 declare
  @Zestaw tinyint,
  @Wymiar real,
  @GodzDo datetime,
  @Data datetime,
  @PRE_Data datetime
 set @PRE_Data = 0
 set @Wymiar = 1
 set @GodzDo = DATEADD(hour,15,CONVERT(datetime,'1899.12.30',102))
 set @Data = @DataOd
 while @Data <= @DataDo
 begin
  if @PRE_Data < @Data
  begin
 select @Wymiar= case when PRE_PRMPracaRodzic=0 then (CONVERT(real,PRE_ETAEtatL)/(case PRE_ETAEtatM when 0 then 1 else PRE_ETAEtatM end)) else (CONVERT(real,PRE_PRMEtatL)/(case PRE_PRMEtatM when 0 then 1 else PRE_PRMEtatM end)) end, @PRE_Data=PRE_DataDo from CDN.PracEtaty where PRE_PraId=@Id and @Data between PRE_DataOd and PRE_DataDo
 select @GodzDo = DATEADD(minute,CONVERT(int,CEILING((case KAL_NormaKalendarz when 0 then DATEDIFF(minute,CONVERT(datetime,'1899.12.30',102),KAL_NormaDobowa) else 480 end)*(case KAL_UwzglWymiarEtatu when 0 then 1 else @Wymiar end)))%1440,DATEADD(hour,7,CONVERT(datetime,'1899.12.30',102)))
    from CDN.Kalendarze
    where KAL_KalId = (select PRE_KalId from CDN.PracEtaty where PRE_PraId=@Id and @Data between PRE_DataOd and PRE_DataDo)
  end
  if not exists(select Data from #CzasPracy where Data = @Data)
  begin
   if (DATEPART(weekday,@Data)+@@DATEFIRST)%7 between 2 and 6
    insert into #CzasPracy (Data, GodzOd, GodzDo, Strefa)
     values (@Data, DATEADD(hour,7,CONVERT(datetime,'1899.12.30',102)), @GodzDo, @StrefaPodstawowaId)
   else
    insert into #CzasPracy (Data,TypDnia,Strefa)
     values (@Data, case (DATEPART(weekday,@Data)+@@DATEFIRST)%7 when 1 then 3 else 2 end, @StrefaNiezdefiniowanaId)
  end
   set @Data = DATEADD(day,1,@Data)
 end
 --usuwam dni, które istnieją w kalendarzu
 delete from #CzasPracy
  where
   exists (select * from cdn.KalendDni where Data = KAD_Data
   and KAD_KalId = (select PRE_KalId from CDN.PracEtaty where PRE_PraId=@Id and @Data between PRE_DataOd and PRE_DataDo))
 --dodaję dni istniejące w kalendarzu
 insert into #CzasPracy(Typ, Data, TypDnia, Nieobec,TypNieob,GodzOd, GodzDo, Strefa, Dzial, Projekt, Zestaw, OdbNadg)
  select 2, KAD_Data, KAD_TypDnia, null, null, KDG_OdGodziny,
   case
   when Kdg_DoGodziny = KDG_OdGodziny or (select KAL_UwzglWymiarEtatu*(PRE_ETAEtatL-PRE_ETAEtatM) from CDN.Kalendarze, CDN.PracEtaty where KAL_KalId = PRE_KalId and PRE_PraId = @Id and KAD_Data between PRE_DataOd and PRE_DataDo)=0
   then KDG_DoGodziny
   else DATEADD(minute,CONVERT(int,CEILING(((case when KDG_DoGodziny <= KDG_OdGodziny then 1440 else 0 end) + DATEDIFF(minute,KDG_OdGodziny,KDG_DoGodziny))*(select CONVERT(decimal,PRE_ETAEtatL)/(case PRE_ETAEtatM when 0 then 1 else PRE_ETAEtatM end)from CDN.PracEtaty where PRE_PraId = @Id and KAD_Data between PRE_DataOd and PRE_DataDo)))%1440,KDG_OdGodziny) end, KDG_Strefa, null, null, (select PRE_ZestCzasuPracy from CDN.PracEtaty where PRE_PraId=@Id and KAD_Data between PRE_DataOd and PRE_DataDo) as Zestaw, 1
   from cdn.KalendDni join cdn.KalendDniGodz on KAD_KadId = KDG_KadId
   where
    KAD_Data between @DataOd and @DataDo
    and KAD_Data not in (select Data from #CzasPracy)
    and KAD_KalID=(select PRE_KalId from CDN.PracEtaty where PRE_PraId=@Id and KAD_Data between PRE_DataOd and PRE_DataDo)
  --usuwam dni, które istnieją w planie pracy
  delete from #CzasPracy
   where exists (select * from cdn.PracPlanDni where PPL_PraId = @Id and Data = PPL_Data)
  --dodaję dni istniejące w planie pracy
  insert into #CzasPracy(Typ,Data, TypDnia ,GodzOd, GodzDo, Strefa, Dzial, Projekt)
   select 3, PPL_Data, PPL_TypDnia, PGL_OdGodziny, PGL_DoGodziny,
    --case when @Typ=1 or PGL_DoGodziny = PGL_OdGodziny or (select KAL_UwzglWymiarEtatu*(PRE_ETAEtatL-PRE_ETAEtatM) from CDN.Kalendarze, CDN.PracEtaty where KAL_KalId = PRE_KalId and PRE_PraId = @Id and PPL_Data between PRE_DataOd and PRE_DataDo)=0 then PGL_DoGodziny else DATEADD(minute,CONVERT(int,CEILING(((case when PGL_DoGodziny <= PGL_OdGodziny then 1440 else 0 end) + DATEDIFF(minute,PGL_OdGodziny,PGL_DoGodziny))*(select CONVERT(decimal,PRE_ETAEtatL)/(case PRE_ETAEtatM when 0 then 1 else PRE_ETAEtatM end) from CDN.PracEtaty where PRE_PraId = @Id and PPL_Data between PRE_DataOd and PRE_DataDo)))%1440,PGL_OdGodziny) end,
    PGL_Strefa, PGL_DzlId, PGL_PrjId
    from cdn.PracPlanDni join cdn.PracPlanDniGodz on PPL_PplId = PGL_PplId
    where PPL_Data between @DataOd and @DataDo
     and PPL_Data not in (select Data from #CzasPracy)
     and PPL_PraId = @Id
  --usuwam dni, które istnieją w czasie pracy
  delete from #CzasPracy
   where exists (select * from cdn.PracPracaDni where PPR_PraId = @Id and Data = PPR_Data)
  set @MaByc = DATEDIFF(day,@DataOd,@DataDo)+1
  declare @GodzOd_N datetime
  declare @GodzDo_N datetime
  declare @roznica INT
  declare @godzinyNb INT
  declare @intTemp INT
  declare @strefa NVARCHAR(50)
  declare @datemin datetime
  set @datemin = CONVERT(datetime,'1899.12.30',102)
  set @Data = @DataOd
  while @Data<=@DataDo
  begin
   select @GodzOd_N = GodzOd, @GodzDo_N = GodzDo, @strefa = Strefa from #CzasPracy where Data = @Data
   --17-Pomnniejszamy plan pracy o niebecnosci cześciowe
   select @godzinyNb = SUM(DATEDIFF(minute, @datemin,PNB_Godz)) from  CDN.PracNieobec where PNB_PraId=@Id and pnb_pracarodzic <> 1 and @Data between PNB_OkresOd and PNB_OkresDo and Pnb_Tryb<>1 and PnB_Calodzienna = 0
   set @intTemp = @godzinyNb
   if  @strefa<>'undefined' and @godzinyNb <> 0 and exists (select 1 from CDN.DefinicjeStref where DST_DstId = @strefa and DST_UwzglCzasPracy = 1)
   begin
    if @GodzDo_N  >= @GodzOd_N
     set @roznica = DATEDIFF(minute, @GodzOd_N,@GodzDo_N)
    else
     set @roznica = (DATEDIFF(minute, @GodzOd_N,@GodzDo_N) + 1440)%1440
    if @godzinyNb > @roznica
    begin
     set @GodzOd_N = @datemin
     set @GodzDo_N = @datemin
     set @godzinyNb = @godzinyNb - @roznica
    end
    else
    begin
     set @GodzDo_N = DATEADD(minute,@roznica - @godzinyNb ,@GodzOd_N)
     set @GodzDo_N = DATEADD(minute,DATEPART(minute,@GodzDo_N)+ 60*DATEPART(hour,@GodzDo_N),CONVERT(datetime,'1899.12.30',102))
     set @godzinyNb = 0
    end
    update #CzasPracy
     set GodzOd = @GodzOd_N, GodzDo = @GodzDo_N
     where Data = @Data
   end
   set @Data = DATEADD(day,1,@Data)
   end
  select @Zestaw=PRE_ZestCzasuPracy, @Wymiar=CONVERT(float,PRE_ETAEtatL)/(case PRE_ETAEtatM when 0 then 1 else PRE_ETAEtatM end), @PRE_Data=PRE_DataDo from CDN.PracEtaty where PRE_PraId=@Id and @DataDo between PRE_DataOd and PRE_DataDo
--select PRE_ZestCzasuPracy from CDN.PracEtaty where PRE_PraId=@Id and @Data between PRE_DataOd and PRE_DataDo
  insert into #CzasPracy(Typ,Data, Nieobec,TypNieob,GodzOd, GodzDo, Strefa, Dzial, Projekt, Zestaw)
   select 4, PPR_Data, null, null, PGR_OdGodziny, PGR_DoGodziny, PGR_Strefa, PGR_DzlId, PGR_PrjId, @Zestaw
    from cdn.PracPracaDni join cdn.pracpracadnigodz on PPR_PprId = PGR_PprId and PPR_PraId = @Id
    where PPR_Data between @DataOd and @DataDo
  update #CzasPracy
   set Typ=5, Nieobec=PNB_PnbId, TypNieob=PNB_TnbId, PracaRodzic = PNB_PracaRodzic
    from #CzasPracy join CDN.PracNieobec on PNB_PraId=@Id and pnb_pracarodzic <> 1 and Data between PNB_OkresOd and PNB_OkresDo and PNB_Tryb<>1 and PNB_Calodzienna = 1
  insert into #CzasPracy(Data,Typ,Nieobec,TypNieob, PracaRodzic)
   select Data,5,PNB_PnbId,PNB_TnbId, PNB_PracaRodzic
    from #CzasPracy join CDN.PracNieobec on PNB_PraId=@Id and pnb_pracarodzic <> 1 and Data between PNB_OkresOd and PNB_OkresDo and PNB_Tryb<>1 and PNB_Calodzienna = 0
--select * from #CzasPracy order by Data
  --usunięcie dni z nieobecnościami pomniejszającymi czas pracy -> mają nie wchodzić do opisu analit.
  delete from #CzasPracy where Typ = 5 and 1 = (select TNB_PomnCzasPracy from cdn.TypNieobec where TNB_TnbId = TypNieob)
   and PracaRodzic <> 1
   /*and (PracaRodzic <> 1 and
     ((433 = (select TNB_Standardowy from cdn.TypNieobec where TNB_TnbId = TypNieob)) or
     (435 = (select TNB_Standardowy from cdn.TypNieobec where TNB_TnbId = TypNieob)) or
     (218 = (select TNB_Standardowy from cdn.TypNieobec where TNB_TnbId = TypNieob)))
     )*/
 --update #CzasPracy set TypDnia = PPL_TypDnia,GodzOd=PGL_OdGodziny,GodzDo=PGL_DoGodziny, Strefa=PGL_Strefa, Dzial = PGL_DzlId, Projekt = PGL_PrjId from cdn.PracPlanDni join cdn.PracPlanDniGodz on PPL_PplId = PGL_PplId where PPL_PraId=@Id and PPL_Data = Data and Typ <> 5
 --wg zestawienia
if @Zestaw = 2
--    if exists(select Data from #CzasPracy where Zestaw=2)
      --select Typ, Data, TypDnia, GodzOd, GodzDo, Strefa, Dzial, Projekt, Nieobec, TypNieob, (select TNB_PomnCzasPracy from CDN.TypNieobec where TNB_TnbId=TypNieob) as Pomniejszac, OdbNadg from #CzasPracy where 3<3 or Zestaw<2 order by Data
   -- else if 3=3
      select PZD_Ilosc, PZD_Czas, PZD_CzasNoc, PZD_CzasWolne, PZD_CzasSW, PZD_Nadgodziny50, PZD_Nadgodziny100, PZD_NadgodzinySW, PZD_DstId, PZD_DzlId, PZD_PrjId,  PZE_OkresOd as Data from CDN.PracZestawElem, CDN.PracZestaw where PZD_PzeId=PZE_PzeId and PZE_PraId=@Id and PZE_Tryb<>1 and @DataOd<=PZE_OkresDo and PZE_OkresOd<=@DataDo
 else      --wg kalendarza
  select * from #CzasPracy order by Data
      /*select
 (select count(*) from #CzasPracy where Norma>0) as NormaDni,
 ISNULL((select sum(Norma) from #CzasPracy where Norma>0),0) as NormaGodz,
 ISNULL((select sum(PZE_Ilosc) from CDN.PracZestaw where PZE_PraId=@Id and PZE_Tryb<>1 and @DataOd<=PZE_OkresDo and PZE_OkresOd<=@DataDo),0)+
 ISNULL((select count(*) from #CzasPracy where Praca>0),0) as PracaDni,
 ISNULL((select sum(DATEDIFF(minute,@Baza,PZE_Czas)) from CDN.PracZestaw where PZE_PraId=@Id and PZE_Tryb<>1 and @DataOd<=PZE_OkresDo and PZE_OkresOd<=@DataDo),0)+
 ISNULL((select sum(Praca) from #CzasPracy where Praca>0),0) as Pracagodz*/
drop table #CzasPracy
