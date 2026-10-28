create function [CDN].[OperatorzyDzialy] ()
returns @data table
(
 OpeId int, DzlId int, PracView int, WyplatyView int, DeklaracjeView int
)
as
begin
 declare @OpeId int
 declare OPERATORZY cursor local fast_forward for
  select Ope_OpeId from OperatorzyView
  open OPERATORZY
   while (1=1)
   begin
    fetch next from OPERATORZY into @OpeId
    if @@fetch_status <> 0 break
    insert into @data select @OpeId, DZL_DzlId, null, null, null from cdn.dzialy where DZL_DzlId > 2
   end
  close OPERATORZY
 deallocate OPERATORZY
 update @data set PracView = 1 where exists (select * from cdn.DzialZakazy where DZA_OpeId = OpeId and DZA_DzlId = DzlId and DZA_PracView = 1)
 update @data set WyplatyView = 1 where exists (select * from cdn.DzialZakazy where DZA_OpeId = OpeId and DZA_DzlId = DzlId and DZA_WyplatyView = 1)
 update @data set DeklaracjeView = 1 where exists (select * from cdn.DzialZakazy where DZA_OpeId = OpeId and DZA_DzlId = DzlId and DZA_DeklaracjeView = 1)
 return
end
