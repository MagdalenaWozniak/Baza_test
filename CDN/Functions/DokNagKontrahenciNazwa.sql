CREATE FUNCTION CDN.DokNagKontrahenciNazwa (@typ int, @id int)
    RETURNS NVARCHAR(1024)
BEGIN
 IF @typ <> 1  RETURN N''
 IF (NOT EXISTS (SELECT *
                 FROM INFORMATION_SCHEMA.TABLES
                 WHERE TABLE_SCHEMA = 'CDN'
                 AND  TABLE_NAME = 'DokPodmioty'))
 BEGIN
  RETURN N''
 END
    DECLARE @nazwa varchar(1024)
 SELECT  @nazwa = COALESCE(@nazwa + ', ' , '' )  + CASE Pod_PodmiotTyp WHEN 3 THEN RTRIM(Pod_Nazwa1) + N' ' + RTRIM(Pod_Nazwa2) ELSE RTRIM(Pod_Nazwa1) END FROM cdn.DokPodmioty
 JOIN cdn.PodmiotyView ON CASE
 WHEN DoP_PodmiotTyp IN (3,4) AND Pod_PodmiotTyp = 3 AND Pod_PodId = DoP_PodmiotId AND DoP_DoNID = @id THEN 1
 WHEN DoP_PodmiotTyp < 3 AND Pod_PodmiotTyp = DoP_PodmiotTyp AND Pod_PodId = DoP_PodmiotId AND DoP_DoNID = @id THEN 1
 WHEN DoP_PodmiotTyp > 4 AND Pod_PodmiotTyp = DoP_PodmiotTyp AND Pod_PodId = DoP_PodmiotId AND DoP_DoNID = @id THEN 1
 END = 1
 WHERE DoP_DoNID = @id
 ORDER BY DoP_DoPId
 IF @nazwa IS NULL  SET @nazwa = N''
    RETURN @nazwa
END
