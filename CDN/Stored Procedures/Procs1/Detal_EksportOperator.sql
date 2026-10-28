CREATE PROCEDURE [CDN].[Detal_EksportOperator]
  @ID INT      -- ID Detalu
 ,@DateTSSynchr DATETIME  -- TimeStemp ostatniej synchronizacji
 ,@CzyTaSamaBaza tinyint
AS
SET NOCOUNT ON
 DECLARE
  @sqltxt           NVARCHAR (1000),
  @TmpSrvName       SYSNAME,
  @ServerCfgString  NVARCHAR(512),
  @BazaCfgString    NVARCHAR(512),
  @TrN_DataDokChar  NVARCHAR(25),
  @OptimaId int,
  @Kod NVARCHAR(20),
  @Nazwisko NVARCHAR(50),
  @KodDlaDF NVARCHAR(10),
  @KodFunkcji NVARCHAR(20),
  @ZmianaCenySprzedazy tinyint,
  @PrawoDoRabatowPozycja tinyint,
  @PrawoDoRabatowDokument tinyint,
  @StornoOstatniejPozycji tinyint,
  @StornoCalegoParagonu tinyint,
  @WplataDoKasy tinyint,
  @WyplataZKasy tinyint,
  @ZamkniecieZmiany tinyint,
  @ReczneOtwarcieSzuflady tinyint,
  @RaportFiskalny tinyint,
  @RaportOkresowy tinyint,
  @PodgladStanuKasy tinyint,
  @PlatnoscInnymiFormami tinyint,
  @ZwrotTowaru tinyint,
  @FakturaDoParagonu tinyint,
  @PodgladDokWlasnych tinyint,
  @PodgladDokWszystkich tinyint,
  @KonfiguracjaProgramu tinyint,
  @KonfiguracjaInterfejsu tinyint,
  @OtwarcieZmiany tinyint,
  @PrzekazanieParagonow tinyint,
  @EdycjaParagonow tinyint,
  @StanWszystkieMagazyny tinyint,
  @NieokreslonyPlatOdroczona tinyint,
  @ZmianaJM tinyint,
  @KontoDomenowe VARCHAR(100),
  @KontoDomenoweSID VARCHAR(200)
 IF NOT EXISTS (select dsta_dstaid from cdn.detalstanowiska where dsta_dstaid = @ID)
 BEGIN
   RAISERROR('Nie znaleziono Stanowiska w konfiguracji Optimy ', 16, 1)
   rollback
   SET NOCOUNT OFF
   RETURN
 END
 --pobranie notowania
  SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
  SELECT @ServerCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1001
  SELECT @BazaCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1002
  SELECT @TrN_DataDokChar    = CONVERT(NVARCHAR(25), GETDATE(), 102)
  IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
    SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
  SET @sqltxt = 'EXEC ['
  IF @ServerCfgString <> @TmpSrvName
    SET @sqltxt = @sqltxt + @ServerCfgString +'].['
  SET @sqltxt = @sqltxt + @BazaCfgString+'].CDN.Detal_PobierzOperatorow '
CREATE TABLE #Operatorzy(
 Ope_OpeID int NOT NULL,
 Ope_Kod NVARCHAR(20) NOT NULL,
 Ope_Nazwisko NVARCHAR(50) NOT NULL,
 Ope_KodDlaDF NVARCHAR(10) NOT NULL,
 Ope_KodFunkcji NVARCHAR(20) NOT NULL,
 Ope_ZmianaCenySprzedazy tinyint NOT NULL,
 Ope_PrawoDoRabatowPozycja tinyint NOT NULL,
 Ope_PrawoDoRabatowDokument tinyint NOT NULL,
 Ope_StornoOstatniejPozycji tinyint NOT NULL,
 Ope_StornoCalegoParagonu tinyint NOT NULL,
 Ope_WplataDoKasy tinyint NOT NULL,
 Ope_WyplataZKasy tinyint NOT NULL,
 Ope_ZamkniecieZmiany tinyint NOT NULL,
 Ope_ReczneOtwarcieSzuflady tinyint NOT NULL,
 Ope_RaportFiskalny tinyint NOT NULL,
 Ope_RaportOkresowy tinyint NOT NULL,
 Ope_PodgladStanuKasy tinyint NOT NULL,
 Ope_PlatnoscInnymiFormami tinyint NOT NULL,
 Ope_ZwrotTowaru tinyint NOT NULL,
 Ope_FakturaDoParagonu tinyint NOT NULL,
 Ope_PodgladDokWlasnych tinyint NOT NULL,
 Ope_PodgladDokWszystkich tinyint NOT NULL,
 Ope_KonfiguracjaProgramu tinyint NOT NULL,
 Ope_KonfiguracjaInterfejsu tinyint NOT NULL,
 Ope_OtwarcieZmiany  tinyint NOT NULL,
 Ope_PrzekazanieParagonow  tinyint NOT NULL,
 Ope_EdycjaParagonow tinyint NOT NULL,
 Ope_StanWszystkieMagazyny tinyint NOT NULL,
 Ope_NieokreslonyPlatOdroczona tinyint NOT NULL,
 Ope_ZmianaJM tinyint NOT NULL,
 Ope_KontoDomenowe VARCHAR(100),
 Ope_KontoDomenoweSID VARCHAR(200))
  INSERT INTO  #Operatorzy  ( Ope_OpeID,
 Ope_Kod,
 Ope_Nazwisko ,
 Ope_KodDlaDF,
 Ope_KodFunkcji ,
 Ope_ZmianaCenySprzedazy ,
 Ope_PrawoDoRabatowPozycja ,
 Ope_PrawoDoRabatowDokument ,
 Ope_StornoOstatniejPozycji ,
 Ope_StornoCalegoParagonu ,
 Ope_WplataDoKasy ,
 Ope_WyplataZKasy ,
 Ope_ZamkniecieZmiany ,
 Ope_ReczneOtwarcieSzuflady ,
 Ope_RaportFiskalny ,
 Ope_RaportOkresowy ,
 Ope_PodgladStanuKasy ,
 Ope_PlatnoscInnymiFormami ,
 Ope_ZwrotTowaru ,
 Ope_FakturaDoParagonu ,
 Ope_PodgladDokWlasnych ,
 Ope_PodgladDokWszystkich,
 Ope_KonfiguracjaProgramu,
 Ope_KonfiguracjaInterfejsu,
 Ope_OtwarcieZmiany,
 Ope_PrzekazanieParagonow,
 Ope_EdycjaParagonow,
 Ope_StanWszystkieMagazyny,
 Ope_NieokreslonyPlatOdroczona,
 Ope_ZmianaJM,
 Ope_KontoDomenowe,
 Ope_KontoDomenoweSID)
  EXEC sp_executesql @sqltxt
 select @DateTSSynchr = GetDate()
