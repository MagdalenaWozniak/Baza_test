create procedure cdn.SetWyplataArchiwalna @Archiwalna tinyint, @RokOd int, @MiesiacOd int, @RokDo int, @MiesiacDo int, @PraId int
 as
 set nocount on
  declare @ArchiwalnaNegative tinyint
  if @Archiwalna = 0
   set @ArchiwalnaNegative = 1
  if @Archiwalna = 1
   set @ArchiwalnaNegative = 0
   if exists (select wpl_wplid from cdn.Wyplaty
    where WPL_PraId = @PraId and WPL_Zamknieta = 1
     and
     (
     (WPL_Rok > @RokOd or (WPL_Miesiac >= @MiesiacOd and WPL_Rok = @RokOd))
     and
     (WPL_Rok < @RokDo or (WPL_Miesiac <= @MiesiacDo and WPL_Rok = @RokDo))
     )
     and WPL_Archiwalna = @ArchiwalnaNegative)
   begin
    begin transaction
    update cdn.Wyplaty set WPL_Archiwalna = @Archiwalna
     where WPL_PraId = @PraId and WPL_Zamknieta = 1
      and
      (
      (WPL_Rok > @RokOd or (WPL_Miesiac >= @MiesiacOd and WPL_Rok = @RokOd))
      and
      (WPL_Rok < @RokDo or (WPL_Miesiac <= @MiesiacDo and WPL_Rok = @RokDo))
      )
    update cdn.WypElementy set WPE_Archiwalny = @Archiwalna
     from cdn.WypElementy join cdn.Wyplaty on WPL_WplId = WPE_WplId
     where WPE_PraId = @PraId and WPL_Zamknieta = 1
      and
      (
      (WPL_Rok > @RokOd or (WPL_Miesiac >= @MiesiacOd and WPL_Rok = @RokOd))
      and
      (WPL_Rok < @RokDo or (WPL_Miesiac <= @MiesiacDo and WPL_Rok = @RokDo))
      )
    update cdn.WypSkladniki set WPS_Archiwalny = @Archiwalna
     from cdn.WypSkladniki join cdn.Wyplaty on WPL_WplId = WPS_WplId
     where WPS_PraId = @PraId and WPL_Zamknieta = 1
      and
      (
      (WPL_Rok > @RokOd or (WPL_Miesiac >= @MiesiacOd and WPL_Rok = @RokOd))
      and
      (WPL_Rok < @RokDo or (WPL_Miesiac <= @MiesiacDo and WPL_Rok = @RokDo))
      )
    if @@error<>0
    begin
     if @@trancount<>0
      rollback tran
     --declare @s nvarchar
     --set @s = 'Bład przywracania wypłat' --ERR_SQL_Place_BladPrzywracaniaWyplat
     --if @Archiwalna = 1
      --set @s = 'Bład archiwizowania wypłat' --ERR_SQL_Place_BladArchiwizWyplat
     if @Archiwalna = 1
     begin
      RAISERROR('##OPT32146##', 16, 1)--raiserror(@s, 16, 1)
     end
     else
     begin
      RAISERROR('##OPT32145##', 16, 1)--raiserror(@s, 16, 1)
     end
    end
    else
    begin
     if @@trancount<>0
      commit tran
    end
   end
 set nocount off
