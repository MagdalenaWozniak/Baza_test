Create Procedure CDN.OAktualizujAtrybutyGrupyLinki @OptimaID int, @AGL_ATGID int, @AGL_ATKID int, @AGL_NazwaKlasy varchar(41)
AS
set nocount on
declare
@s nvarchar
if exists (select * from sysobjects where name = 'Synch2015 ' And xtype = 'p')
 begin
 declare @set int
 exec cdn.Synch2015 @pWynik = @set OUTPUT
 if @set = 1
  return
 end
else
 return
Begin
if LEN(@AGL_NazwaKlasy) > 0
    Begin
      Update CDN.OAtrybutyGrupyLinki
      set
   AGL_AtgId = @AGL_ATGID,
   AGL_AtkId = @AGL_ATKID,
   AGL_NazwaKlasy = @AGL_NazwaKlasy
      where AGL_AglId = @OptimaID
   END
if @@error<>0 and @@trancount<>0
    begin
        rollback tran
        set @s = '##OPT32408##%%element%%=OKasujAtrybutyGrupyLinki##'
        raiserror(@s, 16, 1)
    end
End
--go
