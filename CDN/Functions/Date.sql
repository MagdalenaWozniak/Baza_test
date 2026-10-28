CREATE FUNCTION cdn.Date(@Year int, @Month int, @Day int)
-- returns a datetime value for the specified year, month and day
-- Michael Valentine Jones formula
RETURNS DATETIME
AS
BEGIN
    RETURN DateAdd(month,((@Year-1900)*12)+@Month-1,@Day-1)
END
