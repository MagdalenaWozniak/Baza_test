CREATE PROCEDURE CDN.Z3_Quart @DataOd DATETIME , @DataDo DATETIME, @PrcId INT, @ZasNaDzien DATETIME
AS
SET NOCOUNT ON
DECLARE @monthyear  INT
DECLARE @year       INT
DECLARE @month      INT
DECLARE @quart      INT
--
DECLARE @Id      INT
--
DECLARE @Wartosc    DECIMAL (15,2)
DECLARE @MonthDekl  INT
DECLARE @RozlNadg INT
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
 CREATE TABLE #Z3_Quart (
  Tmp_Rok          INT,
  Tmp_Kwartal      INT,
  Tmp_WartWyp      DECIMAL (15,2),
  Tmp_PodstWyp     DECIMAL (15,2),
  Tmp_PodstChor    DECIMAL (15,2),
  Tmp_SumaSkl      DECIMAL (15,2)
  )
-- Wstawiam kwoty z okresem co 3 miesiace
  DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  wpe_wartosc, Year(wpl_DataDo), Month(wpl_DataDo), WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac
  from cdn.wypelementy
  join cdn.typwyplata on wpe_twpid=twp_twpid
  join cdn.wyplaty on wpe_wplid = wpl_wplid
  join cdn.pracetaty on pre_praid = wpl_praid
  join cdn.listyplac on lpl_lplid = wpl_lplid
  where wpl_praid = @PrcId AND lpl_dataod>=@DataOd and lpl_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and @DataDo between pre_dataod and pre_datado
  and @DataDo between pre_zatrudnionyod and pre_zatrudnionydo
  and ((twp_okreswyplaty=5 and twp_wliczchor<>1))
  -- TFS:247201 and wpe_podstchor<>0) )
  order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @year, @MonthDekl , @PodstWyp, @PodstChor, @SumaSkladek
      IF @@FETCH_STATUS <> 0 BREAK
      IF @MonthDekl % 3 = 0
         SET @quart = @MonthDekl / 3
      ELSE
         SET @quart = (@MonthDekl / 3)+1
      IF NOT EXISTS (SELECT 1 FROM #Z3_Quart WHERE Tmp_Rok=@year AND Tmp_Kwartal=@quart)
         INSERT INTO #Z3_Quart values (@year, @quart, @Wartosc, @PodstWyp,@PodstChor,@SumaSkladek)
      ELSE
         UPDATE #Z3_Quart SET Tmp_WartWyp = Tmp_WartWyp + @Wartosc, Tmp_PodstWyp = Tmp_PodstWyp + @PodstWyp, Tmp_PodstChor = Tmp_PodstChor + @PodstChor,
                              Tmp_SumaSkl = Tmp_SumaSkl +  @SumaSkladek WHERE Tmp_Rok=@year AND Tmp_Kwartal=@quart
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
-- Wstawiam kwoty z okresem co 3 miesiace DRUGI raz
  DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  wpe_wartosc, Year(wpl_DataDo), Month(wpl_DataDo), WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac, A.TWP_TwpId
  from cdn.wypelementy
  join cdn.typwyplata A on wpe_twpid = A.twp_twpid
  join cdn.wyplaty on wpe_wplid = wpl_wplid
  join cdn.pracetaty on pre_praid = wpl_praid
  join cdn.listyplac on lpl_lplid = wpl_lplid
  where wpl_praid = @PrcId AND lpl_dataod>=@DataOd and lpl_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and Month(wpl_DataDo) in (  Month(Dateadd(mm,-5, @DataDo)), Month(Dateadd(mm,-4, @DataDo)) ,Month(Dateadd(mm,-3, @DataDo))  )
  and @DataDo between pre_dataod and pre_datado
  and @DataDo between pre_zatrudnionyod and pre_zatrudnionydo
  and ((A.TWP_WliczChorPodwojnie=1 and A.twp_okreswyplaty=5 and A.twp_wliczchor<>1 ))
  -- TFS:247201 and wpe_podstchor<>0) )
  and not exists (
  SELECT  wpe_wartosc, Year(wpl_DataDo), Month(wpl_DataDo), WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac, B.TWP_TwpId
  from cdn.wypelementy
  join cdn.typwyplata B on wpe_twpid = B.twp_twpid
  join cdn.wyplaty on wpe_wplid = wpl_wplid
  join cdn.pracetaty on pre_praid = wpl_praid
  join cdn.listyplac on lpl_lplid = wpl_lplid
  where wpl_praid = @PrcId AND lpl_dataod>=@DataOd and lpl_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and A.TWP_TwpId = B.TWP_TwpId
  and Month(wpl_DataDo) in ( Month(@DataDo),  Month(Dateadd(mm, -1, @DataDo)),  Month(Dateadd(mm, -2, @DataDo)))
  and @DataDo between pre_dataod and pre_datado
  and @DataDo between pre_zatrudnionyod and pre_zatrudnionydo
  and ((B.TWP_WliczChorPodwojnie=1 and B.twp_okreswyplaty=5 and B.twp_wliczchor<>1) )
  -- TFS:247201 and wpe_podstchor<>0) )
  )
  order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @year, @MonthDekl , @PodstWyp, @PodstChor, @SumaSkladek, @Id
      IF @@FETCH_STATUS <> 0 BREAK
      IF @MonthDekl % 3 = 0
         SET @quart = @MonthDekl / 3
      ELSE
         SET @quart = (@MonthDekl / 3)+1
      IF NOT EXISTS (SELECT 1 FROM #Z3_Quart WHERE Tmp_Rok=@year AND Tmp_Kwartal=@quart)
         INSERT INTO #Z3_Quart values (@year, @quart, @Wartosc, @PodstWyp,@PodstChor,@SumaSkladek)
      ELSE
         UPDATE #Z3_Quart SET Tmp_WartWyp = Tmp_WartWyp + @Wartosc, Tmp_PodstWyp = Tmp_PodstWyp + @PodstWyp, Tmp_PodstChor = Tmp_PodstChor + @PodstChor,
                              Tmp_SumaSkl = Tmp_SumaSkl +  @SumaSkladek WHERE Tmp_Rok=@year AND Tmp_Kwartal=@quart
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
-- Wstawiam kwoty z doplat do nadgodzin
  DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  wpe_wartosc, Year(wpl_DataDo), Month(wpl_DataDo),WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac
  from cdn.wypelementy
  join cdn.typwyplata on wpe_twpid=twp_twpid
  join cdn.wyplaty on wpe_wplid = wpl_wplid
  join cdn.pracetaty on pre_praid=wpl_praid
  join cdn.kalendarze on kal_kalid = pre_kalid
  join cdn.listyplac on lpl_lplid = wpl_lplid
  where wpl_praid = @PrcId and twp_Standardowy in (6,7,8,28)
  and WPL_Tryb<>1 and WPL_Tryb<>2
  AND lpl_dataod>=@DataOd and lpl_datado<=@DataDo
  and @DataDo between pre_dataod and pre_datado
  and @DataDo between pre_zatrudnionyod and pre_zatrudnionydo
  and twp_wliczchor<>1 and wpe_podstchor<>0
  and kal_nadgodzokres=3
  order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @year, @MonthDekl,@PodstWyp, @PodstChor, @SumaSkladek
      IF @@FETCH_STATUS <> 0 BREAK
      IF @MonthDekl % 3 = 0
         SET @quart = @MonthDekl / 3
      ELSE
         SET @quart = (@MonthDekl / 3)+1
      IF NOT EXISTS (SELECT 1 FROM #Z3_Quart WHERE Tmp_Rok=@year AND Tmp_Kwartal=@quart)
         INSERT INTO #Z3_Quart values (@year, @quart, @Wartosc,@PodstWyp, @PodstChor, @SumaSkladek )
      ELSE
         UPDATE #Z3_Quart SET Tmp_WartWyp = Tmp_WartWyp + @Wartosc, Tmp_PodstWyp = Tmp_PodstWyp + @PodstWyp, Tmp_PodstChor = Tmp_PodstChor + @PodstChor,
                              Tmp_SumaSkl = Tmp_SumaSkl +  @SumaSkladek WHERE Tmp_Rok=@year AND Tmp_Kwartal=@quart
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
-- [JK] TFS:154587
IF @ZasPoZwol = 1
 BEGIN
  DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  wpe_wartosc, Year(wpl_DataDo), Month(wpl_DataDo), WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac
  from cdn.wypelementy
  join cdn.typwyplata on wpe_twpid=twp_twpid
  join cdn.wyplaty on wpe_wplid = wpl_wplid
  join cdn.pracetaty on pre_praid = wpl_praid
  join cdn.listyplac on lpl_lplid = wpl_lplid
  where wpl_praid = @PrcId AND lpl_dataod>=@DataOd and lpl_datado<=@DataDo
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and @DataDo between pre_dataod and pre_datado
  and @DataDo between pre_zatrudnionyod and pre_zatrudnionydo
  and twp_okreswyplaty=5 and twp_wliczchor = 1 and TWP_SklZUS = 2
  order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @year, @MonthDekl , @PodstWyp, @PodstChor, @SumaSkladek
      IF @@FETCH_STATUS <> 0 BREAK
      IF @MonthDekl % 3 = 0
         SET @quart = @MonthDekl / 3
      ELSE
         SET @quart = (@MonthDekl / 3)+1
      IF NOT EXISTS (SELECT 1 FROM #Z3_Quart WHERE Tmp_Rok=@year AND Tmp_Kwartal=@quart)
         INSERT INTO #Z3_Quart values (@year, @quart, @Wartosc, @PodstWyp,@PodstChor,@SumaSkladek)
      ELSE
         UPDATE #Z3_Quart SET Tmp_WartWyp = Tmp_WartWyp + @Wartosc, Tmp_PodstWyp = Tmp_PodstWyp + @PodstWyp, Tmp_PodstChor = Tmp_PodstChor + @PodstChor,
                              Tmp_SumaSkl = Tmp_SumaSkl +  @SumaSkladek WHERE Tmp_Rok=@year AND Tmp_Kwartal=@quart
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
  END
--
SET NOCOUNT OFF
SELECT
 *
FROM #Z3_Quart
ORDER BY Tmp_Rok ASC , Tmp_Kwartal ASC
