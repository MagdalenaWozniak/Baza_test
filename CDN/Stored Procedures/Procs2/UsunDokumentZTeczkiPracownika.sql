create procedure cdn.UsunDokumentZTeczkiPracownika @ptdId int
as
begin
 if @ptdId > 0
 begin
  declare @prtId int
  select @prtId = PTD_PrtId from cdn.PracTeczkiDokumenty where PTD_PtdId = @ptdId
  if exists (select * from cdn.DaneBinarne where DAB_Typ = 20 and DAB_TwAID in (select PTD_PtdId from cdn.PracTeczkiDokumenty where PTD_PrtId = @prtId))
   delete from cdn.DaneBinarne where DAB_Typ = 20 and DAB_TwAID in (select PTD_PtdId from cdn.PracTeczkiDokumenty where PTD_PrtId = @prtId)
  delete from cdn.PracTeczki
   where PRT_PrtId = @prtId
 end
end
--////////////////////////////////////////////////////////////////////////////////////////////////////////
