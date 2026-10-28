CREATE  FUNCTION cdn.DateOnly(@DateTime DATETIME)
-- Returns @DateTime at midnight; i.e., it removes the time portion of a DateTime value.
RETURNS DATETIME
AS
    BEGIN
    RETURN DateAdd(dd,0, DateDiff(dd,0,@DateTime))
    END
