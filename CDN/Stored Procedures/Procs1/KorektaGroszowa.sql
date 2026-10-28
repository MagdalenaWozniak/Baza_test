create procedure cdn.KorektaGroszowa
 as
 set nocount on
  declare
   @WyplataId int,
   @SumaZdrow decimal(14, 2),
   @SumaZdrow2 decimal(14, 2),
   @TyUb int
  declare @KXGYZZ table (Pracownik NVARCHAR(128), NumerPelnyWyplaty NVARCHAR(64), Informacja NVARCHAR(64))
  declare GROSZ_WYPLATY cursor local fast_forward
   for
    select wpl_wplid, sum(wpe_sklzdrowsuma), sum(wpe_sklzdrowprac), wpe_tyub
     from
      cdn.wyplaty
      join cdn.wypelementy on wpl_wplid = wpe_wplid
      join cdn.wypskladniki on wpe_wpeid = wps_wpeid
      join cdn.typwyplata on wps_twpid = twp_twpid
     where
      wpl_tryb in (0, 3)
      and twp_sklzdrow = 1
      and (wpe_sklzdrowsuma <> 0 or wpe_sklzdrowprac <> 0)
     group by wpl_wplid, wpe_tyub
   open GROSZ_WYPLATY
    while (1=1)
     begin
       fetch next from GROSZ_WYPLATY into @WyplataId, @SumaZdrow, @SumaZdrow2, @TyUb
       if @@fetch_status <> 0 break
       --sprawdzenie czy istnieją elementy do których można przenieść nadmiarową kwotę składki
       if 0 < (
          select distinct count(wpe_wpeid)
           from
            cdn.wypelementy
             join cdn.wyplaty on wpe_wplid = wpl_wplid
             join cdn.wypskladniki on wpe_wpeid = wps_wpeid
             join cdn.typwyplata on wps_twpid = twp_twpid
           where
            wpl_wplid = @WyplataId
            and wpe_tyub = @TyUb
            and twp_sklzdrow <> 1
         )
       begin
         --wyzerowanie składki w elemencie dla którego nie powinno być kwoty
         update cdn.wypelementy
          set wpe_sklzdrowsuma = 0
          where
           wpe_wplid = @WyplataId
           and wpe_tyub = @TyUb
           and wpe_wpeid in
            (
             select distinct wpe_wpeid
              from
               cdn.wypelementy
                join cdn.wyplaty on wpe_wplid = wpl_wplid
                join cdn.wypskladniki on wpe_wpeid = wps_wpeid
                join cdn.typwyplata on wps_twpid = twp_twpid
              where
               twp_sklzdrow = 1
               and wpe_sklzdrowsuma <> 0
            )
         update cdn.wypelementy
          set wpe_sklzdrowprac = 0
          where
           wpe_wplid = @WyplataId
           and wpe_tyub = @TyUb
           and wpe_wpeid in
            (
             select distinct wpe_wpeid
              from
               cdn.wypelementy
                join cdn.wyplaty on wpe_wplid = wpl_wplid
                join cdn.wypskladniki on wpe_wpeid = wps_wpeid
                join cdn.typwyplata on wps_twpid = twp_twpid
              where
               twp_sklzdrow = 1
               and wpe_sklzdrowprac <> 0
            )
         --dodanie nadmiarowej składki do elementu opodatkowanego zdrowotnym
         update cdn.wypelementy
          set wpe_sklzdrowsuma = wpe_sklzdrowsuma  + @SumaZdrow, wpe_sklzdrowprac = wpe_sklzdrowprac  + @SumaZdrow2
          where
           wpe_wpeid =
            (
             select top 1 wpe_wpeid
              from
               cdn.wypelementy
                join cdn.wyplaty on wpe_wplid = wpl_wplid
                join cdn.wypskladniki on wpe_wpeid = wps_wpeid
                join cdn.typwyplata on wps_twpid = twp_twpid
              where
               wpl_wplid = @WyplataId
               and wpe_tyub = @TyUb
               and twp_sklzdrow <> 1
            )
         insert into @KXGYZZ
         select distinct pri_imie1 + ' ' + pri_nazwisko + ' [' + pra_kod + ']' as Pracownik, wpl_numerpelny as Wyplata, 'skorygowano składkę zdrowotną' as Informacja
            from cdn.wyplaty as tempwyplaty
            join cdn.prackod on wpl_praid = pra_praid
            join cdn.pracidx on pra_praid = pri_praid
           where
            wpl_wplid = @WyplataId
       end
     end
   close GROSZ_WYPLATY
  deallocate GROSZ_WYPLATY
 if exists (select * from sysobjects where name = 'KOREKTA_X_GROSZ_Y_ZDROW_Z_FINAL' and xtype = 'u')
  drop table KOREKTA_X_GROSZ_Y_ZDROW_Z_FINAL
 select Pracownik, NumerPelnyWyplaty, Informacja
 into KOREKTA_X_GROSZ_Y_ZDROW_Z_FINAL
     from @KXGYZZ
 delete from @KXGYZZ
 set nocount off
