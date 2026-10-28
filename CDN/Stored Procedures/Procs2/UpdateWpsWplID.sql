create procedure cdn.UpdateWpsWplID @WplId int
 as
  set nocount on
   update cdn.wypskladniki set wps_wplid = @WplId where wps_wpeid in (select wpe_wpeid from cdn.wypelementy where wpe_wplid = @WplId)
  set nocount off
