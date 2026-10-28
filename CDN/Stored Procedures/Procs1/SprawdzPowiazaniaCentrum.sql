create procedure cdn.SprawdzPowiazaniaCentrum @ID int
 as
 set nocount on
  declare @s0 varchar(256)
  declare @s varchar(256)
  select @s0 = cnt_nazwa from cdn.Centra where CNT_CntId = @ID
  if (select count(cnt_cntid) from cdn.Centra where CNT_ParentId = @ID) > 0
  begin
   --set @s = 'Nie można usunąć centrum: ' + @s0 + '. Istnieje powiązanie z centrum podrzędnym. Tabela: cdn.Centra, kolumna: CNT_ParentId.'
   --RAISERROR('##OPT32188##%%msg%%=%s##', 16, 1, @s0)--raiserror(@s, 16, 1) --ERR_SQL_Place_NieMoznaUsunacCentrum1
   exec CDN.RiseOptimaException 32188, 'msg', @s0
   return
  end
  if (select count(pre_preid) from cdn.PracEtaty where PRE_CntId = @ID) > 0
  begin
   --set @s = 'Nie można usunąć centrum: ' + @s0 + '. Istnieje powiązanie z zapisem historycznym pracownika. Tabela: cdn.PracEtaty, kolumna: PRE_CntId.'
   --RAISERROR('##OPT32189##%%msg%%=%s##', 16, 1, @s0)--raiserror(@s, 16, 1) --ERR_SQL_Place_NieMoznaUsunacCentrum2
   exec CDN.RiseOptimaException 32189, 'msg', @s0
   return
  end
  if (select count(pri_priid) from cdn.Pracidx where PRI_CntId = @ID) > 0
  begin
   --set @s = 'Nie można usunąć centrum: ' + @s0 + '. Istnieje powiązanie z pracownikiem. Tabela: cdn.PracIdx, kolumna: PRI_CntId.'
   --RAISERROR('##OPT32190##%%msg%%=%s##', 16, 1, @s0)--raiserror(@s, 16, 1) --ERR_SQL_Place_NieMoznaUsunacCentrum3
   exec CDN.RiseOptimaException 32190, 'msg', @s0
   return
  end
 set nocount off
