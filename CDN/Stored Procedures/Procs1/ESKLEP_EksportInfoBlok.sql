CREATE  PROCEDURE [CDN].[ESKLEP_EksportInfoBlok]
   @ID   INT   -- ID e-sklepu
 ,@ExpOpcje     INT    -- Maska opcji eksportu
 ,@SynchroGuid nvarchar(254) = null
 ,@Start int = 1
AS
 SET NOCOUNT ON
 DECLARE
     @TSSynchr nvarchar(254),
     @TSSynchrTwr nvarchar(254),
     @TSSynchrGrup nvarchar(254),
     @TSSynchrKntPtw nvarchar(254),
     @TSSynchrKntERP nvarchar(254),
     @TSSynchrBin nvarchar(254),
     @TSSynchrCSelling nvarchar(254),
  @DateTSSynchr DATETIME,
     @TwGNumer nvarchar(254),
     @TimeStamp INT,
     @WalutaSys nvarchar(3),
     @BazaDanych nvarchar(31),
     @WersjaBazy nvarchar(20),
     @NrCenyInt        INT,
     @NrCenyPopInt     INT,
     @Rabaty nvarchar(3),
  @KontrolaLimituPlat TinyInt,
  @GUID nvarchar(254)
    --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1849) SELECT @WalutaSys = '' ELSE SELECT @WalutaSys = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1849
    SELECT @BazaDanych = SYS_Wartosc FROM CDN.SystemCDN WHERE SYS_ID = 1
    SELECT @WersjaBazy = SYS_Wartosc FROM CDN.SystemCDN WHERE SYS_ID = 3
 SELECT @GUID = SYS_Wartosc FROM CDN.SystemCDN WHERE SYS_ID = 1004
     SET @TimeStamp = DATEDIFF(s,CONVERT(DATETIME,'19900101',121),GETDATE())
     UPDATE cdn.eSklepStanowiska SET ESS_TS_Synchro = @TimeStamp WHERE ESS_IdISklep = @ID
     IF (@ExpOpcje & 1 = 1 and (@ExpOpcje & 64) / 64 = 0)   -- eksport cennika
        UPDATE cdn.eSklepStanowiska SET ESS_TS_SynchroTwr = @TimeStamp WHERE ESS_IdISklep = @ID
     IF((@ExpOpcje & 4) / 4 = 1 and (@ExpOpcje & 64) / 64 = 0)  -- eksport grup
        UPDATE cdn.eSklepStanowiska SET ESS_TS_SynchroGrup = @TimeStamp WHERE ESS_IdISklep = @ID
     IF((@ExpOpcje & 512) / 512= 1 and (@ExpOpcje & 64) / 64 = 0)  -- eksport knt z optimy
        UPDATE cdn.eSklepStanowiska SET ESS_TS_SynchroKntOptima = @TimeStamp WHERE ESS_IdISklep = @ID
     IF((@ExpOpcje & 1024) / 1024= 1 and (@ExpOpcje & 64) / 64 = 0)  -- eksport zestawów
        UPDATE cdn.eSklepStanowiska SET ESS_TS_SynchroZestawyTwr = @TimeStamp WHERE ESS_IdISklep = @ID
     IF((@ExpOpcje & 1) / 1= 1 and (@ExpOpcje & 64) / 64 = 0)  -- eksport danych binarnych
        UPDATE cdn.eSklepStanowiska SET ESS_TS_SynchroBin = @TimeStamp WHERE ESS_IdISklep = @ID
    select  @WalutaSys = ESS_DomyslnaWaluta,
   @TSSynchr =  ESS_TS_Synchro,
   @TSSynchrTwr =  ESS_TS_SynchroTwr,
   @DateTSSynchr = dateadd( second, CONVERT(INT,ESS_TS_SynchroTwrPotw),CONVERT(DATETIME,'1990-01-01',120)),
   @TSSynchrGrup = ESS_TS_SynchroGrup,
   @TSSynchrKntPtw = ESS_TS_SynchroKntPotw,
   @TSSynchrKntERP = ESS_TS_SynchroKntOptima,
   @TSSynchrCSelling = ESS_TS_SynchroZestawyTwr,
   @TSSynchrBin = ESS_TS_SynchroBin,
   @TwGNumer = ESS_TwGNumer,
   @KontrolaLimituPlat = ESS_KontrolaLimituPlat,
   @NrCenyInt = ESS_NrCeny,
   @NrCenyPopInt = case when ESS_NrCenyDomyslnej = 0 then -1 else ESS_NrCenyDomyslnej end from cdn.eSklepStanowiska where ESS_IdISklep = @ID
        IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1484) SELECT @Rabaty = 0 ELSE SELECT @Rabaty = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1484
        --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1835) SELECT @TSSynchrTwr = 0 ELSE SELECT @TSSynchrTwr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1835
        --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1840) SELECT @TSSynchrGrup = 0 ELSE SELECT @TSSynchrGrup = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1840
        --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1830) SELECT @TSSynchrKntPtw = 0 ELSE SELECT @TSSynchrKntPtw = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1830
        --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1837) SELECT @TwGNumer = 0 ELSE SELECT @TwGNumer = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1837
   if (@ExpOpcje & 1 = 1) and
   (select COUNT(*)
   from cdn.DefAtrybuty as SATR
   WHERE DeA_TS_Mod > CASE WHEN (@ExpOpcje & 2) / 2 = 0 THEN @DateTSSynchr ELSE 0 END and DeA_Typ = 1 and DeA_ESklep = 1) > 0
   begin
  set @ExpOpcje = @ExpOpcje+4096+ (CASE WHEN (@ExpOpcje & 2) / 2 = 0 then 0 else 8192 end)
   end
SELECT  TOP 1
   @ID             AS eSklepID
  ,case when @SynchroGuid is null  or  @SynchroGuid = '' then '15' else '16' end   AS Wersja
  ,@TSSynchr       AS TSSynchr
  ,@TSSynchrTwr    AS TSSynchrTwr
  ,@TSSynchrGrup   AS TSSynchrGrup
  ,@TSSynchrKntPtw AS TSSynchrKntPtw
  ,@TSSynchrKntERP AS TSSynchrKntERP
  ,@TSSynchrCSelling AS TSSynchrCSelling
  ,@TSSynchrBin  AS TSSynchrBin
  ,@TwGNumer       AS ExpTwGNumer
  ,@ExpOpcje       AS EksportTyp
  ,@WalutaSys      AS WalutaSys
  ,1      AS ZrodloID
  ,'CDN Optima'    AS Zrodlo
  ,1               AS Lokalizacja
  ,@BazaDanych    AS BazaDanych
  ,@WersjaBazy     AS WersjaBazy
  ,@GUID AS BazaDanychGUID
  ,@Rabaty  AS Rabaty
  ,@NrCenyInt AS CenaD
  ,@NrCenyPopInt AS CenaDP
  --,@KontrolaLimituPlat AS Zam
  ,CASE WHEN @ExpOpcje = 0 THEN 1 ELSE 0 END AS Koniec
  ,@SynchroGuid AS SynchroGUID
  ,@Start AS Start
FROM CDN.Firma     AS INFOBLOK
FOR XML AUTO
SET NOCOUNT OFF
