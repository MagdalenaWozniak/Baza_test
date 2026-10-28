create procedure cdn.OKasujAtrybutyHist
@AtrybutHistID int
as
begin
set nocount on
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
 declare @atrybutId int
 set @atrybutId = (select ATH_OatId  from cdn.OAtrybutyHist where ATH_AthId = @AtrybutHistID)
 begin try
  delete cdn.OAtrybutyHist
   where
   ATH_AthId = @AtrybutHistID
  exec cdn.AktualizujAtrybuty @atrybutId
 end try
    begin catch
        set @s = '##OPT32404##'
        raiserror(@s, 16, 1)
    end catch
set nocount off
end
