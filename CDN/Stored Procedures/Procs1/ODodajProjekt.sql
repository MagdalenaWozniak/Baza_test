create procedure cdn.ODodajProjekt @ParentId int, @Kod varchar(40), @Nazwa varchar(255), @Nieaktywny tinyint, @Konto nvarchar(51)
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
   @LP int
  set @Poziom = 1
  set @Adres = ''
  if @ParentId > 0
  begin
   select @Poziom = PRJ_Poziom + 1, @Adres = PRJ_Wezel from cdn.DefProjekty where PRJ_PrjId = @ParentId
   select @LP = max(PRJ_Lp) from cdn.DefProjekty where PRJ_ParentId = @ParentId
  end
  else
  begin
   select @Poziom = PRJ_Poziom, @Adres = '' from cdn.DefProjekty where PRJ_PrjId = 1
   select @LP = max(PRJ_Lp) from cdn.DefProjekty where PRJ_Poziom = 1
  end
  if @LP is null or @LP = 0
   set @LP = 1
  else
   set @LP = @LP + 1
  set @Adres = cdn.UtworzAdresWezla(@Adres, @LP)
  if len(@Kod) > 0 and len(@Nazwa) > 0
  begin
   declare @OpeId int
   set @OpeId = cdn.GetXLOperatorID()
   declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
   exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
   insert into cdn.DefProjekty
    (
    PRJ_Kod,
    PRJ_Nazwa,
    PRJ_Nieaktywny,
    PRJ_Konto,
    PRJ_ParentId,
    PRJ_Poziom,
    PRJ_Symbol,
    PRJ_Url,
    PRJ_Wezel,
    PRJ_Lp,
    PRJ_OpeZalId,
    PRJ_OpeZalKod,
    PRJ_OpeZalNazwisko,
    PRJ_OpeModId,
    PRJ_OpeModKod,
    PRJ_OpeModNazwisko,
    PRJ_TS_Mod,
    PRJ_TS_Zal
    )
   values
    (
    @Kod,
    @Nazwa,
    @Nieaktywny,
    @Konto,
    @ParentId,
    @Poziom,
    '',
    '',
    @Adres,
    @LP,
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
    --set @s = 'Błąd dodawania projektu' --ERR_SQL_Place_BladDodawaniaProjektu
    --RAISERROR('##OPT32154##', 16, 1)--raiserror(@s, 16, 1)
    exec CDN.RiseOptimaException 32154
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
    exec CDN.RejestrOperacjiDodaj 24502, 0, @obj_id, @Nazwa, 1, ''
   end
   if @@trancount <> 0 and @TRanWewnetrzna = 1
       commit tran
        end
 set nocount off
