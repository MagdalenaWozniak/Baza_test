--EXEC cdn.Przewalutowanie @kwotaSys OUTPUT, @walutaB, @walutaD, @data, @errText OUTPUT
CREATE PROCEDURE [CDN].Przewalutowanie
 @kwota  DECIMAL(17,4) OUTPUT,
 @walutaB VARCHAR(3),
 @walutaD VARCHAR(3),
 @dataNotowania DATETIME,
 @errText NVARCHAR(255) OUTPUT
AS
BEGIN
 SET NOCOUNT ON;
 SET @errText = ''
 IF @walutaB = @walutaD
 BEGIN
  GOTO KONIEC
 END
 DECLARE @kursL DECIMAL(15,4),
   @kursM DECIMAL(5,0),
   @kursLD DECIMAL(15,4),
   @kursMD DECIMAL(5,0),
   @err INT,
   @walSystemowa NVARCHAR(3)
   --,@kwotaSys DECIMAL(15,2)
 SET @kursL = NULL
 SET @kursM = NULL
 --EXEC CDN.SymbolWalSys @walSystemowa  -- pobierz symbol waluty systemowej
 --SET @kwotaSys = 1.00
 --EXEC [CDN].Przewalutowanie @kwotaSys OUTPUT, @walSystemowa, @walutaD
 EXEC [CDN].PobierzKursWaluty @walutaB, @dataNotowania, @kursL OUTPUT, @kursM OUTPUT, @err OUTPUT
 IF @err > 0
 BEGIN
  SET @errText = cdn.PobierzKursWalutyErr(@walutaB, @dataNotowania, @err)
  GOTO KONIEC
 END
 EXEC [CDN].PobierzKursWaluty @walutaD, @dataNotowania, @kursLD OUTPUT, @kursMD OUTPUT, @err OUTPUT
 IF @err > 0
 BEGIN
  SET @errText = cdn.PobierzKursWalutyErr(@walutaD, @dataNotowania, @err)
  GOTO KONIEC
 END
 DECLARE @kursL_N DECIMAL(15,4),  @kursM_N DECIMAL(15,4)
 SET @kursL_N = @kursL * @kursMD
 SET @kursM_N = @kursM * @kursLD
 IF @KursM_N IS NULL SET @KursM_N = 1
 SET @kwota   = @kwota * @kursL_N/@KursM_N   -- cena bazowa w walucie docelowej
KONIEC:
  SET NOCOUNT OFF;
  RETURN
END
