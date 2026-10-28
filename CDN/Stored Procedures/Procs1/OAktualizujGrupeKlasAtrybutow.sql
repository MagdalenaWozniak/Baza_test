Create Procedure CDN.OAktualizujGrupeKlasAtrybutow @OptimaID int, @Nazwa varchar(41)
AS
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
declare
@s nvarchar
Begin
if LEN(@Nazwa) > 0
    Begin
      Update CDN.OAtrybutyGrupy
      set ATG_Nazwa = @Nazwa
      where ATG_AtgId = @OptimaID
   END
if @@error<>0 and @@trancount<>0
    begin
        rollback tran
        set @s = '##OPT32380##'
        raiserror(@s, 16, 1)
    end
End
