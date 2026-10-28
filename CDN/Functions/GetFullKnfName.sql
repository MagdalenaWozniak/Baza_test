CREATE FUNCTION CDN.GetFullKnfName()
RETURNS NVARCHAR(512)
AS
BEGIN
 DECLARE
  @TmpSrvName       SYSNAME,
  @ServerCfgString  NVARCHAR(512),
  @BazaCfgString    NVARCHAR(512),
  @FullKnfName  NVARCHAR(512)
  SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
  SELECT @ServerCfgString = sys_wartosc FROM cdn.systemcdn where sys_id = 1001
  SELECT @BazaCfgString   = sys_wartosc FROM cdn.systemcdn where sys_id = 1002
  IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
    SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
   IF @ServerCfgString <> @TmpSrvName
      SET @FullKnfName = '[' +   @ServerCfgString    + '].[' +   @BazaCfgString  + ']'
   ELSE
      SET @FullKnfName = '[' + @BazaCfgString  + ']'
 RETURN @FullKnfName
END
