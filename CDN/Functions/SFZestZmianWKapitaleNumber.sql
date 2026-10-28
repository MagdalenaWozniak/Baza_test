CREATE FUNCTION CDN.SFZestZmianWKapitaleNumber(@id int)
RETURNS nvarchar(255)
AS
BEGIN
 declare @Result nvarchar(255) = upper(CDN.SFZestawieniaAutoNumber(@id));
 declare @lp int = 0;
 select @lp = ZKP_Lp from cdn.ZestKsiPoz where Zkp_ZkpId = @id;
 set @Result = REPLACE(@Result, '-', rtrim(ltrim(Str(@lp))) );
 if @Result = 'II'
  Set @Result = 'IA';
 else if @Result = 'III'
  Set @Result = 'II';
 else if @Result = 'IV'
  Set @Result = 'III';
 if CharIndex( 'II_', @Result, 1) = 1
  Set @Result = 'IA' + SUBSTRING( @Result, 3, LEN(@Result)-2);
 return @Result
END
