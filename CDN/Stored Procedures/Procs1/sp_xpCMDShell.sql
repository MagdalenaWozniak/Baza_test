CREATE PROCEDURE CDN.sp_xpCMDShell  @Command NVARCHAR(2048) AS
begin
set nocount on;
create table #CmdShell
(  OutLine CHAR(512) )
insert #CmdShell exec  master..xp_CmdShell @Command
select * from #CmdShell
set nocount off;
end
