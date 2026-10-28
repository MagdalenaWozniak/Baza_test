CREATE Procedure [CDN].[KartaCzasuPracyN]
 @DataOd DATETIME,
 @DataDo DATETIME,
 @PrcId INT
AS
BEGIN
DECLARE @DataOdZ DATETIME
DECLARE @DataDoZ DATETIME
DECLARE @Zest  INT
DECLARE @Licznik INT
DECLARE @IleZap  INT
DECLARE @IdKalend INT
DECLARE @Kned INT
DECLARE @Knod INT
DECLARE @Kndo INT
DECLARE @Knlim INT
DECLARE @Kal INT
SET @Kned =0
SET @Knod =0
SET @Kndo =0
SET @Knlim =0
SET @Kal =0
SET @IdKalend = 0
DECLARE @NOd      INT
DECLARE @NDo      INT
DECLARE @NLimit   INT
DECLARE @temp   NVARCHAR(5)
SET  @temp = (select cfw_wartosc from cdn.cfgwartosci join cdn.cfgklucze on cfw_cfkid = cfk_cfkid where cfk_nazwa='Noc od')
SELECT @NOd   = CAST (SUBSTRING ( @temp , 1 , 2 ) as INT) *60+CAST (SUBSTRING ( @temp , 4 , 2 ) as INT)
SET  @NOd = isnull (@NOd, 1260)
SET  @temp = (select cfw_wartosc from cdn.cfgwartosci join cdn.cfgklucze on cfw_cfkid = cfk_cfkid where cfk_nazwa='Noc do')
SELECT @NDo = CAST (SUBSTRING ( @temp , 1 , 2 ) as INT) * 60+CAST (SUBSTRING ( @temp , 4 , 2 ) as INT)
SET  @NDo = isnull (@NDo, 1860)
SET  @temp = (select cfw_wartosc from cdn.cfgwartosci join cdn.cfgklucze on cfw_cfkid = cfk_cfkid where cfk_nazwa='Noc limit')
SELECT @NLimit =CAST (SUBSTRING ( @temp , 1 , 2 ) as INT) *60+CAST (SUBSTRING ( @temp , 4 , 2 ) as INT)
SET  @NLimit = isnull (@NLimit, 480)
CREATE TABLE
#Zapisy (
 Tmp_PrcId INT,
 Tmp_Zest INT,
 Tmp_DataOd DATETIME,
 Tmp_DataDo DATETIME,
 Tmp_IdKal INT,
 Tmp_NocLimit INT,
 Tmp_NocOd INT,
 Tmp_NocDo INT
)
SET @DataOdZ = CONVERT(DATETIME, '2999-12-31', 120)
SET @DataDoZ = CONVERT(DATETIME, '2999-12-31', 120)
SET @Licznik = 0
SET @IleZap = 0
SET @IleZap = (SELECT COUNT(*)FROM CDN.PracEtaty
    WHERE PRE_PraId = @PrcId and
    (IsNull(PRE_ZatrudnionyOd, 0) <> 0
    OR IsNull(PRE_ZatrudnionyDo, 0) <> 0) and
    (PRE_DataOd <= @DataOd and PRE_DataDo>= @DataOd
    OR
    PRE_DataOd <= @DataOd and PRE_DataDo>= @DataOd
    OR
    PRE_DataOd between @DataOd and @DataDo))
DECLARE Tmp_Zapisy CURSOR
LOCAL FAST_FORWARD READ_ONLY FOR
 SELECT
   Pre_ZestCzasuPracy,
   PRE_DataOd,
   PRE_DataDo ,
   PRE_KalId,
   KAL_EdycjaNocne,
   DATEDIFF(n,convert(datetime ,'1899-12-30 00:00:00.000',120),KAL_NocLimit),
   DATEDIFF(n,convert(datetime ,'1899-12-30 00:00:00.000',120),KAL_NocOd),
   DATEDIFF(n,convert(datetime ,'1899-12-30 00:00:00.000',120),KAL_NocDo)
 FROM CDN.PracEtaty
   JOIN cdn.Kalendarze on PRE_KalId=Kal_KalId
 WHERE
   PRE_PraId = @PrcId and (IsNull(PRE_ZatrudnionyOd, 0) <> 0  OR IsNull(PRE_ZatrudnionyDo, 0) <> 0) and
   (PRE_DataOd <= @DataOd and PRE_DataDo>= @DataOd  OR  PRE_DataOd <= @DataOd and PRE_DataDo>= @DataOd  OR  PRE_DataOd between @DataOd and @DataDo)
 ORDER BY
   PRE_DataDo
