CREATE PROCEDURE CDN.jdp_getObroty
 @KntID int = 2,
 @DataChr char(10),
 @LMcy int = 3,
 @Poprz bit = 0
AS
DECLARE
 @Data Datetime,
 @Str char(7),
 @DPocz datetime
SET @Data = convert(datetime, @DataChr, 120)
IF @Poprz = 1
 SET @Data = DATEADD(Year, -1, @Data)
SET @Str = CONVERT(char(7), DATEADD(Month, 1 - @LMcy, @Data), 120)
SET @DPocz = CONVERT(datetime, @Str + '-01', 120)
SELECT
 CONVERT(char(7), TrN_DataDok, 120) AS Data,
 SUM(TrN_RazemNetto) AS Obroty
FROM
 cdn.TraNag
WHERE
 TrN_PodmiotTyp = 1 AND
 TrN_PodID = @KntID AND
 TrN_DataDok BETWEEN @DPocz AND @Data AND
 TrN_Bufor <> -1 AND
 (TrN_TypDokumentu = 302 OR TrN_TypDokumentu = 305)
GROUP BY
 CONVERT(char(7), TrN_DataDok, 120)
ORDER BY
 CONVERT(char(7), TrN_DataDok, 120)
