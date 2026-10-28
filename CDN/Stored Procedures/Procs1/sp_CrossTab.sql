CREATE PROCEDURE CDN.sp_CrossTab
 @table  AS NVARCHAR(512), --Nazwa tabeli (lub tabel) do raportu
 @where  AS NVARCHAR(512)=NULL, --Warunek WHERE, może być pusty
 @onrows  AS NVARCHAR(128), --Grupowanie na wierszach
 @onrowsalias AS sysname = NULL, --Alias grupowania na wierszach
 @oncols  AS NVARCHAR(128), --Grupowanie na kolumnach
 @oncolsprefix AS NVARCHAR(128)=NULL, --Prefiks nazw kolumn
 @sumcol  AS sysname = NULL --Komórki z danymi
AS
SET NOCOUNT ON
DECLARE @sql    AS NVARCHAR(MAX)
DECLARE @keysql AS NVARCHAR(1000)
DECLARE @key    AS NVARCHAR(100)
CREATE TABLE #keys(keyvalue NVARCHAR(100) NOT NULL PRIMARY KEY)
SET @keysql =
   'INSERT INTO #keys ' +
   'SELECT DISTINCT CAST(' + @oncols + ' AS NVARCHAR(100)) ' +
   'FROM ' + @table +
   CASE WHEN @where IS NOT NULL THEN ' WHERE ' + @where ELSE '' END
EXEC (@keysql)
SET @sql =
   'SELECT ' +
   @onrows +
   CASE WHEN @onrowsalias IS NOT NULL THEN ' AS ' + @onrowsalias ELSE '' END
SELECT @key = MIN(keyvalue) FROM #keys
WHILE @key IS NOT NULL
BEGIN
  SET @sql =
     @sql + ', '                                                                     +
     'SUM(CASE CAST(' + @oncols + ' AS NVARCHAR(100))'                                +
     '     WHEN ''' + @key + ''''                                                    +
     '     THEN ' + CASE WHEN @sumcol IS NULL THEN '1' ELSE @sumcol END + ' ELSE 0'  +
     '     END) AS '''                                                               +
     CASE WHEN ISNUMERIC(@key)=1 THEN ISNULL(@oncolsprefix,'_') + @key ELSE @key END + ''''
  SELECT @key = MIN(keyvalue) FROM #keys WHERE keyvalue > @key
END
SET @sql =
   @sql                                                             +
   ' FROM ' + @table                                             +
   CASE WHEN @where IS NOT NULL THEN ' WHERE ' + @where ELSE '' END +
   ' GROUP BY ' + @onrows                                     +
   ' ORDER BY ' + @onrows
SET NOCOUNT OFF
EXEC (@sql)