OPEN Tmp_Zapisy
WHILE 1=1
BEGIN
 FETCH NEXT FROM Tmp_Zapisy INTO  @Zest, @DataOdZ, @DataDoZ, @Kal,  @Kned,  @Knlim, @Knod, @Kndo
 IF @@FETCH_STATUS <> 0 BREAK
 BEGIN
  IF @Kned = 0
   BEGIN
    SET @Knod = @NOd
    SET @Kndo = @NDo
    SET @Knlim = @NLimit
   END
  SET @Licznik = @Licznik + 1
  IF  @Licznik = 1 and @IleZap<>1
   INSERT INTO #Zapisy values (@PrcId, @Zest, @DataOd, @DataDoZ, @Kal, @Knlim, @Knod, @Kndo)
  IF  @Licznik = 1 and @IleZap=1
   INSERT INTO #Zapisy values (@PrcId, @Zest, @DataOd, @DataDo, @Kal, @Knlim, @Knod, @Kndo)
  IF  @Licznik >1 and  @Licznik<@IleZap
   INSERT INTO #Zapisy values (@PrcId, @Zest, @DataOdZ, @DataDoZ, @Kal, @Knlim, @Knod, @Kndo)
  IF  @Licznik=@IleZap and @IleZap<>1
   INSERT INTO #Zapisy values (@PrcId, @Zest, @DataOdZ, @DataDo, @Kal, @Knlim, @Knod, @Kndo)
 END
END
CLOSE  Tmp_Zapisy
DEALLOCATE  Tmp_Zapisy
DECLARE @IdPrc INT
DECLARE @CzasOd DATETIME
DECLARE @CzasDo DATETIME
DECLARE @CzasZest INT
CREATE TABLE #CzasPracy (
 Tmp_Typ          INT,
 Tmp_PrcId        INT,
 Tmp_Data         DATETIME,
 Tmp_TypDnia   INT,
 Tmp_OdwId int, --nvarchar(2),
 Tmp_Symbol nvarchar(2),
 Tmp_NormaDob     DECIMAL(15,2),
 Tmp_Praca        DECIMAL(15,2),
 Tmp_GodzNocne    DECIMAL(15,2),
 Tmp_TnkId        INT,
 Tmp_Opis    NVARCHAR(50)
)
DECLARE Tmp_LiczCzas CURSOR
LOCAL FAST_FORWARD READ_ONLY FOR
 SELECT  DISTINCT * FROM #Zapisy
 ORDER BY Tmp_DataOd
OPEN Tmp_LiczCzas
WHILE 1=1
BEGIN
 FETCH NEXT FROM Tmp_LiczCzas INTO  @IdPrc, @CzasZest, @CzasOd, @CzasDo, @IdKalend, @NLimit, @NOd, @NDo
 IF @@FETCH_STATUS <> 0 BREAK
 BEGIN
  exec [CDN].[KartaCzasuPracyCalcN] @CzasOd , @CzasDo , @IdPrc , @CzasZest , @NLimit, @NOd, @NDo
 END
END
CLOSE  Tmp_LiczCzas
DEALLOCATE  Tmp_LiczCzas
CREATE TABLE #CzasPracy2 (
 Tmp_Typ          INT,
 Tmp_PrcId        INT,
 Tmp_Data         DATETIME,
 Tmp_TypDnia   INT,
 Tmp_OdwId int, --  nvarchar(2),
 Tmp_Symbol nvarchar(2),
 Tmp_NormaDob     DECIMAL(15,2),
 Tmp_Praca        DECIMAL(15,2),
 Tmp_GodzNocne    DECIMAL(15,2),
 Tmp_TnkId        INT,
 Tmp_Opis    NVARCHAR(50),
 Tmp_PracaOd datetime,
 Tmp_PracaDo datetime,
 Tmp_UwzglWymEtatu int,
 Tmp_KalId int,
 Tmp_NormaKalendarz int,
 Tmp_PracaRodzic int,
 Tmp_WymiarEtatu DECIMAL(6,2)
 )
