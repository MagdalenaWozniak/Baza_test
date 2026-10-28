CREATE Procedure [CDN].[Mobile_EksportStawkiVat]
AS
SET NOCOUNT ON
DECLARE
 @Stawka decimal(5, 2) ,
 @Flaga smallint,
    @sqltxt           NVARCHAR (1000),
    @TmpSrvName       SYSNAME,
    @ServerCfgString  NVARCHAR(512),
    @BazaCfgString    NVARCHAR(512),
    @TrN_DataDokChar  NVARCHAR(25)
  SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
  SELECT @ServerCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1001
  SELECT @BazaCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1002
  SELECT @TrN_DataDokChar    = CONVERT(NVARCHAR(25), GETDATE(), 102)
  IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
    SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
  SET @sqltxt = 'EXEC ['
  IF @ServerCfgString <> @TmpSrvName
  SET @sqltxt = @sqltxt + @ServerCfgString +'].['
  SET @sqltxt = @sqltxt + @BazaCfgString+'].CDN.Detal_PobierzStawkiVAT '
EXEC sp_executesql @sqltxt
SET NOCOUNT OFF
