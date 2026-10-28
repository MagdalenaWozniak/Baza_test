CREATE FUNCTION CDN.SrsCzynnosciKontrahentNaFa (@SrYId INT)
RETURNS VARCHAR(20)
AS
BEGIN
 DECLARE @KOD VARCHAR(20)
 SELECT TOP 1 @KOD = Pod_Kod FROM cdn.SrsCzynnosci
 JOIN cdn.TraElemRelacje ON TeR_ParentTyp=901 AND TeR_ParentId=SrY_SrYId
 JOIN cdn.TraElem        ON TeR_ChildTyp = TrE_TypDokumentu AND TeR_ChildId = TrE_TrEId
 JOIN cdn.TraNag         ON TrE_TrNId = TrN_TrNId
 JOIN cdn.PodmiotyView ON TrN_PodmiotTyp = Pod_PodmiotTyp AND TrN_PodID = Pod_PodId
 WHERE SrY_SrYId = @SrYId
 AND TeR_ChildTyp IN (302, 304, 305, 306)
 ORDER BY TeR_ChildTyp
 IF @KOD IS NULL SET @KOD = ''
 RETURN @KOD
END
