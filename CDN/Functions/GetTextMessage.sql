CREATE FUNCTION CDN.GetTextMessage( @ClassId nvarchar(64), @MessageId nvarchar(320) )
RETURNS nvarchar(max)
AS
BEGIN
 declare @Result nvarchar(max);
 declare @TranslationId int = 1;
 select @Result = Dct_Message from CDN.Dictionary where Dct_TranslationId = @TranslationId and Dct_MessageId = @MessageId;
 return IsNull(@Result, '');
END
