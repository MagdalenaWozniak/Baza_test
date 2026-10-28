CREATE FUNCTION [CDN].[GetKntId]( @identyfikator VARCHAR(20))
RETURNS INT
AS
BEGIN
 IF @identyfikator IS NULL RETURN 0
 IF LEN(@identyfikator) = 0  RETURN 0
 DECLARE @kntId INT
 SET @kntId = [CDN].[GetKntIdByKod](@identyfikator)
 IF @kntId IS NOT NULL AND @kntId > 0 GOTO KONIEC
 SET @kntId = [CDN].[GetKntIdByNip](@identyfikator)
 IF @kntId IS NOT NULL AND @kntId > 0 GOTO KONIEC
 SET @kntId = [CDN].[GetKntIdByGln](@identyfikator)
 IF @kntId IS NOT NULL AND @kntId > 0 GOTO KONIEC
KONIEC:
 IF @kntId IS NULL SET @kntId = 0
 RETURN @kntId
END
