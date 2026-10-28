CREATE FUNCTION cdn.DayOfWeekNo(@date DATETIME)
RETURNS INT
AS
BEGIN
 DECLARE @dzienTygodnia INT
 SET @dzienTygodnia = 1 + ((5 + DATEPART(dw, cdn.DateOnly(@date)) + @@DATEFIRST) % 7)
 RETURN @dzienTygodnia
END
