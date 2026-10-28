CREATE FUNCTION CDN.ProjName (@IdProj INT)
RETURNS NVARCHAR(400)
AS
BEGIN
declare @nameProj as NVARCHAR(400)
declare @namePom as NVARCHAR(40)
declare @IdParent as Int
SET @nameProj =  ''
SELECT @IdParent = PRJ_ParentId from CDN.DefProjekty
where PRJ_PrjId = @IdProj
WHILE @IdProj > 1
BEGIN
 select @namePom =  PRJ_Nazwa, @IdProj =  PRJ_ParentId from CDN.DefProjekty where PRJ_PrjId = @IdProj
 SET @nameProj =  @namePom + '-'+ @nameProj
END
IF Len(@nameProj) > 0
   SET @nameProj = Substring(@nameProj, 1, len(@nameProj)-1)
Return  @nameProj
END
