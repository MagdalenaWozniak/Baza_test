CREATE FUNCTION CDN.NumerKonta (@AccId INT)
RETURNS NVARCHAR(50)
AS
BEGIN
 DECLARE @Wynik   NVARCHAR(50)
 SET @Wynik   = ''
 WHILE @AccId IS NOT NULL
  BEGIN
   IF NOT EXISTS (SELECT * FROM CDN.Konta WHERE Acc_AccId = @AccId) BREAK
   SELECT @AccId = Acc_ParId, @Wynik = Acc_Segment + CASE @Wynik WHEN '' THEN @Wynik ELSE '.' + @Wynik END FROM CDN.Konta WHERE Acc_AccId = @AccId
  END
 RETURN @Wynik
END
