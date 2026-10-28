CREATE FUNCTION CDN.TeRIsChild (@ParentTyp INT, @ParentId INT, @ChildTyp INT)
RETURNS INT
AS
BEGIN
 DECLARE @ChildId INT
  SET @ChildId = 0
 SELECT TOP 1 @ChildId = TeR_ChildId FROM  CDN.TraElemRelacje
 WHERE TeR_ParentTyp=@ParentTyp and TeR_ParentId=@ParentId and TeR_ChildTyp=@ChildTyp
 ORDER BY TeR_TeRId
 RETURN @ChildId
END
