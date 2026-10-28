CREATE PROCEDURE [CDN].[epDelegacje_Insert]
@Status SMALLINT, @DDfId INT, @NumerNr INT, @NumerString NVARCHAR (31), @DataDok DATETIME, @PodmiotKod NVARCHAR (20), @PodmiotTyp INT, @PodmiotId INT, @DataOd DATETIME, @DataDo DATETIME, @DataRozliczenia DATETIME, @WyjazdZMZ SMALLINT, --@KursNumer int,
--@KursL decimal(15,4),
--@KursM decimal(5,0),
--@KwotaSys decimal(15,2),
--@KwotaWal decimal(15,2),
@Opis NVARCHAR (255), @BuforData DATETIME, @BuforOperatorId INT, --@PolecenieWyjazduOperatorId int,
--@WydatkiData DateTime,
--@WydatkiOperatorId int,
--@ZatwierdzenieData DateTime,
--@ZatwierdzenieOperatorId int,
@OpeZalID INT, @StaZalId INT, @TS_Zal DATETIME, @OpeModID INT, @StaModId INT, @TS_Mod DATETIME, @CzyZagraniczna SMALLINT, @MiejsceDocelowe NVARCHAR (255) --@Waluta varchar(3),@PolecenieWyjazduData DateTime,
AS
IF @Status IS NULL
    SET @Status = 1;
IF @DataDok IS NULL
    SET @DataDok = DATEADD(dd, DATEDIFF(dd, 0, getdate()), 0);
IF @PodmiotKod IS NOT NULL
    SELECT @PodmiotTyp = Pod_PodmiotTyp,
           @PodmiotId = Pod_PodId
    FROM   CDN.PodmiotyView
    WHERE  Pod_PodmiotTyp = 3
           AND Pod_Kod = @PodmiotKod;
IF @DataRozliczenia IS NULL
    SET @DataRozliczenia = @DataDo + 1;
SELECT @DDfId = DefinicjaDokumentuId,
       @NumerNr = NumerNr,
       @NumerString = NumerString
FROM   CDN.DlgNumerDomyslny (@DataDok);
--if @Waluta is Null Set @Waluta = '';
--if @KursNumer is Null Set @KursNumer = 0;
--if @KursL is Null Set @KursL = 0;
--if @KursM is Null Set @KursM = 0;
IF @BuforData IS NULL
    SET @BuforData = DATEADD(dd, DATEDIFF(dd, 0, getdate()), 0);
IF @OpeZalID IS NULL
    SET @OpeZalID = @BuforOperatorId;
IF @StaZalId IS NULL
    SET @StaZalId = 1; -- !!! co tu mam wpakować
IF @TS_Zal IS NULL
    SET @TS_Zal = GETDATE();
IF @OpeModID IS NULL
    SET @OpeModID = @BuforOperatorId;
IF @StaModId IS NULL
    SET @StaModId = 1; -- !!! co tu mam wpakować
IF @TS_Mod IS NULL
    SET @TS_Mod = GETDATE();
DECLARE @OpeZalKod AS VARCHAR (20),
        @OpeZalNazwisko AS NVARCHAR (50);
EXECUTE CDN.OpeKodNazwisko @OpeZalID, @OpeZalKod OUTPUT, @OpeZalNazwisko OUTPUT;
DECLARE @OpeModKod AS VARCHAR (20),
        @OpeModNazwisko AS NVARCHAR (50);
