CREATE FUNCTION cdn.MonthName(@monthIndex INT)
RETURNS NVARCHAR(128)
AS
BEGIN
 DECLARE @lcid INT
 SET @lcid = cdn.UI_LCID()
 RETURN cdn.MonthNameEx(@monthIndex, @lcid)
END
