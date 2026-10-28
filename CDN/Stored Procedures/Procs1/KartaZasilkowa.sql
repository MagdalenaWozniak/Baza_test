CREATE PROCEDURE CDN.KartaZasilkowa  @Od DATETIME, @Do DATETIME, @PrcId INT
AS
SET NOCOUNT ON
DECLARE @Symbol  NVARCHAR(30)
DECLARE @NrPoz INT
DECLARE @TypWyp  INT
DECLARE @KodChor NVARCHAR(4)
DECLARE @DataListy DATETIME
DECLARE @DataOd  DATETIME
DECLARE @DataDo  DATETIME
DECLARE @Nazwa  NVARCHAR(128)
DECLARE @Dni  INT
DECLARE @ZasDzienny  DECIMAL(15,2)
DECLARE @ZasBrutto  DECIMAL(15,2)
DECLARE @Przypis  DECIMAL(15,2)
DECLARE @ZalPod  DECIMAL(15,2)
DECLARE @ZasNetto DECIMAL(15,2)
DECLARE @Procent NVARCHAR(10)
DECLARE @Przychod DECIMAL(15,2)
IF @Od IS NULL OR @Do IS NULL
 BEGIN
  SET @Od = '1899-12-30 00:00:00'
  SET @Do = '1899-12-30 00:00:00'
 END
 ELSE
 BEGIN
  SET @Od = CONVERT(DATETIME, CAST(DATEPART(year ,@Od) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@Od) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@Od) AS NVARCHAR)+' 00:00:000', 120)
  SET @Do = CONVERT(DATETIME, CAST(DATEPART(year ,@Do) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@Do) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@Do) AS NVARCHAR)+' 00:00:000', 120)
 END
CREATE TABLE #KartaZas (
 Tmp_Nazwa  NVARCHAR(128),
 Tmp_NrPoz INT,
 Tmp_TypWypId  INT,
 Tmp_KodChor NVARCHAR(4),
 Tmp_Symbol      NVARCHAR(30),
 Tmp_DataListy   DATETIME,
 Tmp_DataOd      DATETIME,
 Tmp_DataDo      DATETIME,
 Tmp_Dni   INT,
 Tmp_ZasDzienny  DECIMAL(15,2),
 Tmp_ZasBrutto   DECIMAL(15,2),
 Tmp_Przypis  DECIMAL(15,2),
 Tmp_ZalPod  DECIMAL(15,2),
 Tmp_ZasNetto  DECIMAL(15,2),
 Tmp_Procent  NVARCHAR(10),
 Tmp_Przychod  DECIMAL(15,2),
)
DECLARE Tmp_WypPrc CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT wps_nazwa, wpl_NumerNr, TWP_PdzId, PNB_KodNieobecnosci, WPL_NumerPelny, LPL_DataDok, WPS_DataOd, WPS_DataDo, WPS_OkresDni,
Case When (WPS_OkresDni=0) Then 0 Else (WPE_Wartosc/WPS_OkresDni) End,
WPE_Wartosc, (WPE_ZalFis + WPE_SklZdrowPrac),WPE_ZalFis,(WPE_Wartosc-WPE_ZalFis-WPE_SklZdrowPrac),Cast(Cast(WPS_Procent as Decimal(3,0)) as NVARCHAR)+' %',
--[JK] TFS:192144
Case When WPS_PracaRodzic = 1 Then WPS_PracaRodzicPodstawa Else WPS_Podstawa End
 FROM CDN.WypElementy
 INNER JOIN CDN.WypSkladniki ON WPE_WpeId = WPS_WpeId
 INNER JOIN CDN.TypWyplata on WPE_TwpId = Twp_TwpId
 INNER JOIN CDN.Wyplaty on WPL_WplId = WPE_WplId
 INNER JOIN CDN.ListyPlac on WPL_LplId = LPL_LplId
 LEFT OUTER JOIN CDN.PracNieobec   ON  WPS_ZrodloId = PNB_PNBID and PNB_Tryb<>1
  WHERE WPS_PraID = @PrcId and
  WPS_DataOd between @Od and @do
 and WPL_Tryb<>1 and WPL_Tryb<>2
 and ((TWP_PdzId >310 AND TWP_PdzId < 350) OR (TWP_PdzId = 155))
 --[JK] TFS:192144
 and TWP_PdzId <> 329
 ORDER BY WPS_DataOd
  OPEN Tmp_WypPrc
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM Tmp_WypPrc  INTO  @Nazwa, @NrPoz, @TypWyp, @KodChor, @Symbol, @DataListy, @DataOd, @DataDo, @Dni, @ZasDzienny, @ZasBrutto, @Przypis, @ZalPod, @ZasNetto, @Procent, @Przychod
      IF @@FETCH_STATUS <> 0 BREAK
    INSERT INTO #KartaZas values (@nazwa, @NrPoz, @TypWyp, @KodChor, @Symbol, @DataListy, @DataOd, @DataDo, @Dni, @ZasDzienny, @ZasBrutto, @Przypis, @ZalPod, @ZasNetto, @Procent, @Przychod)
  END
  CLOSE  Tmp_WypPrc
  DEALLOCATE  Tmp_WypPrc
SET NOCOUNT OFF
SELECT
  * FROM #KartaZas
