CREATE PROCEDURE CDN.SprzedazDedykowana_Wykres
@KntID            AS INT,
@DataOd     AS DATETIME,
@DataDo     AS DATETIME
AS
BEGIN
SELECT
cdn.CapitalizeFirstChar(cdn.MonthName(MONTH(TrN_DataDok))) AS Miesiac,
Sum(TrN_RazemNetto) AS Obroty,
MONTH(TrN_DataDok)  AS MiesiacNr
FROM cdn.TraNag
WHERE TrN_PodmiotTyp=1 AND TrN_PodID IN (SELECT Knt_KntId FROM cdn.Kontrahenci WHERE Knt_GlID = @KntID)
AND TrN_DataDok BETWEEN @DataOd AND @DataDo
AND TrN_Bufor<>-1
AND (TrN_TypDokumentu=302 OR (TrN_TypDokumentu=305 AND TrN_TrNId NOT IN (SELECT TrN_TrNId FROM cdn.TraNag LEFT JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId WHERE TrR_TrNTyp=305 AND TrR_FaTyp = 302)))
GROUP BY SUBSTRING(CONVERT(CHAR(10), TrN_DataDok, 120), 1, 7),
MONTH(TrN_DataDok)
ORDER BY SUBSTRING(CONVERT(CHAR(10), TrN_DataDok, 120), 1, 7)
END
