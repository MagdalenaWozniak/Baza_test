create PROCEDURE CDN.Med_StanowiskoOperatorzy
   @DStaId int, -- id stanowiska (cdn.detalstanowiska)
   @Kod NVARCHAR(20), -- kod operatora
   @Nazwa NVARCHAR(50) -- nazwa operatora
AS
BEGIN
SET NOCOUNT ON
 declare
   @OpeId            INT,
   @sqltxt           NVARCHAR (4000),
    @TmpSrvName       SYSNAME,
    @ServerCfgString  NVARCHAR(512),
    @BazaCfgString    NVARCHAR(512),
    @TrN_DataDokChar  NVARCHAR(25)
  SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
  SELECT @ServerCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1001
  SELECT @BazaCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1002
  SELECT @TrN_DataDokChar    = CONVERT(NVARCHAR(25), GETDATE(), 102)
  IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
    SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
SET @sqltxt ='IF NOT EXISTS (SELECT Ope_OpeID FROM ['
SET @sqltxt = @sqltxt + @ServerCfgString +'].['+ @BazaCfgString+ '].CDN.Operatorzy'
SET @sqltxt = @sqltxt + ' WHERE Ope_Kod= '''+@Kod+''') INSERT INTO ['
SET @sqltxt = @sqltxt + @ServerCfgString +'].['+ @BazaCfgString+ '].CDN.Operatorzy'
SET @sqltxt = @sqltxt + ' (Ope_Kod,Ope_Nazwisko,Ope_Haslo,Ope_HasloChk,Ope_NTSid,Ope_NTKonto,Ope_NTLogin,Ope_Administrator,Ope_Startowa,Ope_BuforNazwa,
   Ope_KsiegaGlowna,Ope_BuforVATSpr,Ope_BuforVATZak,Ope_BuforKasa,Ope_BuforOkres,Ope_BuforAmortyz,Ope_BuforPlace,Ope_BuforEwid,Ope_ZakazCenyZak,
Ope_ZmianyOffLine,
   Ope_TylkoStartowa,Ope_KlasycznaKlawiatura,Ope_Powiadamianie,Ope_NumerSMS,Ope_Email,Ope_NazwaKomputera,Ope_InfoPoUruchomieniu,Ope_InfoRazDziennie,Ope_ZmianaLimituKred,Ope_Kierownik,
   Ope_BlokadaZmianTowaru,Ope_BlokadaZmianCenFA,Ope_BlokadaZmianCenFZ,Ope_BlokadaZmianCenPA,Ope_BlokadaZmianCenRO,Ope_BlokadaZmianCenZD,Ope_BlokadaZmianCenFPF,Ope_BlokadaFAPAdoBufora,Ope_ZapisFAPApoWydruku,Ope_ZamkniecieDnia,
   Ope_AktualizacjaKntHaMag,Ope_ZmianaOpisuHaMag,
Ope_MinMarzaHaMag,Ope_BlokadaAnulowaniaHaMag,Ope_RozliczanieZListyHaMag,
   Ope_SymbolDlaNumeracji,Ope_Magazyn,Ope_Parametr,Ope_Nieaktywny,Ope_ZmianaKategorii,Ope_BlokadaZmianMagazynu,Ope_BlokadaPonownejFiskFAPA,Ope_BlokadaZmianMagazynuListy,Ope_Kasa,
   Ope_KodDlaDF,Ope_KonfigProgressLoga,Ope_RaportProgressLoga,Ope_BlokadaPlac,Ope_PlatnosciSprzedazBufor,Ope_PlatnosciSprzedazTrwaly,Ope_ZmianaPoprzedniegoCzasu,Ope_ZmianaAtrNaZatwDok,Ope_BlokadaDanychPlacowych,Ope_BlokadaDanychPlacowychStawka,
   Ope_DostepDoZadanInnychOpe,Ope_OdblokowanieZlecen,Ope_DetalFunkcjaPrac,Ope_BlokadaAnulWyplaty,Ope_BlokadaAnulNieobecIZestCzas,Ope_UdostepnianieAnalWPodgladzie,Ope_ZmianaProcesuDomyslnego,Ope_ModyfikacjaProcesow,Ope_DostepDoSkrzynkiInnychOperatorow,Ope_PrawoOdblokowaniaKontaktu,
   Ope_UdostepnianieWydrukWPodgladzie,Ope_HasloPM,Ope_KopiaBezpieczenstwa,Ope_PrawoDoZamianEFaktury,Ope_BlokadaTylkoWynagrodzen,Ope_KotrolaCzesciPobranych,Ope_UproszczoneFakturowanie,Ope_PrawoDoPobrCzesciMagSerw,Ope_PrawoDoPobrCzesciMagLok,Ope_Opis,
   Ope_PelneMenu,Ope_ModulKP,Ope_ModulKH,Ope_ModulKHP,Ope_ModulST,Ope_ModulFA,Ope_ModulMAG,Ope_ModulPK,Ope_ModulPKXL,Ope_ModulANL,
   Ope_ModulCRM,Ope_ModulDET,Ope_ModulBIU,Ope_ModulSRW,Ope_ModulOBD,Ope_ModulKB,Ope_ModulKBP,Ope_ModulHAP,Ope_BlokadaSeryjnegoUsuwania,Ope_DataRSS,Ope_ModulCRMP,Ope_ZapisWZpoWydruku)
   VALUES('''+@Kod+''','''+@Nazwa+''',''MVZXJ8xBv9w'',''Xo'','''','''',0,1,0,'''',0
,1,1,0,0,1,1,1,0,0
   ,0,0,0,'''','''','''',0,0,1,0
,0,0,0,0,0,0,0,0,0,0
,0,0
,0,0,0
   ,'''','''','''',1,0,0,0,0,'''','''',0,1,0,2,0,0,0,0,0,1,1,0,0,0,0,0,1,0,0
   ,0,'''',1,0,0,0,0,1,1,''iMed24'',1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,GETDATE(),0,0)'
EXEC sp_executesql @sqltxt
SET @sqltxt ='SELECT Ope_OpeID FROM ['
SET @sqltxt = @sqltxt + @ServerCfgString +'].['+ @BazaCfgString+ '].CDN.Operatorzy'
SET @sqltxt = @sqltxt + ' WHERE Ope_Kod= '''+@Kod +''''
CREATE TABLE #table (opeid int)
insert into #table(opeid)
EXEC sp_executesql @sqltxt
IF NOT EXISTS (Select DOpe_OpeId from CDN.DetalOperator
join #table on opeid = DOpe_OpeId
where DOpe_DStaId = @DStaId)
INSERT INTO CDN.DetalOperator
           (DOpe_DStaId
           ,DOpe_OpeId)
select @DStaId, opeid from #table
-- zwrocic id
select opeid from #table
   DROP TABLE #table
SET NOCOUNT OFF
END
