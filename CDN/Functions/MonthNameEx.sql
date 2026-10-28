CREATE FUNCTION cdn.MonthNameEx(@monthIndex INT, @lcid INT)
RETURNS NVARCHAR(128)
AS
BEGIN
 DECLARE @name NVARCHAR(128), @monthId VARCHAR(10)
 SET @monthId = 'Months_M' + LTRIM(RTRIM(STR(@monthIndex)))
 SELECT TOP 1 @name = ZJE_Komunikat FROM cdn.Zasobyjezykowe WHERE ZJE_Id LIKE @monthId AND ZJE_Jezyk = @lcid
 IF @name is NULL SET @name = N''
 RETURN @name
END
