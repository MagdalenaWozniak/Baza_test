CREATE Function CDN.KntListaUsunPrefiks(@Val NVARCHAR(256), @Prf NVARCHAR(16), @UwzgledniajKropke TINYINT)
Returns NVARCHAR(256)
AS
BEGIN
 DECLARE @retVal NVARCHAR(256)
 SET @retVal = @val
 SET @retVal = CDN.KntListaUsunPrefiksCore(@Val, @Prf)
 IF @UwzgledniajKropke = 1
 BEGIN
  SET @Prf = @Prf + '.'
  SET @retVal = CDN.KntListaUsunPrefiksCore(@retVal, @Prf)
 END
 RETURN @retVal
END
