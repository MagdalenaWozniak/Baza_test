create procedure CDN.Altum_KasujAtrybut
 @AtrSynchId nvarchar(36), --PRA_ImportRowId --unikalny identyfikator pracownika (GUID)
 @Throw nvarchar(256) output --treść wyjątku
 as
 set nocount on
  set @Throw = ''
  begin try
 declare @AtkId int, @OatId int
 select @AtkId = Ath_Atkid, @OatId = ATH_OatId from cdn.OatrybutyHist where ATH_ImportRowId = @AtrSynchId
  delete from cdn.OAtrybutyHist
     where ATH_ImportRowId = @AtrSynchId
  if not exists (select ATH_AthId from cdn.OAtrybutyHist where ATH_OatId = @OatId)
  begin
  delete from cdn.OAtrybuty
  where OAT_Oatid = @OatId
  --[logowanie]
  declare @prc_id int
  declare @klasa_name nvarchar(128)
  select @prc_id = OAT_PrcId, @klasa_name = OAT_NazwaKlasy from cdn.OAtrybuty where OAT_OatId = @OatId
  declare @obj_name nvarchar
  select @obj_name = '[' + PRI_Kod + '] ' + PRI_Imie1 + ' ' + PRI_Nazwisko from cdn.PracIdx where PRI_PraId = @prc_id and PRI_Typ = 1
  declare @oid int
  set @oid = cdn.GetAltumOperatorID()
  if @oid > 0
  begin
   exec CDN.RejestrOperacjiContextInfo @oid
   exec CDN.RejestrOperacjiDodaj 24206, 0, @OatId, @klasa_name, 3, @obj_name
  end
  end
  else
  exec cdn.AktualizujAtrybuty @OatId
    end try
  begin catch
   set @Throw = '##OPT32401##'
  end catch
set nocount off
