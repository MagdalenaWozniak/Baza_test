CREATE FUNCTION [CDN].[DokNagKontrahent] (@typ int, @id int)
    RETURNS NVARCHAR(255)
BEGIN
 IF @typ <> 1  RETURN N''
 IF (NOT EXISTS (SELECT *
                 FROM INFORMATION_SCHEMA.TABLES
                 WHERE TABLE_SCHEMA = 'CDN'
                 AND  TABLE_NAME = 'DokPodmioty'))
 BEGIN
  RETURN N''
 END
    DECLARE @nazwa NVARCHAR(255), @ilosc   int, @podmiotTyp int, @podmiotId int
 SET    @ilosc = 0
    SELECT TOP 1 @podmiotTyp = DoP_PodmiotTyp, @podmiotId = DoP_PodmiotId FROM CDN.DokPodmioty WHERE DoP_DoNID = @id ORDER BY DoP_DoPId
    IF @podmiotTyp IS NULL OR @podmiotId IS NULL
    BEGIN
  SET @ilosc = 0
  SET @nazwa = ''
 END
    ELSE
    BEGIN
  SELECT @ilosc = COUNT(*) FROM CDN.DokPodmioty WHERE DoP_DoNID = @id
     IF @podmiotTyp = 4 SET @podmiotTyp = 3    -- właściciel
  SELECT TOP 1 @nazwa = Pod_Kod FROM Cdn.PodmiotyView WHERE Pod_PodmiotTyp = @podmiotTyp AND Pod_PodId = @podmiotId
 END
 IF @nazwa IS NULL  SET @nazwa = N''
    IF(@ilosc>1) SET @nazwa = @nazwa + ' + ' + LTRIM( STR(@ilosc-1))
    RETURN @nazwa
END
