CREATE PROCEDURE [CDN].WyliczCeneDlaTowaru
@twrId INT,
@cenaBazowa INT,
@cenaDocelowa INT,
@rodzaj INT,
@kwota DECIMAL(17,4),
@waluta VARCHAR(3),
@dataNotowania DATETIME,
@walSystemowa VARCHAR(3),
@rejestrOperacji INT,
@komunikat NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
 IF @dataNotowania Is Null  SET @dataNotowania = GetDate()
    DECLARE @kwotaCenyB DECIMAL(17,4), @staraCena DECIMAL(17,4),
   @nowaCena DECIMAL(17,4), @walutaB VARCHAR(3), @walutaD VARCHAR(3), @kwotaSys DECIMAL(17,4),
   @errText NVARCHAR(255), @typBazowej INT, @typNowej INT, @stawkaVat DECIMAL(5,2)
    DECLARE @ZaokraglajDo  SMALLINT
 SET @komunikat = ''
    SELECT @komunikat = Twr_Kod, @stawkaVat = Twr_Stawka, @ZaokraglajDo=case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end FROM cdn.Towary WHERE TwR_TwRId=@twrId
    -- select * fro m cdn.twrceny
 -- cena bazowa
    SELECT @typBazowej = TwC_Typ, @staraCena = TwC_Wartosc, @kwotaCenyB= TwC_Wartosc, @walutaB = TwC_Waluta
 FROM CDN.TwrCeny WITH (NOLOCK) WHERE TwC_TwrId = @twrId AND TwC_TwCNumer = @cenaBazowa
 IF @staraCena Is Null
 BEGIN
  SET @komunikat = @komunikat + SPACE(2) + 'Cena_bazowa_nie_zostala_zdefiniowana_dla_tego_towaru'
  GOTO KONIEC
 END
    SELECT @typNowej = TwC_Typ, @nowaCena = TwC_Wartosc, @walutaD = TwC_Waluta
 FROM CDN.TwrCeny WITH (NOLOCK) WHERE TwC_TwrId = @twrId AND TwC_TwCNumer = @cenaDocelowa
 IF @nowaCena Is Null
 BEGIN
  SET @komunikat = @komunikat + SPACE(2) + 'Cena_docelowa_nie_zostala_zdefiniowana_dla_tego_towaru'
  GOTO KONIEC
 END
 SET @staraCena = cdn.PrzeliczCene(@staraCena, @stawkaVat, @typBazowej,@typNowej,@ZaokraglajDo)
 IF @rodzaj = 0  -- zmiana o procent
 BEGIN
  IF @walutaB = @walutaD  -- różne waluty
  BEGIN
   SET @kwotaSys = round(@staraCena + ( @staraCena * @kwota ) / 100,@ZaokraglajDo)
  END
  BEGIN      -- wyraź @kwotaSys w walucie ceny wyliczanej; najpierw przewalutownaie potem dodanie marży (tak jak na cenniku)
   SET @kwotaSys = round(@staraCena,@ZaokraglajDo)
   EXEC cdn.Przewalutowanie @kwotaSys OUTPUT, @walutaB, @walutaD, @dataNotowania, @errText OUTPUT
   IF Len(@errText) > 0
   BEGIN
    SET @komunikat = @komunikat + SPACE(2) + @errText
    GOTO KONIEC
   END
   SET @kwotaSys = round(@kwotaSys + ( @kwotaSys * @kwota ) / 100,@ZaokraglajDo)
  END
  SET @nowaCena = @kwotaSys
  GOTO UPDATE_NOWA
 END
 DECLARE @kwotaPrzeceny DECIMAL(17,4)
 SET @kwotaPrzeceny = @kwota
 IF @rodzaj = 1  -- zmiana o kwote
 BEGIN
  DECLARE @kursL DECIMAL(15,4), @kursM DECIMAL(5,0), @err INT
  --EXEC CDN.SymbolWalSys @walSystemowa  -- pobierz symbol waluty systemowej
  IF @walutaB = @walutaD AND @walutaB = @walSystemowa   -- wszystkie kwoty są w walucie systmowej
  BEGIN
   SET @kwotaSys = @staraCena
   SET @kwotaPrzeceny = @kwota
  END
  ELSE  -- różne waluty
  BEGIN
   SET @kwotaSys = @staraCena
   EXEC cdn.Przewalutowanie @kwotaSys OUTPUT, @walutaB, @walutaD, @dataNotowania, @errText OUTPUT
   IF Len(@errText) > 0
   BEGIN
    SET @komunikat = @komunikat + SPACE(2) + @errText
    GOTO KONIEC
   END
   SET @kwotaPrzeceny = @kwota
   EXEC cdn.Przewalutowanie @kwotaPrzeceny OUTPUT, @waluta, @walutaD, @dataNotowania, @errText OUTPUT
   IF Len(@errText) > 0
   BEGIN
    SET @komunikat = @komunikat + SPACE(2) + @errText
    GOTO KONIEC
   END
  END
  -- ustal nową cenę
  SET @nowaCena = round(@kwotaSys + @kwotaPrzeceny,@ZaokraglajDo)
 END
UPDATE_NOWA:
 IF @nowaCena < 0
  SET @nowaCena = 0
    UPDATE cdn.TwrCeny SET
  TwC_Wartosc = cdn.ZaokraglijCene(@nowaCena, TwC_Zaokraglenie, TwC_Offset,@ZaokraglajDo)
 FROM cdn.TwrCeny
    WHERE TwC_TwrId = @twrId AND TwC_TwCNumer = @cenaDocelowa
 EXEC cdn.PrzeliczMarze  @twrId, @cenaDocelowa, @walSystemowa
    IF @@ERROR = 0
 BEGIN
        IF @rejestrOperacji = 1
        BEGIN
            EXEC [CDN].[RejestrOperacjiDodaj] 1106 ,0, @twrId, @komunikat, 2, '';
        END
        SET @komunikat = @komunikat + SPACE(2) + 'zmieniono_cene_towaru. Cena_bazowa: ' + CAST(@kwotaCenyB AS NVARCHAR(20)) + SPACE(1) + @walutaB + '. Cena_wyliczona: ' +  CAST(@nowaCena AS NVARCHAR(20)) + SPACE(1) + @walutaD
 END
KONIEC:
 SET NOCOUNT OFF;
END