if @CzyTaSamaBaza = 1
BEGIN
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
  select #Operatorzy.* from #Operatorzy
    join cdn.detaloperator on ope_opeid = dope_opeid
    join cdn.detalstanowiska on dsta_dstaid = dope_dstaid
   where dsta_dstaid = @ID
 OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
            @OptimaId,
            @Kod,
            @Nazwisko,
            @KodDlaDF,
            @KodFunkcji,
            @ZmianaCenySprzedazy,
            @PrawoDoRabatowPozycja,
            @PrawoDoRabatowDokument,
            @StornoOstatniejPozycji,
            @StornoCalegoParagonu,
            @WplataDoKasy,
            @WyplataZKasy,
            @ZamkniecieZmiany,
            @ReczneOtwarcieSzuflady,
            @RaportFiskalny,
            @RaportOkresowy,
            @PodgladStanuKasy,
            @PlatnoscInnymiFormami,
            @ZwrotTowaru,
            @FakturaDoParagonu,
            @PodgladDokWlasnych,
            @PodgladDokWszystkich,
            @KonfiguracjaProgramu,
            @KonfiguracjaInterfejsu,
            @OtwarcieZmiany,
            @PrzekazanieParagonow,
            @EdycjaParagonow,
            @StanWszystkieMagazyny,
            @NieokreslonyPlatOdroczona,
   @ZmianaJM,
   @KontoDomenowe,
   @KontoDomenoweSID
   IF @@FETCH_STATUS <> 0 BREAK
  exec [CDN].[DetalStan_AktualizujOperatorow]
            @ID,
            @OptimaId,
            @Kod,
            @Nazwisko,
            @KodDlaDF,
            @KodFunkcji,
            @ZmianaCenySprzedazy,
            @PrawoDoRabatowPozycja,
            @PrawoDoRabatowDokument,
            @StornoOstatniejPozycji,
            @StornoCalegoParagonu,
            @WplataDoKasy,
            @WyplataZKasy,
            @ZamkniecieZmiany,
            @ReczneOtwarcieSzuflady,
            @RaportFiskalny,
            @RaportOkresowy,
            @PodgladStanuKasy,
            @PlatnoscInnymiFormami,
            @ZwrotTowaru,
            @FakturaDoParagonu,
            @PodgladDokWlasnych,
            @PodgladDokWszystkich,
            @KonfiguracjaProgramu,
            @KonfiguracjaInterfejsu,
            @OtwarcieZmiany,
            @PrzekazanieParagonow,
            @EdycjaParagonow,
            @StanWszystkieMagazyny,
            @NieokreslonyPlatOdroczona,
   @ZmianaJM,
            @DateTSSynchr,
   @KontoDomenowe,
   @KontoDomenoweSID
END
    CLOSE Dodawane
    DEALLOCATE Dodawane
END
ELSE
  select #Operatorzy.*,@DateTSSynchr from #Operatorzy
    join cdn.detaloperator on ope_opeid = dope_opeid
    join cdn.detalstanowiska on dsta_dstaid = dope_dstaid
   where dsta_dstaid = @ID
SET NOCOUNT OFF
