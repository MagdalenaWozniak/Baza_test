CREATE FUNCTION cdn.OptimaNazwaObiektu (@typId INT, @subTyp INT = NULL)
  RETURNS     NVARCHAR(256)
  AS
  BEGIN
    DECLARE @jezykId INT
 SET @jezykId = cdn.UI_LCID()
 RETURN cdn.OptimaNazwaObiektuEx(@typId, @subTyp, @jezykId)
  END
