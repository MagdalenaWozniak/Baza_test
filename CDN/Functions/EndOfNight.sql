CREATE FUNCTION CDN.EndOfNight(@Date DateTime)
RETURNS DateTime
AS
BEGIN
 declare @date_eon datetime; set @date_eon = @Date
 declare @date_bon datetime;
 set @date_eon = DATEADD(HOUR, -DATEPART(HOUR,  @date_eon), @date_eon)
 set @date_eon = DATEADD(MINUTE, -DATEPART(MINUTE, @date_eon), @date_eon)
 set @date_eon = DATEADD(SECOND, -DATEPART(SECOND, @date_eon), @date_eon)
 --set @date_bon = DATEADD(HH, 21, @date_eon)
 set @date_eon = DATEADD(HH,  7, @date_eon)
 if @Date >= @date_eon
  set @date_eon = DATEADD(day, 1, @date_eon)
 return @date_eon
END
