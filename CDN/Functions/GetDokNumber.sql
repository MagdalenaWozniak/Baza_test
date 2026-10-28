CREATE FUNCTION CDN.GetDokNumber( @schemat nvarchar(50), @number nvarchar(50))
RETURNS int
WITH SCHEMABINDING
AS
BEGIN
 DECLARE @startPosSch as integer
 DECLARE @endPosSch integer
 DECLARE @startPosNum integer
 DECLARE @endPosNum integer
 DECLARE @strSch nvarchar(10)
 SET @startPosSch = 1
 SET @startPosNum = 1
 SET @endPosSch = CHARINDEX('/', @schemat, @startPosSch)
 SET @endPosNum = CHARINDEX('/', @number, @startPosNum)
    IF @endPosSch = 0 OR @endPosNum = 0
  RETURN 0;
 WHILE(@startPosSch < LEN(@schemat))
 BEGIN
  SET @strSch = SUBSTRING(@schemat, @startPosSch, @endPosSch - @startPosSch )
  IF(@strSch = '@numerS' OR @strSch = '@numer')
  BEGIN
   IF( @endPosNum > @startPosNum AND ISNUMERIC(SUBSTRING(@number, @startPosNum, @endPosNum - @startPosNum)) = 1)
   begin
    --declare @numberAsDecimal decimal(15,0)
    --declare @numerAsInt int
    --select @numberAsDecimal = cast(SUBSTRING(@number, @startPosNum, @endPosNum - @startPosNum) as DECIMAL)
    --select @numerAsInt = cast (@numberAsDecimal as int)
    --RETURN @numerAsInt;
    -- return robi to co zakomentowane linijki wyżej
    return cast(cast(SUBSTRING(@number, @startPosNum, @endPosNum - @startPosNum) as DECIMAL) as int);
   end
   ELSE
    RETURN 0;
  END
  SET @startPosSch = @endPosSch + 1
  SET @endPosSch = CHARINDEX('/', @schemat, @startPosSch)
  IF(@endPosSch = 0) SET @endPosSch = LEN(@schemat) + 1
  IF(@strSch <> '@brak')
  BEGIN
   SET @startPosNum = @endPosNum + 1
   SET @endPosNum = CHARINDEX('/', @number, @startPosNum)
   IF(@endPosNum = 0) SET @endPosNum = LEN(@number) + 1
  END
 END
 RETURN 0
END
