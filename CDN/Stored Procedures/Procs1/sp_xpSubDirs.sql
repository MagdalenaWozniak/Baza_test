CREATE PROCEDURE CDN.sp_xpSubDirs  @Path  NVARCHAR(2048) AS
begin
set nocount on;
create table #SubDirs
(  Directory CHAR(256) )
insert #SubDirs exec  master..xp_SubDirs @Path
select * from #SubDirs
set nocount off;
end
