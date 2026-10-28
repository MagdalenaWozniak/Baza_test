CREATE PROCEDURE CDN.ListaPlacStatus @akcja SMALLINT, @idLPL INT
AS
SET NOCOUNT ON
DECLARE @ID INT
declare @NumerPelny nvarchar(30)
--12.0 dodanie warunku na tryb
DECLARE WYPLATY CURSOR LOCAL FAST_FORWARD FOR
  /*select WPL_WplId from CDN.Wyplaty, CDN.BnkZdarzenia
 where (WPL_LplId = @idLPL) and WPL_Tryb <> 1 and WPL_Tryb <> 2
 and ((BZD_DokumentTyp = 8 and BZD_DokumentId = WPL_WplId)
 and wpl_archiwalna = 0
--11
-- and BZD_Rozliczono = 1)
 or (WPL_Wartosc = 0))*/
 select WPL_WplId, WPL_NumerPelny from CDN.Wyplaty --join CDN.BnkZdarzenia on bzd_dokumenttyp = 8 and wpl_wplid = bzd_dokumentid
 where WPL_LplId = @idLPL and (WPL_Tryb <> 1 and WPL_Tryb <> 2 and wpl_archiwalna = 0)
OPEN WYPLATY
WHILE (1=1)
 BEGIN
  FETCH NEXT FROM WYPLATY INTO @ID, @NumerPelny
  IF @@fetch_status <> 0 BREAK
  --declare @idPRA int
  --select @idPRA = WPL_PraId from cdn.Wyplaty where WPL_WplId = @ID
  --execute cdn.WyplataSingleStatus @akcja, @idLPL, @idPRA, 0
 declare @rozliczona tinyint, @rozliczona2 tinyint
    select @rozliczona = max(BZd_Rozliczono), @rozliczona2 = max(BZd_Rozliczono2)
  from cdn.BnkZdarzenia where BZD_DokumentTyp = 8 and BZD_DokumentId = @ID  --max bo mogą być płatności podzielone
  if @rozliczona2 > 1 --rozliczona2 obejmuje przypadek całkowitego lub częściowego rozliczenia
  --begin
 --set @message = @osoba + ': wypłata lub jej część jest rozliczona - nie można zmienić statusu [' + @numer + ']'
 --set @warning = 1
 continue
  --end
 if(@akcja = 1)  --zamykanie
 begin
  if exists(select WPL_WplId from cdn.Wyplaty where WPL_WplId = @ID and wpl_archiwalna = 0 and WPL_Zamknieta <> 1)
  begin
   update CDN.Wyplaty set WPL_Zamknieta = 1
     where WPL_WplId = @ID
   update CDN.BnkZdarzenia set BZD_Stan = 1
     where BZD_DokumentTyp = 8 and BZD_DokumentId = @ID
   --[logowanie]
   exec CDN.RejestrOperacjiDodaj 24100, 0, @ID, @NumerPelny, 101, ''
  end
 end
 else --otwieranie
 begin
  if exists(select WPL_WplId from cdn.Wyplaty where WPL_WplId = @ID and wpl_archiwalna = 0 and WPL_Zamknieta = 1)
  begin
   update CDN.Wyplaty set WPL_Zamknieta = 0
    where WPL_WplId = @ID
   update CDN.BnkZdarzenia set BZD_Stan = 0
    where BZD_DokumentTyp = 8 and BZD_DokumentId = @ID
   --[logowanie]
   exec CDN.RejestrOperacjiDodaj 24100, 0, @ID, @NumerPelny, 100, ''
  end
 end
 END
CLOSE WYPLATY
DEALLOCATE WYPLATY