insert into #CzasPracy2
SELECT Tmp_Typ ,Tmp_PrcId, Tmp_Data, MAX(Tmp_TypDnia) as Tmp_TypDnia, max(Tmp_OdwId) as Tmp_OdwId, '', sum(Tmp_NormaDob) as Tmp_NormaDob,SUM(Tmp_Praca) as Tmp_Praca, SUM(Tmp_GodzNocne) as Tmp_GodzNocne,MAX(Tmp_TnkId) as Tmp_TnkId,Tmp_Opis, null, null, null, null, null, null, null
FROM #CzasPracy
group by  Tmp_Typ ,Tmp_PrcId, Tmp_Data, Tmp_Opis
UNION
-- strefy
SELECT 15, Tmp_PrcId, @DataDo+2, Tmp_TypDnia as Tmp_TypDnia, Tmp_OdwId as Tmp_OdwId, '', sum(Tmp_NormaDob) as Tmp_NormaDob,SUM(Tmp_Praca) as Tmp_Praca, SUM(Tmp_GodzNocne) as Tmp_GodzNocne,
MAX(Tmp_TnkId) as Tmp_TnkId,Tmp_Opis, null, null, null, null, null, null, null
FROM #CzasPracy
where Tmp_Typ=13
group by Tmp_Typ, Tmp_PrcId, Tmp_TypDnia, Tmp_OdwId, Tmp_TnkId, Tmp_Opis
END
--
declare @Zestaw int
select @Zestaw = PRE_ZestCzasuPracy from cdn.PracEtaty where PRE_PraId = @PrcId --and PRE_DataDo <= @DataOd and PRE_DataDo >= @DataDo
update #CzasPracy2
 set
 Tmp_PracaRodzic = PRE_PRMPracaRodzic
 from cdn.PracEtaty where PRE_PraId = @PrcId and (PRE_DataOd <= Tmp_Data and PRE_DataDo >= Tmp_Data)
update #CzasPracy2
 set
 Tmp_UwzglWymEtatu = KAL_UwzglWymiarEtatu,
 Tmp_KalId = KAL_KalId,
 Tmp_NormaKalendarz = KAL_NormaKalendarz
 from cdn.Kalendarze where KAL_KalId = (select KAL_KalId from cdn.Kalendarze join cdn.PracEtaty on KAL_KalId = PRE_KalId where PRE_PraId = @PrcId and (PRE_DataOd <= Tmp_Data and PRE_DataDo >= Tmp_Data))
update #CzasPracy2
 set
 Tmp_UwzglWymEtatu = KAL_UwzglWymiarEtatu,
 Tmp_KalId = KAL_KalId,
 Tmp_NormaKalendarz = KAL_NormaKalendarz
 from cdn.Kalendarze where Tmp_PracaRodzic > 0 and (KAL_KalId = (select KAL_KalId from cdn.Kalendarze join cdn.PracEtaty on KAL_KalId = PRE_PRMKalId where PRE_PraId = @PrcId and (PRE_DataOd <= Tmp_Data and PRE_DataDo >= Tmp_Data)))
declare @dtStart datetime
set @dtStart = convert(datetime,'1899.12.30',102)
update #CzasPracy2
 set
 Tmp_WymiarEtatu = CONVERT(float,PRE_ETAEtatL)/(case PRE_ETAEtatM when 0 then 1 else PRE_ETAEtatM end)
 from cdn.PracEtaty where PRE_PraId = @PrcId and (PRE_DataOd <= Tmp_Data and PRE_DataDo >= Tmp_Data)
if @Zestaw = 0
begin
 update #CzasPracy2
 set Tmp_PracaOd = convert(datetime, '1899-12-30 00:00:00.000', 120), Tmp_PracaDo = convert(datetime, '1899-12-30 00:00:00.000', 120)
 where #CzasPracy2.Tmp_TypDnia > 1
 update #CzasPracy2
 set Tmp_PracaOd = convert(datetime, '1899-12-30 07:00:00.000', 120), Tmp_PracaDo = convert(datetime, '1899-12-30 15:00:00.000', 120)
 where #CzasPracy2.Tmp_TypDnia = 1
