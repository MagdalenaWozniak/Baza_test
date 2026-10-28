create procedure cdn.KorektaPrzychod50 @Rok int, @Miesiac int
 as
 set nocount on
  declare
   @WyplataId int,
   @PraId int
  declare @KXP50YZZ table (Pracownik NVARCHAR(128), NumerPelnyWyplaty NVARCHAR(64), Informacja NVARCHAR(64))
  declare PRZYCHOD50_WYPLATY cursor local fast_forward
   for
    select wpl_wplid, wpl_praid
     from
      cdn.wyplaty
     where
      wpl_tryb in (0, 3)
      and wpl_rok = @Rok and wpl_miesiac = @Miesiac
   open PRZYCHOD50_WYPLATY
    while (1=1)
     begin
       fetch next from PRZYCHOD50_WYPLATY into @WyplataId, @PraId
       if @@fetch_status <> 0 break
       declare
        @ProcKosztyUzysk decimal(14,2),
        @DataAkt datetime,
        @Dzien int
       if @Miesiac in (1,3,5,7,8,10,12)
        set @Dzien = 31
       else
        set @Dzien = 30
       if @Miesiac = 2
        set @Dzien = 28
       set @DataAkt = convert(datetime, convert(varchar,@Miesiac) + '-' + convert(varchar,@Dzien) + '-' + convert(varchar,@Rok), 120)
       select top 1 @ProcKosztyUzysk = PRE_PODProcKosztyUzysk
        from cdn.PracEtaty
        where PRE_PraId = @PraId and (PRE_DataOd <= @DataAkt and PRE_DataDo >= @DataAkt)
       declare @ElementyDoKorekty tinyint
       set @ElementyDoKorekty = 0
       /*select @ElementyDoKorekty = COUNT(wpe_wpeid)
        from cdn.WypElementy join cdn.TypWyplata on WPE_TwpId = TWP_TwpId join cdn.wyplaty on wpe_wplid = wpl_wplid
        where
         wpe_wplid = @WyplataId and wpl_tryb in (0,3)
         and (TWP_Standardowy in (1,2) or (TWP_Koszty = 3 and TWP_PdpId = 21))*/
       update cdn.wypelementy
        set WPE_Przychod50 = WPE_Wartosc * @ProcKosztyUzysk / 100, @ElementyDoKorekty = @ProcKosztyUzysk
        from cdn.WypElementy join cdn.TypWyplata on WPE_TwpId = TWP_TwpId join cdn.wyplaty on wpe_wplid = wpl_wplid
        where
         wpe_wplid = @WyplataId and wpl_tryb in (0,3)
         and TWP_Standardowy in (1,2)
       update cdn.wypelementy
        set WPE_Przychod50 = WPE_Wartosc * TWP_KosztyProc / 100, @ElementyDoKorekty = TWP_KosztyProc
        from cdn.WypElementy join cdn.TypWyplata on WPE_TwpId = TWP_TwpId join cdn.wyplaty on wpe_wplid = wpl_wplid
        where
         wpe_wplid = @WyplataId and wpl_tryb in (0,3)
         and TWP_Koszty = 3
         and TWP_PdpId = 21 --PIT4.1
       if @ElementyDoKorekty > 0
        insert into @KXP50YZZ
        select distinct pri_imie1 + ' ' + pri_nazwisko + ' [' + pra_kod + ']' as Pracownik, wpl_numerpelny as Wyplata, 'skorygowano przychód 50% kosztów' as Informacja
           from cdn.wyplaty as tempwyplaty
           join cdn.prackod on wpl_praid = pra_praid
           join cdn.pracidx on pra_praid = pri_praid
           where
           wpl_wplid = @WyplataId
     end
   close PRZYCHOD50_WYPLATY
  deallocate PRZYCHOD50_WYPLATY
 if exists (select * from sysobjects where name = 'KOREKTA_X_PRZYCHOD_Y_50_Z_FINAL' and xtype = 'u')
  drop table KOREKTA_X_PRZYCHOD_Y_50_Z_FINAL
 select Pracownik, NumerPelnyWyplaty, Informacja
 into KOREKTA_X_PRZYCHOD_Y_50_Z_FINAL
     from @KXP50YZZ
 delete from @KXP50YZZ
 set nocount off
