CREATE PROCEDURE [CDN].[PodajCzasPracyDzien] @data datetime, @kalid int, @praid int,  @which int, @NormaDob INT, @Etatl INT, @Etatm INT
AS
--Zmienne kwantowe
declare @RozlWg int
declare @typdnia int
declare @nb     int
declare @odgodz datetime
declare @dogodz datetime
declare @strefa int
declare @czas1  int
declare @czas2  int
declare @czasP  int
declare @strefaundefined int
declare @strefastandard int
declare @wliczaj int
declare @TnbPomnCzasPracy int
declare @godzinyNb int
declare @godzinyTemp int
--Zmienne podsumowywujące
declare @czas int
declare @czasTmp int
declare @datemin datetime
set @datemin = CONVERT(datetime,'1899.12.30',102)
--[JK] TFS: 148787
SET @czas  = 0
SET @czas1 = 0
SET @czas2 = 0
SELECT @typdnia = ppl_typdnia from cdn.pracplandni where ppl_data=@data and ppl_praid=@praid
SET @strefaundefined = (select dst_dstid from cdn.definicjestref where dst_standardowy=99)
--select @nb = isnull(Tmp_PnbId,0) from #CzasPracy where tmp_Data = @data and Tmp_Typ=1
select @nb = PNB_Calodzienna from CDN.PracNieobec,#CzasPracy where Tmp_PnbId = PNB_PnBId and tmp_Data = @data and Tmp_Typ=1
select @godzinyNb = SUM(DATEDIFF(minute, @datemin,PNB_Godz)) from  CDN.PracNieobec join CDN.TypNieobec on PnB_TnBId = TnB_TnBId where PNB_PraId=@praid and @data between PNB_OkresOd and PNB_OkresDo and Pnb_Tryb<>1 and PnB_Calodzienna = 0 and tnb_pomnczaspracy = 1
IF isnull(@godzinyNb,0) = 0
  SET @godzinyNb = 0
