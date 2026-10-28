create procedure cdn.OAktualizujWydzialPracownika
 @OptimaID INT,
 @OptimaIDWydzialu INT
 as
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
  declare @Throw nvarchar(256)
  set @Throw = ''
   begin try
    update cdn.OpisKadry
     set
      OPK_DzlId = @OptimaIDWydzialu
     where
      OPK_PraId = @OptimaID
   end try
   begin catch
    set @Throw = '##OPT32385##'
    raiserror(@Throw, 16, 1)
   end catch
 set nocount off
