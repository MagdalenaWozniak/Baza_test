CREATE FUNCTION [CDN].[GetKntIdByGln](@identyfikator VARCHAR(13))
RETURNS INT
AS
BEGIN
 DECLARE @kntId INT
 IF @identyfikator IS NULL OR LEN(@identyfikator) = 0 GOTO KONIEC
 SELECT TOP 1 @kntId = Knt_KntId FROM CDN.Kontrahenci WHERE Knt_GLN = @identyfikator AND (Knt_NadId IS NULL OR Knt_NadId = 0) ORDER BY Knt_Kod
 IF @kntId IS NULL  -- szukaj nadrzednego
 BEGIN
  SELECT TOP 1 @kntId = Knt_GlID FROM CDN.Kontrahenci WHERE Knt_GLN = @identyfikator ORDER BY Knt_Kod
 END
KONIEC:
 IF @kntId IS NULL SET @kntId = 0
 RETURN @kntId
END
