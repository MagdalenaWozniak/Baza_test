--/////////////////////////////////////////////////////////////////////////////////////////////////////
create procedure [CDN].[WyplataSingleStatusW] @akcja smallint, @idLPL int, @idPRA int
as
set nocount on
declare @message varchar(128), @ID int, @tryb smallint, @numer varchar(32), @zamknieta tinyint, @osoba varchar(40), @archiwalna int
declare @warning int
set @warning = 0
select top 1 @osoba = PRE_Imie1 + ' ' + PRE_Nazwisko
 from CDN.PracEtaty
  where PRE_DataDo >= convert(datetime, '2999-12-31', 120) and PRE_PraId = @idPRA
declare @osobakod nvarchar(128)
select top 1 @osobakod = '[' + PRE_Kod + '] ' + PRE_Imie1 + ' ' + PRE_Nazwisko
 from CDN.PracEtaty
  where PRE_DataDo >= convert(datetime, '2999-12-31', 120) and PRE_PraId = @idPRA
declare WYPLATY cursor local fast_forward for
  select distinct WPL_WplId, WPL_Tryb, WPL_NumerPelny, WPL_Zamknieta, WPL_Archiwalna from CDN.Wyplaty
 where (WPL_LplId = @idLPL) and (WPL_PraId = @idPRA) and WPL_Tryb <> 2
 and (WPL_Wartosc = 0)
open WYPLATY
while (1=1)
 begin
  fetch next from WYPLATY into @ID, @tryb, @numer, @zamknieta, @archiwalna
  if @@fetch_status <> 0 break
  if @archiwalna > 0
  begin
   set @message = @osoba + ': wypłata jest archiwalna - nie można zmienić statusu [' + @numer + ']'
   set @warning = 1
   continue
  end
  if @tryb = 1
  begin
   set @message = @osoba + ': wypłata jest anulowana - nie można zmienić statusu [' + @numer + ']'
   set @warning = 2
   continue
   --raiserror(@message, 16, 1)
   --return
  end
 if(@akcja = 1) --zamykanie
  begin
  if @zamknieta = 1
  begin
   set @message = @osoba + ': wypłata była zamknięta - nie można zmienić statusu [' + @numer + ']'
   set @warning = 3
   continue
   --raiserror(@message, 16, 1)
   --return
  end
   update CDN.Wyplaty set WPL_Zamknieta = 1
     where WPL_WplId = @ID
      and WPL_Zamknieta <> 1
 --[logowanie]
 exec CDN.RejestrOperacjiDodaj 24100, 0, @ID, @numer, 101, @osobakod
  end
 else --otwieranie
  begin
  if @zamknieta = 0
  begin
   set @message = @osoba + ': wypłata była otwarta - nie można zmienić statusu [' + @numer + ']'
   set @warning = 4
   continue
   --raiserror(@message, 16, 1)
   --return
  end
   update CDN.Wyplaty set WPL_Zamknieta = 0
     where WPL_WplId = @ID
      and WPL_Zamknieta = 1
 --[logowanie]
 exec CDN.RejestrOperacjiDodaj 24100, 0, @ID, @numer, 100, @osobakod
  end
 end
 if @warning > 0
 begin
 --raiserror(@message, 16, 1)--ERR_SQL_Place_StatusWyplaty
 if @warning = 1
 begin
  --RAISERROR('##OPT32137##%%prac%%=%s%%msg%%=%s##', 16, 1, @osoba, @numer)--ERR_SQL_Place_NieMoznaZmienicStatusuArch
  exec CDN.RiseOptimaException 32137, 's1', @osoba, 's2', @numer
 end
 if @warning = 2
 begin
  --RAISERROR('##OPT32139##%%prac%%=%s%%msg%%=%s##', 16, 1, @osoba, @numer)--ERR_SQL_Place_NieMoznaZmienicStatusuAnulow
  exec CDN.RiseOptimaException 32139, 's1', @osoba, 's2', @numer
 end
 if @warning = 3
 begin
  --RAISERROR('##OPT32140##%%prac%%=%s%%msg%%=%s##', 16, 1, @osoba, @numer)--ERR_SQL_Place_NieMoznaZmienicStatusuZam
  exec CDN.RiseOptimaException 32140, 's1', @osoba, 's2', @numer
 end
 if @warning = 4
 begin
  --RAISERROR('##OPT32143##%%prac%%=%s%%msg%%=%s##', 16, 1, @osoba, @numer)--ERR_SQL_Place_NieMoznaZmienicStatusuOtw
  exec CDN.RiseOptimaException 32143, 's1', @osoba, 's2', @numer
 end
 end
close WYPLATY
deallocate WYPLATY
set nocount off
