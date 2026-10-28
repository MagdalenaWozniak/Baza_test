create procedure cdn.ImportLokalizacje
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@Lok_ImportRowId varchar(36),
@Lok_Kod varchar(40),
@Lok_Nazwa nvarchar(254),
@Lok_Symbol varchar(5),
@Lok_Konto nvarchar(51),
@Lok_Nieaktywny smallint,
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
  if((select count(*) from cdn.Lokalizacje
    where ((isnull(@Lok_ImportRowId, '') <> '' and LOK_ImportRowId = @Lok_ImportRowId) OR LOK_Kod = @Lok_Kod) or (isnull(@Lok_ImportRowId, '') = '' and LOK_Kod = @Lok_Kod)) = 0)
  begin
   insert into cdn.Lokalizacje
   (
    LOK_ImportRowId,
    LOK_Kod,
    LOK_Nazwa,
    LOK_Symbol,
    LOK_Konto,
    LOK_Nieaktywny,
    LOK_OpeZalId,
    LOK_OpeZalKod,
    LOK_OpeZalNazwisko,
    LOK_TS_Zal,
    LOK_OpeModId,
    LOK_OpeModKod,
    LOK_OpeModNazwisko,
    LOK_TS_Mod,
    LOK_ImportAppId--,
    --LOK_TS_Export
   )
   values
   (
    @Lok_ImportRowId,
    @Lok_Kod,
    @Lok_Nazwa,
    @Lok_Symbol,
    @Lok_Konto,
    @Lok_Nieaktywny,
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
    if @OnlyNew <> 1
   begin
    SELECT @SlowID = Lok_LokID FROM CDN.Lokalizacje WHERE (isnull(@LOK_ImportRowId, '') <> '' and LOK_ImportRowId = @LOK_ImportRowId) or (isnull(@LOK_ImportRowId, '') = '' AND LOK_Kod = @Lok_Kod)
    update cdn.Lokalizacje
     set
      LOK_ImportRowId = @Lok_ImportRowId,
      LOK_Kod = @Lok_Kod,
      LOK_Nazwa = @Lok_Nazwa,
      LOK_Symbol = @Lok_Symbol,
      LOK_Konto = @Lok_Konto,
      LOK_Nieaktywny = @Lok_Nieaktywny,
      LOK_OpeZalId = @OpeId,
      LOK_OpeZalKod = @OpeModKod,
      LOK_OpeZalNazwisko = @OpeModNazwisko,
      LOK_TS_Zal = getdate(),
      LOK_OpeModId = @OpeId,
      LOK_OpeModKod = @OpeModKod,
      LOK_OpeModNazwisko = @OpeModNazwisko,
      LOK_TS_Mod = getdate(),
      LOK_ImportAppId = @ZrdId--,
      --LOK_TS_Export = getdate()
     where Lok_LokID = @SlowID
     SET @OperationType = 2 -- OptimaOperationType_Lokalizacja
   end
   else
    RAISERROR('##OPT33092##', 16, 1) --raiserror('Taki zapis już istnieje. Lokalizacja nie została dodana.', 16, 1)
  end
 IF @OperationType <> 0
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 24501, -- OptimaObjectType_Lokalizacja
    @ObiektSubTyp = 0,
    @ObiektID = @SlowID,
    @ObiektNazwa = @Lok_Nazwa,
    @OperacjaTyp = @OperationType,
    @Opis = ''
 end
