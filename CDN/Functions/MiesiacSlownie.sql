CREATE FUNCTION CDN.MiesiacSlownie( @miesiac int )
RETURNS NVARCHAR(15)
AS
BEGIN
 DECLARE @ResultVar NVARCHAR(15)
 SET @ResultVar= CASE @miesiac
   WHEN 1  THEN 'Styczeń'
   WHEN 2  THEN 'Luty'
   WHEN 3  THEN 'Marzec'
   WHEN 4  THEN 'Kwiecień'
   WHEN 5  THEN 'Maj'
   WHEN 6  THEN 'Czerwiec'
   WHEN 7  THEN 'Lipiec'
   WHEN 8  THEN 'Sierpień'
   WHEN 9  THEN 'Wrzesień'
   WHEN 10 THEN 'Październik'
   WHEN 11 THEN 'Listopad'
   WHEN 12 THEN 'Grudzień'
  END
 RETURN @ResultVar
END
