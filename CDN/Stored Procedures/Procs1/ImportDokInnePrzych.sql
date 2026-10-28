CREATE PROCEDURE CDN.ImportDokInnePrzych
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@EDN_ImportRowId nvarchar(36),
@Typ nvarchar(30),
@DDf_Symbol nvarchar(5),
@DDf_ImportRowID nvarchar(36),
@schemat_zewnetrzny nvarchar(50),
@EDN_DataWys nvarchar(10),
@EDN_DataOpe nvarchar(10),
@EDN_DataDok nvarchar(10),
@EDN_NumerPelny nvarchar(30),
@EDN_NumerObcy nvarchar(256),
@EDN_Rejestr nvarchar(20),
@Pod_TypOpis nvarchar(15),
@Pod_Kod nvarchar(20),
@Pod_ImportRowId nvarchar(36),
@Pod_NIP nvarchar(20),
@EDN_Nazwa1 nvarchar(50),
@EDN_Nazwa2 nvarchar(50),
@EDN_Nazwa3 nvarchar(250),
@EDN_NipKraj nvarchar(2),
@EDN_NipE nvarchar(32),
@EDN_Kraj nvarchar(40),
@EDN_Wojewodztwo nvarchar(40),
@EDN_Powiat nvarchar(40),
@EDN_Gmina nvarchar(40),
@EDN_Ulica nvarchar(40),
@EDN_NrDomu nvarchar(10),
@EDN_NrLokalu nvarchar(10),
@EDN_Miasto nvarchar(40),
@EDN_KodPocztowy nvarchar(10),
@EDN_Poczta nvarchar(40),
@EDN_Adres2 nvarchar(40),
@Zal_TypOpis nvarchar(15),
@Zal_Kod nvarchar(20),
@Zal_ImportRowId nvarchar(36),
@Zal_NIP nvarchar(20),
@EDN_PlatnikTypOpis nvarchar(10),
@EDN_PlatnikKod nvarchar(20),
@EDN_PlatnikImportRowID nvarchar(36),
@EDN_PlatnikNIP nvarchar(20),
@EDN_PlatnikRachunekNr0 nvarchar(51),
@Kat_KodSzczegol nvarchar(20),
@Kat_ImportRowId nvarchar(36),
@EDN_Kategoria nvarchar(50),
@EDN_MagazynZrodlowy NVARCHAR(20),
@EDN_MagazynDocelowy NVARCHAR(20),
@EDN_KwotaRazem decimal(15,2),
@EDN_Waluta nvarchar(3),
@WKu_Symbol nvarchar(5),
@EDN_KursL decimal(15,4),
@EDN_KursM decimal(5,0),
@EDN_DataKur nvarchar(10),
@EDN_KwotaRazemSys decimal(15,2),
@KontrolaSumy nvarchar(3),
@EDN_Platnosci tinyint,
@FPl_Nazwa nvarchar(36),
@FPl_ImportRowId nvarchar(36),
@EDN_Termin nvarchar(10),
@Zak_Symbol nvarchar(30),
@Zak_ImportRowId nvarchar(36),
@walutaPlat nvarchar(3),
@symbolPlat nvarchar(5),
@kursLPlat decimal(15, 4),
@kursMPlat decimal(5, 0),
@dataKurPlat nvarchar(10),
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 DECLARE @DDfId    integer,
 @KatId      integer,
 @FplId      integer,
 @KursNumer     integer,
 @schemat     nvarchar(50),
 @lp       integer,
 @PodId      integer,
 @PodTyp      smallint,
 @ZalId      integer,
 @ZalTyp      smallint,
 @DokKlasa     integer,
 @NumerString    nvarchar(31),
 @OkresObrach    nvarchar(5),
 @MaxNr      int,
 @MaxNrZKB     int,
 @seriaOper     nvarchar(20),
 @CzySeriaOper    int,
 @BraId      int,
 @BRpID      int,
 @BRpLP      int,
 @DDfIdZKB     int,
 @BNaId      int,
 @RachunekNr     nvarchar(51),
 @BZp_NumerString   nvarchar(31),
 @BZp_Schemat    nvarchar(50),
 @WkuIdPlat     int,
 @IBAN      tinyint,
 @notUsed     int
 SET @Warnings = ''
 IF ( EXISTS(SELECT *
      FROM CDN.EwidDodNag
      WHERE EDN_ImportRowId = @EDN_ImportRowId))
 BEGIN
  RAISERROR('##OPT33044##', 16, 1) --RAISERROR('Taki zapis już istnieje', 16, 1)
  RETURN
 END
 SET @DDfID = CDN.GetDDfIDFromRowIDOrSymbol(@DDf_ImportRowId, @DDf_Symbol);
 SELECT @schemat = DDf_Numeracja, @DokKlasa = DDf_Klasa
 FROM CDN.DokDefinicje
 WHERE @DDfId = DDf_DDfId
 If(@DDfId is Null AND IsNull(@EDN_NumerPelny, '') <> '')
 BEGIN
  RAISERROR('##OPT32087##', 16, 1) --RAISERROR('Brak definicji dokumentu', 16, 1)
  RETURN
 END
 IF(@schemat_zewnetrzny is not NULL)
  SET @schemat = @schemat_zewnetrzny
