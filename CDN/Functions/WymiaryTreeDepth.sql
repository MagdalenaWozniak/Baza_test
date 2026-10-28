CREATE FUNCTION CDN.WymiaryTreeDepth()
RETURNS @Result TABLE(  WyyId int, Poziom int)
AS
BEGIN
 declare @P int = 0;
 WITH Wymiar AS (
  SELECT @P as Poziom, Wyy_WyyID as WyyID, Wyy_ParentID as ParentID from CDN.Wymiary
  where IsNUll(Wyy_ParentId, 0) = 0
  UNION ALL
  SELECT Poziom+1, A.Wyy_WyyID, A.Wyy_ParentID from CDN.Wymiary A join Wymiar on (Wymiar.WyyID = A.Wyy_ParentID)
 )
 insert into @Result(WyyId, Poziom)
 SELECT WyyID, Poziom
 FROM Wymiar
 return
END
