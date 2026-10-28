create procedure cdn.OAktualizujAtrybutyLista
@AKE_AKEID int, @AKE_ATKID int, @AKE_Wartosc nvarchar(101)
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
 update CDN.OAtrybutyKlasyElem set
  AKE_AtkId = @AKE_ATKID,
  AKE_Wartosc = @AKE_Wartosc
  where AKE_AkeId = @AKE_AKEID
 end try
    begin catch
        set @s = '##OPT32408##%%element%%=OAtrybutyKlasyElem##'
        raiserror(@s, 16, 1)
    end catch
end
