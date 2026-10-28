CREATE FUNCTION [CDN].GetKntIdForEcod(@gln VARCHAR(13))
RETURNS INT
AS
BEGIN
  DECLARE @kntId INT
  IF @gln IS NULL OR LEN(@gln) = 0 GOTO KONIEC
  SELECT TOP 1 @kntId = Knt_KntId FROM CDN.Kontrahenci WHERE Knt_GLN = @gln AND (Knt_NadId IS NULL OR Knt_NadId = 0) ORDER BY Knt_Kod
  IF @kntId IS NOT NULL AND @kntId > 0 GOTO KONIEC
  -- sprawdz duplikaty
  SELECT TOP 1 @kntId = Knt_KntId FROM CDN.Kontrahenci WHERE Knt_GLN = @gln AND (Knt_NadId IS NOT NULL AND Knt_NadId > 0) ORDER BY Knt_Kod
  IF @kntId IS NOT NULL AND @kntId > 0 GOTO KONIEC
KONIEC:
 IF @kntId IS NULL SET @kntId = 0
 RETURN @kntId
END
