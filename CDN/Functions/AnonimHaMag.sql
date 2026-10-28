CREATE FUNCTION cdn.AnonimHaMag(@id INT)
RETURNS     INT
  AS
  BEGIN
 DECLARE @result  INT
 SET @result = 0
 SELECT @result = (SUM(IsNull(A.Knt_LpAnonimizacji, 0)) + SUM(IsNull(B.Knt_LpAnonimizacji, 0)) + SUM(IsNull(C.Knt_LpAnonimizacji, 0)))
        FROM CDN.TraNag
        LEFT OUTER JOIN CDN.Kontrahenci A ON TrN_PodID = A.Knt_KntId AND TrN_PodmiotTyp = A.Knt_PodmiotTyp
        LEFT OUTER JOIN CDN.Kontrahenci B ON TrN_PodZalId = B.Knt_KntID AND TrN_PodmiotZalTyp = B.Knt_PodmiotTyp
        LEFT OUTER JOIN CDN.Kontrahenci C ON TrN_PlatnikID = C.Knt_KntID AND TrN_PlatnikTyp = C.Knt_PodmiotTyp
        WHERE TrN_TrNID = @id
 IF  @result IS NULL SET @result = 0
 RETURN @result
  END
