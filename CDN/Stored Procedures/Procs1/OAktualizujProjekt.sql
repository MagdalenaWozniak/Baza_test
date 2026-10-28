create procedure cdn.OAktualizujProjekt @ID int, @Kod varchar(40), @Nazwa varchar(255), @Nieaktywny tinyint, @Konto nvarchar(51)
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
   update cdn.DefProjekty
    set
     PRJ_Kod = @Kod,
     PRJ_Nazwa = @Nazwa,
     PRJ_Nieaktywny = @Nieaktywny,
     PRJ_Konto = @Konto,
     PRJ_TS_Mod = getdate(),
     PRJ_OpeModId = @OpeId,
     PRJ_OpeModKod = @OpeModKod,
     PRJ_OpeModNazwisko = @OpeModNazwisko
    where PRJ_PrjId = @ID
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
    --set @s = 'Błąd aktualizowania projektu' --ERR_SQL_Place_BladAktProjektu
    --RAISERROR('##OPT32158##', 16, 1)--raiserror(@s, 16, 1)
    exec CDN.RiseOptimaException 32158
   end
  else
  begin
   --[logowanie]
   declare @oid int
   set @oid = cdn.GetXLOperatorID()
   if @oid > 0
   begin
    exec CDN.RejestrOperacjiContextInfo @oid
    exec CDN.RejestrOperacjiDodaj 24502, 0, @ID, @Nazwa, 2, ''
   end
   if @@trancount <> 0 and @TRanWewnetrzna = 1
    commit tran
        end
 set nocount off
