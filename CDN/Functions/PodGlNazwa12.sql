CREATE FUNCTION CDN.PodGlNazwa12 (@PodTyp INT, @PodID INT, @PodNazwa1 NVARCHAR(50), @PodNazwa2 NVARCHAR(50))
RETURNS NVARCHAR(101)
AS
BEGIN
  IF @PodNazwa1 Is Not Null OR @PodNazwa2 Is Not Null
 RETURN CASE WHEN @PodTyp <> 1 THEN IsNull(@PodNazwa1, '') + ' ' + IsNull(@PodNazwa2, '') ELSE (SELECT CASE WHEN A.Knt_NadID Is Null THEN A.Knt_Nazwa1 + ' ' + A.Knt_Nazwa2 ELSE (SELECT B.Knt_Nazwa1 + ' ' + B.Knt_Nazwa2 FROM cdn.Kontrahenci B WHERE B.Knt_KntID = A.Knt_NadID) END FROM cdn.Kontrahenci A WHERE A.Knt_KntID = @PodID) END
  RETURN CASE WHEN @PodTyp <> 1 THEN (SELECT Pod_Nazwa1 + ' ' + Pod_Nazwa2 FROM cdn.PodmiotyView WHERE Pod_PodmiotTyp = @PodTyp AND Pod_PodId = @PodID) ELSE (SELECT CASE WHEN A.Knt_NadID Is Null THEN A.Knt_Nazwa1 + ' ' + A.Knt_Nazwa2 ELSE (SELECT B.Knt_Nazwa1 + ' ' + B.Knt_Nazwa2 FROM cdn.Kontrahenci B WHERE B.Knt_KntID = A.Knt_NadID) END FROM cdn.Kontrahenci A WHERE A.Knt_KntID = @PodID) END
END
