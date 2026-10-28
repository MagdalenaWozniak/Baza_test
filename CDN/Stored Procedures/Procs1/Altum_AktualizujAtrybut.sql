create procedure [CDN].[Altum_AktualizujAtrybut]
@AtrSynchId nvarchar(36),
@PracSynchId nvarchar(36),
@AtkSynchId nvarchar(36),
@DataOd datetime,
@DataDo datetime,
@Wartosc nvarchar(101),
@Throw nvarchar(256) output
as
set nocount on
  set @Throw = ''
  begin try
  declare @PraId int, @AtkId int, @NazwaKlasy nvarchar(101), @OatId int
  set @PraId = (select PRA_PraId from cdn.PracKod where PRA_ImportRowId = @PracSynchId)
  set @AtkId = (select ATK_AtkId from cdn.OAtrybutyKlasy where atk_ImportRowId = @AtkSynchId)
  set @NazwaKlasy = (select ATK_Nazwa from cdn.OAtrybutyKlasy where atk_ImportRowId = @AtkSynchId)
  set @OatId = (select OAT_OatId from cdn.OAtrybuty where OAT_AtkId = @AtkId and OAT_PrcId = @PraId)
  if @DataOd is NULL
  set @DataOd = convert(datetime, '1900-01-01', 120)
  if @DataDo is NULL
  set @DataDo = convert(datetime, '3000-01-01', 120)
  set @DataOd = CAST(FLOOR(CAST(@DataOd AS FLOAT)) AS DATETIME)
  set @DataDo = CAST(FLOOR(CAST(@DataDo AS FLOAT)) AS DATETIME)
  if exists (select ATK_AtkId from cdn.OAtrybutyKlasy where ATK_AtkId = @AtkId and ATK_Typ = 1)
  begin
  if @Wartosc = 'TRUE'
   set @Wartosc = 'Tak'
  else if @Wartosc = 'FALSE'
   set @Wartosc = 'Nie'
  end
update CDN.OAtrybutyHist
  set
   ATH_Wartosc = @Wartosc,
   ATH_DataOd = @DataOd,
   ATH_DataDo = @DataDo
  where
   ATH_ImportRowId = @AtrSynchId
  exec cdn.AktualizujAtrybuty @OatId
 --[logowanie]
 declare @obj_name nvarchar(128)
 declare @prc_id int
 select @prc_id = OAT_PrcId from cdn.OAtrybuty where OAT_OatId = @OatId
 select @obj_name = '[' + PRI_Kod + '] ' + PRI_Imie1 + ' ' + PRI_Nazwisko from cdn.PracIdx where PRI_PraId = @prc_id and PRI_Typ = 1
 declare @oid int
 set @oid = cdn.GetAltumOperatorID()
 if @oid > 0
 begin
  exec CDN.RejestrOperacjiContextInfo @oid
  exec CDN.RejestrOperacjiDodaj 24206, 0, @OatId, @NazwaKlasy, 2, @obj_name
 end
  end try
  begin catch
   set @Throw = '##OPT32405##'
  end catch
set nocount off
