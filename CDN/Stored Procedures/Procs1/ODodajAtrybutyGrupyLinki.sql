Create Procedure CDN.ODodajAtrybutyGrupyLinki @IDGrupy int,@IDKlasy int,@Lp int, @NazwaKlasy nvarchar(41)
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
Declare @s nvarchar
BEGIN
 if LEN(@NazwaKlasy) > 0
     INSERT INTO [CDN].[OAtrybutyGrupyLinki]
           (AGL_AtgId
           ,AGL_AtkId
           ,AGL_Lp
           ,AGL_NazwaKlasy)
     VALUES
           (@IDGrupy
           ,@IDKlasy
           ,@Lp
           ,@NazwaKlasy)
if @@error<>0 and @@trancount<>0
 Begin
    rollback tran
    set @s = '##OPT32381##%%gdzie%%=[OAtrybutyGrupyLinki]##'
    raiserror(@s, 16, 1)
 End
END
