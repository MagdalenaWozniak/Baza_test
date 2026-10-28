CREATE FUNCTION cdn.DateTime(@Year int, @Month int, @Day int, @Hour int, @Minute int, @Second int)
-- returns a dateTime value for the date and time specified.
RETURNS DATETIME
AS
BEGIN
    RETURN cdn.Date(@Year,@Month,@Day) + cdn.Time(@Hour, @Minute,@Second)
END
