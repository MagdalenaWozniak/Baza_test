create procedure cdn.Altum_DodajAtrybutElemWartosci
@AtkSynchId nvarchar(36),
@Values nvarchar(max),
@Throw nvarchar(256) output
 as
 set nocount on
  set @Throw = ''
  begin try
   declare @AtkId int
   declare @vals nvarchar(256)
   set @AtkId = (select ATK_AtkId from cdn.OAtrybutyKlasy where ATK_ImportRowId = @AtkSynchId)
  delete from CDN.OAtrybutyKlasyElem where AKE_AtkId = @AtkId
      DECLARE Elementy CURSOR LOCAL FAST_FORWARD
                    FOR select val from CDN.Split(@Values,';');
                OPEN Elementy;
                WHILE 1 = 1
                    BEGIN
                        FETCH NEXT FROM Elementy INTO @vals;
                        IF @@fetch_status <> 0
                            BREAK;
      insert into CDN.OAtrybutyKlasyElem
       (AKE_AtkId,AKE_Wartosc)
       values
       (@AtkId,@vals)
     END
  end try
  begin catch
   set @Throw = '##OPT34231##'
  end catch
 set nocount off
