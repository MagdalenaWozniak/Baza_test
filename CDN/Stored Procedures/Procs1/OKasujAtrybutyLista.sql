create procedure cdn.OKasujAtrybutyLista
@AKE_AKEID int
as
begin
if exists (select * from sysobjects where name = 'Synch2015 ' And xtype = 'p')
 begin
 declare @set int
 exec cdn.Synch2015 @pWynik = @set OUTPUT
 if @set = 1
  return
 end
else
 return
 declare @s nvarchar(128)
 begin try
  delete cdn.OAtrybutyKlasyElem
   where
   AKE_AkeId = @AKE_AKEID
 end try
    begin catch
        set @s = '##OPT32407##%%element%%=OAtrybutyKlasyElem##'
        raiserror(@s, 16, 1)
    end catch
end
