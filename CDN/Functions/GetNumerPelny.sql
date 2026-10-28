CREATE FUNCTION CDN.GetNumerPelny( @schemat nvarchar(50), @data datetime, @rejestr nvarchar(20) /*inaczej seria*/, @symbol nvarchar(5), @numer nvarchar(20), @magazyn nvarchar(20), @rok_obr nvarchar(10))
RETURNS nvarchar(50)
WITH SCHEMABINDING
BEGIN
 DECLARE @result nvarchar(50),
  @startPosSch int,
  @endPosSch int,
   @strSch nvarchar(10),
  @miesiac int,
  @rok int
 SET @miesiac = MONTH(@data)
 SET @rok = YEAR(@data)
 SET @result = ''
 SET @startPosSch = 1
 SET @endPosSch = CHARINDEX('/', @schemat, @startPosSch)
 WHILE(@startPosSch < LEN(@schemat))
 BEGIN
  SET @strSch = SUBSTRING(@schemat, @startPosSch, @endPosSch - @startPosSch )
    SET @result = @result + case @strSch
     when '@brak' then ''
     when '@symbol' then @symbol + '/'
     when '@rejestr' then @rejestr + '/'
     when '@numerS' then @numer + '/'
          when '@numer' then substring(convert(nvarchar(7), 1000000 +  convert(int, @numer)), 2, 6 ) + '/'
       -- when '@numer' then substring(convert(nvarchar(9), 100000000 +  convert(int, @numer)), 3, 8 ) + '/'
     when '@miesiac' then substring(convert(nvarchar(3), @miesiac + 100), 2, 2) + '/'
     when '@rok_kal' then convert(nvarchar(4), @rok) + '/'
     when '@rok_obr' then @rok_obr + '/'
     when '@magazyn' then @magazyn + '/'
     when '@seria' then @rejestr + '/'
     else '@err'
     end
  SET @startPosSch = @endPosSch + 1
   SET @endPosSch = CHARINDEX('/', @schemat, @startPosSch)
    IF(@endPosSch = 0) SET @endPosSch = LEN(@schemat) + 1
 END
 RETURN SUBSTRING(@result, 1, LEN(@result) - 1)
END
