CREATE PROCEDURE CDN.sp_RestoreHeader @BackupFile nvarchar(1024)
AS
set nocount on;
Create table #Header
 (Bname         nvarchar(128),
  BDesc         nvarchar(255),
  Btype         smallint,
  ExpDate       datetime,
  Compressed  tinyint,
  Pos   smallint,
  DevType  tinyint,
  UserName  nvarchar(128),
  Server  nvarchar(128),
  DBName  nvarchar(128),
  DBVer  int,
  DBCreateDate  datetime,
  BKPSize  numeric(20,0),
  FLSN   numeric(25,0),
  LLSN   numeric(25,0),
  ChckLSN  numeric(25,0),
  DBBckpLSN  numeric(25,0),
  BstartDate  datetime,
  BFinishDate  datetime,
  SortOrder  smallint,
  CodePage  smallint,
  UNILocale  int,
  UniComp  int,
  Compatilibity tinyint,
  SoftVId  int,
  SoftVerMaj  int,
  SoftVerMin  int,
  SoftVerBuild  int,
  MachineName  nvarchar(128)
  )
INSERT #Header
exec master..sp_executesql @BackupFile
select DBName , Convert(NVARCHAR(20),BstartDate,120) as BData from #Header
set nocount off;
