CREATE FUNCTION CDN.GetPrymityw(@numer nvarchar(30) , @schemat nvarchar(50), @prymityw nvarchar(10))
RETURNS
nvarchar(20)
AS
BEGIN
 DECLARE @startNum  int,
  @endNum  int,
  @startSch  int,
  @endSch  int,
  @strSch  nvarchar(10)
 SET @startNum = 1
 SET @startSch = 1
 SET @endNum = CHARINDEX('/', @numer, @startNum)
 SET @endSch = CHARINDEX('/', @schemat, @startSch)
 WHILE (@startSch < LEN(@schemat) AND @startNum <= LEN(@numer))
 BEGIN
  SET @strSch = SUBSTRING(@schemat, @startSch, @endSch - @startSch )
  IF(@strSch = @prymityw)
   RETURN SUBSTRING(@numer, @startNum, @endNum - @startNum)
  SET @startSch = @endSch + 1
  SET @endSch = CHARINDEX('/', @schemat, @startSch)
  IF(@endSch = 0) SET @endSch = LEN(@schemat) + 1
  IF(@strSch <> '@brak')
  BEGIN
   SET @startNum = @endNum + 1
   SET @endNum = CHARINDEX('/', @numer, @startNum)
   IF(@endNum = 0) SET @endNum = LEN(@numer) + 1
  END
 END
 --RAISERROR('Nie znaleziono prymitywu', 16, 1)
 -- RETURN 'Nie znaleziony'
 RETURN ''
END
