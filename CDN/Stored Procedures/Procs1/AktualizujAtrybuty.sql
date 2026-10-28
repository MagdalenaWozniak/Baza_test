create procedure cdn.AktualizujAtrybuty
@AtrybutID int
as
begin
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
 declare @min datetime
 declare @max datetime
 set @min = (select min(ATH_DataOd) from cdn.OAtrybutyHist where ATH_OatId = @AtrybutID)
 set @max = (select max(ATH_DataDo) from cdn.OAtrybutyHist where ATH_OatId = @AtrybutID)
 update cdn.OAtrybuty
 set OAT_OkresOd = @min, OAT_OkresDo  = @max where OAT_OatId = @AtrybutID
set nocount off
end
