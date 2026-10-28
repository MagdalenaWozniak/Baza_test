create procedure cdn.SprawdzPowiazaniaDzialu @ID int
 as
 set nocount on
  declare @s0 varchar(256)
  declare @s varchar(256)
  select @s0 = dzl_nazwa from cdn.Dzialy where DZL_DzlId = @ID
  if (select count(dzl_dzlid) from cdn.Dzialy where DZL_ParentId = @ID) > 0
  begin
   --set @s = 'Nie można usunąć wydziału: ' + @s0 + '. Istnieje powiązanie z wydziałem podrzędnym. Tabela: cdn.Dzialy, kolumna: DZL_ParentId.'
   --RAISERROR('##OPT32173##%%msg%%=%s##', 16, 1, @s0)--raiserror(@s, 16, 1) --ERR_SQL_Place_NieMoznaUsunacWydzialu1
   exec CDN.RiseOptimaException 32173, 'msg', @s0
   return
  end
  if (select count(pre_preid) from cdn.PracEtaty where PRE_DzlId = @ID) > 0
  begin
   --set @s = 'Nie można usunąć wydziału: ' + @s0 + '. Istnieje powiązanie z zapisem historycznym pracownika. Tabela: cdn.PracEtaty, kolumna: PRE_DzlId.'
   --RAISERROR('##OPT32174##%%msg%%=%s##', 16, 1, @s0)--raiserror(@s, 16, 1) --ERR_SQL_Place_NieMoznaUsunacWydzialu2
   exec CDN.RiseOptimaException 32174, 'msg', @s0
   return
  end
  if (select count(pri_priid) from cdn.Pracidx where PRI_DzlId = @ID) > 0
  begin
   --set @s = 'Nie można usunąć wydziału: ' + @s0 + '. Istnieje powiązanie z pracownikiem. Tabela: cdn.PracIdx, kolumna: PRI_DzlId.'
   --RAISERROR('##OPT32175##%%msg%%=%s##', 16, 1, @s0)--raiserror(@s, 16, 1) --ERR_SQL_Place_NieMoznaUsunacWydzialu3
   exec CDN.RiseOptimaException 32175, 'msg', @s0
   return
  end
  if (select count(pgr_pgrid) from cdn.PracPracaDniGodz where PGR_DzlId = @ID) > 0
  begin
   --set @s = 'Nie można usunąć wydziału: ' + @s0 + '. Istnieje powiązanie z czasem pracy pracownika. Tabela: cdn.PracPracaDniGodz, kolumna: PGR_DzlId.'
   --RAISERROR('##OPT32176##%%msg%%=%s##', 16, 1, @s0)--raiserror(@s, 16, 1) --ERR_SQL_Place_NieMoznaUsunacWydzialu4
   exec CDN.RiseOptimaException 32176, 'msg', @s0
   return
  end
  if (select count(pgl_pglid) from cdn.PracPlanDniGodz where PGL_DzlId = @ID) > 0
  begin
   --set @s = 'Nie można usunąć wydziału: ' + @s0 + '. Istnieje powiązanie z planem pracy pracownika. Tabela: cdn.PracPlanDniGodz, kolumna: PGL_DzlId.'
   --RAISERROR('##OPT32177##%%msg%%=%s##', 16, 1, @s0)--raiserror(@s, 16, 1) --ERR_SQL_Place_NieMoznaUsunacWydzialu5
   exec CDN.RiseOptimaException 32177, 'msg', @s0
   return
  end
  if (select count(OPK_OpkId) from cdn.OpisKadry where OPK_DzlId = @ID) > 0
  begin
   --set @s = 'Nie można usunąć wydziału: ' + @s0 + '. Istnieje powiązanie z opisem analitycznym pracownika (kadry). Tabela: cdn.OpisKadry, kolumna: OPK_DzlId.'
   --RAISERROR('##OPT32178##%%msg%%=%s##', 16, 1, @s0)--raiserror(@s, 16, 1) --ERR_SQL_Place_NieMoznaUsunacWydzialu6
   exec CDN.RiseOptimaException 32178, 'msg', @s0
   return
  end
  if (select count(OPP_OppId) from cdn.OpisPlace where OPP_DzlId = @ID) > 0
  begin
   --set @s = 'Nie można usunąć wydziału: ' + @s0 + '. Istnieje powiązanie z opisem analitycznym pracownika (płace). Tabela: cdn.OpisPłace, kolumna: OPP_DzlId.'
   --RAISERROR('##OPT32179##%%msg%%=%s##', 16, 1, @s0)--raiserror(@s, 16, 1) --ERR_SQL_Place_NieMoznaUsunacWydzialu7
   exec CDN.RiseOptimaException 32179, 'msg', @s0
   return
  end
  if (select count(LPL_LplId) from cdn.ListyPlac where LPL_DzlId = @ID) > 0
  begin
   --set @s = 'Nie można usunąć wydziału: ' + @s0 + '. Istnieje powiązanie z listą płac. Tabela: cdn.ListyPlac, kolumna: LPL_DzlId.'
   --RAISERROR('##OPT32180##%%msg%%=%s##', 16, 1, @s0)--raiserror(@s, 16, 1) --ERR_SQL_Place_NieMoznaUsunacWydzialu8
   exec CDN.RiseOptimaException 32180, 'msg', @s0
   return
  end
  if (select count(PZD_PzdId) from cdn.PracZestawElem where PZD_DzlId = @ID) > 0
  begin
   --set @s = 'Nie można usunąć wydziału: ' + @s0 + '. Istnieje powiązanie z zestawieniem czasu pracy pracownika. Tabela: cdn.PracZestawElem, kolumna: PZD_DzlId.'
   --RAISERROR('##OPT32181##%%msg%%=%s##', 16, 1, @s0)--raiserror(@s, 16, 1) --ERR_SQL_Place_NieMoznaUsunacWydzialu9
   exec CDN.RiseOptimaException 32181, 'msg', @s0
   return
  end
 set nocount off
