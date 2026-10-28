CREATE PROCEDURE [CDN].[PracZwolnieniZaznacz] @DataOd DATETIME, @DataDo DATETIME, @CDN_GUID VARCHAR (50), @Typ INT
AS
BEGIN
SET NOCOUNT ON
IF @DataOd IS NULL OR @DataDo IS NULL
 BEGIN
  SET @DataOd = '1899-12-30 00:00:00'
  SET @DataDo = '1899-12-30 00:00:00'
 END
 ELSE
 BEGIN
  SET @DataOd = CONVERT(DATETIME, CAST(DATEPART(year ,@DataOd) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@DataOd) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@DataOd) AS NVARCHAR)+' 00:00:000', 120)
  SET @DataDo = CONVERT(DATETIME, CAST(DATEPART(year ,@DataDo) AS NVARCHAR) +'-'+CAST(DATEPART(month ,@DataDo) AS NVARCHAR)+'-'+ CAST(DATEPART(day ,@DataDo) AS NVARCHAR)+' 00:00:000', 120)
 END;
If @Typ = 1
WITH KOLEJNE AS
(
     SELECT
         RANK() OVER(PARTITION BY PRE_PraId ORDER BY PRE_DataOd) AS kolejnosc,
         PRE_PreId, PRE_PraId
     FROM CDN.PracEtaty
)
SELECT
CASE PRI_Nadrzedny WHEN 1 THEN '+ '+PRE_Nazwisko ELSE CASE ISNULL(PRI_ParentId,0) WHEN 0 THEN PRE_Nazwisko ELSE '- '+PRE_Nazwisko END END AS Nazwisko,
PRE_Imie1 AS Imię,
PRE_Kod AS Akronim,
PRE_ZatrudnionyOd AS 'Zatrudniony od',
PRE_ZatrudnionyDo AS 'Zatrudniony do',
PRE_PreId AS id,
PRE_Plec AS Plec,
a1.DKM_Nazwa AS PowodWyp,
a2.DKM_Nazwa AS Stanowisko,
RpZ2_GUID
FROM CDN.PracEtaty
JOIN CDN.PracIdx ON PRE_PraId = PRI_PraId
LEFT JOIN CDN.DaneKadMod AS a1 ON PRE_ETADkmIdWypowPowod = a1.DKM_DkmId
LEFT JOIN CDN.DaneKadMod AS a2 ON PRE_ETADkmIdStanowisko = a2.DKM_DkmId
INNER JOIN CDN.RptZaznaczenia2 ON RpZ2_GIDNumer = PRE_PraId
WHERE PRI_Typ = 1
AND RpZ2_GUID = @CDN_GUID
AND PRE_ZatrudnionyDo < CDN.Date(2999,12,31)
AND PRE_ZatrudnionyDo >= @DataOd
AND PRE_ZatrudnionyDo <= @DataDo
AND PRE_PreId IN (
SELECT PRE_PreId FROM KOLEJNE K1
WHERE K1.kolejnosc = (SELECT MAX(K2.kolejnosc) FROM KOLEJNE K2 WHERE K1.PRE_PraId = K2.PRE_PraId GROUP BY PRE_PraId)
)
ORDER BY PRE_ZatrudnionyDo, PRE_Nazwisko, PRE_Imie1, PRE_Kod
If @Typ = 0
SELECT
CASE PRI_Nadrzedny WHEN 1 THEN '+ '+PRE_Nazwisko ELSE CASE ISNULL(PRI_ParentId,0) WHEN 0 THEN PRE_Nazwisko ELSE '- '+PRE_Nazwisko END END AS Nazwisko,
PRE_Imie1 AS Imię,
PRE_Kod AS Akronim,
PRE_ZatrudnionyOd AS 'Zatrudniony od',
PRE_ZatrudnionyDo AS 'Zatrudniony do',
PRE_PreId AS id,
PRE_Plec AS Plec,
a1.DKM_Nazwa AS PowodWyp,
a2.DKM_Nazwa AS Stanowisko,
RpZ2_GUID
FROM CDN.PracEtaty
JOIN CDN.PracIdx ON PRE_PraId = PRI_PraId
LEFT JOIN CDN.DaneKadMod AS a1 ON PRE_ETADkmIdWypowPowod = a1.DKM_DkmId
LEFT JOIN CDN.DaneKadMod AS a2 ON PRE_ETADkmIdStanowisko = a2.DKM_DkmId
INNER JOIN CDN.RptZaznaczenia2 ON RpZ2_GIDNumer = PRE_PraId
WHERE PRI_Typ = 1
AND RpZ2_GUID = @CDN_GUID
AND PRE_ZatrudnionyDo < CDN.Date(2999,12,31)
AND PRE_ZatrudnionyDo >= @DataOd
AND PRE_ZatrudnionyDo <= @DataDo
AND PRE_DataDo >= @DataOd
ORDER BY PRE_ZatrudnionyDo, PRE_Nazwisko, PRE_Imie1, PRE_Kod
SET NOCOUNT OFF
END
