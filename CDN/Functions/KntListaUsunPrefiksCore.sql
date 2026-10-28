CREATE Function CDN.KntListaUsunPrefiksCore(@Val NVARCHAR(256), @Prf NVARCHAR(16))
Returns NVARCHAR(256)
AS
BEGIN
 DECLARE @retVal NVARCHAR(256)
 SET @retVal = @Val
 SET @retVal = REPLACE(@retVal, ' ' + @Prf + ' ', '')
 IF LEN(@retVal) > LEN(@Prf)
 BEGIN
  IF SUBSTRING(@retVal, 1, LEN(@Prf)) = @Prf AND SUBSTRING(@retVal, LEN(@Prf)+1, 1) = ' '
  BEGIN
   IF LEN(@retVal) = LEN(@Prf) + 1
    SET @retVal = ''
   ELSE
    SET @retVal = SUBSTRING(@retVal, LEN(@Prf)+2, LEN(@retVal) - LEN(@Prf) - 1)
  END
 END
 RETURN @retVal
END