set @godzinyTemp = @godzinyNb
SET @RozlWg =(select pre_ZestCzasuPracy from CDN.PracKod join cdn.pracetaty on pre_praid=pra_praid where pra_praid=@PraId and pre_dataod<=@data and pre_datado>=@data)
SET @TnbPomnCzasPracy = (
    select tnb_pomnczaspracy from cdn.typnieobec
    where tnb_tnbid=
    (
      select isnull(pnb_tnbid,0) from cdn.pracnieobec
      where pnb_pnbid = (select max(TMP_PNBID) from #CzasPracy where Tmp_Data = @data And Tmp_Typ=1)
    )
)
IF @which=1 -- KalendDni
BEGIN
  delete from #CzasPracy WHERE Tmp_Typ=3 AND Tmp_Data=@data AND Tmp_Data=@data
  BEGIN
   DECLARE Tmp_Czas CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   select kdg_odgodziny, kdg_dogodziny, KDG_Strefa, dst_uwzglczaspracy from cdn.kalenddni join cdn.KalendDniGodz on KAD_KadId = KDG_KadId join cdn.definicjestref on KDG_Strefa=dst_dstid where kad_data=@data and kad_kalid=@kalid
        OPEN Tmp_Czas
  WHILE 1=1
BEGIN
 FETCH NEXT FROM Tmp_Czas INTO @odgodz,@dogodz,@strefa,@wliczaj
 IF @@FETCH_STATUS <> 0 BREAK
  -- [JK] TFS:148963 select @wliczaj = dst_uwzglczaspracy from cdn.definicjestref where dst_dstid=@strefa
  IF @wliczaj=0
  -- [JK] TFS:148963
     SET @czas2 = 0
  IF @strefa<>@strefaundefined
  BEGIN
     exec @czas2 = CDN.PodajCzasPracyS @data, @odgodz, @dogodz, 1, @strefa
     SET @czas2 = CEILING((@czas2*CONVERT(real,@Etatl))/@Etatm)
      --[JK] TFS:152217
     IF @godzinyNb > @czas2
         BEGIN
         set @godzinyNb = @godzinyNb -  @czas2
         set @czas2 = 0
         END
     ELSE
     BEGIN
        set @czas2 = @czas2 - @godzinyNb
        set @godzinyNb = 0
     END
   --
     SET @czas1 = @czas1 + @czas2
     SET @czasP = @czas1
     if @nb<>0 and @TnbPomnCzasPracy=1
     BEGIN
        SET @czasP = 0
     END
     IF @typdnia<>1
     BEGIN
        SET @czas1 = 0
     END
 /* --[JK] TFS:152217
  IF @godzinyNb > @czasP
         BEGIN
      set @godzinyNb = @godzinyNb -  @czasP
      set @czasP = 0
      END
   ELSE
   BEGIN
        set @czasP = @czasP - @godzinyNb
     set @godzinyNb = 0
   END
   */
  IF NOT EXISTS (SELECT 1 FROM #CzasPracy WHERE Tmp_Typ=3 AND Tmp_DstId=@strefa and Tmp_Data=@data)
       INSERT INTO #CzasPracy values (
          3, @praid,null,null,null,@data,null,0,@czas1,0,0,0,0,@czasP,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,NULL,0,@strefa) -- SB 2021 [12263] --
     ELSE
       UPDATE #CzasPracy SET Tmp_Praca = Tmp_Praca + @czasP, Tmp_NormaDob = Tmp_NormaDob + @czas1 WHERE Tmp_DstId=@strefa AND Tmp_Typ=3 AND Tmp_Data=@data
     IF @nb<>0 and @TnbPomnCzasPracy=1
         SET @czasP = @czas1
     SET @czas = @czasP
  END
END
CLOSE Tmp_Czas
DEALLOCATE Tmp_Czas
END
END
ELSE IF @which=2 -- PracPlanDni
BEGIN
  delete from #CzasPracy WHERE Tmp_Typ=3 AND Tmp_Data=@data AND Tmp_Data=@data
  BEGIN
   DECLARE Tmp_Czas CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   select PGL_OdGodziny,PGL_DoGodziny,PGL_Strefa,dst_uwzglczaspracy  from cdn.PracPlanDni join cdn.PracPlanDniGodz on PPL_PplId = PGL_PplId join cdn.definicjestref on PGL_Strefa=dst_dstid where PPL_Data=@data and PPL_PraId=@praid
        OPEN Tmp_Czas
  WHILE 1=1
BEGIN
 FETCH NEXT FROM Tmp_Czas INTO @odgodz,@dogodz,@strefa,@wliczaj
 IF @@FETCH_STATUS <> 0 BREAK
  -- [JK] TFS:148963 select @wliczaj = dst_uwzglczaspracy from cdn.definicjestref where dst_dstid=@strefa
  IF @wliczaj=0
  -- [JK] TFS:148963
     SET @czas2 = 0
  IF @strefa<>@strefaundefined
  BEGIN
     exec @czas2 = CDN.PodajCzasPracyS @data, @odgodz, @dogodz, 1, @strefa
     --[JK] TFS:152217
     IF @godzinyNb > @czas2
         BEGIN
         set @godzinyNb = @godzinyNb -  @czas2
         set @czas2 = 0
         END
     ELSE
     BEGIN
        set @czas2 = @czas2 - @godzinyNb
        set @godzinyNb = 0
     END
   --
     SET @czas1 = @czas1 + @czas2
     SET @czasP = @czas1
     if (@nb<>0 and @TnbPomnCzasPracy=1) or @RozlWg = 1
        SET @czasP = 0
  /* --[JK] TFS:152217
  IF @godzinyNb > @czasP
         BEGIN
      set @godzinyNb = @godzinyNb -  @czasP
      set @czasP = 0
      END
   ELSE
   BEGIN
        set @czasP = @czasP - @godzinyNb
     set @godzinyNb = 0
   END
   */
     IF NOT EXISTS (SELECT 1 FROM #CzasPracy WHERE Tmp_Typ=3 AND Tmp_DstId=@strefa and Tmp_Data=@data)
       INSERT INTO #CzasPracy values (
          3, @praid,null,null,null,@data,null,0,@czas1,0,0,0,0,@czasP,0,@czas1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,NULL,0,@strefa) -- SB 2021 [12263] --
     ELSE
       UPDATE #CzasPracy SET Tmp_NormaDob = Tmp_NormaDob + @czas1, Tmp_Praca = Tmp_Praca + @czasP, Tmp_PracaPlan = Tmp_PracaPlan + @czas1 WHERE Tmp_DstId=@strefa AND Tmp_Typ=3 AND Tmp_Data=@data
     IF (@nb<>0 and @TnbPomnCzasPracy=1) or @RozlWg = 1
      SET   @czasP =  @czas1
    SET @czas = @czasP
  END
END
CLOSE Tmp_Czas
DEALLOCATE Tmp_Czas
END
END
ELSE IF @which=3 -- PracPracaDni
BEGIN
  UPDATE #CzasPracy SET Tmp_Praca=0 WHERE Tmp_Typ=3 AND Tmp_Data=@data AND Tmp_Data=@data
  BEGIN
   DECLARE Tmp_Czas CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   select pgr_odgodziny,pgr_dogodziny,pgr_strefa,dst_uwzglczaspracy  from cdn.PracPracaDni join cdn.pracpracadnigodz on PPR_PprId = PGR_PprId join cdn.definicjestref on PGR_Strefa=dst_dstid where ppr_data=@data and ppr_praid=@praid
  OPEN Tmp_Czas
  WHILE 1=1
BEGIN
 FETCH NEXT FROM Tmp_Czas INTO @odgodz,@dogodz,@strefa,@wliczaj
 IF @@FETCH_STATUS <> 0 BREAK
  -- [JK] TFS:148963 select @wliczaj = dst_uwzglczaspracy from cdn.definicjestref where dst_dstid=@strefa
  IF @wliczaj=0
  BEGIN
     SET @NormaDob = 0
     -- [JK] TFS:148963
     SET @czas2 = 0
  END
  IF @strefa<>@strefaundefined
  BEGIN
     exec @czas2 = CDN.PodajCzasPracyS @data, @odgodz, @dogodz, 1, @strefa
     SET @czas1 = @czas1 + @czas2
       IF NOT EXISTS (SELECT 1 FROM #CzasPracy WHERE Tmp_Typ=3 AND Tmp_DstId=@strefa and Tmp_Data=@data)
       INSERT INTO #CzasPracy values (
          3, @praid,null,null,null,@data,null,0,@NormaDob,0,0,0,0,@czas1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,NULL,0,@strefa) -- SB 2021 [12263] --
     ELSE
       UPDATE #CzasPracy SET Tmp_Praca = Tmp_Praca + @czas1 WHERE Tmp_DstId=@strefa AND Tmp_Typ=3 AND Tmp_Data=@data
       SET @czas = @czas1
  END
END
CLOSE Tmp_Czas
DEALLOCATE Tmp_Czas
END
END
return @czas
