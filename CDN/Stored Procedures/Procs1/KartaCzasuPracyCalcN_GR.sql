CREATE Procedure [CDN].[KartaCzasuPracyCalcN_GR] @DataOd DATETIME, @DataDo DATETIME, @PrcId INT, @ZestCzas INT, @NocLimit INT , @NocOd INT, @NocDo INT
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
DECLARE @nod DATETIME
DECLARE @ndo DATETIME
SET @nod = dateadd(minute,@NocOd,-2)
SET @ndo = dateadd(minute,@NocDo,-2)
IF @ndo<@nod set @ndo=dateadd(day,1,@ndo)
IF @ZestCzas=2
BEGIN
DECLARE @Data0  DATETIME
SET @Data0      = CONVERT ( DATETIME, '1899-12-30 00:00:00' , 120 )
--4 wstawiam czas dla kaĹĽdego dnia
INSERT INTO #CzasPracy
select 4, @prcId, data, TypDnia,
Case When (PRE_ZatrudnionyOd > data or PRE_ZatrudnionyDo < data) then 0 Else
--[JK] uwzglednienie nieobecnosci w danym dniu i pomniejszenie normy
Case When EXISTS(select 1 from CDN.PracNieobec where PNB_PraId=@PrcId and Data between PNB_OkresOd and PNB_OkresDo and PNB_Tryb<>1) and isnull(TNB_TnkId,0)=0 Then Praca else norma end
--Norma
End,
Praca,
Case When (PRE_ZatrudnionyOd > data or PRE_ZatrudnionyDo < data) then 0 Else
(Case When Noc > @NocLimit Then @NocLimit Else Noc End) End,
TNB_TnkId, TNB_Nazwa
from
(select PRE_ZatrudnionyOd,  PRE_ZatrudnionyDo, data, TypDnia, Norma, Praca,
Case when Typ=5 or (Typ<>4 and PRE_ZestCzasuPracy=1)
or (Norma=0 and Praca=0)
or Praca=0
then 0 Else
(Case When ((select DST_UwzglCzasPracy from CDN.DefinicjeStref where DST_DstId=Strefa)=0) then 0 else
CDN.CzasPracyWNocy(Strefa,GodzOd,GOdzDo,@NOd,@NDo)  End)
End Noc, TNB_TnkId, TNB_Nazwa
FROM (select * from
CDN.PracCzasPracyFN(2, @PrcId, @DataOd, @DataDo)
union
select * from
CDN.PracCzasPracyFN(3, @PrcId, @DataOd, @DataDo) ) CzasPracy
inner join CDN.PracEtaty on @PrcId = Pre_PraId and Data between PRE_DataOd and PRE_DataDo
left outer join CDN.TypNieobec on TNB_TnbId = TypNieob) Dni
--11 nieobecnoĹ›ci wĹ‚asne
INSERT INTO #CzasPracy
select 11, @prcId, NULL, 0, 0,0, 0, TNB_TnkId, TNK_Nazwa
from CDN.TypNieobec join CDN.TypNieobecKartaPracy on TNB_tnkId = TNK_TnkId
where  TNB_TnkId > 12
--13 wstawiam dla kaĹĽdej strefy dla pracownikow wg zest
INSERT INTO #CzasPracy
select  13, @PrcId,  NULL, DST_UwzglCzasPracy, isnull(Norma,0), isnull(Praca,0), isnull(PracaNoc,0), 0, DST_nazwa
from (
  select pzd_dstId,
    sum(DATEDIFF(minute, @Data0, CONVERT(DATETIME, pzd_czas, 120))) Praca,
    sum(DATEDIFF(minute, @Data0, CONVERT(DATETIME, pzd_czasNoc, 120))) PracaNoc
  from CDN.PracZestawElem
  inner join cdn.praczestaw on pze_pzeid = pzd_pzeid
  where PZE_Tryb<>1 and pze_praid=@PrcId and @DataOd<= pze_okresod AND @DataDo>=pze_okresdo
  group by pzd_dstId
) Zest
full outer join (
  select Strefa, sum(Norma) Norma
  from (
    select Typ, Data, strefa strefa,
      Case When DATEDIFF(minute, GodzOd, GodzDo)>0 Then DATEDIFF(minute, GodzOd, GodzDo)
      Else DATEDIFF(minute, GodzOd, GodzDo) + 1440 End norma,
      0 praca
    from CDN.PracCzasPracyFN(2,@PrcId,@DataOd, @DataDo) where Strefa <>1
    ) Praca
  inner join CDN.PracEtaty on Pre_PRaId=@PrcId and Data between PRE_DataOd and PRE_DataDo
    and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
  group by Strefa
) Kal
  on pzd_dstId=strefa
inner join CDN.DefinicjeStref
  on Dst_DstId=isnull(pzd_dstId,strefa)
