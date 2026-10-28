create procedure cdn.OAktualizujAtrybutyHist
@AtrybutHistId int,@PrcID int, @AtkID int,@OatID int, @Wartosc nvarchar(101), @DataOd datetime, @DataDo datetime
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
 declare @s nvarchar(128)
 begin try
set @DataOd = (SELECT convert(datetime,convert(bigint, @DataOd)))
 set  @DataDo = (SELECT convert(datetime,convert(bigint, @DataDo)))
   declare @typKlasy int
 set @typKlasy = (select ATK_Typ from cdn.OAtrybutyKlasy WHERE ATK_AtkId = @AtkID)
 if @typKlasy = 1
 begin
 if @Wartosc = 'TAK'
  set @Wartosc = 'Tak'
 if @Wartosc = 'NIE'
  set @Wartosc = 'Nie'
 end
 update CDN.OAtrybutyHist set
  ATH_PrcId = 0,
  ATH_AtkId = @AtkID,
  ATH_OatId = @OatID,
  ATH_Wartosc = @Wartosc,
  ATH_DataOd = @DataOd,
  ATH_DataDo = @DataDo
  where ATH_AthId = @AtrybutHistId
  exec cdn.AktualizujAtrybuty @OatID
 end try
    begin catch
        set @s = '##OPT32405##'
        raiserror(@s, 16, 1)
    end catch
 set nocount off
end
