CREATE PROCEDURE cdn.ImportListyPlac
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
--@Lpl_ParentId int,
@Lpl_ImportRowId varchar(36),
@Lpl_Symbol varchar(5),
@Lpl_Nazwa nvarchar(128),
--@Lpl_DzlId int,
@Dzl_ImportRowID nvarchar(36),
@Dzl_AdresWezla nvarchar(512),
--@Lpl_DdfId int,
@DDf_ImportRowID nvarchar(36),
@DDf_Symbol nvarchar(5),
@DDf_Numeracja nvarchar(50),
@Lpl_NumerString varchar(31),
@Lpl_NumerNr int,
@Lpl_NumerPelny varchar(30),
@Lpl_DataDok nvarchar(10),
@Lpl_Rok int,
@Lpl_Miesiac smallint,
@Lpl_DataOd nvarchar(10),
@Lpl_DataDo nvarchar(10),
@Lpl_DataDanych nvarchar(10),
@Lpl_Tryb int,
@Lpl_Kategoria int,
@Lpl_MiesiecyWstecz int,
@Lpl_Oddelegowani tinyint,
@Lpl_Tymczasowi tinyint,
@Lpl_Waluta varchar(3),
@WKu_Symbol nvarchar(5),
@Lpl_KursL decimal(15,4),
@Lpl_KursM decimal(5,0),
@Lpl_DataKur nvarchar(10),
@Lpl_Zaksiegowana tinyint,
--@Lpl_DekId int,
--@Lpl_KPRId int,
--@Lpl_PreDekId int,
@Lpl_Zamknieta nvarchar(10),
@Lpl_WalutaDieta varchar(3),
@Lpl_OddelegowaniKraj varchar(40),
@WKu_SymbolDieta nvarchar(5),
@Lpl_KursLDieta decimal(15,4),
@Lpl_KursMDieta decimal(5,0),
@Lpl_DataKurDieta nvarchar(10),
@Zak_Symbol nvarchar(30),
@Zak_ImportRowId nvarchar(36),
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int output,
@Warnings nvarchar(1000) output
as
 begin
declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 DECLARE @OperationType INT
 SET @OperationType = 0
  if((select count(*) from cdn.ListyPlac
   where ((isnull(@Lpl_ImportRowId, '') <> '' and LPL_ImportRowId = @Lpl_ImportRowId) OR LPL_NumerPelny = @Lpl_NumerPelny) or (isnull(@Lpl_ImportRowId, '') = '' and LPL_NumerPelny = @Lpl_NumerPelny)) <> 0)
  begin
   RAISERROR('##OPT33097##', 16, 1) --raiserror('Taki zapis już istnieje. Lista płac nie została zaimportowana.', 16, 1)
  end
  DECLARE @DzlID INT
  SET @DzlID = NULL
  IF @Dzl_ImportRowID Is NOT Null
   SELECT @DzlID = Dzl_DzlID FROM CDN.Dzialy WHERE Dzl_ImportRowId = @Dzl_ImportRowID
  IF @DzlID is Null
   SELECT @DzlID = Dzl_DzlID FROM CDN.Dzialy WHERE Dzl_AdresWezla = @Dzl_AdresWezla
  IF @DzlID is Null
  BEGIN
   RAISERROR('##OPT33098##', 16, 1) --RAISERROR('Brak zadanego wydziału w bazie dla listy płac.', 16, 1)
   RETURN
  END
  DECLARE @DDfID INT
  SET @DDfID = NULL
  IF(@DDf_ImportRowID Is Not NULL)
   SELECT @DDfID = DDf_DDfId FROM CDN.DokDefinicje WHERE DDf_ImportRowID = @DDf_ImportRowID AND DDf_Numeracja = @DDf_Numeracja
  IF @DDfID is NULL
   SELECT @DDfID = DDf_DDfID FROM CDN.DokDefinicje WHERE DDf_Symbol = @DDf_Symbol AND DDf_Numeracja = @DDf_Numeracja
  IF @DDfID is NULL
  BEGIN
   -- SET @Warnings = 'Brak definicji dokumentu o zadanym symbolu i zgodnym schemacie numeracji ' + IsNull(@DDf_Symbol, '') + ' w bazie docelowej.\'
   RAISERROR('##OPT33099##', 16, 1) --RAISERROR('Brak zgodnego schematu numeracji w bazie dla listy płac.', 16, 1)
   RETURN
  END
  DECLARE @KursNumer INT
  EXECUTE @KursNumer = CDN.GetTypKursuWaluty @WKu_Symbol, @ConfigDBName, @ServerName
  IF(@KursNumer Is NULL AND @WKu_Symbol <> '')
    RAISERROR('##OPT32090##', 16, 1) --RAISERROR('Brak kursu waluty',  16, 1)
  DECLARE @KursNumerDieta INT
  EXECUTE @KursNumerDieta = CDN.GetTypKursuWaluty @WKu_SymbolDieta, @ConfigDBName, @ServerName
  IF(@KursNumerDieta Is NULL AND @WKu_SymbolDieta <> '')
    RAISERROR('##OPT32090##', 16, 1) --RAISERROR('Brak kursu waluty',  16, 1)
 if @Lpl_WalutaDieta is null
 begin
  set @Lpl_WalutaDieta = ''
 end
 if @Lpl_OddelegowaniKraj is null
 begin
  set @Lpl_OddelegowaniKraj = ''
 end
 if @Lpl_KursLDieta is null
 begin
  set @Lpl_KursLDieta = 1
 end
 if @Lpl_KursMDieta is null
 begin
  set @Lpl_KursMDieta = 1
 end
    DECLARE @Lpl_DataDokDT DATETIME
    SET @Lpl_DataDokDT = CONVERT(DATETIME, @Lpl_DataDok, 120)
    DECLARE @Lpl_DataOdDT DATETIME
    SET @Lpl_DataOdDT = CONVERT(DATETIME, @Lpl_DataOd, 120)
    DECLARE @Lpl_DataDoDT DATETIME
    SET @Lpl_DataDoDT = CONVERT(DATETIME, @Lpl_DataDo, 120)
    DECLARE @Lpl_DataDanychDT DATETIME
    SET @Lpl_DataDanychDT = CONVERT(DATETIME, @Lpl_DataDanych, 120)
    DECLARE @Lpl_DataKurDT DATETIME
    SET @Lpl_DataKurDT = CONVERT(DATETIME, @Lpl_DataKur, 120)
    DECLARE @Lpl_ZamknietaDT DATETIME
    SET @Lpl_ZamknietaDT = CONVERT(DATETIME, @Lpl_Zamknieta, 120)
    DECLARE @Lpl_DataKurDietaDT DATETIME
      SET @Lpl_DataKurDietaDT = CONVERT(DATETIME, @Lpl_DataKurDieta, 120)
    DECLARE @Zak_Id int
    EXEC CDN.GetZakladDlaPracyRozproszonej @Zak_Symbol, @Zak_ImportRowId, 4, @Zak_ID OUTPUT, @Warnings OUTPUT
  if((select count(*) from cdn.ListyPlac
   where ((isnull(@Lpl_ImportRowId, '') <> '' and LPL_ImportRowId = @Lpl_ImportRowId) OR LPL_NumerPelny = @Lpl_NumerPelny) or (isnull(@Lpl_ImportRowId, '') = '' and LPL_NumerPelny = @Lpl_NumerPelny)) = 0)
  begin
   insert into cdn.ListyPlac
   (
    --LPL_ParentId,
    LPL_ImportRowId,
    LPL_Symbol,
    LPL_Nazwa,
    LPL_DzlId,
    LPL_DdfId,
    LPL_NumerString,
    LPL_NumerNr,
    LPL_DataDok,
    LPL_Rok,
    LPL_Miesiac,
    LPL_DataOd,
    LPL_DataDo,
    LPL_DataDanych,
    LPL_Tryb,
    LPL_Kategoria,
    LPL_MiesiecyWstecz,
    LPL_Oddelegowani,
    LPL_Tymczasowi,
    LPL_Waluta,
    LPL_KursNumer,
    LPL_KursL,
    LPL_KursM,
    LPL_DataKur,
    LPL_Zaksiegowana,
    --LPL_PreDekId,
    --LPL_DekId,
    --LPL_KPRId,
    LPL_Zamknieta,
    LPL_WalutaDieta,
    LPL_OddelegowaniKraj,
    LPL_KursNumerDieta,
    LPL_KursLDieta,
    LPL_KursMDieta,
    LPL_DataKurDieta,
    LPL_ZakID,
    LPL_OpeZalId,
    LPL_OpeZalKod,
    LPL_OpeZalNazwisko,
    LPL_TS_Zal,
    LPL_OpeModId,
    LPL_OpeModKod,
    LPL_OpeModNazwisko,
    LPL_TS_Mod,
    LPL_TS_Import,
    LPL_ImportAppId
   )
   values
   (
    --@Lpl_ParentId,
    @Lpl_ImportRowId,
    @Lpl_Symbol,
    @Lpl_Nazwa,
    @DzlId,
    @DdfId,
    @Lpl_NumerString,
    @Lpl_NumerNr,
    @Lpl_DataDokDT,
    @Lpl_Rok,
    @Lpl_Miesiac,
    @Lpl_DataOdDT,
    @Lpl_DataDoDT,
    @Lpl_DataDanychDT,
    @Lpl_Tryb,
    @Lpl_Kategoria,
    @Lpl_MiesiecyWstecz,
    @Lpl_Oddelegowani,
    @Lpl_Tymczasowi,
    @Lpl_Waluta,
    @KursNumer,
    @Lpl_KursL,
    @Lpl_KursM,
    @Lpl_DataKurDT,
    @Lpl_Zaksiegowana,
    --@Lpl_PreDekId,
    --@Lpl_DekId,
    --@Lpl_KPRId,
    @Lpl_ZamknietaDT,
    @LPL_WalutaDieta,
    @LPL_OddelegowaniKraj,
    @KursNumerDieta,
    @Lpl_KursLDieta,
    @Lpl_KursMDieta,
    @Lpl_DataKurDietaDT,
    @Zak_Id,
    @OpeId,
    @OpeModKod,
    @OpeModNazwisko,
    getdate(),
    @OpeId,
    @OpeModKod,
    @OpeModNazwisko,
    getdate(),
    getdate(),
    @ZrdID
   )
   select @IdParam = SCOPE_IDENTITY()
   SET @OperationType = 1 -- OptimaOperationType_Dodanie
  end
  else
  begin
      if @OnlyNew <> 1
   begin
    select @IdParam = LPl_LPlID from cdn.ListyPlac
     where (isnull(@Lpl_ImportRowId, '') <> '' and Lpl_ImportRowId = @Lpl_ImportRowId) or (isnull(@Lpl_ImportRowId, '') = '' AND @Lpl_NumerPelny = @Lpl_NumerPelny)
    update cdn.ListyPlac
     set
      --LPL_ParentId = @Lpl_ParentId,
      LPL_ImportRowId = @Lpl_ImportRowId,
      LPL_Symbol = @Lpl_Symbol,
      LPL_Nazwa = @Lpl_Nazwa,
      LPL_DzlID = @DzlID,
      LPL_DDfID = @DDfID,
      LPL_NumerString = @Lpl_NumerString,
      LPL_NumerNr = @Lpl_NumerNr,
      LPL_DataDok = @Lpl_DataDokDT,
      LPL_Rok = @Lpl_Rok,
      LPL_Miesiac = @Lpl_Miesiac,
      LPL_DataOd = @Lpl_DataOdDT,
      LPL_DataDo = @Lpl_DataDoDT,
      LPL_DataDanych = @Lpl_DataDanychDT,
      LPL_Tryb = @Lpl_Tryb,
      LPL_Kategoria = @Lpl_Kategoria,
      LPL_MiesiecyWstecz = @Lpl_MiesiecyWstecz,
      LPL_Oddelegowani = @Lpl_Oddelegowani,
      LPL_Tymczasowi = @Lpl_Tymczasowi,
      LPL_Waluta = @Lpl_Waluta,
      LPL_KursNumer = @KursNumer,
      LPL_KursL = @Lpl_KursL,
      LPL_KursM = @Lpl_KursM,
      LPL_DataKur = @Lpl_DataKurDT,
      LPL_Zaksiegowana = @Lpl_Zaksiegowana,
      --LPL_PreDekId = @Lpl_PreDekId,
      --LPL_DekId = @Lpl_DekId,
      --LPL_KPRId = @Lpl_KPRId,
      LPL_Zamknieta = @Lpl_ZamknietaDT,
      LPL_WalutaDieta = @LPL_WalutaDieta,
      LPL_OddelegowaniKraj = @LPL_OddelegowaniKraj,
      LPL_KursNumerDieta = @KursNumerDieta,
      LPL_KursLDieta = @Lpl_KursLDieta,
      LPL_KursMDieta = @Lpl_KursMDieta,
      LPL_DataKurDieta = @Lpl_DataKurDietaDT,
      LPL_ZakID = @Zak_ID,
      LPL_OpeZalId = @OpeId,
      LPL_OpeZalKod = @OpeModKod,
      LPL_OpeZalNazwisko = @OpeModNazwisko,
      LPL_TS_Zal = getdate(),
      LPL_OpeModId = @OpeId,
      LPL_OpeModKod = @OpeModKod,
      LPL_OpeModNazwisko = @OpeModNazwisko,
      LPL_TS_Mod = getdate(),
      LPL_TS_Import = getdate(),
      LPL_ImportAppId = @ZrdID
     where LPl_LPlID = @IdParam
     SET @OperationType = 2 -- OptimaOperationType_Modyfikacja
   end
   else
    RAISERROR('##OPT33097##', 16, 1) --raiserror('Taki zapis już istnieje. Lista płac nie została dodana.', 16, 1)
  end
 IF @OperationType <> 0
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 24300, -- OptimaObjectType_ListaPlac
    @ObiektSubTyp = 0,
    @ObiektID = @IdParam,
    @ObiektNazwa = @Lpl_NumerString,
    @OperacjaTyp = @OperationType,
    @Opis = ''
 end
