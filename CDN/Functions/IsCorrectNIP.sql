CREATE FUNCTION CDN.IsCorrectNIP(@NIPKraj nvarchar(2), @NIP nvarchar(20))
RETURNS tinyint
AS
BEGIN
  DECLARE @i int,
  @a int,
  @b int,
  @suma int,
  @modulo int,
  @moduloNIP int
 DECLARE @constTable table(idx int, val int)
 DECLARE @dynTable   table(idx int, val int)
 --Nie sprawdzamy bo kraj nie jest PL
 IF @NIPKraj <> '' and @NIPKraj <> 'PL' RETURN 1
 -- Nie sprawdzamy bo nip jest pusty a taki jest dopuszczalny
 IF  @NIP = ''  RETURN 1
 --Sprawdzamy czy wszystkie znaki są cyframi
 IF IsNumeric(@NIP) = 0 RETURN 0
 INSERT INTO @constTable VALUES(0, 6)
 INSERT INTO @constTable VALUES(1, 5)
 INSERT INTO @constTable VALUES(2, 7)
 INSERT INTO @constTable VALUES(3, 2)
 INSERT INTO @constTable VALUES(4, 3)
 INSERT INTO @constTable VALUES(5, 4)
 INSERT INTO @constTable VALUES(6, 5)
 INSERT INTO @constTable VALUES(7, 6)
 INSERT INTO @constTable VALUES(8, 7)
 SET @i = 0
 SET @Suma = 0
 WHILE @i < 9
 BEGIN
  SET @a = convert(int, SUBSTRING(@NIP, @i+1, 1) )
  SELECT @b = val FROM @constTable WHERE idx = @i
--  INSERT INTO @dynTable VALUES(@i, @b * @a)
  SET @Suma = @Suma + (@b * @a)
  SET @i = @i + 1
 END
 SET @modulo = @suma % 11
 SET @moduloNIP = convert(int, SUBSTRING(@NIP, 10, 1))
 IF @modulo = @moduloNIP RETURN 1
 RETURN 0
END
