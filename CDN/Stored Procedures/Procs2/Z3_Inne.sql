CREATE PROCEDURE CDN.Z3_Inne @DataOd DATETIME ,@DataDo DATETIME, @PrcId INT, @ZasNaDzien DATETIME
AS
SET NOCOUNT ON
DECLARE @monthyear  INT
DECLARE @year       INT
DECLARE @month      INT
DECLARE @Wartosc    DECIMAL (15,2)
DECLARE @Okres      INT
DECLARE @SumaSkladek DECIMAL (15,2)
DECLARE @PodstWyp DECIMAL (15,2)
DECLARE @PodstChor DECIMAL (15,2)
SET @DataOd = CONVERT(DATETIME, @DataOd, 120)
SET @DataDo = CONVERT(DATETIME, @DataDo, 120)
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
 --Tworzę tabelę tymczasową, która zwracać będzie kwoty wypłat
 CREATE TABLE #Z3_Inne (
  Tmp_Okres        INT,
  Tmp_WartWyp      DECIMAL (15,2),
  Tmp_PodstWyp     DECIMAL (15,2),
  Tmp_PodstChor    DECIMAL (15,2),
  Tmp_SumaSkl      DECIMAL (15,2)
  )
-- Wstawiam kwoty z okresem co 2 miesiące
  DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  wpe_wartosc, twp_okreswyplaty, WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac  from  cdn.wypelementy
 join cdn.typwyplata on wpe_twpid=twp_twpid
 join cdn.wyplaty on wpe_wplid = wpl_wplid
 join cdn.pracetaty on pre_praid = wpl_praid
 join cdn.listyplac on lpl_lplid = wpl_lplid
 where wpl_praid = @PrcId and twp_okreswyplaty=4 AND
  WPL_Tryb<>1 and WPL_Tryb<>2 and
                lpl_dataod>=@DataOd and lpl_datado<=@DataDo
                and twp_wliczchor<>1
  -- TFS:247201 and wpe_podstchor<>0
  and @DataOd between pre_dataod and pre_datado and pre_zatrudnionyod <= @DataOd
          order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @Okres, @PodstWyp, @PodstChor, @SumaSkladek
      IF @@FETCH_STATUS <> 0 BREAK
      SET @Okres = @Okres - 2
      IF NOT EXISTS (SELECT 1 FROM #Z3_Inne WHERE Tmp_Okres=@Okres )
         INSERT INTO #Z3_Inne values (@Okres, @Wartosc, @PodstWyp,@PodstChor,@SumaSkladek)
      ELSE
         UPDATE #Z3_Inne set Tmp_WartWyp = Tmp_WartWyp + @Wartosc, Tmp_PodstWyp = Tmp_PodstWyp + @PodstWyp, Tmp_PodstChor = Tmp_PodstChor + @PodstChor,
                             Tmp_SumaSkl = Tmp_SumaSkl +  @SumaSkladek WHERE Tmp_Okres=@Okres
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
-- Wstawiam kwoty z okresem co 2 miesiące DRUGI RAZ
  DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  wpe_wartosc, A.twp_okreswyplaty, WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac
  from  cdn.wypelementy
  join cdn.typwyplata A on wpe_twpid = A.twp_twpid
  join cdn.wyplaty on wpe_wplid = wpl_wplid
  join cdn.pracetaty on pre_praid = wpl_praid
  join cdn.listyplac on lpl_lplid = wpl_lplid
 where
  wpl_praid = @PrcId
  and A.twp_okreswyplaty=4
  and A.TWP_WliczChorPodwojnie=1
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and lpl_dataod>=@DataOd and lpl_datado<=@DataDo
  and Month(wpl_DataDo) in (Month(Dateadd(mm, -2, @DataDo)), Month(Dateadd(mm, -3, @DataDo)))
  and A.twp_wliczchor<>1
  -- TFS:247201 and wpe_podstchor<>0
  and @DataOd between pre_dataod and pre_datado
  and pre_zatrudnionyod <= @DataOd
  and not exists (
   SELECT  wpe_wartosc, B.twp_okreswyplaty, WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac
   from  cdn.wypelementy
   join cdn.typwyplata B on wpe_twpid = B.twp_twpid
   join cdn.wyplaty on wpe_wplid = wpl_wplid
   join cdn.pracetaty on pre_praid = wpl_praid
   join cdn.listyplac on lpl_lplid = wpl_lplid
   where
    wpl_praid = @PrcId
    and B.twp_okreswyplaty=4
    and WPL_Tryb<>1 and WPL_Tryb<>2
    and Month(wpl_DataDo) in ( Month(@DataDo),  Month(Dateadd(mm, -1, @DataDo)))
    and B.TWP_WliczChorPodwojnie=1
    and lpl_dataod>=@DataOd and lpl_datado<=@DataDo
    and B.twp_wliczchor<>1
    -- TFS:247201 and wpe_podstchor<>0
    and A.TWP_TwpId = B.TWP_TwpId
    and @DataOd between pre_dataod and pre_datado
    and pre_zatrudnionyod <= @DataOd
  )
          order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @Okres, @PodstWyp, @PodstChor, @SumaSkladek
      IF @@FETCH_STATUS <> 0 BREAK
      SET @Okres = @Okres - 2
      IF NOT EXISTS (SELECT 1 FROM #Z3_Inne WHERE Tmp_Okres=@Okres )
         INSERT INTO #Z3_Inne values (@Okres, @Wartosc, @PodstWyp,@PodstChor,@SumaSkladek)
      ELSE
         UPDATE #Z3_Inne set Tmp_WartWyp = Tmp_WartWyp + @Wartosc, Tmp_PodstWyp = Tmp_PodstWyp + @PodstWyp, Tmp_PodstChor = Tmp_PodstChor + @PodstChor,
                             Tmp_SumaSkl = Tmp_SumaSkl +  @SumaSkladek WHERE Tmp_Okres=@Okres
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
-- Wstawiam kwoty z okresem co 4 miesiące
  DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  wpe_wartosc, twp_okreswyplaty, WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac from cdn.wypelementy
 join cdn.typwyplata on wpe_twpid=twp_twpid
 join cdn.wyplaty on wpe_wplid = wpl_wplid
 join cdn.pracetaty on pre_praid = wpl_praid
 join cdn.listyplac on lpl_lplid = wpl_lplid
        where wpl_praid = @PrcId and twp_okreswyplaty=6 AND
  WPL_Tryb<>1 and WPL_Tryb<>2 and
                lpl_dataod>=@DataOd and lpl_datado<=@DataDo and twp_wliczchor<>1
    -- TFS:247201 and wpe_podstchor<>0
    and @DataOd between pre_dataod and pre_datado and pre_zatrudnionyod <= @DataOd
          order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @Okres, @PodstWyp, @PodstChor, @SumaSkladek
      IF @@FETCH_STATUS <> 0 BREAK
      SET @Okres = @Okres - 2
      IF NOT EXISTS (SELECT 1 FROM #Z3_Inne WHERE Tmp_Okres=@Okres )
         INSERT INTO #Z3_Inne values (@Okres, @Wartosc, @PodstWyp,@PodstChor,@SumaSkladek)
      ELSE
         UPDATE #Z3_Inne set Tmp_WartWyp = Tmp_WartWyp + @Wartosc, Tmp_PodstWyp = Tmp_PodstWyp + @PodstWyp, Tmp_PodstChor = Tmp_PodstChor + @PodstChor,
                             Tmp_SumaSkl = Tmp_SumaSkl +  @SumaSkladek WHERE Tmp_Okres=@Okres
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
  -- Wstawiam kwoty z okresem co 4 miesiące DRUGI RAZ
  DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  wpe_wartosc, A.twp_okreswyplaty, WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac
 from cdn.wypelementy
 join cdn.typwyplata A on wpe_twpid = A.twp_twpid
 join cdn.wyplaty on wpe_wplid = wpl_wplid
 join cdn.pracetaty on pre_praid = wpl_praid
 join cdn.listyplac on lpl_lplid = wpl_lplid
    where wpl_praid = @PrcId
 and A.twp_okreswyplaty=6
 and WPL_Tryb<>1 and WPL_Tryb<>2
 and A.TWP_WliczChorPodwojnie=1
 and Month(wpl_DataDo) in ( Month(Dateadd(mm, -4, @DataDo)), Month(Dateadd(mm, -5, @DataDo)),  Month(Dateadd(mm, -6, @DataDo)), Month(Dateadd(mm, -7, @DataDo)))
 and lpl_dataod>=@DataOd and lpl_datado<=@DataDo
 and A.twp_wliczchor<>1
 -- TFS:247201 and wpe_podstchor<>0
 and @DataOd between pre_dataod and pre_datado
 and pre_zatrudnionyod <= @DataOd
 and  not exists (
 SELECT  wpe_wartosc, B.twp_okreswyplaty, WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac
 from cdn.wypelementy
  join cdn.typwyplata B on wpe_twpid= B.twp_twpid
  join cdn.wyplaty on wpe_wplid = wpl_wplid
  join cdn.pracetaty on pre_praid = wpl_praid
  join cdn.listyplac on lpl_lplid = wpl_lplid
  where wpl_praid = @PrcId
   and B.twp_okreswyplaty=6
   and WPL_Tryb<>1 and WPL_Tryb<>2
   and A.TWP_TwpId = B.TWP_TwpId
   and B.TWP_WliczChorPodwojnie=1
   and lpl_dataod>=@DataOd and lpl_datado<=@DataDo
   and B.twp_wliczchor<>1
   -- TFS:247201 and wpe_podstchor<>0
   and @DataOd between pre_dataod and pre_datado
   and pre_zatrudnionyod <= @DataOd
   and Month(wpl_DataDo) in ( Month(@DataDo),  Month(Dateadd(mm, -1, @DataDo)),  Month(Dateadd(mm, -2, @DataDo)), Month(Dateadd(mm, -3, @DataDo)))
 )
    order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @Okres, @PodstWyp, @PodstChor, @SumaSkladek
      IF @@FETCH_STATUS <> 0 BREAK
      SET @Okres = @Okres - 2
      IF NOT EXISTS (SELECT 1 FROM #Z3_Inne WHERE Tmp_Okres=@Okres )
         INSERT INTO #Z3_Inne values (@Okres, @Wartosc, @PodstWyp,@PodstChor,@SumaSkladek)
      ELSE
         UPDATE #Z3_Inne set Tmp_WartWyp = Tmp_WartWyp + @Wartosc, Tmp_PodstWyp = Tmp_PodstWyp + @PodstWyp, Tmp_PodstChor = Tmp_PodstChor + @PodstChor,
                             Tmp_SumaSkl = Tmp_SumaSkl +  @SumaSkladek WHERE Tmp_Okres=@Okres
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
-- Wstawiam kwoty z okresem co 6 miesięcy
  DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  wpe_wartosc, twp_okreswyplaty, WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac from cdn.wypelementy
  join cdn.typwyplata on wpe_twpid=twp_twpid
  join cdn.wyplaty on wpe_wplid = wpl_wplid
  join cdn.pracetaty on pre_praid = wpl_praid
  join cdn.listyplac on lpl_lplid = wpl_lplid
           where wpl_praid = @PrcId and twp_okreswyplaty=8 AND
   WPL_Tryb<>1 and WPL_Tryb<>2
  and @DataOd between pre_dataod and pre_datado and pre_zatrudnionyod <= @DataOd AND
                 lpl_dataod>=@DataOd and lpl_datado<=@DataDo and
                 twp_wliczchor<>1
     -- TFS:247201 and wpe_podstchor<>0
     and pre_zatrudnionyod <= @DataOd
           order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @Okres, @PodstWyp, @PodstChor, @SumaSkladek
      IF @@FETCH_STATUS <> 0 BREAK
      SET @Okres = @Okres - 2
      IF NOT EXISTS (SELECT 1 FROM #Z3_Inne WHERE Tmp_Okres=@Okres )
         INSERT INTO #Z3_Inne values (@Okres, @Wartosc, @PodstWyp,@PodstChor,@SumaSkladek)
      ELSE
         UPDATE #Z3_Inne set Tmp_WartWyp = Tmp_WartWyp + @Wartosc, Tmp_PodstWyp = Tmp_PodstWyp + @PodstWyp, Tmp_PodstChor = Tmp_PodstChor + @PodstChor,
                             Tmp_SumaSkl = Tmp_SumaSkl +  @SumaSkladek WHERE Tmp_Okres=@Okres
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
  -- Wstawiam kwoty z okresem co 6 miesięcy DRUGI RAZ
  DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  wpe_wartosc, twp_okreswyplaty, WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac
  from cdn.wypelementy
  join cdn.typwyplata A on wpe_twpid= A.twp_twpid
  join cdn.wyplaty on wpe_wplid = wpl_wplid
  join cdn.pracetaty on pre_praid = wpl_praid
  join cdn.listyplac on lpl_lplid = wpl_lplid
        where wpl_praid = @PrcId and twp_okreswyplaty=8
  and WPL_Tryb<>1 and WPL_Tryb<>2
  and A.TWP_WliczChorPodwojnie=1
  and Month(wpl_DataDo) in ( Month(Dateadd(mm, -6, @DataDo)), Month(Dateadd(mm, -7, @DataDo)),  Month(Dateadd(mm, -8, @DataDo)), Month(Dateadd(mm, -9, @DataDo)), Month(Dateadd(mm, -10, @DataDo)), Month(Dateadd(mm, -11, @DataDo)))
  and @DataOd between pre_dataod and pre_datado
  and pre_zatrudnionyod <= @DataOd
  and lpl_dataod>=@DataOd and lpl_datado<=@DataDo
  and A.twp_wliczchor<>1
  -- TFS:247201 and wpe_podstchor<>0
  and pre_zatrudnionyod <= @DataOd
  and  not exists (
  SELECT  wpe_wartosc, B.twp_okreswyplaty, WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac
  from cdn.wypelementy
   join cdn.typwyplata B on wpe_twpid= B.twp_twpid
   join cdn.wyplaty on wpe_wplid = wpl_wplid
   join cdn.pracetaty on pre_praid = wpl_praid
   join cdn.listyplac on lpl_lplid = wpl_lplid
   where wpl_praid = @PrcId and B.twp_okreswyplaty=8
    and WPL_Tryb<>1 and WPL_Tryb<>2
    and B.TWP_WliczChorPodwojnie=1
    and A.TWP_TwpId = B.TWP_TwpId
    and @DataOd between pre_dataod and pre_datado
    and pre_zatrudnionyod <= @DataOd
    and lpl_dataod>=@DataOd and lpl_datado<=@DataDo
    and B.twp_wliczchor<>1
    -- TFS:247201 and wpe_podstchor<>0
    and pre_zatrudnionyod <= @DataOd
    and Month(wpl_DataDo) in ( Month(@DataDo),  Month(Dateadd(mm, -1, @DataDo)),  Month(Dateadd(mm, -2, @DataDo)), Month(Dateadd(mm, -3, @DataDo)), Month(Dateadd(mm, -4, @DataDo)), Month(Dateadd(mm, -5, @DataDo)))
    )
           order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @Okres, @PodstWyp, @PodstChor, @SumaSkladek
      IF @@FETCH_STATUS <> 0 BREAK
      SET @Okres = @Okres - 2
      IF NOT EXISTS (SELECT 1 FROM #Z3_Inne WHERE Tmp_Okres=@Okres )
         INSERT INTO #Z3_Inne values (@Okres, @Wartosc, @PodstWyp,@PodstChor,@SumaSkladek)
      ELSE
         UPDATE #Z3_Inne set Tmp_WartWyp = Tmp_WartWyp + @Wartosc, Tmp_PodstWyp = Tmp_PodstWyp + @PodstWyp, Tmp_PodstChor = Tmp_PodstChor + @PodstChor,
                             Tmp_SumaSkl = Tmp_SumaSkl +  @SumaSkladek WHERE Tmp_Okres=@Okres
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
-- Wstawiam dopłaty do nadgodzin - ustawione w kalendarzu co 2 miesiące
  DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  wpe_wartosc, twp_okreswyplaty, WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac from cdn.wypelementy
  join cdn.typwyplata on wpe_twpid=twp_twpid
  join cdn.wyplaty on wpe_wplid = wpl_wplid
  join cdn.pracetaty on pre_praid=wpl_praid
  join cdn.kalendarze on kal_kalid = pre_kalid
  join cdn.listyplac on lpl_lplid = wpl_lplid
           where wpl_praid = @PrcId and twp_standardowy in (6,7,8,28) AND
  WPL_Tryb<>1 and WPL_Tryb<>2 and
                lpl_dataod>=@DataOd and lpl_datado<=@DataDo and
                twp_wliczchor<>1 and wpe_podstchor<>0 and kal_nadgodzokres=2 and @DataDo between pre_dataod and pre_datado and pre_zatrudnionyod <= @DataOd
          order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @Okres, @PodstWyp, @PodstChor, @SumaSkladek
      IF @@FETCH_STATUS <> 0 BREAK
      SET @Okres = @Okres - 2
      IF NOT EXISTS (SELECT 1 FROM #Z3_Inne WHERE Tmp_Okres=@Okres )
         INSERT INTO #Z3_Inne values (@Okres, @Wartosc, @PodstWyp,@PodstChor,@SumaSkladek)
      ELSE
         UPDATE #Z3_Inne set Tmp_WartWyp = Tmp_WartWyp + @Wartosc, Tmp_PodstWyp = Tmp_PodstWyp + @PodstWyp, Tmp_PodstChor = Tmp_PodstChor + @PodstChor,
                             Tmp_SumaSkl = Tmp_SumaSkl +  @SumaSkladek WHERE Tmp_Okres=@Okres
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
-- Wstawiam dopłaty do nadgodzin - ustawione w kalendarzu co 4 miesiące
  DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  wpe_wartosc, twp_okreswyplaty, WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac from cdn.wypelementy
  join cdn.typwyplata on wpe_twpid=twp_twpid
  join cdn.wyplaty on wpe_wplid = wpl_wplid
  join cdn.pracetaty on pre_praid=wpl_praid
  join cdn.kalendarze on kal_kalid = pre_kalid
  join cdn.listyplac on lpl_lplid = wpl_lplid
           where wpl_praid = @PrcId and twp_standardowy in (6,7,8,28) AND
  WPL_Tryb<>1 and WPL_Tryb<>2 and
                lpl_dataod>=@DataOd and lpl_datado<=@DataDo and
                twp_wliczchor<>1 and wpe_podstchor<>0 and kal_nadgodzokres=4 and @DataDo between pre_dataod and pre_datado and pre_zatrudnionyod <= @DataOd
          order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @Okres, @PodstWyp,@PodstChor,@SumaSkladek
      IF @@FETCH_STATUS <> 0 BREAK
      SET @Okres = @Okres - 2
      IF NOT EXISTS (SELECT 1 FROM #Z3_Inne WHERE Tmp_Okres=@Okres )
         INSERT INTO #Z3_Inne values (@Okres, @Wartosc, @PodstWyp,@PodstChor,@SumaSkladek)
      ELSE
         UPDATE #Z3_Inne set Tmp_WartWyp = Tmp_WartWyp + @Wartosc, Tmp_PodstWyp = Tmp_PodstWyp + @PodstWyp, Tmp_PodstChor = Tmp_PodstChor + @PodstChor,
                             Tmp_SumaSkl = Tmp_SumaSkl +  @SumaSkladek WHERE Tmp_Okres=@Okres
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
-- Wstawiam dopłaty do nadgodzin - ustawione w kalendarzu co 5 lub 6 miesięcy
  DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  wpe_wartosc, twp_okreswyplaty, WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac from cdn.wypelementy
  join cdn.typwyplata on wpe_twpid=twp_twpid
  join cdn.wyplaty on wpe_wplid = wpl_wplid
  join cdn.pracetaty on pre_praid=wpl_praid
  join cdn.kalendarze on kal_kalid = pre_kalid
  join cdn.listyplac on lpl_lplid = wpl_lplid
           where wpl_praid = @PrcId and twp_standardowy in (6,7,8,28) AND
  WPL_Tryb<>1 and WPL_Tryb<>2 and
                lpl_dataod>=@DataOd and lpl_datado<=@DataDo and
                twp_wliczchor<>1 and wpe_podstchor<>0 and kal_nadgodzokres in (5,6) and @DataDo between pre_dataod and pre_datado and pre_zatrudnionyod <= @DataOd
          order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @Okres, @PodstWyp,@PodstChor,@SumaSkladek
      IF @@FETCH_STATUS <> 0 BREAK
      SET @Okres = @Okres - 2
      IF NOT EXISTS (SELECT 1 FROM #Z3_Inne WHERE Tmp_Okres=@Okres )
         INSERT INTO #Z3_Inne values (@Okres, @Wartosc, @PodstWyp,@PodstChor,@SumaSkladek)
      ELSE
         UPDATE #Z3_Inne set Tmp_WartWyp = Tmp_WartWyp + @Wartosc, Tmp_PodstWyp = Tmp_PodstWyp + @PodstWyp, Tmp_PodstChor = Tmp_PodstChor + @PodstChor,
                             Tmp_SumaSkl = Tmp_SumaSkl +  @SumaSkladek WHERE Tmp_Okres=@Okres
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
-- Wstawiam dopłaty do nadgodzin - ustawione w kalendarzu co 7,8,9,10,11 lub 12 miesięcy
  DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  wpe_wartosc, twp_okreswyplaty, WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac from cdn.wypelementy
  join cdn.typwyplata on wpe_twpid=twp_twpid
  join cdn.wyplaty on wpe_wplid = wpl_wplid
  join cdn.pracetaty on pre_praid=wpl_praid
  join cdn.kalendarze on kal_kalid = pre_kalid
  join cdn.listyplac on lpl_lplid = wpl_lplid
           where wpl_praid = @PrcId and twp_standardowy in (6,7,8,28) AND
  WPL_Tryb<>1 and WPL_Tryb<>2 and
                lpl_dataod>=@DataOd and lpl_datado<=@DataDo and
                twp_wliczchor<>1 and wpe_podstchor<>0 and kal_nadgodzokres > 6 and kal_nadgodzokres <>12 and @DataDo between pre_dataod and pre_datado and pre_zatrudnionyod <= @DataOd
          order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @Okres, @PodstWyp,@PodstChor,@SumaSkladek
      IF @@FETCH_STATUS <> 0 BREAK
      SET @Okres = @Okres - 2
      IF NOT EXISTS (SELECT 1 FROM #Z3_Inne WHERE Tmp_Okres=@Okres )
         INSERT INTO #Z3_Inne values (@Okres, @Wartosc, @PodstWyp,@PodstChor,@SumaSkladek)
      ELSE
         UPDATE #Z3_Inne set Tmp_WartWyp = Tmp_WartWyp + @Wartosc, Tmp_PodstWyp = Tmp_PodstWyp + @PodstWyp, Tmp_PodstChor = Tmp_PodstChor + @PodstChor,
                             Tmp_SumaSkl = Tmp_SumaSkl +  @SumaSkladek WHERE Tmp_Okres=@Okres
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
--
IF @ZasPoZwol = 1
BEGIN
-- Wstawiam kwoty z okresem co 2 miesiące
  DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  wpe_wartosc, twp_okreswyplaty, WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac  from  cdn.wypelementy
 join cdn.typwyplata on wpe_twpid=twp_twpid
 join cdn.wyplaty on wpe_wplid = wpl_wplid
 join cdn.pracetaty on pre_praid = wpl_praid
 join cdn.listyplac on lpl_lplid = wpl_lplid
 where wpl_praid = @PrcId and twp_okreswyplaty=4 AND
  WPL_Tryb<>1 and WPL_Tryb<>2 and
                lpl_dataod>=@DataOd and lpl_datado<=@DataDo
                and twp_wliczchor = 1 and TWP_SklZUS = 2
  and @DataOd between pre_dataod and pre_datado and pre_zatrudnionyod <= @DataOd
          order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @Okres, @PodstWyp, @PodstChor, @SumaSkladek
      IF @@FETCH_STATUS <> 0 BREAK
      SET @Okres = @Okres - 2
      IF NOT EXISTS (SELECT 1 FROM #Z3_Inne WHERE Tmp_Okres=@Okres )
         INSERT INTO #Z3_Inne values (@Okres, @Wartosc, @PodstWyp,@PodstChor,@SumaSkladek)
      ELSE
         UPDATE #Z3_Inne set Tmp_WartWyp = Tmp_WartWyp + @Wartosc, Tmp_PodstWyp = Tmp_PodstWyp + @PodstWyp, Tmp_PodstChor = Tmp_PodstChor + @PodstChor,
                             Tmp_SumaSkl = Tmp_SumaSkl +  @SumaSkladek WHERE Tmp_Okres=@Okres
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
-- Wstawiam kwoty z okresem co 4 miesiące
  DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  wpe_wartosc, twp_okreswyplaty, WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac from cdn.wypelementy
 join cdn.typwyplata on wpe_twpid=twp_twpid
 join cdn.wyplaty on wpe_wplid = wpl_wplid
 join cdn.pracetaty on pre_praid = wpl_praid
 join cdn.listyplac on lpl_lplid = wpl_lplid
        where wpl_praid = @PrcId and twp_okreswyplaty=6 AND
  WPL_Tryb<>1 and WPL_Tryb<>2 and
                lpl_dataod>=@DataOd and lpl_datado<=@DataDo and twp_wliczchor = 1 and TWP_SklZUS = 2
    and @DataOd between pre_dataod and pre_datado and pre_zatrudnionyod <= @DataOd
          order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @Okres, @PodstWyp, @PodstChor, @SumaSkladek
      IF @@FETCH_STATUS <> 0 BREAK
      SET @Okres = @Okres - 2
      IF NOT EXISTS (SELECT 1 FROM #Z3_Inne WHERE Tmp_Okres=@Okres )
         INSERT INTO #Z3_Inne values (@Okres, @Wartosc, @PodstWyp,@PodstChor,@SumaSkladek)
      ELSE
         UPDATE #Z3_Inne set Tmp_WartWyp = Tmp_WartWyp + @Wartosc, Tmp_PodstWyp = Tmp_PodstWyp + @PodstWyp, Tmp_PodstChor = Tmp_PodstChor + @PodstChor,
                             Tmp_SumaSkl = Tmp_SumaSkl +  @SumaSkladek WHERE Tmp_Okres=@Okres
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
-- Wstawiam kwoty z okresem co 6 miesięcy
  DECLARE Tmp_cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT  wpe_wartosc, twp_okreswyplaty, WPE_PodstWypad, WPE_PodstChor, WPE_SklEmerPrac+WPE_SklRentPrac+WPE_SklChorPrac from cdn.wypelementy
  join cdn.typwyplata on wpe_twpid=twp_twpid
  join cdn.wyplaty on wpe_wplid = wpl_wplid
  join cdn.pracetaty on pre_praid = wpl_praid
  join cdn.listyplac on lpl_lplid = wpl_lplid
           where wpl_praid = @PrcId and twp_okreswyplaty=8 AND
   WPL_Tryb<>1 and WPL_Tryb<>2
  and @DataOd between pre_dataod and pre_datado and pre_zatrudnionyod <= @DataOd AND
                 lpl_dataod>=@DataOd and lpl_datado<=@DataDo and
                 twp_wliczchor = 1 and TWP_SklZUS = 2
     and pre_zatrudnionyod <= @DataOd
           order by wpl_dataod desc
  OPEN Tmp_cursor
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_cursor INTO @Wartosc, @Okres, @PodstWyp, @PodstChor, @SumaSkladek
      IF @@FETCH_STATUS <> 0 BREAK
      SET @Okres = @Okres - 2
      IF NOT EXISTS (SELECT 1 FROM #Z3_Inne WHERE Tmp_Okres=@Okres )
         INSERT INTO #Z3_Inne values (@Okres, @Wartosc, @PodstWyp,@PodstChor,@SumaSkladek)
      ELSE
         UPDATE #Z3_Inne set Tmp_WartWyp = Tmp_WartWyp + @Wartosc, Tmp_PodstWyp = Tmp_PodstWyp + @PodstWyp, Tmp_PodstChor = Tmp_PodstChor + @PodstChor,
                             Tmp_SumaSkl = Tmp_SumaSkl +  @SumaSkladek WHERE Tmp_Okres=@Okres
  END
  CLOSE Tmp_cursor
  DEALLOCATE Tmp_cursor
END
SET NOCOUNT OFF
SELECT
 *
FROM #Z3_Inne
ORDER BY Tmp_Okres ASC
