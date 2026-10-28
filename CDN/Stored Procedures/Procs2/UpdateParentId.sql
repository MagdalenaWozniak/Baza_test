create procedure cdn.UpdateParentId @WepId int
as
begin
 declare @RodzajElem int, @WliczMetoda int
 declare @WpeId int, @PraId int, @OkresOd datetime, @OkresDo datetime
 select @WpeId = WEP_WpeId, @PraId = WEP_PraId, @OkresOd = WEP_OkresOd, @OkresDo = WEP_OkresDo from cdn.WypElementyPodstawa where WEP_WepId = @WepId
 declare @pracarodzic int
 select @pracarodzic = WPS_PracaRodzic from cdn.WypSkladniki join cdn.WypElementy on WPS_WpeId = WPE_WpeId where WPE_WpeId = @WpeId
 declare @ParentId int
 select @ParentId = cdn.ParentPodstawaLog(@PraId, @OkresOd, @OkresDo, @WepId, @pracarodzic)
 if @ParentId > 0
 begin
  update cdn.WypElementyPodstawa
   set WEP_ParentId = @ParentId
   where WEP_WepId = @WepId
 end
end
