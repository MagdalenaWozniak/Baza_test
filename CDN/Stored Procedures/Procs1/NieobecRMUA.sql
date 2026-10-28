CREATE PROCEDURE CDN.NieobecRMUA @IdPrac INT, @Okres_Od DATETIME, @Okres_Do DATETIME
AS
SET NOCOUNT ON
DECLARE @Od DATETIME
DECLARE @Do DATETIME
DECLARE @TytUbNieob INT
DECLARE @DniZas INT
DECLARE @Nazwa NVarChar(40)
DECLARE @PozZus INT
DECLARE @Kwota DECIMAL(15,2)
CREATE TABLE #NieobecRMUA(
 Tmp_Prcid INT,
 Tmp_Od DATETIME,
 Tmp_Do DATETIME,
 Tmp_TytUbNieob INT,
 Tmp_Nazwa NVarChar(40),
 Tmp_PozZUS INT,
 Tmp_DniZas INT,
 Tmp_Kwota DECIMAL(15,2)
)
DECLARE Tmp_NieobecRMUA CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
 SELECT
 @IdPrac,
 Case when Pnb_OkresOd < @Okres_Od then @Okres_Od else Pnb_OkresOd end,
 Case when PNB_OkresDo > @Okres_Do then @Okres_Do else Pnb_OkresDo end,
 PNB_TyuId,
 TNB_Nazwa,
 TNB_PdzID,
 0,
 0
 FROM CDN.PracIdx join CDN.PracNieobec on PRI_PraId = PNB_PraId join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
 WHERE PRI_Typ = 1 and TNB_PdzId in (111,112,121,122,151,152) and (PNB_Tryb = 0 or PNB_Tryb = 2) and PRI_PraId = @IdPrac and
 (Pnb_OkresOd <= @Okres_Od and PNB_OkresDo>=@Okres_Od or Pnb_OkresOd >=@Okres_Od and Pnb_OkresOd<=@Okres_Do)
  order by PNB_OkresOd desc
  OPEN Tmp_NieobecRMUA
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_NieobecRMUA INTO @IdPrac, @Od, @Do,@TytUbNieob, @Nazwa,@PozZus, @DniZas, @Kwota
      IF @@FETCH_STATUS <> 0 BREAK
      BEGIN
      INSERT INTO #NieobecRMUA values (@IdPrac, @Od, @Do,@TytUbNieob, @Nazwa,@PozZus, @DniZas, @Kwota)
      IF @PozZus in (121,122) and @TytUbNieob=1230
      BEGIN
  INSERT INTO #NieobecRMUA values (@IdPrac, @Od, @Do,@TytUbNieob, 'Inne świadczenie/przerwy','350', 0, 0)
      END
      END
  END
 CLOSE Tmp_NieobecRMUA
 DEALLOCATE Tmp_NieobecRMUA
DECLARE @RokDekl INT
DECLARE @MiesDekl INT
SET @RokDekl = Year(@Okres_Do)
SET @MiesDekl = Month(@Okres_Do)
DECLARE Tmp_NieobecRMUA2 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
SELECT
 @IdPrac,
 max(WPS_DataOd),
 max(WPS_DataDo),
 0,
 max(TWP_Nazwa),
 max(TWP_PdzId),
 Case when TWP_PdzId in (321,322,323,324) then 1 else DATEDIFF(D,WPS_DataOd,WPS_DataDo) + 1 end,
 sum(WPE_Wartosc)
 FROM CDN.WypElementy join CDN.Wyplaty on WPE_WplId = WPL_WplId join CDN.ListyPlac on WPL_LplId = LPL_LplId
 join CDN.TypWyplata on WPE_TwpId=TWP_TwpId  join CDN.WypSkladniki on WPS_WpeId = WPE_WpeId join CDN.PracKod on PRA_PraId = WPE_PraId
 WHERE TWP_PdzId >=212 and TWP_PdzId <=338 and TWP_PdzId <>213 and WPL_Tryb<>1 and WPL_Tryb<>2 and LPL_Rok = @RokDekl and
 (((PRA_Nadrzedny = 1 and PRA_PraId = @IdPrac) or PRA_ParentId = @IdPrac) or (PRA_Nadrzedny = 0 and isnull(PRA_ParentId,0)=0 and
 PRA_PraId = @IdPrac) ) and LPL_Miesiac = @MiesDekl group by TWP_PdzId,WPS_DataOd,WPS_DataDo
  OPEN Tmp_NieobecRMUA2
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_NieobecRMUA2 INTO @IdPrac, @Od, @Do,@TytUbNieob, @Nazwa,@PozZus, @DniZas, @Kwota
      IF @@FETCH_STATUS <> 0 BREAK
      BEGIN
      INSERT INTO #NieobecRMUA values (@IdPrac, @Od, @Do,@TytUbNieob, @Nazwa,@PozZus, @DniZas, @Kwota)
      END
  END
 CLOSE Tmp_NieobecRMUA2
 DEALLOCATE Tmp_NieobecRMUA2
DECLARE Tmp_NieobecRMUA3 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
 SELECT
 @IdPrac,
 WPS_DataOd,
 WPS_DataDo,
 0,
 TNB_Nazwa,
 TNB_PdzID,
 0,
 0
 FROM CDN.WypElementy join CDN.Wyplaty on WPE_WplId = WPL_WplId join CDN.ListyPlac on WPL_LplId = LPL_LplId
 join CDN.TypWyplata on WPE_TwpId=TWP_TwpId  join CDN.WypSkladniki on WPS_WpeId = WPE_WpeId join cdn.PracNieobec on PNB_PnbId = WPS_PnbId
 join CDN.TypNieobec on Pnb_tnbid=TNB_TnbId
 WHERE WPS_TwpId in (9,10) and TNB_PdzId=350 and WPS_RodzajZrodla=1 and WPL_Tryb<>1 and WPL_Tryb<>2 and WPE_PraId = @IdPrac and LPL_Rok = @RokDekl
 and LPL_Miesiac = @MiesDekl
  OPEN Tmp_NieobecRMUA3
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_NieobecRMUA3 INTO @IdPrac, @Od, @Do,@TytUbNieob, @Nazwa,@PozZus, @DniZas, @Kwota
      IF @@FETCH_STATUS <> 0 BREAK
      BEGIN
      INSERT INTO #NieobecRMUA values (@IdPrac, @Od, @Do,@TytUbNieob, @Nazwa,@PozZus, @DniZas, @Kwota)
      END
  END
 CLOSE Tmp_NieobecRMUA3
 DEALLOCATE Tmp_NieobecRMUA3
 SELECT  * FROM #NieobecRMUA order by Tmp_Od
