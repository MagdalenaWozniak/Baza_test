CREATE PROCEDURE CDN.GetOpeIntProp @ServerName NVARCHAR(50), @ConfigDBName NVARCHAR(50), @OpeID INT, @retVal INT OUTPUT
AS
BEGIN
 DECLARE @sqltxt NVARCHAR (1000), @TmpSrvName SYSNAME
 SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
 IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
  SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
 SET @sqltxt = 'SELECT Ope_PrawoImportuZapKBOtwRapKB as retVal FROM ['
 IF @ServerName <> @TmpSrvName
  SET @sqltxt = @sqltxt + @TmpSrvName + '].['
 SET @sqltxt = @sqltxt + @ConfigDBName + ']' + '.[CDN].[Operatorzy] WHERE Ope_OpeID = ' + convert(nvarchar(10), @OpeId)
 CREATE TABLE #TmpTable (retVal TINYINT)
 INSERT INTO #TmpTable (retVal)
 EXEC sp_executesql @sqltxt
 SELECT @retVal = retVal FROM #TmpTable
 DROP TABLE #TmpTable
END
