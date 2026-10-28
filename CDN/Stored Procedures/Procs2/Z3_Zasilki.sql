CREATE PROCEDURE CDN.Z3_Zasilki @IdPrac INT, @DataZas DATETIME
AS
SET NOCOUNT ON
DECLARE @NieobecOd DATETIME
DECLARE @NieobecDo DATETIME
DECLARE @WpsOd DATETIME
DECLARE @WpsDo DATETIME
DECLARE @poprzOd DATETIME
DECLARE @poprzDo DATETIME
DECLARE @CzyKont INT
DECLARE @PoprzCzyKont INT
DECLARE @KodNieobec NVarChar(4)
DECLARE @Nazwa NVarChar(40)
DECLARE @KodZUS NVarChar(3)
DECLARE @Okres_Od DATETIME
DECLARE @Param INT
DECLARE @Procent NVARCHAR(10)
DECLARE @Licz INT
SET @Licz = 1
SET @Param = 0
IF (select Top 1 TNB_PdzId from cdn.PracNieobec join CDN.TypNieobec on Pnb_tnbid=TNB_TnbId where TNB_PdzId in (311,319,325,327,321,322,331) and (PNB_Tryb = 0 or PNB_Tryb = 2) and PNB_PraId = @IdPrac and @DataZas between PNB_OkresOd and PNB_OkresDo order by PNB_PracaRodzic Desc)=331
BEGIN
SET @Param = 1
END
IF (select Top 1 TNB_PdzId from cdn.PracNieobec join CDN.TypNieobec on Pnb_tnbid=TNB_TnbId where TNB_PdzId in (311,319,325,327,321,322,331) and (PNB_Tryb = 0 or PNB_Tryb = 2) and PNB_PraId = @IdPrac and @DataZas between PNB_OkresOd and PNB_OkresDo order by PNB_PracaRodzic Desc)in (311,319,325,327)
BEGIN
SET @Param = 2
END
IF (select Top 1 TNB_PdzId from cdn.PracNieobec join CDN.TypNieobec on Pnb_tnbid=TNB_TnbId where TNB_PdzId in (311,319,325,327,321,322,331) and (PNB_Tryb = 0 or PNB_Tryb = 2) and PNB_PraId = @IdPrac and @DataZas between PNB_OkresOd and PNB_OkresDo order by PNB_PracaRodzic Desc)in (321,322)
BEGIN
SET @Param = 3
END
SET @Okres_Od = isnull((select Top 1 PNB_OkresDo from cdn.PracNieobec join CDN.TypNieobec on Pnb_tnbid=TNB_TnbId where TNB_PdzId in (311,319,325,327,321,322,331) and (PNB_Tryb = 0 or PNB_Tryb = 2) and PNB_PraId = @IdPrac and @DataZas between PNB_OkresOd and PNB_OkresDo order by PNB_PracaRodzic Desc),CONVERT(DATETIME,'1899-12-30 00:00:00',120))
CREATE TABLE #Zasilki_Z3(
 Tmp_Prcid INT,
 Tmp_NieobecOd DATETIME,
 Tmp_NieobecDo DATETIME,
 Tmp_WpsOd DATETIME,
 Tmp_WpsDo DATETIME,
 Tmp_Nazwa NVarChar(40),
 Tmp_KodZUS INT,
 Tmp_KodNieobec NVarChar(4),
 Tmp_Kontynuacja INT,
 Tmp_Procent  NVARCHAR(10),
  )
 IF @Param = 1
 BEGIN
