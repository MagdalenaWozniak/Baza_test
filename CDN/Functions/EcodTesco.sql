CREATE FUNCTION CDN.EcodTesco(@podmiotTyp INT, @podmiotId INT)
RETURNS TINYINT
AS
BEGIN
 IF @podmiotTyp <> 1 RETURN 0
 IF EXISTS( SELECT Knt_KntId FROM cdn.Kontrahenci WHERE Knt_KntId = @podmiotId AND Knt_GLN = '5900001240007' )
  RETURN 1
 RETURN 0
END
