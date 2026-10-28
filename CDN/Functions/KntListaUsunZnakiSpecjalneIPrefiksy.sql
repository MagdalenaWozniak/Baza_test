CREATE Function CDN.KntListaUsunZnakiSpecjalneIPrefiksy (@Ulica NVARCHAR(50), @NrDomu NVARCHAR(16), @NrLokalu NVARCHAR(16))
Returns NVARCHAR(256)
AS
BEGIN
 DECLARE @retVal NVARCHAR(256)
 SET @retVal = @Ulica
 SET @retVal = CDN.KntListaUsunPrefiks(@retVal, 'ulica', 0)
 SET @retVal = CDN.KntListaUsunPrefiks(@retVal, 'ul', 1)
 SET @retVal = CDN.KntListaUsunPrefiks(@retVal, 'aleja', 0)
 SET @retVal = CDN.KntListaUsunPrefiks(@retVal, 'al', 1)
 SET @retVal = CDN.KntListaUsunPrefiks(@retVal, 'osiedle', 0)
 SET @retVal = CDN.KntListaUsunPrefiks(@retVal, 'os', 1)
 SET @retVal = CDN.KntListaUsunPrefiks(@retVal, 'plac', 0)
 SET @retVal = CDN.KntListaUsunPrefiks(@retVal, 'pl', 1)
 SET @retVal = @retVal + @NrDomu + @NrLokalu
 SET @retVal = REPLACE(@retVal, '.', '')
 SET @retVal = REPLACE(@retVal, ',', '')
 SET @retVal = REPLACE(@retVal, '-', '')
 SET @retVal = REPLACE(@retVal, ' ', '')
 SET @retVal = REPLACE(@retVal, ':', '')
 SET @retVal = REPLACE(@retVal, ';', '')
 SET @retVal = REPLACE(@retVal, '/', '')
 RETURN @retVal
END
