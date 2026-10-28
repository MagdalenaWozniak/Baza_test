create procedure cdn.ImportDzialy
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@ParentID int,
@Dzl_ImportRowId varchar(36),
@Dzl_Kod varchar(40),
@Dzl_Nazwa nvarchar(254),
@Dzl_Symbol varchar(5),
@Dzl_Poziom smallint,
@Dzl_AdresWezla nvarchar(512),
@Dzl_Lisc int,
@Dzl_Last tinyint,
@Lok_ImportRowId varchar(36),
@Lok_Kod varchar(40),
@Dzl_AddMethod tinyint,
@Dzl_Konto nvarchar(51),
@Dzl_ImpId int,
--@Dzl_ZrgId int,
@Dzl_Nieaktywny smallint,
@ZrdId nvarchar(5),
@OpeId int,
@SlowId int output,
@Warnings nvarchar(1000) output
as
 begin
declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 DECLARE @OperationType INT
 SET @OperationType = 0
  declare @LokId int
  set @LokId = NULL
  if @Lok_ImportRowId Is Not Null
   select @LokId = LOK_LokId from cdn.Lokalizacje where Lok_ImportRowId = @Lok_ImportRowId
  if @LokId Is Null
   select @LokId = LOK_LokId from cdn.Lokalizacje where Lok_Kod = @Lok_Kod
  IF @LokId is Null
  BEGIN
   RAISERROR('##OPT33093##', 16, 1) --RAISERROR('Brak zadanej lokalizacji w bazie.', 16, 1)
   RETURN
  END
  IF @ParentID = NULL
   SELECT @ParentID = DZL_DzlId from cdn.Dzialy WHERE Dzl_DzlID = 1
  if((select count(*) from cdn.Dzialy
    where ((isnull(@Dzl_ImportRowId, '') <> '' and DZL_ImportRowId = @Dzl_ImportRowId) OR DZL_AdresWezla = @Dzl_AdresWezla)
     or (isnull(@Dzl_ImportRowId, '') = '' and DZL_AdresWezla = @Dzl_AdresWezla)) = 0)
  begin
   insert into cdn.Dzialy
   (
    DZL_ParentId,
    DZL_ImportRowId,
    DZL_Kod,
    DZL_Nazwa,
    DZL_Symbol,
    DZL_Poziom,
    DZL_AdresWezla,
    DZL_Lisc,
    DZL_Last,
    DZL_LokId,
    DZL_AddMethod,
    DZL_Konto,
    DZL_ImpId,
    DZL_ZrgId,
    DZL_Nieaktywny,
    DZL_OpeZalId,
    DZL_OpeZalKod,
    DZL_OpeZalNazwisko,
    DZL_TS_Zal,
    DZL_OpeModId,
    DZL_OpeModKod,
    DZL_OpeModNazwisko,
    DZL_TS_Mod,
    DZL_ImportAppId--,
    --DZL_TS_Export
   )
   values
   (
    @ParentId,
    @Dzl_ImportRowId,
    @Dzl_Kod,
    @Dzl_Nazwa,
    @Dzl_Symbol,
    @Dzl_Poziom,
    @Dzl_AdresWezla,
    @Dzl_Lisc,
    @Dzl_Last,
    @LokId,
    @Dzl_AddMethod,
    @Dzl_Konto,
    @Dzl_ImpId,
    null,--@Dzl_ZrgId,
    @Dzl_Nieaktywny,
    @OpeId,
    @OpeModKod,
    @OpeModNazwisko,
    getdate(),
    @OpeId,
    @OpeModKod,
    @OpeModNazwisko,
    getdate(),
    @ZrdId--,
    --getdate()
   )
   select @SlowID = SCOPE_IDENTITY()
   SET @OperationType = 1 -- OptimaOperationType_Dodanie
  end
  else
  begin
   select @SlowID = Dzl_DzlID from cdn.Dzialy
     where ((isnull(@Dzl_ImportRowId, '') <> '' and DZL_ImportRowId = @Dzl_ImportRowId) OR DZL_AdresWezla = @Dzl_AdresWezla)
     or (isnull(@Dzl_ImportRowId, '') = '' and DZL_AdresWezla = @Dzl_AdresWezla)
      if @OnlyNew <> 1
   begin
    update cdn.Dzialy
     set
      DZL_ParentId = @ParentId,
      DZL_ImportRowId = @Dzl_ImportRowId,
      DZL_Kod = @Dzl_Kod,
      DZL_Nazwa = @Dzl_Nazwa,
      DZL_Symbol = @Dzl_Symbol,
      DZL_Poziom = @Dzl_Poziom,
      DZL_AdresWezla = @Dzl_AdresWezla,
      DZL_Lisc = @Dzl_Lisc,
      DZL_Last = @Dzl_Last,
      DZL_LokId = @LokId,
      DZL_AddMethod = @Dzl_AddMethod,
      DZL_Konto = @Dzl_Konto,
      DZL_ImpId = @Dzl_ImpId,
      --DZL_ZrgId = null,--@Dzl_ZrgId,
      DZL_Nieaktywny = @Dzl_Nieaktywny,
      DZL_OpeZalId = @OpeId,
      DZL_OpeZalKod = @OpeModKod,
      DZL_OpeZalNazwisko = @OpeModNazwisko,
      DZL_TS_Zal = getdate(),
      DZL_OpeModId = @OpeId,
      DZL_OpeModKod = @OpeModKod,
      DZL_OpeModNazwisko = @OpeModNazwisko,
      DZL_TS_Mod = getdate(),
      DZL_ImportAppId = @ZrdId--,
      --DZL_TS_Export = getdate()
     where (isnull(@Dzl_ImportRowId, '') <> '' and Dzl_ImportRowId = @Dzl_ImportRowId) or (isnull(@Dzl_ImportRowId, '') = '' AND Dzl_AdresWezla = @Dzl_AdresWezla)
     SET @OperationType = 2 -- OptimaOperationType_Lokalizacja
   end
   else
    RAISERROR('##OPT33094##', 16, 1) --raiserror('Taki zapis już istnieje. Wydział nie został dodany.', 16, 1)
  end
 IF @OperationType <> 0
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 24500, -- OptimaObjectType_Dzial
    @ObiektSubTyp = 0,
    @ObiektID = @SlowID,
    @ObiektNazwa = @Dzl_Nazwa,
    @OperacjaTyp = @OperationType,
    @Opis = ''
 end
