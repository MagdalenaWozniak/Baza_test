CREATE FUNCTION cdn.AnonimKnt(@id INT)
RETURNS     INT
  AS
  BEGIN
   DECLARE @result  INT
   SET @result = 0
   IF EXISTS(SELECT * FROM cdn.Kontrahenci WHERE Knt_KntId = @id AND Knt_LpAnonimizacji IS NOT NULL AND Knt_LpAnonimizacji > 0)
  SET @result = 1
   RETURN @result
  END
