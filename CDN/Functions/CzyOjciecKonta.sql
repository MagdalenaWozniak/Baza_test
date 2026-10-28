CREATE FUNCTION CDN.CzyOjciecKonta (@AccId INT, @ParId INT)
RETURNS INT
AS
BEGIN
 DECLARE @Wynik INT, @Poziom INT
 SET @Wynik  = 0
 SET @Poziom = 0
 WHILE @AccId IS NOT NULL
  BEGIN
   IF NOT EXISTS (SELECT * FROM CDN.Konta WHERE Acc_AccId = @AccId) BREAK
   SET @Poziom = @Poziom + 1
   IF @AccId = @ParId
     BEGIN
       SET @Wynik = @Poziom
       BREAK
     END
   SELECT @AccId = Acc_ParId FROM CDN.Konta WHERE Acc_AccId = @AccId
  END
 RETURN @Wynik
END
