CREATE PROCEDURE CDN.Z3_Roczny @DataOd DATETIME , @DataDo DATETIME, @PrcId INT, @ZasNaDzien DATETIME
AS
SET NOCOUNT ON
DECLARE @monthyear  INT
DECLARE @year       INT
DECLARE @month      INT
DECLARE @Wartosc    DECIMAL (15,2)
DECLARE @MonthDekl  INT
DECLARE @TwpId      INT
DECLARE @RozlNadg   INT
-- [JK] TFS:9827
DECLARE @SumaSkladek DECIMAL (15,2)
DECLARE @PodstWyp DECIMAL (15,2)
DECLARE @PodstChor DECIMAL (15,2)
SET @DataOd = CONVERT(DATETIME, @DataOd, 120)
SET @DataDo = CONVERT(DATETIME, @DataDo, 120)
SET @RozlNadg = (select KAL_NadgodzOkres from cdn.pracetaty inner join CDN.Kalendarze on PRE_KalId = KAL_KalId where PRE_PraId = @PrcId and @DataDo between pre_dataod and pre_datado)
--[JK] TFS:154587
DECLARE @ZasPoZwol INT
IF @ZasNaDzien > (select PRE_ZatrudnionyDo from cdn.pracetaty where pre_praid = @PrcId and year(pre_datado) = 2999)
BEGIN
  SET @ZasPoZwol = 1
END
ELSE
BEGIN
  SET @ZasPoZwol = 0
END
 --Tworze tabele tymczasowa, która zwracac bedzie kwoty wyplat
 CREATE TABLE #Z3_Roczny (
  Tmp_Rok          INT,
  Tmp_WartWyp      DECIMAL (15,2),
  Tmp_TwpId        INT,
  Tmp_PodstWyp     DECIMAL (15,2),
  Tmp_PodstChor    DECIMAL (15,2),
  Tmp_SumaSkl      DECIMAL (15,2)
  )
 DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
-- [JK] TFS:9827 dodano WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac
  SELECT  wpe_wartosc, year(lpl_datado) , twp_TwpId, WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac
  from cdn.wypelementy
  join cdn.typwyplata on wpe_twpid=twp_twpid
  join cdn.wyplaty on wpe_wplid = wpl_wplid
  join cdn.pracetaty on pre_praid=wpl_praid
  join cdn.kalendarze on kal_kalid = pre_kalid
  join cdn.listyplac on lpl_lplid = wpl_lplid
  where wpl_praid = @PrcId AND lpl_dataod>=@DataOd and lpl_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and @DataDo between pre_dataod and pre_datado and pre_zatrudnionyod <= @DataOd
  and twp_wliczchor<>1 and
  -- TFS:247201 and wpe_podstchor<>0
  ((twp_Standardowy in (2,6,7, 8,28) and kal_nadgodzokres=12) or twp_okreswyplaty=14 )
  order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
-- [JK] TFS:9827 dodano @PodstWyp, @PodstChor, @SumaSkladek
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @year, @TwpId, @PodstWyp, @PodstChor, @SumaSkladek
      IF @@FETCH_STATUS <> 0 BREAK
      --IF NOT EXISTS (SELECT 1 FROM #Z3_Roczny WHERE Tmp_Rok=@year AND Tmp_TwpId=@TwpId)
-- [JK] TFS:9827 dodano @PodstWyp, @PodstChor, @SumaSkladek
         INSERT INTO #Z3_Roczny values (@year, @Wartosc, @TwpId, @PodstWyp,@PodstChor,@SumaSkladek)
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
-- [JK] TFS:154587
IF @ZasPoZwol = 1
BEGIN
DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
-- [JK] TFS:9827 dodano WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac
  SELECT  wpe_wartosc, year(lpl_datado) , twp_TwpId, WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac
  from cdn.wypelementy
  join cdn.typwyplata on wpe_twpid=twp_twpid
  join cdn.wyplaty on wpe_wplid = wpl_wplid
  join cdn.pracetaty on pre_praid=wpl_praid
  join cdn.kalendarze on kal_kalid = pre_kalid
  join cdn.listyplac on lpl_lplid = wpl_lplid
  where wpl_praid = @PrcId AND lpl_dataod>=@DataOd and lpl_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and @DataDo between pre_dataod and pre_datado and pre_zatrudnionyod <= @DataOd
  and twp_wliczchor = 1 and  TWP_SklZUS = 2 and twp_okreswyplaty=14
  order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
-- [JK] TFS:9827 dodano @PodstWyp, @PodstChor, @SumaSkladek
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @year, @TwpId, @PodstWyp, @PodstChor, @SumaSkladek
      IF @@FETCH_STATUS <> 0 BREAK
      --IF NOT EXISTS (SELECT 1 FROM #Z3_Roczny WHERE Tmp_Rok=@year AND Tmp_TwpId=@TwpId)
-- [JK] TFS:9827 dodano @PodstWyp, @PodstChor, @SumaSkladek
         INSERT INTO #Z3_Roczny values (@year, @Wartosc, @TwpId, @PodstWyp,@PodstChor,@SumaSkladek)
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
END
--
SET NOCOUNT OFF
SELECT
 sum(Tmp_WartWyp) as 'Tmp_WartWyp', Tmp_Rok, sum(@PodstWyp) as Tmp_PodstWyp, sum(@PodstChor) as Tmp_PodstChor, sum(@SumaSkladek) as Tmp_SumaSkl
FROM #Z3_Roczny
GROUP BY Tmp_Rok
ORDER BY Tmp_Rok ASC