EXECUTE CDN.OpeKodNazwisko @OpeModID, @OpeModKod OUTPUT, @OpeModNazwisko OUTPUT;
DECLARE @sql AS NVARCHAR (2048);
SET @sql = 'insert into CDN.DlgNag(' + 'DLN_Zrodlo,' + 'DLN_Status,' + 'DLN_DDfId,' + 'DLN_NumerNr,' + 'DLN_NumerString,' + 'DLN_DataDok,' + 'DLN_PodmiotTyp,' + 'DLN_PodmiotId,' + 'DLN_DataOd,' + 'DLN_DataDo,' + 'DLN_DataRozliczenia,' + 'DLN_WyjazdZMZ,' + 'DLN_Waluta,' + 'DLN_KursNumer,' + 'DLN_KursL,' + 'DLN_KursM,' + 'DLN_KwotaSys,' + 'DLN_KwotaWal,' + 'DLN_Opis,' + 'DLN_BuforData,' + 'DLN_BuforOperatorId,' -- + 'DLN_PolecenieWyjazduOperatorId,'
-- + 'DLN_WydatkiData,'
-- + 'DLN_WydatkiOperatorId,'
-- + 'DLN_ZatwierdzenieData,'
-- + 'DLN_ZatwierdzenieOperatorId,'
+ 'DLN_OpeZalID,' + 'DLN_OpeZalKod,' + 'DLN_OpeZalNazwisko,' + 'DLN_StaZalId,' + 'DLN_TS_Zal,' + 'DLN_OpeModID,' + 'DLN_OpeModKod,' + 'DLN_OpeModNazwisko,' + 'DLN_StaModId,' + 'DLN_TS_Mod,' + 'DLN_Zagraniczna,' + 'DLN_MiejsceDocelowe' + ')' + ' values(' + '10' + ',' + CONVERT (NVARCHAR, @Status) + ',' + CONVERT (NVARCHAR, @DDfId) + ',' + CONVERT (NVARCHAR, @NumerNr) + ',' + '''' + @NumerString + ''',' + CDN.Date2String(@DataDok, 120, 0) + ',' + CONVERT (NVARCHAR, @PodmiotTyp) + ',' + CONVERT (NVARCHAR, @PodmiotId) + ',' + CDN.Date2String(@DataOd, 120, 0) + ',' + CDN.Date2String(@DataDo, 120, 0) + ',' + CDN.Date2String(@DataRozliczenia, 120, 0) + ',' + CONVERT (NVARCHAR, @WyjazdZMZ) + ',' + ''''',' + '0,' + '0,' + '0,' + '0,' + '0,' + '''' + @Opis + ''',' + CDN.Date2String(@BuforData, 120, 0) + ',' + CONVERT (NVARCHAR, @BuforOperatorId) + ',' -- + convert(nvarchar, @PolecenieWyjazduOperatorId) + ','
-- +   '''' + convert(nvarchar, @WydatkiData, 120) + ''','
-- + convert(nvarchar, @WydatkiOperatorId) + ','
-- +   '''' + convert(nvarchar, @ZatwierdzenieData, 120) + ''','
-- + convert(nvarchar, @ZatwierdzenieOperatorId) + ','
+ CONVERT (NVARCHAR, @OpeZalID) + ',' + '''' + @OpeZalKod + ''',' + '''' + @OpeZalNazwisko + ''',' + CONVERT (NVARCHAR, @StaZalId) + ',' + CDN.Date2String(@TS_Zal, 120, 0) + ',' + CONVERT (NVARCHAR, @OpeModID) + ',' + '''' + @OpeModKod + ''',' + '''' + @OpeModNazwisko + ''',' + CONVERT (NVARCHAR, @StaModId) + ',' + CDN.Date2String(@TS_Mod, 120, 0) + ',' + CONVERT (NVARCHAR, @CzyZagraniczna) + ',' + '''' + @MiejsceDocelowe + '''' + ')'; -- + 'DLN_PolecenieWyjazduData,' +   '''' + convert(nvarchar, @PolecenieWyjazduData, 120) + ''',' +   '''' + convert(nvarchar, @DataDok, 120) + ''',' +   '''' + convert(nvarchar, @DataOd, 120) + ''',' +   '''' + convert(nvarchar, @DataDo, 120) + ''',' +   '''' + convert(nvarchar, @DataRozliczenia, 120) + ''',' +   '''' + convert(nvarchar, @BuforData, 120) + ''',' +   '''' + convert(nvarchar, @TS_Zal, 120) + ''',' +   '''' + convert(nvarchar, @TS_Mod, 120) + ''''
EXECUTE dbo.sp_executesql @sql;