end
if @Zestaw = 0
begin
 update #CzasPracy2
 set
  Tmp_PracaOd =
   (select case when min(KDG_OdGodziny) is not null then min(KDG_OdGodziny) else #CzasPracy2.Tmp_PracaOd end
    from cdn.KalendDni
     join cdn.KalendDniGodz on KAD_KadId = KDG_KadId
     join cdn.DefinicjeStref on KDG_Strefa = DST_DstId
     join cdn.Kalendarze on KAL_KalId = KAD_KalId
    where KAD_Data = #CzasPracy2.Tmp_Data and DST_UwzglCzasPracy = 1 and KAL_KalId = Tmp_KalId),
  Tmp_PracaDo =
  (
   select
    case
     when (Tmp_UwzglWymEtatu > 0 and Tmp_WymiarEtatu = 1)
      then
      (select case when max(KDG_DoGodziny) is not null then max(KDG_DoGodziny) else #CzasPracy2.Tmp_PracaDo end
       from cdn.KalendDni
        join cdn.KalendDniGodz on KAD_KadId = KDG_KadId
        join cdn.DefinicjeStref on KDG_Strefa = DST_DstId
        join cdn.Kalendarze on KAL_KalId = KAD_KalId
       where KAD_Data = #CzasPracy2.Tmp_Data and DST_UwzglCzasPracy = 1 and KAL_KalId = Tmp_KalId)
     when (Tmp_UwzglWymEtatu > 0 and Tmp_WymiarEtatu <> 1)
      then
      (
       dateadd(minute,
         convert(int,
           ceiling(Tmp_NormaDob)) %1440,
           dateadd(hour,
            datepart(hour,
              (select case when min(KDG_OdGodziny) is not null then min(KDG_OdGodziny) else #CzasPracy2.Tmp_PracaOd end
               from cdn.KalendDni
                join cdn.KalendDniGodz on KAD_KadId = KDG_KadId
                join cdn.DefinicjeStref on KDG_Strefa = DST_DstId
                join cdn.Kalendarze on KAL_KalId = KAD_KalId
               where KAD_Data = #CzasPracy2.Tmp_Data and DST_UwzglCzasPracy = 1 and KAL_KalId = Tmp_KalId)
              ),
            dateadd(minute,
              datepart(minute,
                (select case when min(KDG_OdGodziny) is not null then min(KDG_OdGodziny) else #CzasPracy2.Tmp_PracaOd end
                from cdn.KalendDni
                 join cdn.KalendDniGodz on KAD_KadId = KDG_KadId
                 join cdn.DefinicjeStref on KDG_Strefa = DST_DstId
                 join cdn.Kalendarze on KAL_KalId = KAD_KalId
                where KAD_Data = #CzasPracy2.Tmp_Data and DST_UwzglCzasPracy = 1 and KAL_KalId = Tmp_KalId)),
              @dtStart
              )
            )
         )
      )
    else
     (select case when max(KDG_DoGodziny) is not null then max(KDG_DoGodziny) else #CzasPracy2.Tmp_PracaDo end
      from cdn.KalendDni
       join cdn.KalendDniGodz on KAD_KadId = KDG_KadId
       join cdn.DefinicjeStref on KDG_Strefa = DST_DstId
       join cdn.Kalendarze on KAL_KalId = KAD_KalId
      where KAD_Data = #CzasPracy2.Tmp_Data and DST_UwzglCzasPracy = 1 and KAL_KalId = Tmp_KalId
     )
    end
  )
end
if @Zestaw = 0
begin
 update #CzasPracy2
 set
 Tmp_PracaOd =
 (select case when min(PGL_OdGodziny) is not null then min(PGL_OdGodziny) else #CzasPracy2.Tmp_PracaOd end from cdn.PracPlanDni join cdn.PracPlanDniGodz on PPL_PplId = PGL_PplId join cdn.DefinicjeStref on PGL_Strefa = DST_DstId where PPL_PraId = @PrcId and PPL_Data = #CzasPracy2.Tmp_Data and DST_UwzglCzasPracy = 1),
 Tmp_PracaDo =
 (select case when max(PGL_DoGodziny) is not null then max(PGL_DoGodziny) else #CzasPracy2.Tmp_PracaDo end from cdn.PracPlanDni join cdn.PracPlanDniGodz on PPL_PplId = PGL_PplId join cdn.DefinicjeStref on PGL_Strefa = DST_DstId where PPL_PraId = @PrcId and PPL_Data = #CzasPracy2.Tmp_Data and DST_UwzglCzasPracy = 1)
end
update #CzasPracy2
set
Tmp_PracaOd =
(select case when min(PGR_OdGodziny) is not null then min(PGR_OdGodziny) else #CzasPracy2.Tmp_PracaOd end from cdn.PracPracaDni join cdn.PracPracaDniGodz on PPR_PprId = PGR_PprId join cdn.DefinicjeStref on PGR_Strefa = DST_DstId where PPR_PraId = @PrcId and PPR_Data = #CzasPracy2.Tmp_Data and DST_UwzglCzasPracy = 1),
Tmp_PracaDo =
(select case when max(PGR_DoGodziny) is not null then
(select top 1 PGR_DoGodziny from cdn.PracPracaDni join cdn.PracPracaDniGodz on PPR_PprId = PGR_PprId join cdn.DefinicjeStref on PGR_Strefa = DST_DstId where PPR_PraId = @PrcId and PPR_Data = #CzasPracy2.Tmp_Data and DST_UwzglCzasPracy = 1 order by PGR_Lp desc)
 else #CzasPracy2.Tmp_PracaDo end from cdn.PracPracaDni join cdn.PracPracaDniGodz on PPR_PprId = PGR_PprId join cdn.DefinicjeStref on PGR_Strefa = DST_DstId where PPR_PraId = @PrcId and PPR_Data = #CzasPracy2.Tmp_Data and DST_UwzglCzasPracy = 1)
update #CzasPracy2
set
Tmp_PracaOd = convert(datetime, '1899-12-30 00:00.000', 120), Tmp_PracaDo = convert(datetime, '1899-12-30 00:00.000', 120)
where #CzasPracy2.Tmp_Praca = 0
update #CzasPracy2
set
Tmp_PracaOd = null, Tmp_PracaDo = null
where exists (select * from cdn.PracNieobec where PNB_PraId = @PrcId and PNB_Calodzienna = 1 and (#CzasPracy2.Tmp_Data = PNB_OkresOd or #CzasPracy2.Tmp_Data = PNB_OkresDo)) or #CzasPracy2.Tmp_TnkId > 0
update #CzasPracy2
set
Tmp_PracaOd = #CzasPracy2.Tmp_PracaOd,
Tmp_PracaDo = #CzasPracy2.Tmp_PracaDo - (select top 1 PNB_Godz from cdn.PracNieobec where PNB_PraId = @PrcId and PNB_Calodzienna = 0 and (#CzasPracy2.Tmp_Data = PNB_OkresOd or #CzasPracy2.Tmp_Data = PNB_OkresDo)) - 1
where exists (select * from cdn.PracNieobec where PNB_PraId = @PrcId and PNB_Calodzienna = 0 and (#CzasPracy2.Tmp_Data = PNB_OkresOd or #CzasPracy2.Tmp_Data = PNB_OkresDo)) and not exists (select * from cdn.PracPracaDni where PPR_PraId = @PrcId and PPR_Data = #CzasPracy2.Tmp_Data)
declare @NDId int, @NDSym nvarchar(2)
declare @SOId int, @SOSym nvarchar(2)
select top 1 @NDId = ODW_OdwId, @NDSym = ODW_Symbol from cdn.OpisyDniWolne where ODW_Standardowy = 1
select top 1 @SOId = ODW_OdwId, @SOSym = ODW_Symbol from cdn.OpisyDniWolne where ODW_Standardowy = 3
update #CzasPracy2 set Tmp_Symbol = (select top 1 ODW_Symbol from cdn.OpisyDniWolne where ODW_OdwId = Tmp_OdwId)
update #CzasPracy2 set Tmp_OdwId = @NDId where Tmp_TypDnia = 3 and Tmp_OdwId is null
update #CzasPracy2 set Tmp_Symbol = @NDSym where Tmp_TypDnia = 3 and Tmp_Symbol is null
update #CzasPracy2 set Tmp_OdwId = @SOId where Tmp_TypDnia = 2 and Tmp_OdwId is null
update #CzasPracy2 set Tmp_Symbol = @SOSym where Tmp_TypDnia = 2 and Tmp_Symbol is null
update #CzasPracy2 set Tmp_Symbol = '' where Tmp_Symbol is null
select * from #CzasPracy2
--go
