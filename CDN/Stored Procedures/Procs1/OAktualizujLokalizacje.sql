create procedure cdn.OAktualizujLokalizacje @ID int, @Kod varchar(40), @Nazwa varchar(255), @Nieaktywny tinyint, @Konto nvarchar(51)
 as
 set nocount on
  declare @TRanWewnetrzna int
  set @TRanWewnetrzna = 0
  if @@trancount = 0
  begin
   begin tran
   set @TRanWewnetrzna = 1
  end
  declare @s nvarchar
  if len(@Kod) > 0 and len(@Nazwa) > 0
  begin
   declare @OpeId int
   set @OpeId = cdn.GetXLOperatorID()
   declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
   exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
   update cdn.Lokalizacje
    set
     LOK_Kod = @Kod,
     LOK_Nazwa = @Nazwa,
     LOK_Nieaktywny = @Nieaktywny,
     LOK_Konto = @Konto,
     LOK_TS_Mod = getdate(),
     LOK_OpeModId = @OpeId,
     LOK_OpeModKod = @OpeModKod,
     LOK_OpeModNazwisko = @OpeModNazwisko
    where Lok_LokId = @ID
   update cdn.Dzialy
    set
     DZL_Kod = @Kod,
     DZL_Nazwa = @Nazwa
    where
     DZL_LokId = @ID
   if @@error <> 0
   begin
    if @@trancount <> 0
     rollback tran
    --set @s = 'Błąd aktualizowania lokalizacji' --ERR_SQL_Place_BladAktLokalizacji
    --RAISERROR('##OPT32160##', 16, 1)--raiserror(@s, 16, 1)
    exec CDN.RiseOptimaException 32160
   end
   else
   begin
    if @@trancount <> 0 and @TRanWewnetrzna = 1
     commit tran
   end
  end
  else
  begin
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
    --set @s = 'Błąd aktualizowania lokalizacji' --ERR_SQL_Place_BladAktLokalizacji
    --RAISERROR('##OPT32160##', 16, 1)--raiserror(@s, 16, 1)
    exec CDN.RiseOptimaException 32160
   end
  else
  begin
   --[logowanie]
   declare @oid int
   set @oid = cdn.GetXLOperatorID()
   if @oid > 0
   begin
    exec CDN.RejestrOperacjiContextInfo @oid
    exec CDN.RejestrOperacjiDodaj 24501, 0, @ID, @Nazwa, 2, ''
   end
   if @@trancount <> 0 and @TRanWewnetrzna = 1
    commit tran
  end
 set nocount off
