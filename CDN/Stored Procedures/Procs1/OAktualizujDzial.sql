create procedure cdn.OAktualizujDzial @ID int, @Kod varchar(40), @Nazwa varchar(255), @Nieaktywny tinyint, @Konto nvarchar(51), @LokId int, @ZrgId int, @Symbol varchar(5)
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
   update cdn.Dzialy
    set
     DZL_Kod = @Kod,
     DZL_Nazwa = @Nazwa,
     DZL_Nieaktywny = @Nieaktywny,
     DZL_Konto = @Konto,
     --DZL_Symbol = @Symbol,
     DZL_LokId = @LokId,
     DZL_ZrgId = @ZrgId,
     DZL_TS_Mod = getdate(),
     DZL_OpeModId = @OpeId,
     DZL_OpeModKod = @OpeModKod,
     DZL_OpeModNazwisko = @OpeModNazwisko
    where DZL_DzlId = @ID
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
    --set @s = 'Błąd aktualizowania wydziału' --ERR_SQL_Place_BladAktWydzialu
    --RAISERROR('##OPT32159##', 16, 1)--raiserror(@s, 16, 1)
    exec CDN.RiseOptimaException 32159
   end
  else
  begin
   --[logowanie]
   declare @oid int
   set @oid = cdn.GetXLOperatorID()
   if @oid > 0
   begin
    exec CDN.RejestrOperacjiContextInfo @oid
    exec CDN.RejestrOperacjiDodaj 24500, 0, @ID, @Nazwa, 2, ''
   end
   if @@trancount <> 0 and @TRanWewnetrzna = 1
    commit tran
  end
 set nocount off
