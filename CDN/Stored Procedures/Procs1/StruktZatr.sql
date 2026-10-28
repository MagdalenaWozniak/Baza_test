CREATE PROCEDURE CDN.StruktZatr @DataOd DATETIME, @DataDo DATETIME
AS
SET NOCOUNT ON
SET @DataOd = CONVERT(DATETIME, CAST(DATEPART(year ,@DataOd) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@DataOd) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@DataOd) AS NVARCHAR)+' 00:00:000', 120)
SET @DataDo = CONVERT(DATETIME, CAST(DATEPART(year ,@DataDo) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@DataDo) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@DataDo) AS NVARCHAR)+' 00:00:000', 120)
--Tworzę tabelę tymczasową
--Tworzę tabelę tymczasową
CREATE TABLE #StrukturaZatr (
 Tmp_Data         DATETIME,
 Tmp_OS_P         INT,
 Tmp_OS_W         INT,
 Tmp_OS_U1        INT,
 Tmp_OS_U2        INT,
 Tmp_OS_U3        INT,
 Tmp_OS_PL_K      INT,
 Tmp_OS_PL_M      INT,
 Tmp_ET_P         DECIMAL(15,2),
 Tmp_ET_W         DECIMAL(15,2),
 Tmp_ET_U         DECIMAL(15,2)
 )
 exec CDN.StruktZatrCalc @DataOd, @DataDo
SET NOCOUNT OFF
SELECT
 Tmp_Data  ,
 Tmp_OS_P  ,
 Tmp_OS_W  ,
 Tmp_OS_U1 ,
 Tmp_OS_U2 ,
 Tmp_OS_U3 ,
 Tmp_ET_P ,
 Tmp_ET_W ,
 Tmp_ET_U ,
 Tmp_OS_PL_K,
 Tmp_OS_PL_M
FROM #StrukturaZatr
--JOIN CDN.PracKod ON Pra_PraId = Tmp_PrcId
