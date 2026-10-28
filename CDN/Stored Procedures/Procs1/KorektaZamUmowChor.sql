create procedure cdn.KorektaZamUmowChor @Data datetime
 as
 set nocount on
  declare
   @UmowaId int,
   @PraId int
  declare @KXZUCYZZ table (Pracownik NVARCHAR(128), NumerPelnyUmowy NVARCHAR(64), Informacja NVARCHAR(64))
  declare ZAMUMOWCHOR_UMOWY cursor local fast_forward
   for
    select umw_umwid, umw_praid
     from
      cdn.umowy
     where umw_datado >= convert(datetime, '2999-12-31', 120)
      and (umw_splacona = 1 or (umw_splacona = 2 and umw_brutto <= umw_splacono))
      and @Data >=
      (
       select max(lpl_datadok)
        from cdn.wypskladniki
         join cdn.wyplaty on wpl_wplid = wps_wplid
         join cdn.listyplac on lpl_lplid = wpl_lplid
        where wps_rodzajzrodla = 8 and wps_zrodloid = umw_umwid
      )
   open ZAMUMOWCHOR_UMOWY
    while (1=1)
     begin
      fetch next from ZAMUMOWCHOR_UMOWY into @UmowaId, @PraId
      if @@fetch_status <> 0 break
      declare @MaxDataDok datetime
      select @MaxDataDok = max(lpl_datado)
       from cdn.listyplac
        join cdn.wyplaty on lpl_lplid = wpl_lplid
        join cdn.wypskladniki on wpl_wplid = wps_wplid
       where wps_rodzajzrodla = 8 and wps_zrodloid = @UmowaId
      update cdn.umowy
       set umw_datado = @MaxDataDok, umw_wliczchorzakonczona = 1
       where umw_umwid = @UmowaId
      insert into @KXZUCYZZ
       select distinct pri_imie1 + ' ' + pri_nazwisko + ' [' + pra_kod + ']' as Pracownik,
        umw_numerpelny as Umowa, 'skorygowano umowę cywilnoprawną' as Informacja
        from cdn.umowy as tempumowy
         join cdn.prackod on umw_praid = pra_praid
         join cdn.pracidx on pra_praid = pri_praid
        where
         umw_umwid = @UmowaId
     end
   close ZAMUMOWCHOR_UMOWY
  deallocate ZAMUMOWCHOR_UMOWY
 if exists (select * from sysobjects where name = 'KOREKTA_X_ZAMUMOW_Y_CHOR_Z_FINAL' and xtype = 'u')
  drop table KOREKTA_X_ZAMUMOW_Y_CHOR_Z_FINAL
 select Pracownik, NumerPelnyUmowy, Informacja
  into KOREKTA_X_ZAMUMOW_Y_CHOR_Z_FINAL
   from @KXZUCYZZ
 delete from @KXZUCYZZ
 set nocount off
