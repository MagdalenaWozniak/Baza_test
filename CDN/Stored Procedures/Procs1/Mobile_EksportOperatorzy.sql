CREATE PROCEDURE [CDN].[Mobile_EksportOperatorzy]
  @Kod NVARCHAR(20),
  @BazaString    NVARCHAR(512)
AS
SET NOCOUNT ON
 DECLARE
  @sqltxt           NVARCHAR (1000),
  @TmpSrvName       SYSNAME,
  @ServerCfgString  NVARCHAR(512),
  @BazaCfgString    NVARCHAR(512)
  SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
  SELECT @ServerCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1001
  SELECT @BazaCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1002
  IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
    SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
  SET @sqltxt = 'EXEC ['
  IF @ServerCfgString <> @TmpSrvName
    SET @sqltxt = @sqltxt + @ServerCfgString +'].['
  if @Kod =''
  SET @sqltxt = @sqltxt + @BazaCfgString+'].CDN.Mobile_PobierzOperatorow '''','''''
  else
  SET @sqltxt = @sqltxt + @BazaCfgString+'].CDN.Mobile_PobierzOperatorow ''' + @Kod + ''',' + @BazaString
  EXEC sp_executesql @sqltxt
SET NOCOUNT OFF
