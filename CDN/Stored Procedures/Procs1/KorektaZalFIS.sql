--/////////////////////////////////////////////////////////////////////////////////////////////////////
create procedure CDN.KorektaZalFIS
as
set nocount on
 if exists (select * from sysobjects where name = 'KOREKTA_X_ZAL_Y_FIS_Z_FINAL' and xtype = 'u')
  drop table KOREKTA_X_ZAL_Y_FIS_Z_FINAL
 declare @Wyplata int
 declare WYPLATY cursor local fast_forward for
  select wpl_wplid from cdn.wyplaty as tempwyplaty join cdn.prackod on wpl_praid = pra_praid
   where (wpl_tryb = 0 or wpl_tryb = 3) and 0 <
    (select count(wpe_wpeid) from cdn.wypelementy join cdn.typwyplata on wpe_twpid = twp_twpid join cdn.pozdeklpit on twp_pdpid = pdp_pdpid
     where wpe_wplid = tempwyplaty.wpl_wplid and pdp_kod like '0' and wpe_zalfis > 0)
  open WYPLATY
   while (1=1)
    begin
     fetch next from WYPLATY into @Wyplata
     if @@fetch_status <> 0 break
     declare @cSumaZalFIS decimal(14,2)
     declare @iTempID int
     select @cSumaZalFIS = sum(WPE_ZalFIS) from cdn.wypelementy join cdn.typwyplata on wpe_twpid = twp_twpid join cdn.pozdeklpit on twp_pdpid = pdp_pdpid
      where wpe_wplid = @Wyplata and pdp_kod like '0' and wpe_zalfis > 0
     select top 1 @iTempID = WPE_WpeId from cdn.wypelementy join cdn.typwyplata on wpe_twpid = twp_twpid join cdn.pozdeklpit on twp_pdpid = pdp_pdpid
      where wpe_wplid = @Wyplata and pdp_kod not like '0' and wpe_zalfis > 0
     if @iTempID > 0
      begin
       update cdn.wypelementy set WPE_ZalFIS = WPE_ZalFIS + @cSumaZalFIS where wpe_wpeid = @iTempID
       update cdn.wypelementy set WPE_ZalFIS = 0 from cdn.wypelementy join cdn.typwyplata on wpe_twpid = twp_twpid join cdn.pozdeklpit on twp_pdpid = pdp_pdpid
        where wpe_wplid = @Wyplata and pdp_kod like '0' and wpe_zalfis > 0
      end
    end
  close WYPLATY
 deallocate WYPLATY
 select distinct pri_imie1 + ' ' + pri_nazwisko + ' [' + pra_kod + ']' as Pracownik, wpl_numerpelny as Wyplata, 'zaliczka podatku bez zmian' as Informacja
  into KOREKTA_X_ZAL_Y_FIS_Z_FINAL
  from cdn.wyplaty as tempwyplaty
   join cdn.prackod on wpl_praid = pra_praid
   join cdn.pracidx on pra_praid = pri_praid
   where (wpl_tryb = 0 or wpl_tryb = 3) and 0 <
    (select count(wpe_wpeid) from cdn.wypelementy join cdn.typwyplata on wpe_twpid = twp_twpid join cdn.pozdeklpit on twp_pdpid = pdp_pdpid
     where wpe_wplid = tempwyplaty.wpl_wplid and pdp_kod like '0' and wpe_zalfis > 0)
   --order by pri_nazwisko, pri_imie1
--/////////////////////////////////////////////////////////////////////////////////////////////////////
