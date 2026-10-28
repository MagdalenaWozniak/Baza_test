create procedure [CDN].OKasujCentrum
@OptimaId int
as
begin try
declare @set int
 exec cdn.SynchStrPodlXL @pWynik = @set OUTPUT
 if @set = 1
  return
declare @s nvarchar(128)
if @OptimaId < 4 raiserror('', 16, 1)
if exists (select pre_preid from cdn.PracEtaty where PRE_CntId = @OptimaId )raiserror('', 16, 1)
delete from cdn.Centra where CNT_CntId = @OptimaId
 --[logowanie]
 declare @obj_name nvarchar(128)
 select @obj_name = CNT_Nazwa from cdn.Centra where CNT_CntId = @OptimaId
 declare @oid int
 set @oid = cdn.GetXLOperatorID()
 if @oid > 0
 begin
  exec CDN.RejestrOperacjiContextInfo @oid
  exec CDN.RejestrOperacjiDodaj 24503, 0, @OptimaId, @obj_name, 3, ''
 end
end try
begin catch
  set @s = '##OPT32407##%%element%%=centrum##'
        raiserror(@s, 16, 1)
end catch
