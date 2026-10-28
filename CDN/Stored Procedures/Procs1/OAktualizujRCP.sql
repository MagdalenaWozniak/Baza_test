create procedure cdn.OAktualizujRCP
@PKR_PkrID int,
@PKR_PrcID int,
@PKR_Numer nvarchar(20),
@PKR_OkresOd datetime,
@PKR_OkresDo datetime
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
 set @PKR_OkresOd = (SELECT convert(datetime,convert(bigint, @PKR_OkresOd)))
 set  @PKR_OkresDo = (SELECT convert(datetime,convert(bigint, @PKR_OkresDo)))
 update cdn.PracKartyRcp
 set
 PKR_PrcId = @PKR_PrcID,
 PKR_Numer = @PKR_Numer,
 PKR_OkresOd = @PKR_OkresOd,
 PKR_OkresDo = @PKR_OkresDo
 where
  PKR_PkrId = @PKR_PkrID
 end try
    begin catch
        set @s = '##OPT32395##'
        raiserror(@s, 16, 1)
    end catch
end
