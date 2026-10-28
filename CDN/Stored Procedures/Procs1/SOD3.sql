Create Procedure CDN.SOD3
@DataOd DateTime,
@DataDo DateTime,
@Typ INT
As
SET NOCOUNT ON
SET @DataOd = CONVERT(DATETIME, CAST(DATEPART(year ,@DataOd) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@DataOd) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@DataOd) AS NVARCHAR)+' 00:00:000', 120)
SET @DataDo = CONVERT(DATETIME, CAST(DATEPART(year ,@DataDo) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@DataDo) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@DataDo) AS NVARCHAR)+' 00:00:000', 120)
--Tworze tabele tymczasowa
CREATE TABLE #SOD(
 Tmp_Data         DATETIME,
 Tmp_OS_P         INT,
 Tmp_OS_N         INT,
 Tmp_OS_L         INT,
 Tmp_OS_U         INT,
 Tmp_OS_Z         INT,
 Tmp_ET_P         DECIMAL(15,7),
 Tmp_ET_PP        DECIMAL(15,7),
 Tmp_ET_N         DECIMAL(15,7),
 Tmp_ET_L         DECIMAL(15,7),
 Tmp_ET_U         DECIMAL(15,7),
 Tmp_ET_US        DECIMAL(15,7),
 Tmp_ET_Z         DECIMAL(15,7),
 Tmp_ET_ZS        DECIMAL(15,7)
 )
 exec CDN.SOD3Calc @DataOd, @DataDo, @Typ
SET NOCOUNT OFF
SELECT
 Tmp_Data ,
 Tmp_OS_P ,
 Tmp_OS_N ,
 Tmp_OS_L ,
 Tmp_OS_U ,
 Tmp_OS_Z ,
 Tmp_ET_P ,
 Tmp_ET_PP ,
 Tmp_ET_N ,
 Tmp_ET_L ,
 Tmp_ET_U ,
 Tmp_ET_US ,
 Tmp_ET_Z ,
 Tmp_ET_ZS
FROM #SOD
--JOIN CDN.PracKod ON Pra_PraId = Tmp_PrcId
