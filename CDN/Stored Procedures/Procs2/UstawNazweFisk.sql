-- Ustawienie Nazwy fiskalnej nazwy i unikalnosci
CREATE PROCEDURE [CDN].[UstawNazweFisk]
@twrId INT, @UnikalnoscNazwy INT,@KolejnaCyfra INT, @SkrocNazwe INT, @IloscZnakow INT
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE
 @komunikat NVARCHAR(255),
 @nazwaFiskalna NVARCHAR(40),
 @Kod NVARCHAR(50),
 @TwrIdDuplikat int,
 @NazwaFiskalnaDuplikat NVARCHAR(40),
 @NazwaFiskalnaNowa NVARCHAR(40),
 @i int,
 @aaaa int,
 @TwrKod NVARCHAR(50)
 IF @IloscZnakow = 0 SET @IloscZnakow = 40
 SELECT @nazwaFiskalna = SUBSTRING(Twr_NazwaFiskalna,1,@IloscZnakow), @komunikat = Twr_Kod ,@TwrKod = Twr_Kod FROM cdn.Towary WHERE Twr_TwrId = @twrId
 IF @nazwaFiskalna IS NULL  SET @nazwaFiskalna = ''
 IF @komunikat IS NULL  SET @komunikat = ''
 IF @nazwaFiskalna = ''
 BEGIN
  SET @komunikat = @komunikat + SPACE(2) + ' ustawiono dane. '
  GOTO KONIEC
 END
 SELECT TOP 1 @Kod = Twr_Kod FROM cdn.Towary WHERE SUBSTRING(Twr_NazwaFiskalna,1,@IloscZnakow) =  @NazwaFiskalna AND Twr_TwrId <> @twrId
 IF @Kod IS NULL SET @Kod = ''
 IF @Kod = ''  -- nie ma duplikatów
 BEGIN
  UPDATE cdn.Towary SET Twr_NazwaFiskalna = @NazwaFiskalna WHERE Twr_TwrId = @twrId
  exec [CDN].[RejestrOperacjiDodaj] 1106 ,0, @twrId, @TwrKod, 2, '';
  SET @komunikat = @komunikat + SPACE(2) + ' ustawiono dane. '
  GOTO KONIEC
 END
 IF @KolejnaCyfra = 0
 BEGIN
      SET @komunikat = @komunikat + SPACE(2) + 'Nazwa nie jest unikalna. Podobna nazwa dla towaru o kodzie: ' + @Kod
      GOTO KONIEC
 END
 -- dodaj cyfry
 DECLARE @maxLen INTEGER, @index NVARCHAR(40)
 SET @i = 0
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR SELECT Twr_TwrId,Twr_Kod FROM cdn.Towary WHERE SUBSTRING(Twr_NazwaFiskalna, 1, @IloscZnakow) =  @NazwaFiskalna
 OPEN Dodawane
    WHILE 1=1
 BEGIN
  FETCH NEXT FROM Dodawane INTO @TwrIdDuplikat,@TwrKod
  IF @@FETCH_STATUS <> 0 BREAK
  SET @i = @i + 1
  SET @index = CONVERT(NVARCHAR(40), @i)
  SET @maxLen = @IloscZnakow - Len(LTRIM(RTRIM(@index)))
  SELECT @NazwaFiskalnaNowa = SUBSTRING(@NazwaFiskalna, 1, @maxLen) + @index
   WHILE EXISTS ( SELECT Twr_TwrId FROM cdn.Towary WHERE SUBSTRING(Twr_NazwaFiskalna, 1, @IloscZnakow) =  @NazwaFiskalnaNowa )
         BEGIN
   SET @i = @i + 1
   SET @index = CONVERT(NVARCHAR(40), @i)
   SET @maxLen = @IloscZnakow - Len(LTRIM(RTRIM(@index)))
   SELECT @NazwaFiskalnaNowa = SUBSTRING(@NazwaFiskalna, 1, @maxLen) + @index
   END
         UPDATE cdn.Towary SET Twr_NazwaFiskalna = @NazwaFiskalnaNowa WHERE Twr_twrid = @TwrIdDuplikat
   exec [CDN].[RejestrOperacjiDodaj] 1106 ,0, @TwrIdDuplikat, @TwrKod, 2, '';
 END
    CLOSE Dodawane
    DEALLOCATE Dodawane
 IF @@ERROR = 0 SET @komunikat = @komunikat + SPACE(2) + ' ustawiono dane. '
KONIEC:
 SET NOCOUNT OFF;
 SELECT @komunikat
END
