CREATE FUNCTION cdn.Time(@Hour int, @Minute int, @Second int)
-- Returns a datetime value for the specified time at the "base" date (1/1/1900)
RETURNS DATETIME
AS
BEGIN
    RETURN DateAdd(ss,(@Hour*3600)+(@Minute*60)+@Second,0)
END
