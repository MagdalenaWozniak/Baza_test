CREATE FUNCTION CDN.BeginOfNight(@Date DateTime)
RETURNS DateTime
AS
BEGIN
 declare @date_bon datetime; set @date_bon = @Date
 declare @date_eon datetime;
 set @date_bon = DATEADD(HOUR, -DATEPART(HOUR,  @date_bon), @date_bon)
 set @date_bon = DATEADD(MINUTE, -DATEPART(MINUTE, @date_bon), @date_bon)
 set @date_bon = DATEADD(SECOND, -DATEPART(SECOND, @date_bon), @date_bon)
 set @date_eon = DATEADD(HH,  7, @date_bon)
 set @date_bon = DATEADD(HH, 21, @date_bon)
 if @Date < @date_eon
  set @date_bon = DATEADD(day, -1, @date_bon)
 return @date_bon
END
