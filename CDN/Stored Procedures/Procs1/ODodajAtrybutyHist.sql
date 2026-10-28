create procedure cdn.ODodajAtrybutyHist
 @PrcID int, @AtkID int,@OatID int, @Wartosc nvarchar(101), @DataOd datetime, @DataDo datetime
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
   declare @typKlasy int
 set @typKlasy = (select ATK_Typ from cdn.OAtrybutyKlasy WHERE ATK_AtkId = @AtkID)
 if @typKlasy = 1
 begin
 if @Wartosc = 'TAK'
  set @Wartosc = 'Tak'
 if @Wartosc = 'NIE'
  set @Wartosc = 'Nie'
 end
 set @DataOd = (SELECT convert(datetime,convert(bigint, @DataOd)))
 set  @DataDo = (SELECT convert(datetime,convert(bigint, @DataDo)))
  insert into CDN.OAtrybutyHist
  (ATH_PrcId,ATH_AtkId,ATH_OatId,ATH_DataOd,ATH_DataDo,ATH_Wartosc)
  values
  (0,@AtkID,@OatID,@DataOd,@DataDo, @Wartosc)
  exec cdn.AktualizujAtrybuty @OatID
 end try
    begin catch
        set @s = '##OPT32403##'
        raiserror(@s, 16, 1)
    end catch
end
