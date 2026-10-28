CREATE FUNCTION CDN.IsCorrectPesel(@Pesel nvarchar(11))
RETURNS
int
BEGIN
 IF @Pesel = '' RETURN 1
 IF Len(@Pesel) <> 11 RETURN 0
 IF IsNumeric(@Pesel) = 0 RETURN 0
 DECLARE @constTable table(idx int, val int)
 DECLARE @i int,
  @a int,
  @b int,
  @modulo int,
  @lastDigit int,
  @Suma int
 INSERT INTO @constTable VALUES(1, 1)
 INSERT INTO @constTable VALUES(2, 3)
 INSERT INTO @constTable VALUES(3, 7)
 INSERT INTO @constTable VALUES(4, 9)
 INSERT INTO @constTable VALUES(5, 1)
 INSERT INTO @constTable VALUES(6, 3)
 INSERT INTO @constTable VALUES(7, 7)
 INSERT INTO @constTable VALUES(8, 9)
  INSERT INTO @constTable VALUES(9, 1)
  INSERT INTO @constTable VALUES(10, 3)
 SET @i = 1
 SET @Suma = 0
 WHILE @i < 11
 BEGIN
  SET @a = convert(int, SUBSTRING(@Pesel, @i, 1) )
  SELECT @b = val FROM @constTable WHERE idx = @i
  SET @Suma = @Suma + (@b * @a)
  SET @i = @i + 1
 END
 SET @lastDigit = convert(int, SUBSTRING(@Pesel, 11, 1))
 SET @modulo = @Suma % 10
 SET @modulo = 10 - @modulo
 IF @lastDigit = @modulo % 10
  RETURN 1
 RETURN 0
END
