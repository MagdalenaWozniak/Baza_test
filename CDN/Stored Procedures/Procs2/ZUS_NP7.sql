CREATE PROCEDURE [CDN].[ZUS_NP7] @IdPrac INT, @Okres_Zas DATETIME
AS
SET NOCOUNT ON
DECLARE @Od DATETIME
DECLARE @Do DATETIME
DECLARE @KodZUS NVarChar(3)
DECLARE @poprzOd DATETIME
DECLARE @poprzDo DATETIME
DECLARE @PoprzKodZUS NVarChar(3)
DECLARE @Typ SMALLINT
DECLARE @Dni INT
DECLARE @Okres_Od DATETIME
DECLARE @Okres_Do DATETIME
DECLARE @Przyczyna SMALLINT
DECLARE @OstPrzyczyna SMALLINT
DECLARE @SumaDni INT
--zerowanie zmiennych
SET @Okres_Do = CONVERT ( DATETIME, '2999-12-30 00:00:00' , 120 )
SET @Do = CONVERT ( DATETIME, '2999-12-30 00:00:00' , 120 )
SET @Dni = 0
SET @SumaDni = 0
SET @KodZUS = ''
SET @Okres_Od =
IsNull((SELECT PNB_OkresOd
  FROM CDN.PracNieobec join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
  WHERE TNB_PdzId in (331) and (PNB_Tryb = 0 or PNB_Tryb = 2) and PNB_PraId = @IdPrac and
  @Okres_Zas between Pnb_OkresOd and PNB_OkresDo),CONVERT ( DATETIME, '2999-12-30 00:00:00' , 120 ))
SET @OstPrzyczyna =
IsNull((Select top 1 PNB_Przyczyna
  FROM CDN.PracNieobec join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
  WHERE TNB_PdzId in (331) and (PNB_Tryb = 0 or PNB_Tryb = 2) and PNB_PraId =  @IdPrac and
  Pnb_OkresOd >= @Okres_Od order by PNB_OkresOd desc),0)
CREATE TABLE #ZUS_NP7(
 Tmp_Typ SMALLINT,
 Tmp_Prcid INT,
 Tmp_Od DATETIME,
 Tmp_Do DATETIME,
 Tmp_KodZUS NVarChar(3),
 Tmp_Dni INT,
 Tmp_Przyczyna SMALLINT
 )
 DECLARE Tmp_ZUS_NP7_1 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT
  1,
  @IdPrac,
  PNB_OkresOd,
  PNB_OkresDo,
  TNB_PdzId,
  PNB_DniKalend,
  PNB_Przyczyna
  FROM CDN.PracNieobec join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
  WHERE TNB_PdzId in (331) and (PNB_Tryb = 0 or PNB_Tryb = 2) and PNB_PraId = @IdPrac and
  Pnb_OkresOd >= @Okres_Od
  order by PNB_OkresOd
  OPEN Tmp_ZUS_NP7_1
  WHILE 1=1
  BEGIN
      SET @SumaDni = @SumaDni + @Dni
   BEGIN
   IF @OstPrzyczyna in (5,6)
   IF @SumaDni >=270
   SET  @Okres_Do =  @Do
   ELSE
   SET  @Okres_Do = DATEADD(day,270-@SumaDni, @Do)
   ELSE
   IF @SumaDni >=182
   SET  @Okres_Do =  @Do
   ELSE
   SET  @Okres_Do = DATEADD(day,182-@SumaDni, @Do)
   END
   FETCH NEXT FROM Tmp_ZUS_NP7_1 INTO @Typ, @IdPrac, @Od, @Do, @KodZUS, @Dni, @Przyczyna
      IF @@FETCH_STATUS <> 0 BREAK
   --BEGIN
   --INSERT INTO #ZUS_NP7 values (11, @IdPrac, @Od, @Do, @KodZUS, @Dni, @Przyczyna)
      --END
  END
  --INSERT INTO #ZUS_NP7 values (111, @IdPrac, @Okres_Od, @Do, @KodZUS, @SumaDni, @OstPrzyczyna)
  --IF @OstPrzyczyna in (5,6)
  --SET  @Okres_Do = DATEADD(day,270-@SumaDni, @Do)
  --ELSE
  --SET  @Okres_Do = DATEADD(day,182-@SumaDni, @Do)
 INSERT INTO #ZUS_NP7 values (1, @IdPrac, @Okres_Od, @Okres_Do, @KodZUS, @SumaDni, @OstPrzyczyna)
 CLOSE Tmp_ZUS_NP7_1
 DEALLOCATE Tmp_ZUS_NP7_1
DECLARE Tmp_ZUS_NP7_2 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
 SELECT
 2,
 @IdPrac,
 WPS_DataOd,
 WPS_DataDo,
 TWP_PdzId,
 0,
 0
 FROM CDN.WypElementy join CDN.Wyplaty on WPE_WplId = WPL_WplId join CDN.ListyPlac on WPL_LplId = LPL_LplId
 join CDN.TypWyplata on WPE_TwpId=TWP_TwpId  join CDN.WypSkladniki on WPS_WpeId = WPE_WpeId join cdn.PracNieobec on PNB_PnbId = WPS_ZrodloId
 join CDN.TypNieobec on Pnb_tnbid=TNB_TnbId
 WHERE TWP_PdzId in (313,314,331) and WPS_RodzajZrodla=6 and WPL_Tryb<>1 and WPL_Tryb<>2 and WPE_PraId = @IdPrac
 and WPS_DataOd >= @Okres_Od
 order by WPS_DataOd
  OPEN Tmp_ZUS_NP7_2
  WHILE 1=1
  BEGIN
      SET @poprzOd = @Od
      SET @poprzDo = @Do
      SET @PoprzKodZUS = @KodZUS
      FETCH NEXT FROM Tmp_ZUS_NP7_2 INTO @Typ, @IdPrac, @Od, @Do, @KodZUS, @Dni, @Przyczyna
      IF @@FETCH_STATUS <> 0 BREAK
      BEGIN
      IF (@Od<>@poprzDo+1 and @PoprzKodZUS=@KodZUS) or ISNULL(@poprzDo,0)=0 or (@PoprzKodZUS<>@KodZUS)
      BEGIN
       INSERT INTO #ZUS_NP7 values (@Typ, @IdPrac, @Od, @Do, @KodZUS, @Dni, @Przyczyna)
      END
      IF (@Od=@poprzDo+1 and @PoprzKodZUS=@KodZUS)
      BEGIN
    UPDATE #ZUS_NP7 SET Tmp_Do = @Do WHERE Tmp_Do = @poprzDo and Tmp_Typ = 2
      END
      END
  END
 CLOSE Tmp_ZUS_NP7_2
 DEALLOCATE Tmp_ZUS_NP7_2
 SELECT  * FROM #ZUS_NP7 order by Tmp_Typ,Tmp_Od
