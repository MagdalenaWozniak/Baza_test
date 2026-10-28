CREATE FUNCTION cdn.DdfNazwaForObd(@klasDok INT, @jezykId INT)
  RETURNS     NVARCHAR(256)
  AS
  BEGIN
    DECLARE @nazwa NVARCHAR(256), @typId INT, @subTyp INT, @num INT
 SET @num = 0
 IF @klasDok > 900000 AND @klasDok < 910000
 BEGIN
  SET @typId = @klasDok - 900000
  SET @subTyp = NULL
 END
 IF @klasDok > 750000000 AND @klasDok < 751000000
 BEGIN
  SET @num = @klasDok - 750000000
  SET @typId  = @num / 100
  SET @subTyp = @num - (@typId * 100)
  IF @typId = 1003 SET @subTyp = @subTyp + 100
 END
 IF @subTyp = 0 SET @subTyp = NULL
 SET @nazwa = cdn.OptimaNazwaObiektuEx(@typId, @subTyp, @jezykId )
 IF @nazwa IS NULL SET @nazwa = N''
 RETURN @nazwa
  END