--14 wstawiam dla podsumowania dla pracownikow wg zest
INSERT INTO #CzasPracy
select 14, @PrcId,  NULL,
sum(DATEDIFF(minute, @Data0, CONVERT(DATETIME, pze_czasWolne, 120))),
(select sum(norma) from CDN.PracCzasPracyFN(2, @PrcId, @DataOd, @DataDo)
inner join CDN.PracEtaty on Pre_PRaId=@PrcId and Data between PRE_DataOd and PRE_DataDo
and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo),
sum(DATEDIFF(minute, @Data0, CONVERT(DATETIME, pze_czas, 120))),
sum(DATEDIFF(minute, @Data0, CONVERT(DATETIME, pze_czasNoc, 120))),
sum(DATEDIFF(minute, @Data0, CONVERT(DATETIME, pze_czasSW, 120))),
NULL
from cdn.praczestaw
WHERE pze_praid=@PrcId and PZE_Tryb<>1 and @DataOd<= pze_okresod AND @DataDo>=pze_okresdo
end
IF @ZestCzas<>2
BEGIN
--3 wstawiam czas dla kaĹĽdego dnia
INSERT INTO #CzasPracy
select 3, @prcId, data, TypDnia,
Case When (PRE_ZatrudnionyOd > data or PRE_ZatrudnionyDo < data) then 0 Else
--[JK] uwzglednienie nieobecnosci w danym dniu i pomniejszenie normy
Case When EXISTS(select 1 from CDN.PracNieobec where PNB_PraId=@PrcId and Data between PNB_OkresOd and PNB_OkresDo and PNB_Tryb<>1 and PNB_PracaRodzic<>1) and isnull(TNB_TnkId,0)=0 Then Praca else norma end
--Norma
End,
Praca,
Case When (PRE_ZatrudnionyOd > data or PRE_ZatrudnionyDo < data) then 0 Else
(Case When Noc > @NocLimit Then @NocLimit Else Noc End) End,
TNB_TnkId, TNB_Nazwa
from
(select PRE_ZatrudnionyOd,  PRE_ZatrudnionyDo, data, TypDnia, Norma, Praca,
Case when Typ=5 or (Typ<>4 and PRE_ZestCzasuPracy=1)
or (Norma=0 and Praca=0)
or Praca=0
then 0 Else
(Case When ((select DST_UwzglCzasPracy from CDN.DefinicjeStref where DST_DstId=Strefa)=0) then 0 else
CDN.CzasPracyWNocy(Strefa,GodzOd,GOdzDo,@NOd,@NDo)  End)
End Noc, TNB_TnkId, TNB_Nazwa
FROM (select * from
CDN.PracCzasPracyFN(2, @PrcId, @DataOd, @DataDo)
union
select * from
CDN.PracCzasPracyFN(3, @PrcId, @DataOd, @DataDo) ) CzasPracy
inner join CDN.PracEtaty on @PrcId = Pre_PraId and Data between PRE_DataOd and PRE_DataDo
left outer join CDN.TypNieobec on TNB_TnbId = TypNieob) Dni
--11 nieobecnoĹ›ci wĹ‚asne
INSERT INTO #CzasPracy
select 11, @prcId, NULL, 0, 0,0, 0, TNB_TnkId, TNK_Nazwa
from CDN.TypNieobec join CDN.TypNieobecKartaPracy on TNB_tnkId = TNK_TnkId
where TNB_TnkId > 12 AND TNB_TnkId < 21 -- SB 2021 [12263] --
--12 wstawiam czas pracy w strefach
INSERT INTO #CzasPracy
select 13, @prcId, NULL,
(select DST_UwzglCzasPracy  from CDN.DefinicjeStref where DST_DstId = strefa),
sum(norma),
--sum(case when Typ=4 or (PRE_ZestCzasuPracy=0 and Typ<>5) then Praca Else 0 End) as Praca, [KB] TFS 144955
sum(case when Typ=4 or PRE_ZestCzasuPracy=0 then Praca Else 0 End) as Praca,
0, 0, Dst_Nazwa
from (
  select Typ, Data, strefa strefa, 0 norma,
  Case When DATEDIFF(minute, GodzOd, GodzDo)>=0 Then
 --[JK] TFS:151309
  Case When (select DST_UwzglCzasPracy  from CDN.DefinicjeStref where DST_DstId = strefa) = 1 Then
  --[JK] TFS:150666
  praca Else
  DATEDIFF(minute, GodzOd, GodzDo) End
  Else DATEDIFF(minute, GodzOd, GodzDo) + 1440 End praca
  from CDN.PracCzasPracyFN(3,@PrcId,@DataOd, @DataDo) where Strefa <>1
  union all
  select Typ, Data, strefa strefa,
  Case When DATEDIFF(minute, GodzOd, GodzDo)>0 Then DATEDIFF(minute, GodzOd, GodzDo)
  Else DATEDIFF(minute, GodzOd, GodzDo) + 1440 End norma,
  0 praca
  from CDN.PracCzasPracyFN(2,@PrcId,@DataOd, @DataDo) where Strefa <>1
  ) Praca
inner join CDN.PracEtaty on Pre_PRaId=@PrcId and Data between PRE_DataOd and PRE_DataDo
                            and Data between PRE_ZatrudnionyOd and PRE_ZatrudnionyDo
inner join CDN.DefinicjeStref on Dst_DstId=strefa
group by strefa, Dst_Nazwa
END
SET NOCOUNT OFF
END
