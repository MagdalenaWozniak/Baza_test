CREATE FUNCTION CDN.NoOfNight(@DataOd DateTime, @DataDo DateTime)
RETURNS int
AS
BEGIN
 declare @result int
 set @result = 0
 if(@dataDo <= @dataOd)
  return 0
 declare @current DateTime;
 set @current = @DataOd
 while(@current < @DataDo)
 begin
  declare @eon datetime;
  declare @bon datetime;
  set @eon = CDN.EndOfNight(@current)
  set @bon = CDN.BeginOfNight(@current)
  if @eon > @DataDo
   set @eon = @DataDo
  if @bon > @DataDo
   set @eon = @DataDo
  declare @d int; set @d = DateDiff(MINUTE, @current, @eon)/60
  declare @dd int; set @dd = DateDiff(MINUTE, @bon, @eon)/60
  if @dd >= 6 and @d >= 6
   set @result = @result+ 1
  set @current = @eon
 end
 return @result
END
