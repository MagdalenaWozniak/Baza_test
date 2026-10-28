create  PROCEDURE CDN.KartaCzasuPracy1 @DataOd DATETIME, @DataDo DATETIME, @PrcId INT
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
--Tworze tabele tymczasowa, ktora zwracac bedzie czas pracy pracownika
declare @CzasPracy TABLE (
 Tmp_Typ          INT,
 Tmp_PrcId        INT,
 Tmp_Data         DATETIME,
 Tmp_TypDnia   INT,
 Tmp_NormaDob     DECIMAL(15,2),
 Tmp_Praca        DECIMAL(15,2),
 Tmp_GodzNocne    DECIMAL(15,2),
 Tmp_TnkId        INT,
 Tmp_Opis   NVARCHAR(50) -- opis nieobecnosci ze skrótu
 )
IF exists(select * from CDN.PracEtaty where PRE_ZestCzasuPracy=2 and PRE_PraId=@PrcId and @DataDo between PRE_DataOd and PRE_DataDo)
BEGIN
DECLARE @Data0  DATETIME
SET @Data0      = CONVERT ( DATETIME, '1899-12-30 00:00:00' , 120 )
--13 wstawiam dla każdej strefy dla pracownikow wg zest
INSERT INTO @CzasPracy
select 13, @PrcId, NULL, DST_UwzglCzasPracy, isnull(Norma,0), isnull(Praca,0), isnull(PracaNoc,0), 0, DST_nazwa
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
INSERT INTO @CzasPracy
select 14, @PrcId, NULL,
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
-- NOC
declare @NocOd      INT
declare @NocDo      INT
declare @NocCzas    INT
declare @NocLimit   INT
declare @temp   NVARCHAR(5)
SET @temp = (select cfw_wartosc from cdn.cfgwartosci join cdn.cfgklucze on cfw_cfkid = cfk_cfkid where cfk_nazwa='Noc od')
SELECT @NocOd   = CAST (SUBSTRING ( @temp , 1 , 2 ) as INT) *60+CAST (SUBSTRING ( @temp , 4 , 2 ) as INT)
SET @NocOd = isnull (@NocOd, 1260)
SET @temp = (select cfw_wartosc from cdn.cfgwartosci join cdn.cfgklucze on cfw_cfkid = cfk_cfkid where cfk_nazwa='Noc do')
SELECT @NocDo = CAST (SUBSTRING ( @temp , 1 , 2 ) as INT) * 60+CAST (SUBSTRING ( @temp , 4 , 2 ) as INT)
SET @NocDo = isnull (@NocDo, 1860)
SET @temp = (select cfw_wartosc from cdn.cfgwartosci join cdn.cfgklucze on cfw_cfkid = cfk_cfkid where cfk_nazwa='Noc limit')
SELECT @NocLimit =CAST (SUBSTRING ( @temp , 1 , 2 ) as INT) *60+CAST (SUBSTRING ( @temp , 4 , 2 ) as INT)
SET @NocLimit = isnull (@NocLimit, 480)
SET @NocCzas = @NocDo - @NocOd
declare @nod datetime
declare @ndo datetime
set @nod = dateadd(minute,@NocOd,-2)
set @ndo = dateadd(minute,@NocDo,-2)
if @ndo<@nod set @ndo=dateadd(day,1,@ndo)
--3 wstawiam czas dla każdego dnia
INSERT INTO @CzasPracy
select 3, @prcId, data, TypDnia,
Case When (PRE_ZatrudnionyOd > data or PRE_ZatrudnionyDo < data) then 0 Else
--[JK] uwzglednienie nieobecnosci w danym dniu i pomniejszenie normy
Case When EXISTS(select 1 from CDN.PracNieobec where PNB_PraId=@PrcId and Data between PNB_OkresOd and PNB_OkresDo and PNB_Tryb<>1 and PNB_PracaRodzic <>1) and isnull(TNB_TnkId,0)=0 Then Praca else norma end
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
--[JK] TFS:148970
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
--11 nieobecności własne
INSERT INTO @CzasPracy
select 11, @prcId, NULL, 0, 0,0, 0, TNB_TnkId, TNK_Nazwa
from CDN.TypNieobec join CDN.TypNieobecKartaPracy on TNB_tnkId = TNK_TnkId
where  TNB_TnkId > 12
--12 wstawiam czas pracy w strefach
INSERT INTO @CzasPracy
select 12, @prcId, Null,
(select DST_UwzglCzasPracy  from CDN.DefinicjeStref where DST_DstId = strefa),
sum(norma),
sum(case when Typ=4 or (PRE_ZestCzasuPracy=0 and Typ<>5) then Praca Else 0 End), 0, 0, Dst_Nazwa
from (
  select Typ, Data, strefa strefa, 0 norma,
  Case When DATEDIFF(minute, GodzOd, GodzDo)>0 Then
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
SELECT Tmp_Typ ,Tmp_PrcId, Tmp_Data, MAX(Tmp_TypDnia) as Tmp_TypDnia,sum(Tmp_NormaDob) as Tmp_NormaDob,SUM(Tmp_Praca) as Tmp_Praca, SUM(Tmp_GodzNocne) as Tmp_GodzNocne,MAX(Tmp_TnkId) as Tmp_TnkId,Tmp_Opis from @CzasPracy
group by Tmp_Typ ,Tmp_PrcId, Tmp_Data, Tmp_Opis
--[JK] usunięcie pustego zapisu dla czasu pracy
--having (sum(Tmp_NormaDob)>0 or SUM(Tmp_Praca)>0) and MAX(tmp_typdnia)=1 or max(Tmp_TypDnia)>1
--order by Tmp_Typ ,Tmp_Data
SET NOCOUNT OFF
END
