create procedure cdn.ImportWyplaty
@Wpl_LplId int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@Pra_ImportRowID nvarchar(36),
@Pra_Kod varchar(20),
@Dzl_ImportRowID nvarchar(36),
@Dzl_AdresWezla nvarchar(512),
@Wpl_Nazwa nvarchar(40),
@DDf_ImportRowID nvarchar(36),
@DDf_Symbol nvarchar(5),
@DDf_Numeracja nvarchar(50),
@Wpl_NumerString varchar(31),
@Wpl_NumerNr int,
@Wpl_NumerPelny varchar(30),
@Wpl_DataDok nvarchar(10),
@Wpl_Rok int,
@Wpl_Miesiac tinyint,
@Wpl_DataOd nvarchar(10),
@Wpl_DataDo nvarchar(10),
@Wpl_Wartosc decimal(15, 2),
@Wpl_Brutto decimal(15, 2),
@Wpl_Tryb int,
--@Wpl_KatId int,
@Kat_KodSzczegol nvarchar(20),
@Kat_ImportRowId nvarchar(36),
@Wpl_KategoriaOpis varchar(50),
@Wpl_Korekta tinyint,
@Wpl_KorektaPola int,
@Wpl_KorektaPola2 int,
@Wpl_KorektaPlatnosci tinyint,
@Wpl_Archiwalna tinyint,
@Wpl_Zamknieta tinyint,
@Wpl_UmowaDodZas smallint,
@Wpl_ObnizSklPPK tinyint,
@WPL_PodstawaPodat1 decimal(15, 2),
@WPL_PodstawaPodat2 decimal(15, 2),
@WPL_ProcentPodat1 decimal(5, 2),
@WPL_ProcentPodat2 decimal(5, 2),
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int output,
@Warnings nvarchar(1000) output
as
 begin
declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
  -- Importujemy zawsze całą listę płac jako nową, nigdy nie "uzupełniamy" istniejącej. Zatem nie musimy sprawdzać ImportRowID wypłaty -
  -- sprawdzamy tylko duplikacje po numerze pełnym oraz trybie (korygowana, zwykła) w ramach danego pliku XML.
  if((select count(*) from cdn.Wyplaty
   where Wpl_NumerPelny = @Wpl_NumerPelny AND Wpl_Tryb = @Wpl_Tryb) <> 0)
  begin
   RAISERROR('##OPT33100##', 16, 1) --raiserror('Taki zapis już istnieje. Wypłata nie została dodana.', 16, 1)
   return
  end
  IF @Wpl_ObnizSklPPK Is NULL
   SELECT @Wpl_ObnizSklPPK = 0
  IF @WPL_PodstawaPodat1 Is NULL
   SELECT @WPL_PodstawaPodat1 = 0
  IF @WPL_PodstawaPodat2 Is NULL
   SELECT @WPL_PodstawaPodat2 = 0
  IF @WPL_ProcentPodat1 Is NULL
   SELECT @WPL_ProcentPodat1 = 0
  IF @WPL_ProcentPodat2 Is NULL
   SELECT @WPL_ProcentPodat2 = 0
  if @Wpl_KorektaPola2 is null
   select @Wpl_KorektaPola2 = 0
  DECLARE @PraID INT
  SET @PraID = NULL
  IF @Pra_ImportRowID Is NOT Null
   SELECT @PraID = Pra_PraID FROM CDN.PracKod WHERE Pra_ImportRowId = @Pra_ImportRowID
  IF @PraID is Null
   SELECT @PraID = Pra_PraID FROM CDN.PracKod WHERE Pra_Kod = @Pra_Kod
  IF @PraID is Null
  BEGIN
   RAISERROR('##OPT33101##', 16, 1) --RAISERROR('Brak zadanego pracownika w bazie dla wypłaty.', 16, 1)
   RETURN
  END
  DECLARE @DzlID INT
  SET @DzlID = NULL
  IF @Dzl_ImportRowID Is NOT Null
   SELECT @DzlID = Dzl_DzlID FROM CDN.Dzialy WHERE Dzl_ImportRowId = @Dzl_ImportRowID
  IF @DzlID is Null
   SELECT @DzlID = Dzl_DzlID FROM CDN.Dzialy WHERE Dzl_AdresWezla = @Dzl_AdresWezla
  IF @DzlID is Null
  BEGIN
   RAISERROR('##OPT33101##', 16, 1) --RAISERROR('Brak zadanego wydziału w bazie dla wypłaty.', 16, 1)
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
   RAISERROR('##OPT33102##', 16, 1) --RAISERROR('Brak zgodnego schematu numeracji w bazie dla wypłaty.', 16, 1)
   RETURN
  END
  DECLARE @KatID INT
  SET @KatID = NULL
  IF(@Kat_ImportRowId is not NULL OR @Kat_KodSzczegol is not NULL)
  BEGIN
   SELECT @KatId = Kat_KatId FROM CDN.Kategorie WHERE Kat_ImportRowId = @Kat_ImportRowId
   IF(@KatId is NULL)
   BEGIN
    SELECT @KatId = Kat_KatId FROM CDN.Kategorie WHERE Kat_KodSzczegol = @Kat_KodSzczegol
    IF @KatId is NULL
     --SET @Warnings = 'Brak kategorii ' + IsNull(@Kat_KodSzczegol, '') + ' w bazie docelowej. Kategoria na wypłacie nie została zaimportowana.\'
     SET @Warnings = '##OPT33206##%%kategoria%%=' + IsNull(@Kat_KodSzczegol, '') + '##\'
   END
  END
    DECLARE @Wpl_DataDokDT DATETIME
    SET @Wpl_DataDokDT = CONVERT(DATETIME, @Wpl_DataDok, 120)
    DECLARE @Wpl_DataOdDT DATETIME
    SET @Wpl_DataOdDT = CONVERT(DATETIME, @Wpl_DataOd, 120)
    DECLARE @Wpl_DataDoDT DATETIME
    SET @Wpl_DataDoDT = CONVERT(DATETIME, @Wpl_DataDo, 120)
  insert into cdn.Wyplaty
  (
   WPL_LplID   ,
   --WPL_ParentId  ,
   WPL_PraID   ,
   WPL_DzlID   ,
   WPL_Nazwa  ,
   WPL_DdfID   ,
   WPL_NumerString  ,
   WPL_NumerNr   ,
   WPL_DataDok   ,
   WPL_Rok   ,
   WPL_Miesiac   ,
   WPL_DataOd   ,
   WPL_DataDo   ,
   WPL_Wartosc ,
   WPL_Brutto ,
   WPL_Tryb   ,
   WPL_KatID  ,
   WPL_KategoriaOpis ,
   WPL_Korekta   ,
   WPL_KorektaPola   ,
   WPL_KorektaPola2   ,
   WPL_KorektaPlatnosci   ,
   WPL_Archiwalna   ,
   WPL_Zamknieta   ,
   WPL_UmowaDodZas,
   WPL_ObnizSklPPK,
   WPL_PodstawaPodat1,
   WPL_PodstawaPodat2,
   WPL_ProcentPodat1,
   WPL_ProcentPodat2,
   Wpl_TS_Import,
   WPL_OpeZalId  ,
   WPL_OpeZalKod  ,
   WPL_OpeZalNazwisko  ,
   WPL_TS_Zal  ,
   WPL_OpeModId  ,
   WPL_OpeModKod  ,
   WPL_OpeModNazwisko  ,
   WPL_TS_Mod
  )
  values
  (
   @Wpl_LplId  ,
   --@Wpl_ParentId   ,
   @PraID  ,
   @DzlID  ,
   @Wpl_Nazwa  ,
   @DdfID  ,
   @Wpl_NumerString  ,
   @Wpl_NumerNr  ,
      @Wpl_DataDokDT  ,
   @Wpl_Rok  ,
   @Wpl_Miesiac  ,
      @Wpl_DataOdDT  ,
      @Wpl_DataDoDT  ,
   @Wpl_Wartosc  ,
   @Wpl_Brutto  ,
   @Wpl_Tryb  ,
   @KatID  ,
   @Wpl_KategoriaOpis  ,
   @Wpl_Korekta  ,
   @Wpl_KorektaPola  ,
   @Wpl_KorektaPola2  ,
   @Wpl_KorektaPlatnosci  ,
   @Wpl_Archiwalna  ,
   @Wpl_Zamknieta  ,
   @Wpl_UmowaDodZas,
   @Wpl_ObnizSklPPK,
   @WPL_PodstawaPodat1,
   @WPL_PodstawaPodat2,
   @WPL_ProcentPodat1,
   @WPL_ProcentPodat2,
   getdate(),
   @OpeId  ,
   @OpeModKod,
   @OpeModNazwisko,
   getdate(),
   @OpeId  ,
   @OpeModKod,
   @OpeModNazwisko,
   getdate()
  )
  select @IdParam = SCOPE_IDENTITY()
  declare @obj_name nvarchar(128)
  select @obj_name = '[' + PRI_Kod + '] ' + PRI_Imie1 + ' ' + PRI_Nazwisko from cdn.PracIdx where PRI_Typ = 1 and PRI_PraId = @PraID
  DECLARE @NumerPelny NVARCHAR(256)
  SELECT @NumerPelny = Wpl_NumerPelny FROM cdn.Wyplaty WHERE Wpl_WplID = @IdParam
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 24100, -- OptimaObjectType_Wyplata
    @ObiektSubTyp = 0,
    @ObiektID = @IdParam,
    @ObiektNazwa = @NumerPelny,
    @OperacjaTyp = 1, -- OptimaOperationType_Dodanie
    @Opis = ''
 end
