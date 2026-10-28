CREATE FUNCTION CDN.WymiarRootId(@id int)
RETURNS int
AS
BEGIN
 declare @Result int = NULL;
 WITH Wymiar AS (
  SELECT Wyy_WyyID as WyyID, Wyy_ParentID as ParentID from CDN.Wymiary
  where Wyy_WyyID = @ID
  UNION ALL
  SELECT A.Wyy_WyyID, A.Wyy_ParentID from CDN.Wymiary A join Wymiar on (Wymiar.ParentID = A.Wyy_WyyID)
 )
 SELECT @Result = WyyID
 FROM Wymiar where ParentID=0;
 return @Result
END
