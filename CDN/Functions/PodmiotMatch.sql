CREATE FUNCTION CDN.PodmiotMatch (@PodTyp INT, @PodID INT, @MatchPodTyp INT, @MatchPodID INT)
RETURNS TINYINT
AS
BEGIN
  --IF @PodTyp = @MatchPodTyp AND (@PodID = @MatchPodID OR @MatchPodTyp = 1 AND @PodID IN (SELECT @MatchPodID UNION ALL SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @MatchPodID))
  IF @PodTyp = @MatchPodTyp AND @PodID IN (SELECT @MatchPodID UNION ALL SELECT Knt_KntID FROM CDN.Kontrahenci WHERE @MatchPodTyp = 1 AND Knt_NadID = @MatchPodID)
    RETURN 1
  RETURN 0
END
