create procedure cdn.OAktualizujAtrybuty
@AtrybutID int, @PrcID int, @AtkID int, @Wartosc nvarchar(101), @NazwaKlasy nvarchar(101)
as
begin
 declare @s nvarchar(128)
if exists (select * from sysobjects where name = 'Synch2015 ' And xtype = 'p')
 begin
 declare @set int
 exec cdn.Synch2015 @pWynik = @set OUTPUT
 if @set = 1
  return
 end
else
 return
 begin try
 update CDN.OAtrybuty set
  OAT_PrcId = @PrcID,
  OAT_AtkId = @AtkID,
  OAT_Wartosc = '',
  OAT_NazwaKlasy = @NazwaKlasy
  where OAT_OatId = @AtrybutID
 end try
    begin catch
        set @s = '##OPT32402##'
        raiserror(@s, 16, 1)
    end catch
end
