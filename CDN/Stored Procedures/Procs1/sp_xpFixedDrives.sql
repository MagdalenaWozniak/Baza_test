CREATE PROCEDURE CDN.sp_xpFixedDrives  AS
begin
set nocount on;
create table #FixedDrives
(  Drive      NVARCHAR(5),
   MBFree  int
)
insert #fixedDrives exec  master..xp_fixeddrives
select * from #fixeddrives
set nocount off;
end
