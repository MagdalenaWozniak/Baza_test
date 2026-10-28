CREATE  FUNCTION CDN.GetDokNumString(@schemat nvarchar(50), @number nvarchar(50))
RETURNS nvarchar(50)
WITH SCHEMABINDING
AS
BEGIN
 DECLARE @startPosSch integer
 DECLARE @endPosSch integer
 DECLARE @startPosNum integer
 DECLARE @endPosNum integer
 DECLARE @strSch nvarchar(50)
 DECLARE @result nvarchar(50)
  SET @startPosSch = 1
  SET @startPosNum = 1
  SET @endPosSch = CHARINDEX('/', @schemat, @startPosSch)
  SET @endPosNum = CHARINDEX('/', @number, @startPosNum)
  SET @result = ''
  WHILE(@startPosSch < LEN(@schemat))
  BEGIN
   SET @strSch = SUBSTRING(@schemat, @startPosSch, @endPosSch - @startPosSch)
   IF(@strSch <> '@brak')
   BEGIN
    IF(@strSch = '@numerS' OR @strSch = '@numer')
     SET @result = @result + @strSch + '/'
    ELSE
    BEGIN
     SET @result = @result + SUBSTRING(@number, @startPosNum, @endPosNum - @startPosNum + 1)
    END
    SET @startPosNum = @endPosNum + 1
    SET @endPosNum = CHARINDEX('/', @number, @startPosNum)
    IF(@EndPosNum = 0) SET @EndPosNum = LEN(@number)+1
   END
   SET @startPosSch = @endPosSch + 1
   SET @endPosSch = CHARINDEX('/', @schemat, @startPosSch)
   IF(@endPosSch = 0) SET @endPosSch = LEN(@schemat)+1
  END
  IF( CHARINDEX('/', REVERSE(@result))=1 )
   SET @result = SUBSTRING(@result, 1, LEN(@result)-1)
 RETURN @result
END
