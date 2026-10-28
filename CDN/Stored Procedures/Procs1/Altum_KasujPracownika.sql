create procedure cdn.Altum_KasujPracownika
 @PracSynchId nvarchar(36), --PRA_ImportRowId --unikalny identyfikator pracownika (GUID)
 @Throw nvarchar(256) output --treść wyjątku
 as
 set nocount on
  set @Throw = ''
  declare @s nvarchar(128)
  set @s = ''
  declare @PraId int, @Nadrzedny tinyint
  set @PraId = 0
  select @PraId = PRA_PraId, @Nadrzedny = PRA_Nadrzedny from cdn.PracKod
   where PRA_ImportRowId = @PracSynchId
  declare @Historia table(ID int, DabId int)
  insert into @Historia (ID, DabId)
   select PRE_PreId, PRE_DabId from cdn.PracEtaty where PRE_PraId = @PraId
  if (select count(WPS_WpsId) from cdn.wypskladniki
    where wps_rodzajzrodla = 1
    and wps_zrodloid in (select ID from @Historia)) > 0
   set @Throw = '##OPT34180##'
  if (select count(SPL_SplId) from CDN.SchematPlatnosci
    where SPL_OdbPodmiotTyp = 3
    and SPL_PodmiotId not in (select ID from @Historia)
    and SPL_OdbPodmiotId in (select ID from @Historia)) > 0
   set @Throw = '##OPT34202##'
  if (select count(dkn_dknid) from cdn.deklnag where dkn_praid = @PraId) > 0
   set @Throw = '##OPT34203##'
  if (select count(wpl_wplid) from cdn.Wyplaty where WPL_PraId = @PraId) >0
   set @Throw = '##OPT34204##'
  if (select count(WyN_WyNId) from CDN.WyplatyNag where WYN_PrcId = @PraId) > 0
   set @Throw = '##OPT34204##'
  if (select count(crk_crkid) from cdn.crmkontakty
    where (crk_podmiottyp = 3 and crk_podid = @PraId) or (crk_opiekuntyp = 3 and crk_opiekunid = @PraId)) > 0
   set @Throw = '##OPT34205##'
  if (select count(wdke_wdkeid) from cdn.wdrkopieelektroniczne where wdke_objsubjecttype = 3 and wdke_objsubjectid = @PraId) > 0
   set @Throw = '##OPT34206##'
  if (select count(src_srcid) from cdn.SrsCzesci where SrC_SerwisantTyp = 3 and SrC_SerwisantId = @PraId) > 0
   set @Throw = '##OPT34207##'
  if (select count(sry_sryid) from cdn.SrsCzynnosci where SrY_SerwisantTyp = 3 and Sry_SerwisantId = @PraId) > 0
   set @Throw = '##OPT34207##'
  if (select count(SrN_SrNId) from CDN.SrsNotatki where SrN_SerwisantTyp in (3, 4) and SrN_SerwisantId = @PraId) > 0
   set @Throw = '##OPT34207##'
  --if (select count(DNV_DoNID) from CDN.DokNagView where DNV_OpiekunTyp in (3, 4) and DNV_OpiekunID = @PraId) > 0
   --set @Throw = 'Nie można usunąć pracownika, który jest opiekunem dokumentu w Bibliotece dokumentów.'
  if (select count(DoP_DoPId) from CDN.DokPodmioty where DoP_PodmiotTyp in (3, 4) and DoP_PodmiotID = @PraId) > 0
   set @Throw = '##OPT34208##'
  if (select count(TrN_TrNId) from CDN.TraNag where TrN_PodmiotTyp in (3, 4) and TrN_PodID = @PraId) > 0
   set @Throw = '##OPT34209##'
  if (select count(TRN_TrnId) from CDN.TraNag where TRN_PodmiotZalTyp in (3, 4) and TRN_PodZalID = @PraId) > 0
   set @Throw = '##OPT34209##'
  if @Nadrzedny > 0
  begin
   if (select count(PRA_PraId) from CDN.PracKod where PRA_ParentId = @PraId) > 0
   set @Throw = '##OPT34210##'
  end
  if (select count(DLN_DlnId) from CDN.DlgNag where DLN_PodmiotTyp = 3 and DLN_PodmiotId = @PraId) > 0
   set @Throw = '##OPT34211##'
  if (select count(cnk_cnkid) from cdn.CentraKierownicy where CNK_PraId = @PraId) > 0
   set @Throw = '##OPT34212##'
  if(len(@Throw) > 1)
   return
  if @PraId > 0
  begin try
   --[logowanie]
   declare @obj_id int
   set @obj_id = (select top 1 ID from @Historia)
   declare @obj_name nvarchar(128)
   select @obj_name = '[' + PRI_Kod + '] ' + PRI_Imie1 + ' ' + PRI_Nazwisko from cdn.PracIdx where PRI_PraId = @PraId and PRI_Typ = 1
   delete from cdn.PracKod
    where PRA_PraId = @PraId
   if (select count(DabId) from @Historia) > 0
    delete from cdn.DaneBinarne
     where DAB_Typ = 8 and DAB_DABID in (select DabId from @Historia)
   --[logowanie]
   declare @oid int
   set @oid = cdn.GetAltumOperatorID()
   if @oid > 0
   begin
    exec CDN.RejestrOperacjiContextInfo @oid
    exec CDN.RejestrOperacjiDodaj 24000, 0, @obj_id, @obj_name, 3, ''
   end
  end try
  begin catch
   set @Throw = '##OPT34218##'
  end catch
  else
  begin
   set @Throw = '##OPT34219##%guid%=' + @PracSynchId +'##'
  end
 set nocount off
