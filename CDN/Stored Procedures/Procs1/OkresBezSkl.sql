create PROCEDURE CDN.OkresBezSkl @IdPrac INT, @Okres_Od DATETIME, @Okres_Do DATETIME, @NieobWyp INT
AS
SET NOCOUNT ON
DECLARE @Od DATETIME
DECLARE @Do DATETIME
DECLARE @Nazwa NVarChar(40)
DECLARE @poprzOd DATETIME
DECLARE @poprzDo DATETIME
DECLARE @PoprzNazwa NVarChar(40)
CREATE TABLE #OkresBezSkl(
 Tmp_Prcid INT,
 Tmp_Od DATETIME,
 Tmp_Do DATETIME,
 Tmp_Nazwa NVarChar(40),
 )
DECLARE Tmp_OkresBezSkl CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
 SELECT
 @IdPrac,
 Case when Pnb_OkresOd < @Okres_Od then @Okres_Od else Pnb_OkresOd end,
 Case when PNB_OkresDo > @Okres_Do then @Okres_Do else Pnb_OkresDo end,
 TNB_Nazwa
 FROM CDN.PracIdx join CDN.PracNieobec on PRI_PraId = PNB_PraId join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
 WHERE PRI_Typ = 1
 --[JK] TFS:173538 dodanie warunku na @NieobWyp
 and ((TNB_PdzId not in (111,112,151,152,311,331,999,319,325,327) and @NieobWyp=1)
 or (TNB_PdzId not in (111,112,151,152,311,999,319,325,327) and @NieobWyp=0))
 and TNB_Standardowy <>312 and (PNB_Tryb = 0 or PNB_Tryb = 2) and PRI_PraId = @IdPrac and
 (Pnb_OkresOd >= @Okres_Od and PNB_OkresOd<=@Okres_Do)
  order by PNB_OkresOd desc
  OPEN Tmp_OkresBezSkl
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_OkresBezSkl INTO @IdPrac, @Od, @Do, @Nazwa
      IF @@FETCH_STATUS <> 0 BREAK
      BEGIN
      INSERT INTO #OkresBezSkl values (@IdPrac, @Od, @Do,@Nazwa)
      END
  END
 CLOSE Tmp_OkresBezSkl
 DEALLOCATE Tmp_OkresBezSkl
DECLARE @RokDekl INT
DECLARE @MiesDekl INT
SET @RokDekl = Year(@Okres_Do)
SET @MiesDekl = Month(@Okres_Do)
DECLARE Tmp_OkresBezSkl3 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
 SELECT
 @IdPrac,
 WPS_DataOd,
 WPS_DataDo,
 TNB_Nazwa
 FROM CDN.WypElementy join CDN.Wyplaty on WPE_WplId = WPL_WplId join CDN.ListyPlac on WPL_LplId = LPL_LplId
 join CDN.TypWyplata on WPE_TwpId=TWP_TwpId  join CDN.WypSkladniki on WPS_WpeId = WPE_WpeId join cdn.PracNieobec on PNB_PnbId = WPS_ZrodloId
 join CDN.TypNieobec on Pnb_tnbid=TNB_TnbId
 WHERE TNB_PdzId=331 and WPS_RodzajZrodla=6 and WPL_Tryb<>1 and WPL_Tryb<>2 and WPE_PraId = @IdPrac and TWP_PdzId <>151
 and (WPS_DataOd >= @Okres_Od and WPS_DataOd<=@Okres_Do)
 --[JK] TFS:173538 dodanie warunku na @NieobWyp
 and @NieobWyp=1
 order by WPS_DataOd
  OPEN Tmp_OkresBezSkl3
  WHILE 1=1
  BEGIN
      SET @poprzOd = @Od
      SET @poprzDo = @Do
      SET @PoprzNazwa = @Nazwa
      FETCH NEXT FROM Tmp_OkresBezSkl3 INTO @IdPrac, @Od, @Do, @Nazwa
      IF @@FETCH_STATUS <> 0 BREAK
      BEGIN
      IF (@Od<>@poprzDo+1 and @PoprzNazwa=@Nazwa) or ISNULL(@poprzDo,0)=0 or (@PoprzNazwa<>@Nazwa)
      BEGIN
       INSERT INTO #OkresBezSkl values (@IdPrac, @Od, @Do, @Nazwa)
      END
      IF (@Od=@poprzDo+1 and @PoprzNazwa=@Nazwa)
      BEGIN
    UPDATE #OkresBezSkl SET Tmp_Do = @Do WHERE Tmp_Do = @poprzDo
      END
      END
  END
 CLOSE Tmp_OkresBezSkl3
 DEALLOCATE Tmp_OkresBezSkl3
 SELECT  * FROM #OkresBezSkl order by Tmp_Od
