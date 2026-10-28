CREATE FUNCTION cdn.LastDayOfMonth(@date DATETIME)
RETURNS     INT
  AS
BEGIN
 --SELECT DATEADD(dd,-(DATEPART(dw, @Date) - 1),@Date) AS 'First day of the week'
 --SELECT DATEADD(dd,-(DATEPART(dw, @Date) - 7),@Date) AS 'Last day of the week'
 DECLARE @wynik INT
 SELECT @wynik = DAY(DATEADD(d, -DAY(DATEADD(m,1,@Date)),DATEADD(m,1,@Date)))
 RETURN @wynik
END
