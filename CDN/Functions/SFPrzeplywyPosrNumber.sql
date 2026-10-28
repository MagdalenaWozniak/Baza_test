CREATE FUNCTION CDN.SFPrzeplywyPosrNumber(@id int)
RETURNS nvarchar(255)
AS
BEGIN
 declare @Result nvarchar(255) = upper(CDN.SFZestawieniaAutoNumber(@id));
 declare @lp int = 0;
 select @lp = ZKP_Lp from cdn.ZestKsiPoz where Zkp_ZkpId = @id;
 set @Result = REPLACE(@Result, '-', rtrim(ltrim(Str(@lp))) );
 return @Result
END
