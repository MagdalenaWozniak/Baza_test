create procedure cdn.Altum_DodajAtrybutElem
@AtkSynchId nvarchar(36),
@Wartosc nvarchar(101),
@Throw nvarchar(256) output
 as
 set nocount on
  set @Throw = ''
  begin try
   declare @AtkId int
   set @AtkId = (select ATK_AtkId from cdn.OAtrybutyKlasy where ATK_ImportRowId = @AtkSynchId)
     insert into CDN.OAtrybutyKlasyElem
     (AKE_AtkId,AKE_Wartosc)
     values
     (@AtkId,@Wartosc)
  end try
  begin catch
   set @Throw = '##OPT34231##'
  end catch
 set nocount off
