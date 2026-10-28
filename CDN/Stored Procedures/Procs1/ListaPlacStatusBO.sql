CREATE PROCEDURE CDN.ListaPlacStatusBO @akcja SMALLINT, @idLPL INT
AS
SET NOCOUNT ON
DECLARE @ID INT
declare @NumerPelny nvarchar(30)
--12.0 dodanie warunku na tryb
DECLARE WYPLATYBO CURSOR LOCAL FAST_FORWARD FOR
  select WPL_WplId, WPL_NumerPelny from CDN.Wyplaty
 where WPL_LplId = @idLPL and WPL_Tryb <> 1 and WPL_Tryb <> 2
OPEN WYPLATYBO
WHILE (1=1)
 BEGIN
  FETCH NEXT FROM WYPLATYBO INTO @ID, @NumerPelny
  IF @@fetch_status <> 0 BREAK
 if(@akcja = 1)
  begin
   update CDN.Wyplaty set WPL_Zamknieta = 1
     where WPL_WplId = @ID
      and WPL_Zamknieta <> 1
   --[logowanie]
   exec CDN.RejestrOperacjiDodaj 24100, 0, @ID, @NumerPelny, 101, ''
  end
 else
  begin
   update CDN.Wyplaty set WPL_Zamknieta = 0
     where WPL_WplId = @ID
      and WPL_Zamknieta = 1
   --[logowanie]
   exec CDN.RejestrOperacjiDodaj 24100, 0, @ID, @NumerPelny, 100, ''
  end
 END
CLOSE WYPLATYBO
DEALLOCATE WYPLATYBO
