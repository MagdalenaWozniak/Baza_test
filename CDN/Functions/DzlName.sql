CREATE FUNCTION CDN.DzlName (@IdDzl INT)
RETURNS NVARCHAR(400)
AS
BEGIN
declare @nameDzl as NVARCHAR(400)
declare @namePom as NVARCHAR(40)
declare @IdParent as Int
SET @nameDzl =  ''
SELECT @IdParent = DZL_ParentId from CDN.Dzialy
where DZL_DzlId = @IdDzl
WHILE @IdDzl > 1
BEGIN
 select @namePom =  DZL_Nazwa, @IdDzl = DZL_ParentId from CDN.Dzialy where DZL_DzlId = @IdDzl
 SET @nameDzl =  @namePom + '-'+ @nameDzl
END
IF Len(@nameDzl) > 0
   SET @nameDzl = Substring(@nameDzl, 1, len(@nameDzl)-1)
Return @nameDzl
END
