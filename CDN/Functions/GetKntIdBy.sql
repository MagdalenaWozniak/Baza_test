CREATE FUNCTION [CDN].GetKntIdBy(@kod VARCHAR(20), @nip NVARCHAR(20), @gln VARCHAR(13))
RETURNS INT
AS
BEGIN
 DECLARE @kntId INT
 IF @kod IS NOT NULL
 BEGIN
  SET @kntId = [CDN].[GetKntIdByKod](@kod)
  IF @kntId IS NOT NULL AND @kntId > 0 GOTO KONIEC
 END
 IF @nip IS NOT NULL
 BEGIN
  SET @kntId = [CDN].[GetKntIdByNip](@nip)
  IF @kntId IS NOT NULL AND @kntId > 0 GOTO KONIEC
 END
 IF @gln IS NOT NULL
 BEGIN
  SET @kntId = [CDN].[GetKntIdByGln](@gln)
  IF @kntId IS NOT NULL AND @kntId > 0 GOTO KONIEC
 END
KONIEC:
 IF @kntId IS NULL SET @kntId = 0
 RETURN @kntId
END
