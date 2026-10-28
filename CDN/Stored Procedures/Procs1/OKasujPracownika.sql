create procedure cdn.OKasujPracownika
 @OptimaID int --PRA_ImportRowId --unikalny identyfikator pracownika (GUID)
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
  declare @Throw nvarchar(128)
  set @Throw = ''
  declare @PraId int, @Nadrzedny tinyint
  set @PraId = @OptimaID
  --select @PraId = PRA_PraId, @Nadrzedny = PRA_Nadrzedny from cdn.PracKod
  -- where Pra = @PracSynchId
  declare @Historia table(ID int, DabId int)
  insert into @Historia (ID, DabId)
   select PRE_PreId, PRE_DabId from cdn.PracEtaty where PRE_PraId = @PraId
  if (select count(WPS_WpsId) from cdn.wypskladniki
    where wps_rodzajzrodla = 1
    and wps_zrodloid in (select ID from @Historia)) > 0
   set @Throw = '##OPT24391##'
  if (select count(SPL_SplId) from CDN.SchematPlatnosci
    where SPL_OdbPodmiotTyp = 3
    and SPL_PodmiotId not in (select ID from @Historia)
    and SPL_OdbPodmiotId in (select ID from @Historia)) > 0
   set @Throw = '##OPT24415##'
  if (select count(dkn_dknid) from cdn.deklnag where dkn_praid = @PraId) > 0
   set @Throw = '##OPT24043##'
  if (select count(wpl_wplid) from cdn.Wyplaty where WPL_PraId = @PraId) >0
   set @Throw = '##OPT24028##'
  if (select count(WyN_WyNId) from CDN.WyplatyNag where WYN_PrcId = @PraId) > 0
   set @Throw = '##OPT24028##'
  if (select count(crk_crkid) from cdn.crmkontakty
    where (crk_podmiottyp = 3 and crk_podid = @PraId) or (crk_opiekuntyp = 3 and crk_opiekunid = @PraId)) > 0
   set @Throw = '##OPT24392##'
  if (select count(wdke_wdkeid) from cdn.wdrkopieelektroniczne where wdke_objsubjecttype = 3 and wdke_objsubjectid = @PraId) > 0
   set @Throw = '##OPT24394##'
  if (select count(src_srcid) from cdn.SrsCzesci where SrC_SerwisantTyp = 3 and SrC_SerwisantId = @PraId) > 0
   set @Throw = '##OPT24396##'
  if (select count(sry_sryid) from cdn.SrsCzynnosci where SrY_SerwisantTyp = 3 and Sry_SerwisantId = @PraId) > 0
   set @Throw = '##OPT24396##'
  if (select count(SrN_SrNId) from CDN.SrsNotatki where SrN_SerwisantTyp in (3, 4) and SrN_SerwisantId = @PraId) > 0
   set @Throw = '##OPT24396##'
  --if (select count(DNV_DoNID) from CDN.DokNagView where DNV_OpiekunTyp in (3, 4) and DNV_OpiekunID = @PraId) > 0
   --set @Throw = 'Nie można usunąć pracownika, który jest opiekunem dokumentu w Bibliotece dokumentów.'
  if (select count(DoP_DoPId) from CDN.DokPodmioty where DoP_PodmiotTyp in (3, 4) and DoP_PodmiotID = @PraId) > 0
   set @Throw = '##OPT24400##'
  if (select count(TrN_TrNId) from CDN.TraNag where TrN_PodmiotTyp in (3, 4) and TrN_PodID = @PraId) > 0
   set @Throw = '##OPT24402##'
  if (select count(TRN_TrnId) from CDN.TraNag where TRN_PodmiotZalTyp in (3, 4) and TRN_PodZalID = @PraId) > 0
   set @Throw = '##OPT24402##'
  if @Nadrzedny > 0
  begin
   if (select count(PRA_PraId) from CDN.PracKod where PRA_ParentId = @PraId) > 0
    set @Throw = '##OPT24404##'
  end
  if (select count(DLN_DlnId) from CDN.DlgNag where DLN_PodmiotTyp = 3 and DLN_PodmiotId = @PraId) > 0
   set @Throw = '##OPT24409##'
  if (select count(cnk_cnkid) from cdn.CentraKierownicy where CNK_PraId = @PraId) > 0
   set @Throw = '##OPT24410##'
  if(len(@Throw) > 1)
  begin
   raiserror(@Throw, 16, 1)
   return
  end
  if @PraId > 0
  begin try
   delete from cdn.SchematPlatnosci where spl_podmiotid in (select pre_preid from cdn.PracEtaty where PRE_PraId = @PraId)
   --[logowanie]
   declare @obj_id int
   set @obj_id = (select top 1 ID from @Historia)
   declare @obj_name nvarchar(128)
   select @obj_name = '[' + PRI_Kod + '] ' + PRI_Imie1 + ' ' + PRI_Nazwisko from cdn.PracIdx where PRI_PraId = @PraId and PRI_Typ = 1
   delete from cdn.PracKod
    where PRA_PraId = @PraId
   --[logowanie]
   declare @oid int
   set @oid = cdn.GetXLOperatorID()
   if @oid > 0
   begin
    exec CDN.RejestrOperacjiContextInfo @oid
    exec CDN.RejestrOperacjiDodaj 24100, 0, @obj_id, @obj_name, 3, ''
   end
   if (select count(DabId) from @Historia) > 0
    delete from cdn.DaneBinarne
     where DAB_Typ = 8 and DAB_DABID in (select DabId from @Historia)
  end try
  begin catch
   set @Throw = '##OPT32392##'
  end catch
  else
  begin
   set @Throw = '##OPT32393##'
  end
  if(len(@Throw) > 1)
  begin
   raiserror(@Throw, 16, 1)
  end
 set nocount off
