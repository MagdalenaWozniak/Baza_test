CREATE FUNCTION CDN.SFZestawieniaAutoNumber(@id int)
RETURNS nvarchar(255)
AS
BEGIN
 declare @Result nvarchar(255) = '';
 declare @parentId int = 0;
 declare @Segment nvarchar(50) = ''
 select @parentId = ZKP_ParId, @Segment = ZKP_Segment from CDN.ZestKsiPoz where ZKP_ZKPId = @id;
 if @parentId is not null
  set @Result = CDN.StringExpression(CDN.StringExpression(@Result, '_', CDN.SFZestawieniaAutoNumber(@parentId)), '_', @Segment);
 else
  set @Result = CDN.StringExpression(@Result, '_', @Segment);
 return @Result
END
