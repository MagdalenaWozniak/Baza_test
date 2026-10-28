CREATE FUNCTION cdn.AnonimKnO(@id INT)
RETURNS     INT
  AS
  BEGIN
   DECLARE @result  INT
   SET @result = 0
   IF EXISTS(SELECT * FROM cdn.KntOsoby WHERE KnO_KnoId = @id AND KnO_LpAnonimizacji IS NOT NULL AND KnO_LpAnonimizacji > 0)
  SET @result = 1
   RETURN @result
  END
