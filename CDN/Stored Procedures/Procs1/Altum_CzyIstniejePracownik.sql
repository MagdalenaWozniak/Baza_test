create procedure cdn.Altum_CzyIstniejePracownik @Kod nvarchar(20), @RetVal tinyint out
 as
 set nocount on
 begin
  set @RetVal = 0
  if (select isnull(PRA_PraId, 0) from cdn.PracKod where PRA_Kod = @Kod) > 0
   set @RetVal = 1
 end
 set nocount off
