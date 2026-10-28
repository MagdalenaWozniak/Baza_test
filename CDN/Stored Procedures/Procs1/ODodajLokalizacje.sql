create procedure cdn.ODodajLokalizacje @Kod varchar(40), @Nazwa varchar(255), @Nieaktywny tinyint, @Konto nvarchar(51)
 as
 set nocount on
  declare @TRanWewnetrzna int
  set @TRanWewnetrzna = 0
  if @@trancount = 0
  begin
   begin tran
   set @TRanWewnetrzna = 1
  end
  if len(@Kod) > 0 and len(@Nazwa) > 0
  begin
   declare @OpeId int
   set @OpeId = cdn.GetXLOperatorID()
   declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
   exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
   insert into cdn.Lokalizacje
    (
    LOK_Kod,
    LOK_Nazwa,
    LOK_Nieaktywny,
    LOK_Konto,
    LOK_Symbol,
    LOK_OpeZalId,
    LOK_OpeZalKod,
    LOK_OpeZalNazwisko,
    Lok_OpeModId,
    Lok_OpeModKod,
    Lok_OpeModNazwisko,
    LOK_TS_Mod,
    LOK_TS_Zal
    )
   values
    (
    @Kod,
    @Nazwa,
    @Nieaktywny,
    @Konto,
    '',
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
    --set @s = 'Błąd dodawania lokalizacji' --ERR_SQL_Place_BladDodawaniaLokalizacji
    --RAISERROR('##OPT32156##', 16, 1)--raiserror(@s, 16, 1)
    exec CDN.RiseOptimaException 32156
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
    exec CDN.RejestrOperacjiDodaj 24501, 0, @obj_id, @Nazwa, 1, ''
   end
   if @@trancount <> 0 and @TRanWewnetrzna = 1
    commit tran
  end
 set nocount off
