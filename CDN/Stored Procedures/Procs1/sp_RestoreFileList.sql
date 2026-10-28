CREATE PROCEDURE CDN.sp_RestoreFileList @BackupFile nvarchar(1024)
AS
set nocount on;
Create table #FileList
 (LogicalName         nvarchar(128),
  PhysicalName       nvarchar(260),
  Type                      char(1),
  FileGroup               nvarchar(128),
  FSize                      numeric(20,0),
  FMaxSize                numeric(20,0)
  )
INSERT #FileList
exec master..sp_executesql @BackupFile
select LogicalName, PhysicalName from #FileList
set nocount off;
