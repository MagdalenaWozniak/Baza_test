Create Procedure CDN.OKasujAtrybutyGrupyLinki @AGL_ATGID int,@AGL_ATKID int
as
 set nocount on
if exists (select * from sysobjects where name = 'Synch2015 ' And xtype = 'p')
 begin
 declare @set int
 exec cdn.Synch2015 @pWynik = @set OUTPUT
 if @set = 1
  return
 end
else
 return
  declare @TRanWewnetrzna int
  set @TRanWewnetrzna = 0
                               if @@trancount = 0
                               begin
                                               Begin tran
                                               Set @TRanWewnetrzna = 1
                               end
  delete from cdn.[OAtrybutyGrupyLinki] where AGL_AtgId = @AGL_ATGID
           and AGL_AtkId = @AGL_ATKID
  if @@error<>0
   begin
    if @@trancount<>0
     rollback tran
    declare @s nvarchar
    set @s = '##OPT32407##%%element%%=OKasujAtrybutyGrupyLinki##'
    raiserror(@s, 16, 1)
   end
  else
                   begin
                     if @@trancount<>0 and @TRanWewnetrzna = 1
                          commit tran
                end
 set nocount off
