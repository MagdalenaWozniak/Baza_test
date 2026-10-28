CREATE FUNCTION cdn.TimeOnly(@DateTime DateTime)
-- returns only the time portion of a DateTime, at the "base" date (1/1/1900)
RETURNS DATETIME
AS
BEGIN
    RETURN DateAdd(day, -datediff(day, 0, @datetime), @datetime)
END
