create procedure cdn.ODodajAtrybutyLista
@AKE_ATKID int, @AKE_Wartosc nvarchar(101)
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
  insert into CDN.OAtrybutyKlasyElem
  (AKE_AtkId,AKE_Wartosc)
  values
  (@AKE_ATKID,@AKE_Wartosc)
 end try
    begin catch
        set @s = '##OPT32409##%%element%%=OAtrybutyKlasyElem##'
        raiserror(@s, 16, 1)
    end catch
end
