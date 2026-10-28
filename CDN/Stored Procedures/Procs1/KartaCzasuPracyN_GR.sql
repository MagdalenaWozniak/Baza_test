CREATE Procedure  [CDN].[KartaCzasuPracyN_GR]
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
  exec [CDN].[KartaCzasuPracyCalcN_GR] @CzasOd , @CzasDo , @IdPrc , @CzasZest , @NLimit, @NOd, @NDo
 END
END
CLOSE  Tmp_LiczCzas
DEALLOCATE  Tmp_LiczCzas
SELECT * FROM (
SELECT Tmp_Typ ,Tmp_PrcId, Tmp_Data, MAX(Tmp_TypDnia) as Tmp_TypDnia, sum(Tmp_NormaDob) as Tmp_NormaDob, SUM(Tmp_Praca) as Tmp_Praca, SUM(Tmp_GodzNocne) as Tmp_GodzNocne, MAX(Tmp_TnkId) as Tmp_TnkId, Tmp_Opis, ROW_NUMBER() OVER(PARTITION BY Tmp_Data ORDER BY Tmp_TnkId DESC) AS "Row Number"
FROM #CzasPracy
--group by Tmp_Typ ,Tmp_PrcId, Tmp_Data, Tmp_Opis
GROUP BY Tmp_Typ, Tmp_PrcId, Tmp_Data, Tmp_TnkId, Tmp_Opis) AS t
WHERE (Tmp_Typ = 3 and ("Row Number" = 1 OR ("Row Number" = 2 and Tmp_NormaDob > 0))) OR Tmp_Typ = 4
--WHERE "Row Number" = 1
UNION
-- strefy
SELECT * FROM (
SELECT 15 as Tmp_Typ, Tmp_PrcId, NULL as Tmp_Data, Tmp_TypDnia as Tmp_TypDnia, sum(Tmp_NormaDob) as Tmp_NormaDob, SUM(Tmp_Praca) as Tmp_Praca, SUM(Tmp_GodzNocne) as Tmp_GodzNocne, MAX(Tmp_TnkId) as Tmp_TnkId, Tmp_Opis, ROW_NUMBER() OVER(PARTITION BY Tmp_Data ORDER BY Tmp_TnkId DESC) AS "Row Number"
FROM #CzasPracy
where Tmp_Typ=13
--group by Tmp_Typ, Tmp_PrcId, Tmp_TypDnia, Tmp_TnkId, Tmp_Opis
GROUP BY Tmp_Typ, Tmp_PrcId, Tmp_TypDnia, Tmp_Data, Tmp_TnkId, Tmp_Opis) AS t
UNION
-- strefy
SELECT * FROM (
SELECT 16 as Tmp_Typ, Tmp_PrcId, NULL as Tmp_Data, Tmp_TypDnia as Tmp_TypDnia, sum(Tmp_NormaDob) as Tmp_NormaDob, SUM(Tmp_Praca) as Tmp_Praca, SUM(Tmp_GodzNocne) as Tmp_GodzNocne, MAX(Tmp_TnkId) as Tmp_TnkId, Tmp_Opis, ROW_NUMBER() OVER(PARTITION BY Tmp_Data ORDER BY Tmp_TnkId DESC) AS "Row Number"
FROM #CzasPracy
where Tmp_Typ=13
and Tmp_Opis not in (select DST_Nazwa from CDN.DefinicjeStref where DST_UwzglCzasPracy = 0 and DST_Akronim <> 'undefined')
--group by Tmp_Typ, Tmp_PrcId, Tmp_TypDnia, Tmp_TnkId, Tmp_Opis
GROUP BY Tmp_Typ, Tmp_PrcId, Tmp_TypDnia, Tmp_Data, Tmp_TnkId, Tmp_Opis) AS t
ORDER BY Tmp_Typ, Tmp_Data, Tmp_TnkId, Tmp_Opis
END