-- IF @DokKlasa = 101
 SET @EDN_Platnosci = (@EDN_Platnosci + 1) % 2
 EXECUTE @KursNumer = CDN.GetTypKursuWaluty @Wku_Symbol, @ConfigDBName, @ServerName
 IF(@KursNumer is NULL)
  RAISERROR('##OPT32090##', 16, 1) --RAISERROR('Brak kursu waluty',  16, 1)
 --pobranie kursy waluta dla płatnosci automatycznego zapisu kasowo bankowego
 IF(@symbolPlat is NULL OR @symbolPlat = '') SET @symbolPlat = '<-->'
 EXECUTE @WkuIdPlat = CDN.GetTypKursuWaluty @symbolPlat, @ConfigDBName, @ServerName
 IF(@Fpl_Nazwa is NULL OR @Fpl_Nazwa = '') SET @FPl_Nazwa = 'gotówka'
 SELECT @FplId = Fpl_FplId, @BRaId = Fpl_BraId
 FROM CDN.FormyPlatnosci
 WHERE Fpl_ImportRowId = @Fpl_ImportRowId
 IF @FplId is NULL
  SELECT @FplId = Fpl_FplId, @BRaId = Fpl_BraId
  FROM CDN.FormyPlatnosci
  WHERE Fpl_Nazwa = @Fpl_Nazwa
