create procedure cdn.SprawdzPowiazaniaProjektu @ID int
 as
 set nocount on
  declare @s0 varchar(256)
  declare @s varchar(256)
  select @s0 = PRJ_nazwa from cdn.DefProjekty where PRJ_PrjId = @ID
  if (select count(PRJ_Prjid) from cdn.DefProjekty where PRJ_ParentId = @ID) > 0
  begin
   --set @s = 'Nie można usunąć projektu: ' + @s0 + '. Istnieje powiązanie z projektem podrzędnym. Tabela: cdn.DefProjekty, kolumna: PRJ_ParentId.'
   --RAISERROR('##OPT32182##%%msg%%=%s##', 16, 1, @s0)--raiserror(@s, 16, 1) --ERR_SQL_Place_NieMoznaUsunacProjektu1
   exec CDN.RiseOptimaException 32182, 'msg', @s0
   return
  end
  if (select count(pgr_pgrid) from cdn.PracPracaDniGodz where PGR_PrjId = @ID) > 0
  begin
   --set @s = 'Nie można usunąć projektu: ' + @s0 + '. Istnieje powiązanie z czasem pracy pracownika. Tabela: cdn.PracPracaDniGodz, kolumna: PGR_PrjId.'
   --RAISERROR('##OPT32183##%%msg%%=%s##', 16, 1, @s0)--raiserror(@s, 16, 1) --ERR_SQL_Place_NieMoznaUsunacProjektu2
   exec CDN.RiseOptimaException 32183, 'msg', @s0
   return
  end
  if (select count(pgl_pglid) from cdn.PracPlanDniGodz where PGL_PrjId = @ID) > 0
  begin
   --set @s = 'Nie można usunąć projektu: ' + @s0 + '. Istnieje powiązanie z planem pracy pracownika. Tabela: cdn.PracPlanDniGodz, kolumna: PGL_PrjId.'
   --RAISERROR('##OPT32184##%%msg%%=%s##', 16, 1, @s0)--raiserror(@s, 16, 1) --ERR_SQL_Place_NieMoznaUsunacProjektu3
   exec CDN.RiseOptimaException 32184, 'msg', @s0
   return
  end
  if (select count(OPK_OpkId) from cdn.OpisKadry where OPK_PrjId = @ID) > 0
  begin
   --set @s = 'Nie można usunąć projektu: ' + @s0 + '. Istnieje powiązanie z opisem analitycznym pracownika (kadry). Tabela: cdn.OpisKadry, kolumna: OPK_PrjId.'
   --RAISERROR('##OPT32185##%%msg%%=%s##', 16, 1, @s0)--raiserror(@s, 16, 1) --ERR_SQL_Place_NieMoznaUsunacProjektu4
   exec CDN.RiseOptimaException 32185, 'msg', @s0
   return
  end
  if (select count(OPP_OppId) from cdn.OpisPlace where OPP_PrjId = @ID) > 0
  begin
   --set @s = 'Nie można usunąć projektu: ' + @s0 + '. Istnieje powiązanie z opisem analitycznym pracownika (płace). Tabela: cdn.OpisPłace, kolumna: OPP_PrjId.'
   --RAISERROR('##OPT32186##%%msg%%=%s##', 16, 1, @s0)--raiserror(@s, 16, 1) --ERR_SQL_Place_NieMoznaUsunacProjektu5
   exec CDN.RiseOptimaException 32186, 'msg', @s0
   return
  end
  if (select count(PZD_PzdId) from cdn.PracZestawElem where PZD_PrjId = @ID) > 0
  begin
   --set @s = 'Nie można usunąć projektu: ' + @s0 + '. Istnieje powiązanie z zestawieniem czasu pracy pracownika. Tabela: cdn.PracZestawElem, kolumna: PZD_PrjId.'
   --RAISERROR('##OPT32187##%%msg%%=%s##', 16, 1, @s0)--raiserror(@s, 16, 1) --ERR_SQL_Place_NieMoznaUsunacProjektu6
   exec CDN.RiseOptimaException 32187, 'msg', @s0
   return
  end
 set nocount off
