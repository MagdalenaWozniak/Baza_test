CREATE FUNCTION [CDN].PobierzKursWalutyErr(@symbolWal VARCHAR(3), @dataNotowania DATETIME, @err INT )
RETURNS NVARCHAR(64)
BEGIN
--pobranie notowania
 DECLARE @komunikat   NVARCHAR(64),
   @dataNotowaniaChar NVARCHAR(25)
 SELECT @dataNotowaniaChar = CONVERT(NVARCHAR(25), @dataNotowania, 102)
 SET @komunikat = ''
 IF @err = 1
  SET @komunikat = 'W Konfiguracji nie znaleziono definicji waluty: ' + @symbolWal
 IF @err = 2
  SET @komunikat = 'Brak kursu waluty ' + @symbolWal + ' na dzień ' + @dataNotowaniaChar + ' !'
 RETURN @komunikat
END