DECLARE Tmp_Zasilki_Z3 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
 SELECT
 @IdPrac,
 Pnb_OkresOd,
 Pnb_OkresDo,
 WPS_DataOd,
 WPS_DataDo,
 WPS_Nazwa,
 TWP_PdzId,
 IsNull(PNB_KodNieobecnosci,''),
 IsNull(PNB_KontynuacjaOZ,0),
 ''
 FROM CDN.WypElementy join CDN.Wyplaty on WPE_WplId = WPL_WplId join CDN.ListyPlac on WPL_LplId = LPL_LplId
 join CDN.TypWyplata on WPE_TwpId=TWP_TwpId  join CDN.WypSkladniki on WPS_WpeId = WPE_WpeId join cdn.PracNieobec on PNB_PnbId = WPS_ZrodloId
 join CDN.TypNieobec on Pnb_tnbid=TNB_TnbId
 WHERE TWP_PdzId in (313,314,331,151,333) and (PNB_Tryb = 0 or PNB_Tryb = 2) and WPE_PraId = @IdPrac and
 PNB_OkresOd<=@Okres_Od and WPS_RodzajZrodla=6 and WPL_Tryb<>1 and WPL_Tryb<>2 and WPS_DataOd <= @Okres_Od and WPS_Wartosc > 0
  order by WPS_DataOd desc
  OPEN Tmp_Zasilki_Z3
  WHILE 1=1
  BEGIN
  SET @poprzOd = @WpsOd
  SET @poprzDo = @WpsDo
  SET @PoprzCzyKont = @CzyKont
      FETCH NEXT FROM Tmp_Zasilki_Z3 INTO @IdPrac, @NieobecOd, @NieobecDo, @WpsOd, @WpsDo,@Nazwa, @KodZUS, @KodNieobec, @CzyKont, @Procent
      IF @@FETCH_STATUS <> 0 BREAK
      BEGIN
      IF @WpsDo<>@poprzOd-1 and @PoprzCzyKont=0 or @KodZUS not in (313,314)
      BREAK
      IF @Licz = 1
      BEGIN
      INSERT INTO #Zasilki_Z3 values (@IdPrac, @NieobecOd, @NieobecDo, @WpsOd, @WpsDo,@Nazwa, @KodZUS, @KodNieobec, @CzyKont, @Procent)
      END
      ELSE
      IF @WpsDo=@poprzOd-1 or @PoprzCzyKont=1
      BEGIN
   INSERT INTO #Zasilki_Z3 values (@IdPrac, @NieobecOd, @NieobecDo, @WpsOd, @WpsDo,@Nazwa, @KodZUS, @KodNieobec, @CzyKont, @Procent)
      END
      SET @Licz = @Licz + 1
      END
  END
 CLOSE Tmp_Zasilki_Z3
 DEALLOCATE Tmp_Zasilki_Z3
 END
 IF @Param = 2
 BEGIN
DECLARE Tmp_Zasilki_Z3 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
 SELECT
 @IdPrac,
 Pnb_OkresOd,
 Pnb_OkresDo,
 WPS_DataOd,
 WPS_DataDo,
 WPS_Nazwa,
 TWP_PdzId,
 IsNull(PNB_KodNieobecnosci,''),
 IsNull(PNB_KontynuacjaOZ,0),
 Cast(Cast(WPS_Procent as Decimal(3,0)) as NVARCHAR)+' %'
 FROM CDN.WypElementy join CDN.Wyplaty on WPE_WplId = WPL_WplId join CDN.ListyPlac on WPL_LplId = LPL_LplId
 join CDN.TypWyplata on WPE_TwpId=TWP_TwpId  join CDN.WypSkladniki on WPS_WpeId = WPE_WpeId join cdn.PracNieobec on PNB_PnbId = WPS_ZrodloId
 join CDN.TypNieobec on Pnb_tnbid=TNB_TnbId
  --[JK] TFS:209372 dodanie kodów 313,314 do warunku na TNB_PdzId
 WHERE TWP_PdzId in (311,319,325,327,313,314) and (PNB_Tryb = 0 or PNB_Tryb = 2) and WPE_PraId = @IdPrac and
 PNB_OkresOd<=@Okres_Od and WPS_RodzajZrodla=6 and WPL_Tryb<>1 and WPL_Tryb<>2 and WPS_DataOd <= @Okres_Od and WPS_Wartosc > 0
  order by WPS_DataOd desc
  OPEN Tmp_Zasilki_Z3
  WHILE 1=1
  BEGIN
  SET @poprzOd = @WpsOd
  SET @poprzDo = @WpsDo
  SET @PoprzCzyKont = @CzyKont
      FETCH NEXT FROM Tmp_Zasilki_Z3 INTO @IdPrac, @NieobecOd, @NieobecDo, @WpsOd, @WpsDo,@Nazwa, @KodZUS, @KodNieobec, @CzyKont, @Procent
      IF @@FETCH_STATUS <> 0 BREAK
      BEGIN
   --[JK] TFS:209372
      IF @WpsDo<>@poprzOd-1 and @KodZUS not in (313,314) or @WpsDo<>@poprzOd-1 and @PoprzCzyKont=0 and @KodZUS in (313,314)
      BREAK
      IF @Licz = 1
      BEGIN
      INSERT INTO #Zasilki_Z3 values (@IdPrac, @NieobecOd, @NieobecDo, @WpsOd, @WpsDo,@Nazwa, @KodZUS, @KodNieobec, @CzyKont, @Procent)
      END
      ELSE
   --[JK] TFS:209372
      IF @WpsDo=@poprzOd-1 or @WpsDo<>@poprzOd-1 and @PoprzCzyKont=1 and @KodZUS in (313,314)
      BEGIN
   INSERT INTO #Zasilki_Z3 values (@IdPrac, @NieobecOd, @NieobecDo, @WpsOd, @WpsDo,@Nazwa, @KodZUS, @KodNieobec, @CzyKont, @Procent)
      END
      SET @Licz = @Licz + 1
      END
  END
 CLOSE Tmp_Zasilki_Z3
 DEALLOCATE Tmp_Zasilki_Z3
 END
 IF @Param = 3
 BEGIN
