create procedure cdn.ODodajAtrybuty
 @PrcID int, @AtkID int, @Wartosc nvarchar(101), @NazwaKlasy nvarchar(101)
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
 declare @min datetime
 declare @max datetime
 set @min = (select convert(datetime,'1900-01-01',120))
 set @max = (select convert(datetime,'3000-01-01',120))
 begin try
  insert into CDN.OAtrybuty
  (OAT_PrcId,OAT_AtkId,OAT_OkresOd,OAT_OkresDo,OAT_NazwaKlasy,OAT_Wartosc)
  values
  (@PrcID, @AtkID , @min, @max, @NazwaKlasy,'')
 end try
    begin catch
        set @s = '##OPT32403##'
        raiserror(@s, 16, 1)
    end catch
end
