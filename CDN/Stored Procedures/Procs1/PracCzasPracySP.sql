create PROCEDURE CDN.PracCzasPracySP @Typ smallint, @Id int, @DataOd datetime, @DataDo datetime, @OptimaMode TINYINT = 0
-- 1 = kalendarz, 2 = plan pracy, 3 = czas pracy lub zestawienie, 4 = czas pracy i zestawienie, 5 = podsumowanie
AS
SET NOCOUNT ON
if @DataOd is null set @DataOd=GETDATE()
if @DataDo is null or @DataDo<@DataOd set @DataDo=@DataOd
declare @MaByc int
declare @Jest int
declare @pusty bit
set @MaByc = DATEDIFF(day,@DataOd,@DataDo)+1
set @pusty = 0
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
Norma int default 0,
Praca int default 0,
Zestaw tinyint,
OdbNadg tinyint default 0
)
if @Typ=1 or @Typ=3
set @Jest = 0
else
begin
insert into #CzasPracy
select 3, PPL_Data, PPL_TypDnia, null, null, PGL_OdGodziny, PGL_DoGodziny, PGL_Strefa, PGL_DzlId, PGL_PrjId, 0, 0,
(
select PRE_ZestCzasuPracy
from CDN.PracEtaty
where PRE_PraId=@Id and PPL_Data between PRE_DataOd and PRE_DataDo
) as ZestCzasuPracy,
1
from cdn.PracPlanDni inner join cdn.PracPlanDniGodz on PPL_PplId = PGL_PplId
where PPL_PraId=@Id and PPL_Data between @DataOd and @DataDo
select @Jest = count(*) from #CzasPracy
end
if @Jest < @MaByc
begin
insert into #CzasPracy
select 2, KAD_Data, KAD_TypDnia, null, null, KDG_OdGodziny,
case when @Typ=1 or KDG_DoGodziny = KDG_OdGodziny or (select KAL_UwzglWymiarEtatu*(PRE_ETAEtatL-PRE_ETAEtatM) from CDN.Kalendarze, CDN.PracEtaty where KAL_KalId=PRE_KalId and PRE_PraId=@Id and KAD_Data between PRE_DataOd and PRE_DataDo) = 0 then KDG_DoGodziny else
DATEADD(minute,CONVERT(int,CEILING(((case when KDG_DoGodziny <= KDG_OdGodziny then 1440 else 0 end)+DATEDIFF(minute,KDG_OdGodziny,KDG_DoGodziny))*(select CONVERT(float,PRE_ETAEtatL)/(case PRE_ETAEtatM when 0 then 1 else PRE_ETAEtatM end) from CDN.PracEtaty where PRE_PraId=@Id and KAD_Data between PRE_DataOd and PRE_DataDo)))%1440,KDG_OdGodziny)
end,
KDG_Strefa, null, null, 0, 0,
case @Typ when 1 then 0 else (select PRE_ZestCzasuPracy from CDN.PracEtaty where PRE_PraId=@Id and KAD_Data between PRE_DataOd and PRE_DataDo)
end as Zestaw, 1
from CDN.KalendDni inner join cdn.KalendDniGodz on KAD_KadId = KDG_KadId
where KAD_Data between @DataOd and @DataDo
and KAD_Data not in (select Data from #CzasPracy)
and KAD_KalID=(case @Typ when 1 then @Id else (select PRE_KalId from CDN.PracEtaty where PRE_PraId=@Id and KAD_Data between PRE_DataOd and PRE_DataDo) end)
select @Jest = count(*) from #CzasPracy
if @Jest<@MaByc
begin
set DATEFIRST 7
declare @Zestaw tinyint
declare @Wymiar float
declare @GodzDo datetime
declare @Data datetime
declare @PRE_Data datetime
declare @PodstId int
select @PodstId=DST_DstId from CDN.DefinicjeStref where DST_Standardowy=1
set @PRE_Data = 0
set @Zestaw = 0
set @Wymiar = 1
set @GodzDo = DATEADD(hour,15,CONVERT(datetime,'1899.12.30',102))
if @Typ=1
select @GodzDo = case KAL_NormaKalendarz when 0 then DATEADD(hour,7,KAL_NormaDobowa) else @GodzDo end from CDN.Kalendarze where KAL_KalId=@Id
set @Data = @DataOd
while @Data<=@DataDo
begin
if @Typ>1 and @PRE_Data<@Data
begin
select @Zestaw=PRE_ZestCzasuPracy, @Wymiar=CONVERT(float,PRE_ETAEtatL)/(case PRE_ETAEtatM when 0 then 1 else PRE_ETAEtatM end), @PRE_Data=PRE_DataDo from CDN.PracEtaty where PRE_PraId=@Id and @Data between PRE_DataOd and PRE_DataDo
select @GodzDo = DATEADD(minute,CONVERT(int,CEILING((case KAL_NormaKalendarz when 0 then DATEDIFF(minute,CONVERT(datetime,'1899.12.30',102),KAL_NormaDobowa) else 480 end)*(case KAL_UwzglWymiarEtatu when 0 then 1 else @Wymiar end)))%1440,DATEADD(hour,7,CONVERT(datetime,'1899.12.30',102)))
from CDN.Kalendarze
where KAL_KalId=(select PRE_KalId from CDN.PracEtaty where PRE_PraId=@Id and @Data between PRE_DataOd and PRE_DataDo)
end
if not exists(select Data from #CzasPracy where Data=@Data)
begin
if DATEPART(weekday,@Data) between 2 and 6
insert into #CzasPracy (Data,GodzOd,GodzDo,Strefa,Zestaw)
values (@Data,DATEADD(hour,7,CONVERT(datetime,'1899.12.30',102)),@GodzDo,@PodstId,@Zestaw)
else
insert into #CzasPracy (Data,TypDnia,Strefa,Zestaw)
values (@Data,case DATEPART(weekday,@Data) when 1 then 3 else 2 end,@UndefId,@Zestaw)
end
set @Data = DATEADD(day,1,@Data)
end
end
end
if @Typ=3
begin
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
select
@GodzOd_N = GodzOd, @GodzDo_N = GodzDo,
@strefa = Strefa
from #CzasPracy where Data = @Data
--17-Pomnniejszamy plan pracy o niebecnosci czeciowe
select @godzinyNb = SUM(DATEDIFF(minute, @datemin,PNB_Godz)) from CDN.PracNieobec where PNB_PraId=@Id and @Data between PNB_OkresOd and PNB_OkresDo and Pnb_Tryb<>1 and PnB_Calodzienna = 0
set @intTemp = @godzinyNb
IF @strefa<>'undefined' and @godzinyNb <> 0 and exists (select 1 from CDN.DefinicjeStref where DST_DstId = @strefa and DST_UwzglCzasPracy = 1)
BEGIN
set @roznica = DATEDIFF(minute, @GodzOd_N,@GodzDo_N)
IF @godzinyNb > @roznica
BEGIN
set @GodzOd_N = @datemin
set @GodzDo_N = @datemin
set @godzinyNb = @godzinyNb - @roznica
END
ELSE
BEGIN
set @GodzDo_N = DATEADD(minute,@roznica - @godzinyNb ,@GodzOd_N)
set @godzinyNb = 0
END
END
update #CzasPracy set
Typ = 4,
GodzOd = @GodzOd_N, GodzDo = @GodzDo_N
where Data = @Data and @intTemp <> 0
set @Data = DATEADD(day,1,@Data)
end
update #CzasPracy
set Typ=4,
GodzOd=PGR_OdGodziny, GodzDo=PGR_DoGodziny, Strefa=PGR_Strefa, Dzial=PGR_DzlId, Projekt=PGR_PrjId, OdbNadg = PGR_OdbNadg
from #CzasPracy join CDN.PracPracaDni on PPR_PraId=@Id and PPR_Data=Data join cdn.PracPracaDniGodz on PGR_PprId = PPR_PprId
update #CzasPracy
set Typ=5, Nieobec=PNB_PnbId, TypNieob=PNB_TnbId
from #CzasPracy join CDN.PracNieobec on PNB_PraId=@Id and Data between PNB_OkresOd and PNB_OkresDo and PNB_Tryb<>1 and PNB_Calodzienna = 1
end
SET NOCOUNT OFF
if @Typ<4
begin
if exists(select Data from #CzasPracy where (@Typ<3 or Zestaw<2))
select Typ, Data, TypDnia,
GodzOd, GodzDo, Strefa, Dzial, Projekt,
Nieobec, TypNieob,
(select TNB_PomnCzasPracy from CDN.TypNieobec where TNB_TnbId=TypNieob) as Pomniejszac, OdbNadg
from #CzasPracy where @Typ<3 or Zestaw<2 order by Data
else if @Typ=3
select PZD_Ilosc, PZD_Czas, PZD_CzasNoc, PZD_CzasWolne, PZD_CzasSW, PZD_Nadgodziny50, PZD_Nadgodziny100, PZD_NadgodzinySW, PZD_DstId, PZD_DzlId, PZD_PrjId, PZE_OkresOd as Data
from CDN.PracZestawElem, CDN.PracZestaw where PZD_PzeId=PZE_PzeId and PZE_PraId=@Id and PZE_Tryb<>1
and @DataOd<=PZE_OkresDo and PZE_OkresOd<=@DataDo
end
else
begin
declare @Baza datetime
set @Baza = CONVERT(datetime,'1899.12.30',102)
delete from #CzasPracy where not exists(select PRE_PreId from CDN.PracEtaty where PRE_PraId=@Id and Data between PRE_DataOd and PRE_DataDo and PRE_ZatrudnionyOd<>@Baza and PRE_ZatrudnionyOd<=Data and (PRE_ZatrudnionyDo=@Baza or Data<=PRE_ZatrudnionyDo))
update #CzasPracy set Norma
= (case when (select DST_UwzglCzasPracy from CDN.DefinicjeStref where DST_DstId=Strefa)>0 then DATEDIFF(minute,GodzOd,GodzDo)+(case when GodzOd>=GodzDo then 1440 else 0 end) else 0 end)
if @Typ=4
begin
create table #Okresy (DataOd datetime, DataDo datetime, PzeId int, Dni int, Godz int)
insert into #Okresy
select top 1
case when PRE_DataOd<@DataOd and PRE_ZatrudnionyOd<@DataOd then @DataOd when PRE_ZatrudnionyOd<PRE_DataOd then PRE_DataOd else PRE_ZatrudnionyOd end as DataOd,
(select top 1 case when PRE_DataDo>@DataDo and (PRE_ZatrudnionyDo=@Baza or PRE_ZatrudnionyDo>@DataDo) then @DataDo when PRE_ZatrudnionyDo=@Baza or PRE_ZatrudnionyDo>PRE_DataDo then PRE_DataDo else PRE_ZatrudnionyDo end from CDN.PracEtaty where PRE_PraId=@Id and @DataOd<=PRE_DataDo and PRE_DataOd<=@DataDo and PRE_ZestCzasuPracy<>2 and PRE_ZatrudnionyOd<>@Baza and PRE_ZatrudnionyOd<=@DataDo and (PRE_ZatrudnionyDo=@Baza or @DataOd<=PRE_ZatrudnionyDo) order by PRE_DataOd desc) as DataDo,
null as PzeId,
0,
0
from CDN.PracEtaty
where PRE_PraId=@Id and @DataOd<=PRE_DataDo and PRE_DataOd<=@DataDo and PRE_ZestCzasuPracy<>2 and PRE_ZatrudnionyOd<>@Baza and PRE_ZatrudnionyOd<=@DataDo and (PRE_ZatrudnionyDo=@Baza or @DataOd<=PRE_ZatrudnionyDo)
order by PRE_DataOd
insert into #Okresy
select
case
when Zestaw.PZE_PzeId is null
then case when PRE_DataOd<@DataOd and PRE_ZatrudnionyOd<@DataOd then @DataOd when PRE_ZatrudnionyOd<PRE_DataOd then PRE_DataOd else PRE_ZatrudnionyOd end
when exists(select top 1 PZE_PzeId from CDN.PracZestaw where PZE_PraId=@Id and PZE_Tryb<>1 and PRE_DataOd<=PZE_OkresOd and PZE_OkresDo<=PRE_DataDo and @DataOd<=PZE_OkresDo and PZE_OkresOd<=@DataDo and PZE_OkresDo<Zestaw.PZE_OkresOd order by PZE_OkresOd desc)
then (select top 1 DATEADD(day,1,PZE_OkresDo) from CDN.PracZestaw where PZE_PraId=@Id and PZE_Tryb<>1 and PRE_DataOd<=PZE_OkresOd and PZE_OkresDo<=PRE_DataDo and @DataOd<=PZE_OkresDo and PZE_OkresOd<=@DataDo and PZE_OkresDo<Zestaw.PZE_OkresOd order by PZE_OkresOd desc)
when PRE_DataOd<@DataOd and PRE_ZatrudnionyOd<@DataOd
then @DataOd
when PRE_ZatrudnionyOd<PRE_DataOd
then PRE_DataOd
else
PRE_ZatrudnionyOd
end as DataOd,
case
when Zestaw.PZE_PzeId is null
then case when PRE_DataDo>@DataDo and (PRE_ZatrudnionyDo=@Baza or PRE_ZatrudnionyDo>@DataDo) then @DataDo when PRE_ZatrudnionyDo=@Baza or PRE_ZatrudnionyDo>PRE_DataDo then PRE_DataDo else PRE_ZatrudnionyDo end
when exists(select top 1 PZE_PzeId from CDN.PracZestaw where PZE_PraId=@Id and PZE_Tryb<>1 and PRE_DataOd<=PZE_OkresOd and PZE_OkresDo<=PRE_DataDo and @DataOd<=PZE_OkresDo and PZE_OkresOd<=@DataDo and PZE_OkresOd>Zestaw.PZE_OkresDo order by PZE_OkresOd asc)
then PZE_OkresDo
when PRE_DataDo>@DataDo and (PRE_ZatrudnionyDo=@Baza or PRE_ZatrudnionyDo>@DataDo)
then @DataDo
when PRE_ZatrudnionyDo=@Baza or PRE_ZatrudnionyDo>PRE_DataDo
then PRE_DataDo
else
PRE_ZatrudnionyDo
end as DataDo,
ISNULL(Zestaw.PZE_PzeId,0) as PzeId,
0,
0
from CDN.PracEtaty left outer join CDN.PracZestaw as Zestaw on Zestaw.PZE_PraId=@Id and PZE_Tryb<>1
and PRE_DataOd<=Zestaw.PZE_OkresOd and Zestaw.PZE_OkresDo<=PRE_DataDo and @DataOd<=Zestaw.PZE_OkresDo and Zestaw.PZE_OkresOd<=@DataDo
where PRE_PraId=@Id and @DataOd<=PRE_DataDo and PRE_DataOd<=@DataDo and PRE_ZestCzasuPracy=2 and PRE_ZatrudnionyOd<>@Baza and PRE_ZatrudnionyOd<=@DataDo and (PRE_ZatrudnionyDo=@Baza or @DataOd<=PRE_ZatrudnionyDo)
update #Okresy set
Dni = (select count(*) from #CzasPracy where Data between DataOd and DataDo and Norma>0 and (PzeId is not null or Zestaw<2)),
Godz = (select sum(Norma) from #CzasPracy where Data between DataOd and DataDo and Norma>0 and (PzeId is not null or Zestaw<2))
select CONVERT(NVARCHAR(10),DataOd,120) as DataOd, CONVERT(NVARCHAR(10),DataDo,120) as DataDo, DATEDIFF(day,DataOd,DataDo)+1 as Liczba, PzeId, Dni, Godz from #Okresy
drop table #Okresy
end
if exists(select PRE_PreId from CDN.PracEtaty where PRE_PraId=@Id and PRE_DataOd<=@DataDo and PRE_DataDo>=@DataOd and PRE_ZestCzasuPracy<>2 and PRE_ZatrudnionyOd<>@Baza and PRE_ZatrudnionyOd<=@DataDo and (PRE_ZatrudnionyDo=@Baza or @DataOd<=PRE_ZatrudnionyDo))
begin
update #CzasPracy
set Typ=5, Nieobec=PNB_PnbId, TypNieob=PNB_TnbId
from #CzasPracy join CDN.PracNieobec on PNB_PraId=@Id and Data between PNB_OkresOd and PNB_OkresDo and PNB_Tryb<>1
if @Typ=4
begin
IF @OptimaMode = 1
BEGIN
--PG: ZMIENIAJC PONISZE SELECT-y NALEY KONIECZNIE ZMIENI JE TAKE W SEKCJI ELSE TEGO IF-a
-- (2 miejsca w deklaracji kursora: DECLARE c CURSOR LOCAL FORWARD_ONLY FOR...).
-- Inaczej zmiany nie zobaczy IAP.
select
CONVERT(NVARCHAR(10),Data,120) as Data, DATEDIFF(minute,@Baza,GodzOd) as GodzOd, DATEDIFF(minute,@Baza,GodzDo) as GodzDo,
Strefa, IsNull(Dzial, 0), IsNull(Projekt, 0),
TypDnia, Zestaw, Nieobec,
(select TNB_PomnCzasPracy from CDN.TypNieobec where TNB_TnbId=TypNieob) as Pomniejszac,
OdbNadg
from #CzasPracy where Zestaw<2 order by #CzasPracy.Data
select
CONVERT(NVARCHAR(10),PPR_Data,120) as Data, DATEDIFF(minute,@Baza,PGR_OdGodziny) as GodzOd, DATEDIFF(minute,@Baza,PGR_DoGodziny) as GodzDo, PGR_Strefa as Strefa, PGR_DzlId as Dzial, PGR_PrjId as Projekt
from CDN.PracPracaDni join cdn.PracPracaDniGodz on PGR_PprId = PPR_PprId
where PPR_PraId=@Id and PPR_Data in (select Data from #CzasPracy where Zestaw<2)
END
ELSE
BEGIN
CREATE TABLE #CzasPracy16
(
Data NVARCHAR(10),
GodzOd_1 INT,
GodzDo_1 INT,
Strefa_1 INT,
Dzial_1 INT,
Projekt_1 INT,
GodzOd_2 INT,
GodzDo_2 INT,
Strefa_2 INT,
Dzial_2 INT,
Projekt_2 INT,
GodzOd_3 INT,
GodzDo_3 INT,
Strefa_3 INT,
Dzial_3 INT,
Projekt_3 INT,
GodzOd_4 INT,
GodzDo_4 INT,
Strefa_4 INT,
Dzial_4 INT,
Projekt_4 INT,
GodzOd_5 INT,
GodzDo_5 INT,
Strefa_5 INT,
Dzial_5 INT,
Projekt_5 INT,
GodzOd_6 INT,
GodzDo_6 INT,
Strefa_6 INT,
Dzial_6 INT,
Projekt_6 INT,
TypDnia INT,
Zestaw INT,
Nieobec INT,
Pomniejszac INT,
OdbNadg_1 INT,
OdbNadg_2 INT,
OdbNadg_3 INT,
OdbNadg_4 INT,
OdbNadg_5 INT,
OdbNadg_6 INT
)
DECLARE @d NVARCHAR(10), @lastD NVARCHAR(10), @lastDSaved NVARCHAR(10)
DECLARE @g1 INT, @g11 INT, @g21 INT, @g31 INT, @g41 INT, @g51 INT, @g61 INT
DECLARE @g2 INT, @g12 INT, @g22 INT, @g32 INT, @g42 INT, @g52 INT, @g62 INT
DECLARE @str INT, @str1 INT, @str2 INT, @str3 INT, @str4 INT, @str5 INT, @str6 INT
DECLARE @dz INT, @dz1 INT, @dz2 INT, @dz3 INT, @dz4 INT, @dz5 INT, @dz6 INT
DECLARE @prj INT, @prj1 INT, @prj2 INT, @prj3 INT, @prj4 INT, @prj5 INT, @prj6 INT
DECLARE @TypDnia INT, @lastTypDnia INT
DECLARE @Zest INT, @lastZest INT
DECLARE @Nieobec INT, @lastNieobec INT
DECLARE @Pomniejszac INT, @lastPomniejszac INT
DECLARE @on INT, @on1 INT, @on2 INT, @on3 INT, @on4 INT, @on5 INT, @on6 INT
DECLARE @lp INT
SET @g11 = 0; SET @g12 = 0; SET @str1 = 1; SET @dz1 = 1; SET @prj1 = 1
SET @g21 = 0; SET @g22 = 0; SET @str2 = 1; SET @dz2 = 1; SET @prj2 = 1
SET @g31 = 0; SET @g32 = 0; SET @str3 = 1; SET @dz3 = 1; SET @prj3 = 1
SET @g41 = 0; SET @g42 = 0; SET @str4 = 1; SET @dz4 = 1; SET @prj4 = 1
SET @g51 = 0; SET @g52 = 0; SET @str5 = 1; SET @dz5 = 1; SET @prj5 = 1
SET @g61 = 0; SET @g62 = 0; SET @str6 = 1; SET @dz6 = 1; SET @prj6 = 1
SET @on1 = 0; SET @on2 = 0; SET @on3 = 0; SET @on4 = 0; SET @on5 = 0; SET @on6 = 0
DECLARE c CURSOR LOCAL FORWARD_ONLY FOR
select
CONVERT(NVARCHAR(10),Data,120) as Data, DATEDIFF(minute,@Baza,GodzOd) as GodzOd, DATEDIFF(minute,@Baza,GodzDo) as GodzDo,
Strefa, IsNull(Dzial, 0), IsNull(Projekt, 0),
TypDnia, Zestaw, Nieobec,
(select TNB_PomnCzasPracy from CDN.TypNieobec where TNB_TnbId=TypNieob) as Pomniejszac,
OdbNadg
from #CzasPracy where Zestaw<2 order by #CzasPracy.Data
OPEN c
FETCH NEXT FROM c INTO @d, @g1, @g2, @str, @dz, @prj, @typDnia, @zest, @nieobec, @pomniejszac, @on
SET @lastD = @d
SET @lastTypDnia = @TypDnia
SET @lastZest = @Zest
SET @lastNieobec = @Nieobec
SET @lastPomniejszac = @Pomniejszac
SET @Lp = 1
WHILE @@FETCH_STATUS = 0
BEGIN
IF @Lp = 1
BEGIN
SET @g11 = @g1; SET @g12 = @g2; SET @str1 = @str; SET @dz1 = @dz; SET @prj1 = @prj; SET @on1 = @on
END
IF @Lp = 2
BEGIN
SET @g21 = @g1; SET @g22 = @g2; SET @str2 = @str; SET @dz2 = @dz; SET @prj2 = @prj; SET @on2 = @on
END
IF @Lp = 3
BEGIN
SET @g31 = @g1; SET @g32 = @g2; SET @str3 = @str; SET @dz3 = @dz; SET @prj3 = @prj; SET @on3 = @on
END
IF @Lp = 4
BEGIN
SET @g41 = @g1; SET @g42 = @g2; SET @str4 = @str; SET @dz4 = @dz; SET @prj4 = @prj; SET @on4 = @on
END
IF @Lp = 5
BEGIN
SET @g51 = @g1; SET @g52 = @g2; SET @str5 = @str; SET @dz5 = @dz; SET @prj5 = @prj; SET @on5 = @on
END
IF @Lp = 6
BEGIN
SET @g61 = @g1; SET @g62 = @g2; SET @str6 = @str; SET @dz6 = @dz; SET @prj6 = @prj; SET @on6 = @on
END
FETCH NEXT FROM c INTO @d, @g1, @g2, @str, @dz, @prj, @typDnia, @zest, @nieobec, @pomniejszac, @on
IF @d <> @lastD
BEGIN
INSERT INTO #CzasPracy16 VALUES(@lastD,
@g11, @g12, @str1, @dz1, @prj1, @g21, @g22, @str2, @dz2, @prj2, @g31, @g32, @str3, @dz3, @prj3,
@g41, @g42, @str4, @dz4, @prj4, @g51, @g52, @str5, @dz5, @prj5, @g61, @g62, @str6, @dz6, @prj6,
@lastTypDnia, @lastZest, @lastNieobec, @lastPomniejszac,
@on1, @on2, @on3, @on4, @on5, @on6)
SET @lastDSaved = @lastD
SET @Lp = 1
SET @lastD = @d; SET @lastTypDnia = @TypDnia; SET @lastZest = @Zest; SET @lastNieobec = @Nieobec; SET @lastPomniejszac = @Pomniejszac
SET @g11 = 0; SET @g12 = 0; SET @str1 = 1; SET @dz1 = 1; SET @prj1 = 1
SET @g21 = 0; SET @g22 = 0; SET @str2 = 1; SET @dz2 = 1; SET @prj2 = 1
SET @g31 = 0; SET @g32 = 0; SET @str3 = 1; SET @dz3 = 1; SET @prj3 = 1
SET @g41 = 0; SET @g42 = 0; SET @str4 = 1; SET @dz4 = 1; SET @prj4 = 1
SET @g51 = 0; SET @g52 = 0; SET @str5 = 1; SET @dz5 = 1; SET @prj5 = 1
SET @g61 = 0; SET @g62 = 0; SET @str6 = 1; SET @dz6 = 1; SET @prj6 = 1
SET @on1 = 0; SET @on2 = 0; SET @on3 = 0; SET @on4 = 0; SET @on5 = 0; SET @on6 = 0
END
ELSE
SET @Lp = @Lp + 1
END
ClOSE c
DEALLOCATE c
IF @lastD<>@lastDSaved
BEGIN
INSERT INTO #CzasPracy16 VALUES(@lastD,
@g11, @g12, @str1, @dz1, @prj1, @g21, @g22, @str2, @dz2, @prj2, @g31, @g32, @str3, @dz3, @prj3,
@g41, @g42, @str4, @dz4, @prj4, @g51, @g52, @str5, @dz5, @prj5, @g61, @g62, @str6, @dz6, @prj6,
@lastTypDnia, @lastZest, @lastNieobec, @lastPomniejszac,
@on1, @on2, @on3, @on4, @on5, @on6)
END
SELECT * FROM #CzasPracy16
DELETE #CzasPracy16
SET @g11 = 0; SET @g12 = 0; SET @str1 = 1; SET @dz1 = 1; SET @prj1 = 1
SET @g21 = 0; SET @g22 = 0; SET @str2 = 1; SET @dz2 = 1; SET @prj2 = 1
SET @g31 = 0; SET @g32 = 0; SET @str3 = 1; SET @dz3 = 1; SET @prj3 = 1
SET @g41 = 0; SET @g42 = 0; SET @str4 = 1; SET @dz4 = 1; SET @prj4 = 1
SET @g51 = 0; SET @g52 = 0; SET @str5 = 1; SET @dz5 = 1; SET @prj5 = 1
SET @g61 = 0; SET @g62 = 0; SET @str6 = 1; SET @dz6 = 1; SET @prj6 = 1
if not exists (select
CONVERT(NVARCHAR(10),PPR_Data,120) as Data, DATEDIFF(minute,@Baza,PGR_OdGodziny) as GodzOd, DATEDIFF(minute,@Baza,PGR_DoGodziny) as GodzDo, PGR_Strefa as Strefa, PGR_DzlId as Dzial, PGR_PrjId as Projekt
from CDN.PracPracaDni join cdn.PracPracaDniGodz on PGR_PprId = PPR_PprId
where PPR_PraId=@Id and PPR_Data in (select Data from #CzasPracy where Zestaw<2)
)
set @pusty = 1
DECLARE c CURSOR LOCAL FORWARD_ONLY FOR
select
CONVERT(NVARCHAR(10),PPR_Data,120) as Data, DATEDIFF(minute,@Baza,PGR_OdGodziny) as GodzOd, DATEDIFF(minute,@Baza,PGR_DoGodziny) as GodzDo, PGR_Strefa as Strefa, PGR_DzlId as Dzial, PGR_PrjId as Projekt
from CDN.PracPracaDni join cdn.PracPracaDniGodz on PGR_PprId = PPR_PprId
where PPR_PraId=@Id and PPR_Data in (select Data from #CzasPracy where Zestaw<2)
OPEN c
FETCH NEXT FROM c INTO @d, @g1, @g2, @str, @dz, @prj
SET @lastD = @d
SET @Lp = 1
WHILE @@FETCH_STATUS = 0
BEGIN
IF @Lp = 1
BEGIN
SET @g11 = @g1; SET @g12 = @g2; SET @str1 = @str; SET @dz1 = @dz; SET @prj1 = @prj
END
IF @Lp = 2
BEGIN
SET @g21 = @g1; SET @g22 = @g2; SET @str2 = @str; SET @dz2 = @dz; SET @prj2 = @prj
END
IF @Lp = 3
BEGIN
SET @g31 = @g1; SET @g32 = @g2; SET @str3 = @str; SET @dz3 = @dz; SET @prj3 = @prj
END
IF @Lp = 4
BEGIN
SET @g41 = @g1; SET @g42 = @g2; SET @str4 = @str; SET @dz4 = @dz; SET @prj4 = @prj
END
IF @Lp = 5
BEGIN
SET @g51 = @g1; SET @g52 = @g2; SET @str5 = @str; SET @dz5 = @dz; SET @prj5 = @prj
END
IF @Lp = 6
BEGIN
SET @g61 = @g1; SET @g62 = @g2; SET @str6 = @str; SET @dz6 = @dz; SET @prj6 = @prj
END
FETCH NEXT FROM c INTO @d, @g1, @g2, @str, @dz, @prj
IF @d <> @lastD
BEGIN
INSERT INTO #CzasPracy16
(
Data,
GodzOd_1, GodzDo_1, Strefa_1, Dzial_1, Projekt_1,
GodzOd_2, GodzDo_2, Strefa_2, Dzial_2, Projekt_2,
GodzOd_3, GodzDo_3, Strefa_3, Dzial_3, Projekt_3,
GodzOd_4, GodzDo_4, Strefa_4, Dzial_4, Projekt_4,
GodzOd_5, GodzDo_5, Strefa_5, Dzial_5, Projekt_5,
GodzOd_6, GodzDo_6, Strefa_6, Dzial_6, Projekt_6
)
VALUES(@lastD,
@g11, @g12, @str1, @dz1, @prj1, @g21, @g22, @str2, @dz2, @prj2, @g31, @g32, @str3, @dz3, @prj3,
@g41, @g42, @str4, @dz4, @prj4, @g51, @g52, @str5, @dz5, @prj5, @g61, @g62, @str6, @dz6, @prj6)
SET @lastDSaved = @lastD
SET @Lp = 1
SET @lastD = @d
SET @g11 = 0; SET @g12 = 0; SET @str1 = 1; SET @dz1 = 1; SET @prj1 = 1
SET @g21 = 0; SET @g22 = 0; SET @str2 = 1; SET @dz2 = 1; SET @prj2 = 1
SET @g31 = 0; SET @g32 = 0; SET @str3 = 1; SET @dz3 = 1; SET @prj3 = 1
SET @g41 = 0; SET @g42 = 0; SET @str4 = 1; SET @dz4 = 1; SET @prj4 = 1
SET @g51 = 0; SET @g52 = 0; SET @str5 = 1; SET @dz5 = 1; SET @prj5 = 1
SET @g61 = 0; SET @g62 = 0; SET @str6 = 1; SET @dz6 = 1; SET @prj6 = 1
END
ELSE
SET @Lp = @Lp + 1
END
ClOSE c
DEALLOCATE c
IF @lastD<>@lastDSaved
BEGIN
INSERT INTO #CzasPracy16
(
Data,
GodzOd_1, GodzDo_1, Strefa_1, Dzial_1, Projekt_1,
GodzOd_2, GodzDo_2, Strefa_2, Dzial_2, Projekt_2,
GodzOd_3, GodzDo_3, Strefa_3, Dzial_3, Projekt_3,
GodzOd_4, GodzDo_4, Strefa_4, Dzial_4, Projekt_4,
GodzOd_5, GodzDo_5, Strefa_5, Dzial_5, Projekt_5,
GodzOd_6, GodzDo_6, Strefa_6, Dzial_6, Projekt_6
)
VALUES(@lastD,
@g11, @g12, @str1, @dz1, @prj1, @g21, @g22, @str2, @dz2, @prj2, @g31, @g32, @str3, @dz3, @prj3,
@g41, @g42, @str4, @dz4, @prj4, @g51, @g52, @str5, @dz5, @prj5, @g61, @g62, @str6, @dz6, @prj6)
END
if @pusty <> 1
begin
SELECT
Data,
GodzOd_1, GodzDo_1, Strefa_1, Dzial_1, Projekt_1,
GodzOd_2, GodzDo_2, Strefa_2, Dzial_2, Projekt_2,
GodzOd_3, GodzDo_3, Strefa_3, Dzial_3, Projekt_3,
GodzOd_4, GodzDo_4, Strefa_4, Dzial_4, Projekt_4,
GodzOd_5, GodzDo_5, Strefa_5, Dzial_5, Projekt_5,
GodzOd_6, GodzDo_6, Strefa_6, Dzial_6, Projekt_6
FROM #CzasPracy16
end
else
begin
SELECT
Data,
GodzOd_1, GodzDo_1, Strefa_1, Dzial_1, Projekt_1,
GodzOd_2, GodzDo_2, Strefa_2, Dzial_2, Projekt_2,
GodzOd_3, GodzDo_3, Strefa_3, Dzial_3, Projekt_3,
GodzOd_4, GodzDo_4, Strefa_4, Dzial_4, Projekt_4,
GodzOd_5, GodzDo_5, Strefa_5, Dzial_5, Projekt_5,
GodzOd_6, GodzDo_6, Strefa_6, Dzial_6, Projekt_6
FROM #CzasPracy16 where Projekt_6 = -1
end
DELETE #CzasPracy16
drop table #CzasPracy16
END
end
else
begin
update #CzasPracy
set Typ=4, Praca
= (case when (select DST_UwzglCzasPracy from CDN.DefinicjeStref where DST_DstId=PGR_Strefa)>0 then DATEDIFF(minute,PGR_OdGodziny,PGR_DoGodziny)+(case when PGR_OdGodziny>=PGR_DoGodziny then 1440 else 0 end) else 0 end)
from #CzasPracy join CDN.PracPracaDni on PPR_PraId=@Id and PPR_Data=Data and Nieobec is null join cdn.PracPracaDniGodz on PGR_PprId = PPR_PprId
update #CzasPracy
set Praca=Norma
where Praca=0 and Zestaw=0 and (Nieobec is null or (select TNB_PomnCzasPracy from CDN.TypNieobec where TNB_TnbId=TypNieob)=0)
end
end
if @Typ=4
begin
if exists(select PRE_PreId from CDN.PracEtaty where PRE_PraId=@Id and PRE_DataOd<=@DataDo and PRE_DataDo>=@DataOd and PRE_ZestCzasuPracy=2 and PRE_ZatrudnionyOd<>@Baza and PRE_ZatrudnionyOd<=@DataDo and (PRE_ZatrudnionyDo=@Baza or @DataOd<=PRE_ZatrudnionyDo))
begin
select
PZE_PzeId as PzeId, CONVERT(NVARCHAR(10),PZE_OkresOd,120) as DataOd, CONVERT(NVARCHAR(10),PZE_OkresDo,120) as DataDo, PZE_Ilosc as Dni, DATEDIFF(minute,@Baza,PZE_Czas) as Godz, DATEDIFF(minute,@Baza,PZE_CzasNoc) as GodzNoc, DATEDIFF(minute,@Baza,PZE_Nadgodziny50) as NadGodz50, DATEDIFF(minute,@Baza,PZE_Nadgodziny100) as NadGodz100
from CDN.PracZestaw
where PZE_PraId=@Id and PZE_Tryb<>1 and @DataOd<=PZE_OkresDo and PZE_OkresOd<=@DataDo
select PZD_PzeId as PzeId, PZD_Ilosc as Dni, DATEDIFF(minute,@Baza,PZD_Czas) as Godz, DATEDIFF(minute,@Baza,PZD_CzasNoc) as GodzNoc, DATEDIFF(minute,@Baza,PZD_Nadgodziny50) as NadGodz50, DATEDIFF(minute,@Baza,PZD_Nadgodziny100) as NadGodz100, PZD_DstId as Strefa, PZD_DzlId as Dzial, PZD_PrjId as Projekt
from CDN.PracZestawElem
where PZD_PzeId in (
select PZE_PzeId from CDN.PracZestaw where PZE_PraId=@Id and PZE_Tryb<>1 and @DataOd<=PZE_OkresDo and PZE_OkresOd<=@DataDo
)
end
end
else
select
(select count(*) from #CzasPracy where Norma>0) as NormaDni,
ISNULL((select sum(Norma) from #CzasPracy where Norma>0),0) as NormaGodz,
ISNULL((select sum(PZE_Ilosc) from CDN.PracZestaw where PZE_PraId=@Id and PZE_Tryb<>1 and @DataOd<=PZE_OkresDo and PZE_OkresOd<=@DataDo),0)+
ISNULL((select count(*) from #CzasPracy where Praca>0),0) as PracaDni,
ISNULL((select sum(DATEDIFF(minute,@Baza,PZE_Czas)) from CDN.PracZestaw where PZE_PraId=@Id and PZE_Tryb<>1 and @DataOd<=PZE_OkresDo and PZE_OkresOd<=@DataDo),0)+
ISNULL((select sum(Praca) from #CzasPracy where Praca>0),0) as Pracagodz
end
drop table #CzasPracy
