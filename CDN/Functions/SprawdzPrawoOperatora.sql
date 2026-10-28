create function cdn.SprawdzPrawoOperatora (@DZLID int, @Prawo int, @PRAID int, @Data datetime, @OPEID int, @BigPL tinyint)
returns tinyint
 as
 begin
 declare @DZAWyplatyView int
 set @DZAWyplatyView = 0
 if @BigPL <= 0
  return 1
 if @DZLID = 0 and @PRAID = 0
  return 1
 if @Prawo = 6 --rzeWyplatyView
 begin
  select @DZAWyplatyView = DZA_WyplatyView from cdn.dzialzakazy with (updlock)
   where dza_dzlid = @DZLID and dza_opeid = @OPEID and dza_wyplatyview = 1
  if @DZAWyplatyView > 0
   return 0
 end
 if @PRAID > 0
  select @DZLID = PRE_DzlId from cdn.PracEtaty where PRE_PraId = @PRAID and (@Data >= PRE_DataOd and @Data <= PRE_DataDo)
 declare @Zakaz int
 set @Zakaz = 0
 if @Prawo =  1
     select @Zakaz = DZA_Edycja from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  2
     select @Zakaz = DZA_Podglad from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  3
     select @Zakaz = DZA_Usuwanie from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  4
     select @Zakaz = DZA_WyplatyInsDel from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  5
     select @Zakaz = DZA_WyplatyEdit from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  6
     select @Zakaz = DZA_WyplatyView from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  7
     select @Zakaz = DZA_DeklaracjeInsDel from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  8
     select @Zakaz = DZA_DeklaracjeEdit from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  9
     select @Zakaz = DZA_DeklaracjeView from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  10
     select @Zakaz = DZA_PracIns from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  11
     select @Zakaz = DZA_PracDel from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  12
     select @Zakaz = DZA_PracEdit from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  13
     select @Zakaz = DZA_PracView from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  14
     select @Zakaz = DZA_PracEtat from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  15
     select @Zakaz = DZA_PracUmowy from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  16
     select @Zakaz = DZA_PracDodatki from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  17
     select @Zakaz = DZA_RptKadry from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  18
     select @Zakaz = DZA_RptPlace from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  19
     select @Zakaz = DZA_PracPlace from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  20
     select @Zakaz = DZA_PracKadry from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Prawo =  21
     select @Zakaz = DZA_ListyPlac from cdn.dzialzakazy with (updlock) where dza_dzlid = @DZLID and dza_opeid = @OPEID
 if @Zakaz > 0
  return 0
 else
  return 1
 return 0
 end
