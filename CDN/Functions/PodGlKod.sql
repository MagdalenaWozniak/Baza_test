CREATE FUNCTION CDN.PodGlKod (@PodTyp INT, @PodID INT, @PodKod NVARCHAR(20))
RETURNS NVARCHAR(20)
AS
BEGIN
  IF @PodKod Is Not Null
 RETURN CASE WHEN @PodTyp <> 1 THEN @PodKod ELSE (SELECT CASE WHEN A.Knt_NadID Is Null THEN A.Knt_Kod ELSE (SELECT B.Knt_Kod FROM cdn.Kontrahenci B WHERE B.Knt_KntID = A.Knt_NadID) END FROM cdn.Kontrahenci A WHERE A.Knt_KntID = @PodID) END
  RETURN CASE WHEN @PodTyp <> 1 THEN (SELECT Pod_Kod FROM cdn.PodmiotyView WHERE Pod_PodmiotTyp = @PodTyp AND Pod_PodId = @PodID) ELSE (SELECT CASE WHEN A.Knt_NadID Is Null THEN A.Knt_Kod ELSE (SELECT B.Knt_Kod FROM cdn.Kontrahenci B WHERE B.Knt_KntID = A.Knt_NadID) END FROM cdn.Kontrahenci A WHERE A.Knt_KntID = @PodID) END
END