-- IF(@FplId = NUll)RAISERROR(50005, 16, 1)
 IF(SELECT Fir_Wartosc
  FROM CDN.Firma
  WHERE Fir_Numer = 3077) = '1'
 BEGIN
  SELECT TOP 1 @Lp = IsNull(EDN_Lp, 0) + 1
  FROM CDN.EwidDodNag
  WHERE YEAR(EDN_DataDok) = YEAR(convert(datetime, @EDN_DataDok, 120)) AND EDN_Rejestr = @EDN_Rejestr AND EDN_Typ = 101
  ORDER BY EDN_Lp DESC
 END
 ELSE
 BEGIN
  SELECT TOP 1 @Lp = IsNull(EDN_Lp, 0) + 1
  FROM CDN.EwidDodNag
  WHERE YEAR(EDN_DataDok) = YEAR(convert(datetime, @EDN_DataDok, 120)) AND MONTH(EDN_DataDok) = MONTH(convert(datetime, @EDN_DataDok, 120)) AND EDN_Rejestr = @EDN_Rejestr AND EDN_Typ = 101
  ORDER BY EDN_Lp DESC
 END
 IF(@Lp is NULL) SET @Lp = 1
 EXEC CDN.GetPodmiotDlaPracyRozproszonej @Pod_TypOpis, @Pod_Kod, @Pod_ImportRowId, @EDN_NipE, 1, @PodID OUTPUT, @PodTyp OUTPUT, @notUsed OUTPUT, @Warnings OUTPUT
 if(@Zal_TypOpis IS NOT NULL)
  EXEC CDN.GetPodmiotDlaPracyRozproszonej @Zal_TypOpis, @Zal_Kod, @Zal_ImportRowId, @Zal_NIP, 2, @ZalID OUTPUT, @ZalTyp OUTPUT, @notUsed OUTPUT, @Warnings OUTPUT
 IF (NOT EXISTS( SELECT *
      FROM CDN.Grupy
      WHERE Gru_Typ = 34 and Gru_Nazwa = @EDN_Rejestr) AND @EDN_Rejestr <> '')
   INSERT INTO CDN.Grupy
   (
   Gru_Typ,
   Gru_Nazwa,
   Gru_Opis,
   Gru_Flaga,
   Gru_TS_Zal,
   Gru_TS_Mod
   )
   VALUES
   (
   34,
   @EDN_Rejestr,
   'Ewidencja dodatkowa przychodów',
   NULL,
   GetDate(),
   GetDate()
   )
 SELECT @OkresObrach = OOb_Symbol
 FROM CDN.OkresyObrach
 WHERE OOb_OObId = (SELECT Fir_Wartosc
      FROM CDN.Firma
      WHERE Fir_Numer = '244')
 IF(@EDN_Nazwa1 is NULL)
  BEGIN
   SET @EDN_Nazwa1 = ''
   SELECT @EDN_Nazwa1 = Knt_Nazwa1
   FROM CDN.Kontrahenci
   WHERE Knt_KntId = @PodId AND @PodTyp = 1
  END
 IF(@EDN_Nazwa2 is NULL)
 BEGIN
  SET @EDN_Nazwa2 = ''
  SELECT @EDN_Nazwa2 = Knt_Nazwa2
  FROM CDN.Kontrahenci
  WHERE Knt_KntId = @PodId AND @PodTyp = 1
 END
 IF(@EDN_Nazwa3 is NULL)
 BEGIN
  SET @EDN_Nazwa3 = ''
  SELECT @EDN_Nazwa3 = Knt_Nazwa3
  FROM CDN.Kontrahenci
  WHERE Knt_KntId = @PodId AND @PodTyp = 1
 END
 DECLARE @KategoriaZKontrahenta TINYINT
 SELECT @KategoriaZKontrahenta = 0
 IF(@Kat_ImportRowId is not NULL OR @Kat_KodSzczegol is not NULL)
 BEGIN
  SET @KatId = NULL
  SELECT @KatId = Kat_KatId
  FROM CDN.Kategorie
  WHERE Kat_ImportRowId = @Kat_ImportRowId
  IF(@KatId is NULL)
  BEGIN
   SELECT @KatId = Kat_KatId
   FROM CDN.Kategorie
   WHERE Kat_KodSzczegol = @Kat_KodSzczegol
   IF(@KatId is NULL)
    --SET @Warnings = 'Brak kategorii ' + IsNull(@Kat_KodSzczegol, '') + ' w bazie docelowej. Kategoria nie została zaimportowana.\'
    SET @Warnings = '##OPT33150##%%kategoria%%=' + IsNull(@Kat_KodSzczegol, '') + '##\'
  END
 END
 ELSE IF @PodTyp = 1 AND (SELECT IsNull(Fir_Wartosc, '') FROM cdn.Firma WHERE Fir_Numer = 3139) = '1'
 BEGIN
  SELECT @KatID = Knt_KatID FROM cdn.Kontrahenci WHERE Knt_KntID = @PodID
  IF @KatID Is NOT NULL
   SELECT @KategoriaZKontrahenta = 1
 END
 IF(@EDN_Kategoria is NULL OR @EDN_Kategoria = '' AND @KategoriaZKontrahenta = 1)
 BEGIN
  SELECT @EDN_Kategoria = Kat_Opis FROM CDN.Kategorie WHERE Kat_KatId = @KatID
  SELECT @EDN_Kategoria = IsNull(@EDN_Kategoria, '')
 END
 SET @MaxNr = CDN.GetDokNumber(@schemat, @EDN_NumerPelny)
 SET @NumerString = CDN.GetDokNumstring(@schemat, @EDN_NumerPelny)
