create procedure cdn.OKasujAtrybuty
@AtrybutID int
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
  delete cdn.OAtrybutyHist
   where
   ATH_OatId = @AtrybutID
  delete cdn.OAtrybuty
   where
    OAT_OatId = @AtrybutID
 end try
    begin catch
        set @s = '##OPT32401##'
        raiserror(@s, 16, 1)
    end catch
end
