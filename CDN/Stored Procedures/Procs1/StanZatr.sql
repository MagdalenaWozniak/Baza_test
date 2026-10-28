CREATE PROCEDURE CDN.StanZatr @Data DATETIME
AS
SET NOCOUNT ON
SET @Data = CONVERT(DATETIME, CAST(DATEPART(year ,@Data) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@Data) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@Data) AS NVARCHAR)+' 00:00:000', 120)
--Tworzę tabelę tymczasową
CREATE TABLE #StanZatr (
 Tmp_Data         DATETIME,
 Tmp_OS_OG         INT,
 Tmp_OS_K      INT,
 Tmp_P_OG         INT,
 Tmp_P_K      INT,
 Tmp_N_OG         INT,
 Tmp_N_K      INT,
 Tmp_W_OG         INT,
 Tmp_W_K         INT
 )
 exec CDN.StanZatrCalc @Data
SET NOCOUNT OFF
SELECT
 Tmp_Data  ,
 Tmp_OS_OG  ,
 Tmp_OS_K  ,
 Tmp_P_OG ,
 Tmp_P_K ,
 Tmp_N_OG ,
 Tmp_N_K ,
 Tmp_W_OG ,
 Tmp_W_K
FROM #StanZatr
