create procedure cdn.ImportProjekty
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@ParentID int,
@Prj_ImportRowId nvarchar(36),
@Prj_Kod varchar(40),
@Prj_Nazwa nvarchar(255),
@Prj_Symbol varchar(20),
@Prj_Poziom smallint,
@Prj_Wezel nvarchar(255),
@Prj_Lp int,
@Prj_Url varchar(255),
@Prj_Konto nvarchar(51),
@Prj_Nieaktywny smallint,
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
  IF @ParentID = NULL
   SELECT @ParentID = Prj_PrjID FROM cdn.DefProjekty WHERE Prj_PrjID = 1
  if((select count(*) from cdn.DefProjekty
    where ((isnull(@Prj_ImportRowId, '') <> '' and PRJ_ImportRowId = @Prj_ImportRowId) OR PRJ_Wezel = @PRJ_Wezel)
     or (isnull(@Prj_ImportRowId, '') = '' and PRJ_Wezel = @PRJ_Wezel)) = 0)
  begin
   insert into cdn.DefProjekty
   (
    Prj_ParentID,
    Prj_ImportRowId,
    Prj_Kod,
    Prj_Nazwa,
    Prj_Symbol,
    Prj_Poziom,
    Prj_Wezel,
    Prj_Lp,
    Prj_Url,
    Prj_Konto,
    Prj_Nieaktywny,
    Prj_OpeZalId,
    Prj_OpeZalKod,
    Prj_OpeZalNazwisko,
    Prj_TS_Zal,
    Prj_OpeModId,
    Prj_OpeModKod,
    Prj_OpeModNazwisko,
    Prj_TS_Mod,
    Prj_ImportAppId--,
    --Prj_TS_Export
   )
   values
   (
    @ParentID,
    @Prj_ImportRowId,
    @Prj_Kod,
    @Prj_Nazwa,
    @Prj_Symbol,
    @Prj_Poziom,
    @Prj_Wezel,
    @Prj_Lp,
    @Prj_Url,
    @Prj_Konto,
    @Prj_Nieaktywny,
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
   select @SlowID = Prj_PrjID from cdn.DefProjekty
    where ((isnull(@Prj_ImportRowId, '') <> '' and PRJ_ImportRowId = @Prj_ImportRowId) OR PRJ_Wezel = @PRJ_Wezel)
     or (isnull(@Prj_ImportRowId, '') = '' and PRJ_Wezel = @PRJ_Wezel)
      if @OnlyNew <> 1
   begin
    update cdn.DefProjekty
     set
      Prj_ParentID = @ParentID,
      Prj_ImportRowId = @Prj_ImportRowId,
      Prj_Kod = @Prj_Kod,
      Prj_Nazwa = @Prj_Nazwa,
      Prj_Symbol = @Prj_Symbol,
      Prj_Poziom = @Prj_Poziom,
      Prj_Wezel = @Prj_Wezel,
      Prj_Lp = @Prj_Lp,
      Prj_Url = @Prj_Url,
      Prj_Konto = @Prj_Konto,
      Prj_Nieaktywny = @Prj_Nieaktywny,
      Prj_OpeZalId = @OpeId,
      Prj_OpeZalKod = @OpeModKod,
      Prj_OpeZalNazwisko = @OpeModNazwisko,
      Prj_TS_Zal = getdate(),
      Prj_OpeModId = @OpeId,
      Prj_OpeModKod = @OpeModKod,
      Prj_OpeModNazwisko = @OpeModNazwisko,
      Prj_TS_Mod = getdate(),
      Prj_ImportAppId = @ZrdId--,
      --Prj_TS_Export = getdate()
     where (isnull(@PRJ_ImportRowId, '') <> '' and PRJ_ImportRowId = @PRJ_ImportRowId) or (isnull(@PRJ_ImportRowId, '') = '' AND PRJ_Wezel = @PRJ_Wezel)
     SET @OperationType = 2 -- OptimaOperationType_Lokalizacja
   end
   else
    RAISERROR('##OPT33095##', 16, 1) --raiserror('Taki zapis już istnieje. Projekt nie został dodany.', 16, 1)
  end
 IF @OperationType <> 0
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 24502, -- OptimaObjectType_Projekt
    @ObiektSubTyp = 0,
    @ObiektID = @SlowID,
    @ObiektNazwa = @Prj_Nazwa,
    @OperacjaTyp = @OperationType,
    @Opis = ''
 end
