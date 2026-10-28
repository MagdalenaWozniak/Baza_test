CREATE FUNCTION CDN.VATZD_OstatniaKorektaId( @DeNId int)
RETURNS int
AS
BEGIN
 declare @RokMiesiac int;
 declare @TypDeklar int;
 declare @Result int;
 select @RokMiesiac = DkN_RokMiesiac, @TypDeklar = DkN_TypDeklar from cdn.deklnag  where DkN_DkNID = @DeNId and DkN_Finalna = 1;
 select top 1 @Result = DkN_DkNID from cdn.deklnag
 where DkN_RokMiesiac = @RokMiesiac and DkN_TypDeklar = @TypDeklar and DkN_Finalna <> 1
 order by DkN_Numer desc
 return @Result
END
