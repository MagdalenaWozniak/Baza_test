create procedure cdn.ODodajDzial @ParentId int, @Kod varchar(40), @Nazwa varchar(255), @Nieaktywny tinyint, @Konto nvarchar(51), @LokId int, @ZrgId int, @Symbol varchar(5)
 as
 set nocount on
  declare @TRanWewnetrzna int
  set @TRanWewnetrzna = 0
     if @@trancount = 0
        begin
   begin tran
            set @TRanWewnetrzna = 1
        end
  declare
   @Poziom smallint,
   @Adres varchar(255),
   @LP int,
   @AddMet tinyint
  set @Poziom = 1
  set @Adres = ''
  set @AddMet = 0
  if @ParentId > 0
  begin
   set @AddMet = 1
   select @Poziom = DZL_Poziom + 1, @Adres = DZL_AdresWezla from cdn.Dzialy where DZL_DzlId = @ParentId
   select @LP = max(DZL_Lisc) from cdn.Dzialy where DZL_ParentId = @ParentId
  end
  else
  begin
   select @Poziom = DZL_Poziom + 1, @Adres = DZL_AdresWezla from cdn.Dzialy where DZL_DzlId = 3
   select @LP = max(DZL_Lisc) from cdn.Dzialy where DZL_ParentId = 3
   set @ParentId = 3
  end
  if @LP is null
   set @LP = 1
  else
   set @LP = @LP + 1
  if @LokId is null or @LokId = 0
   set @LokId = 1
  set @Adres = cdn.UtworzAdresWezla(@Adres, @LP)
  if len(@Kod) > 0 and len(@Nazwa) > 0
  begin
   declare @OpeId int
   set @OpeId = cdn.GetXLOperatorID()
   declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
   exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
   insert into cdn.Dzialy
    (
    DZL_Kod,
    DZL_Nazwa,
    DZL_Nieaktywny,
    DZL_Konto,
    DZL_ParentId,
    DZL_Poziom,
    DZL_Symbol,
    DZL_AdresWezla,
    DZL_Lisc,
    DZL_AddMethod,
    DZL_ImpId,
    DZL_Last,
    DZL_LokId,
    DZL_ZrgId,
    DZL_OpeZalId,
    DZL_OpeZalKod,
    DZL_OpeZalNazwisko,
    DZL_OpeModId,
    DZL_OpeModKod,
    DZL_OpeModNazwisko,
    DZL_TS_Mod,
    DZL_TS_Zal
    )
   values
    (
    @Kod,
    @Nazwa,
    @Nieaktywny,
    @Konto,
    @ParentId,
    @Poziom,
    '',--@Symbol,
    @Adres,
    @LP,
    @AddMet,
    0,
    0,
    @LokId,
    @ZrgId,
    @OpeId,
    @OpeModKod,
    @OpeModNazwisko,
    @OpeId,
    @OpeModKod,
    @OpeModNazwisko,
    getdate(),
    getdate()
    )
  end
  else
  begin
   --declare @s nvarchar
   --set @s = 'Nie wypełniono wymaganych pól.' --ERR_SQL_Place_NieWypelWymagPol
   if @@trancount <> 0
    rollback tran
   --RAISERROR('##OPT32153##', 16, 1)--raiserror(@s, 16, 1)
   exec CDN.RiseOptimaException 32153
  end
  if @@error <> 0
   begin
    if @@trancount <> 0
     rollback tran
    --set @s = 'Błąd dodawania wydziału' --ERR_SQL_Place_BladDodawaniaWydzialu
    --RAISERROR('##OPT32155##', 16, 1)--raiserror(@s, 16, 1)
    exec CDN.RiseOptimaException 32155
   end
  else
  begin
   --[logowanie]
   declare @obj_id int
   set @obj_id = scope_identity()
   declare @oid int
   set @oid = cdn.GetXLOperatorID()
   if @oid > 0
   begin
    exec CDN.RejestrOperacjiContextInfo @oid
    exec CDN.RejestrOperacjiDodaj 24500, 0, @obj_id, @Nazwa, 1, ''
   end
   if @@trancount <> 0 and @TRanWewnetrzna = 1
    commit tran
  end
 set nocount off