DECLARE Tmp_Zasilki_Z3 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
 SELECT
 @IdPrac,
 Pnb_OkresOd,
 Pnb_OkresDo,
 WPS_DataOd,
 WPS_DataDo,
 WPS_Nazwa,
 TNB_PdzId,
 IsNull(PNB_KodNieobecnosci,''),
 IsNull(PNB_KontynuacjaOZ,0),
 ''
 FROM CDN.WypElementy join CDN.Wyplaty on WPE_WplId = WPL_WplId join CDN.ListyPlac on WPL_LplId = LPL_LplId
 join CDN.TypWyplata on WPE_TwpId=TWP_TwpId  join CDN.WypSkladniki on WPS_WpeId = WPE_WpeId join cdn.PracNieobec on PNB_PnbId = WPS_ZrodloId
 join CDN.TypNieobec on Pnb_tnbid=TNB_TnbId
 WHERE TNB_PdzId in (321,322) and (PNB_Tryb = 0 or PNB_Tryb = 2) and WPE_PraId = @IdPrac and
 PNB_OkresOd<=@Okres_Od and WPS_RodzajZrodla=6 and WPL_Tryb<>1 and WPL_Tryb<>2 and WPS_DataOd <= @Okres_Od and WPS_Wartosc > 0
  order by WPS_DataOd desc
  OPEN Tmp_Zasilki_Z3
  WHILE 1=1
  BEGIN
  SET @poprzOd = @WpsOd
  SET @poprzDo = @WpsDo
  SET @PoprzCzyKont = @CzyKont
      FETCH NEXT FROM Tmp_Zasilki_Z3 INTO @IdPrac, @NieobecOd, @NieobecDo, @WpsOd, @WpsDo,@Nazwa, @KodZUS, @KodNieobec, @CzyKont, @Procent
      IF @@FETCH_STATUS <> 0 BREAK
      BEGIN
      IF @WpsDo<>@poprzOd-1
      BREAK
      IF @Licz = 1
      BEGIN
      INSERT INTO #Zasilki_Z3 values (@IdPrac, @NieobecOd, @NieobecDo, @WpsOd, @WpsDo,@Nazwa, @KodZUS, @KodNieobec, @CzyKont, @Procent)
      END
      ELSE
      IF @WpsDo=@poprzOd-1
      BEGIN
   INSERT INTO #Zasilki_Z3 values (@IdPrac, @NieobecOd, @NieobecDo, @WpsOd, @WpsDo,@Nazwa, @KodZUS, @KodNieobec, @CzyKont, @Procent)
      END
      SET @Licz = @Licz + 1
      END
  END
 CLOSE Tmp_Zasilki_Z3
 DEALLOCATE Tmp_Zasilki_Z3
 END
 SELECT  * FROM #Zasilki_Z3 order by Tmp_WpsOd desc
 --SELECT  * FROM #Zasilki_Z3 where Tmp_WpsOd < @Okres_Od order by Tmp_WpsOd