/*  [Nie sprawdzamy serii dokumentu na operatorze (mogą być różne z danymi do importu)]
 DECLARE @seriasqltxt NVARCHAR (1000)
 SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
 IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
 SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
 SET @seriasqltxt = 'SELECT Ope_SymbolDlaNumeracji as seria FROM ['
 IF @ServerName <> @TmpSrvName
 SET @seriasqltxt = @seriasqltxt + @ConfigDBName +'].['
 SET @seriasqltxt = @seriasqltxt + @ConfigDBName + ']' + '.[CDN].[Operatorzy] WHERE Ope_OpeID = ' + convert(nvarchar(10), @OpeId)
 CREATE TABLE #Seria (seria nvarchar(5))
 INSERT INTO #Seria (seria)
 EXEC sp_executesql @seriasqltxt
 SELECT @seriaOper = seria FROM #Seria
 DROP TABLE #Seria
*/
  IF @EDN_NumerPelny is NULL OR @EDN_NumerPelny = ''
  BEGIN
   SET @NumerString = CDN.NumerString(909090, @OpeId, 1, 1, convert(datetime, @EDN_DataDok, 120), @seriaOper, @DDf_Symbol, default, @schemat_zewnetrzny)
   SELECT @MaxNr = MAX(EDN_NumerNr) FROM CDN.EwidDodNag  with (updlock) WHERE
       EDN_NumerString = @NumerString AND
       EDN_NumerNr >=0
   SET @MaxNr = IsNull(@MaxNr, 0) + 1
   IF IsNull(@DDfID, 0) = 0 --PG: 173525
    SELECT @DDfId = CONVERT(INT, Fir_Wartosc) FROM cdn.Firma WHERE Fir_Numer = 1443
  END
  ELSE
  BEGIN
   IF CDN.GetNumerPelny(@schemat, convert(datetime, @EDN_DataDok, 120),
     --case @CzySeriaOper when 1 then @SeriaOper else CDN.GetPrymityw(@EDN_NumerPelny, @schemat, '@rejestr') end,
     CDN.GetPrymityw(@EDN_NumerPelny, @schemat, '@rejestr'),
     @DDf_Symbol, @MaxNr, CDN.GetPrymityw(@EDN_NumerPelny, @schemat, '@magazyn'), @OkresObrach) <> @EDN_NumerPelny
   BEGIN
    RAISERROR('##OPT33043##', 16, 1) --RAISERROR('Numer dokumentu nie jest zgodny ze schematem numeracji.', 16, 1)
    RETURN
   END
  END
  DECLARE @PlatnikTyp int
  DECLARE @PlatnikID int
  DECLARE @PlatnikRachunekLp int
  SET @PlatnikRachunekLp = NULL
  IF @EDN_PlatnikTypOpis Is Not Null
  BEGIN
   EXEC CDN.GetPlatnikDlaPracyRozproszonej @EDN_PlatnikTypOpis, @EDN_PlatnikKod, @EDN_PlatnikImportRowID, @EDN_PlatnikNIP, @EDN_PlatnikRachunekNr0,
    1,
    @PlatnikTyp OUTPUT, @PlatnikID OUTPUT, @PlatnikRachunekLp OUTPUT, @Warnings OUTPUT
   IF(@PlatnikID is NULL) -- jeśli nie ma podmiotu w bazie to zaliczkobiorca nie bedzie wypełniony
   BEGIN
    SET @PlatnikTyp = @PodTyp
    SET @PlatnikID = @PodId
   END
  END
  ELSE
  BEGIN
   SET @PlatnikTyp = @PodTyp
   SET @PlatnikID = @PodId
  END
    DECLARE @Zak_Id int
    EXEC CDN.GetZakladDlaPracyRozproszonej @Zak_Symbol, @Zak_ImportRowId, 3, @Zak_ID OUTPUT, @Warnings OUTPUT
  INSERT  INTO CDN.EwidDodNag
  (
  EDN_ImportRowId,
  EDN_DDfId,
  EDN_NumerString,
  EDN_NumerNr,
  EDN_NumerObcy,
  EDN_DataWys,
  EDN_DataDok,
  EDN_DataOpe,
  EDN_Typ,
  EDN_Rejestr,
  EDN_Lp,
  EDN_PodmiotTyp,
  EDN_PodID,
  EDN_Nazwa1,
  EDN_Nazwa2,
  EDN_Nazwa3,
  EDN_Kraj,
  EDN_Wojewodztwo,
  EDN_Powiat,
  EDN_Gmina,
  EDN_Ulica,
  EDN_NrDomu,
  EDN_NrLokalu,
  EDN_Miasto,
  EDN_KodPocztowy,
  EDN_Poczta,
  EDN_Adres2,
  EDN_PodmiotZalTyp,
  EDN_PodZalId,
  EDN_NipKraj,
  EDN_NipE,
  EDN_PlatnikTyp,
  EDN_PlatnikID,
  EDN_PlatnikRachunekLp,
  EDN_PlatnikRachunekNr,
  EDN_KatID,
  EDN_Kategoria,
  EDN_MagazynZrodlowy,
  EDN_MagazynDocelowy,
  EDN_KwotaRazemSys,
  EDN_KontrolaSumy,
  EDN_KwotaRazem,
  EDN_Waluta,
  EDN_KursNumer,
  EDN_KursL,
  EDN_KursM,
  EDN_Platnosci,
  EDN_FPlId,
  EDN_Termin,
  EDN_DekId,
  EDN_KPRId,
  EDN_RycId,
    EDN_ZakID,
  EDN_OpeZalID,
  EDN_OpeZalKod,
  EDN_OpeZalNazwisko,
  EDN_StaZalId,
  EDN_TS_Zal,
  EDN_OpeModID,
  EDN_OpeModKod,
  EDN_OpeModNazwisko,
  EDN_StaModId,
  EDN_TS_Mod,
  EDN_DataKur,
  EDN_ImportAppId
  )
  VALUES
  (
  @EDN_ImportRowId,
  @DDfId,
  @NumerString,
  @MaxNr,
  @EDN_NumerObcy,
  convert(datetime, @EDN_DataWys, 120),
  convert(datetime, @EDN_DataDok, 120),
  convert(datetime, @EDN_DataOpe, 120),
  101,
  @EDN_Rejestr,
  @lp,
  @PodTyp,
  @PodId,
  @EDN_Nazwa1,
  @EDN_Nazwa2,
  @EDN_Nazwa3,
  @EDN_Kraj,
  @EDN_Wojewodztwo,
  @EDN_Powiat,
  @EDN_Gmina,
  @EDN_Ulica,
  @EDN_NrDomu,
  @EDN_NrLokalu,
  @EDN_Miasto,
  @EDN_KodPocztowy,
  @EDN_Poczta,
  @EDN_Adres2,
  @ZalTyp,
  @ZalId,
  @EDN_NipKraj,
  REPLACE(@EDN_NipE, ' ', ''),
  @PlatnikTyp,
  @PlatnikID,
  @PlatnikRachunekLp,
  CASE WHEN IsNull(@PlatnikRachunekLp, 0) <>0 THEN @EDN_PlatnikRachunekNr0 ELSE '' END,
  @KatId,
  @EDN_Kategoria,
  UPPER(@EDN_MagazynZrodlowy),
  UPPER(@EDN_MagazynDocelowy),
  @EDN_KwotaRazemSys,
  0,
  @EDN_KwotaRazem,
  @EDN_Waluta,
  @KursNumer,
  Case when @EDN_KursL=0 then 1 else @EDN_KursL end,
  Case when @EDN_KursM=0 then 1 else @EDN_KursM end,
  @EDN_Platnosci,
  @FPlId,
  convert(datetime,  IsNull(@EDN_Termin, @EDN_DataWys),120),
  NULL,
  NULL,
  NULL,
    @Zak_Id,
  @OpeId,
  @OpeModKod,
  @OpeModNazwisko,
  NULL,
  GETDATE(),
  @OpeId,
  @OpeModKod,
  @OpeModNazwisko,
  NULL,
  GETDATE(),
  convert(datetime, @EDN_DataKur, 120),
  @ZrdId
  )
  SET @IdParam = SCOPE_IDENTITY()
 DECLARE @NumerPelny nvarchar(30)
 SELECT @NumerPelny = EDN_NumerPelny FROM cdn.EwidDodNag WHERE EDN_EDNID = @IdParam
 EXEC [CDN].[RejestrOperacjiDodaj]
   @ObiektTyp = 1003, -- e_op_KlasaEwidencjaDodatkowa
   @ObiektSubTyp = 101,
   @ObiektID = @IdParam,
   @ObiektNazwa = @NumerPelny,
   @OperacjaTyp = 1, -- OptimaOperationType_Dodanie
   @Opis = ''
END
