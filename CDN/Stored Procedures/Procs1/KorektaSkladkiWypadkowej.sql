--/////////////////////////////////////////////////////////////////////////////////////////////////////
create procedure CDN.KorektaSkladkiWypadkowej @Rok int, @Miesiac smallint, @Procent decimal(14,2)
as
set nocount on
 --tymczasowa zmienna tabelaryczna
 declare @KXSYWZ table (SkladkaWypad decimal(14,2), Podstawa decimal(14,2), Tyub int, ElementId int, WyplataId int, PracownikId int)
 --załadowanie pracowników z zaksięgowanymi wypłatami za podany okres -> w tych wypłatach nie zmieniamy składki
 if exists (select * from sysobjects where name = 'KOREKTA_X_SKLADKI_Y_WYPADKOWEJ_Z_FINAL' and xtype = 'u')
  drop table KOREKTA_X_SKLADKI_Y_WYPADKOWEJ_Z_FINAL
 select pri_imie1 + ' ' + pri_nazwisko + ' [' + pra_kod + ']' as Pracownik, wpl_numerpelny as Wyplata, 'nie dokonano korekty: wypłata zaksięgowana' as Informacja
  into KOREKTA_X_SKLADKI_Y_WYPADKOWEJ_Z_FINAL
  from cdn.wyplaty
   join cdn.prackod on wpl_praid = pra_praid
   join cdn.pracidx on pra_praid = pri_praid
   join cdn.listyplac on wpl_lplid = lpl_lplid
  where lpl_kategoria <> 8 and pri_typ = 1 and (wpl_rok = @Rok and wpl_miesiac = @Miesiac)
      and (lpl_dekid is not null or lpl_kprid is not null or lpl_zaksiegowana <> 0) and wpl_tryb not in (1, 2) and WPL_Archiwalna = 0
    order by pri_nazwisko, pri_imie1
 --kursor po wypłatach z danego miesiąca deklaracji (tylko niezaksięgowanych)
 declare @Wyplata int
 declare WYPLATY cursor local fast_forward for
  select wpl_wplid from cdn.wyplaty join cdn.listyplac on wpl_lplid = lpl_lplid
   where lpl_kategoria <> 8 and wpl_rok = @Rok and wpl_miesiac = @Miesiac
    and lpl_dekid is null and lpl_kprid is null and lpl_zaksiegowana = 0
    and wpl_tryb not in (1, 2)
    and WPL_Archiwalna = 0
  open WYPLATY
   while (1=1)
    begin --1
     fetch next from WYPLATY into @Wyplata
     if @@fetch_status <> 0 break
     --wpisanie składki wypadkowej do tymczasowej tabeli z danej wypłaty, pogrupowanej wg tytułów ubezpieczenia
     declare @SaNieZerowePodstW int
     select @SaNieZerowePodstW = count(WPE_PodstWypad)
      from cdn.wypelementy
      where wpe_wplid = @Wyplata and WPE_PodstWypad > 0
     if @SaNieZerowePodstW > 0
     begin
      insert into @KXSYWZ
       select sum(wpe_sklwypadfirma) as SkladkaWypad, sum(wpe_podstwypad) as Podstawa, max(wpe_tyub) as Tyub, min(wpe_wpeid) as ElementId,
         max(wpe_wplid) as WyplataId, max(wpe_praid) as PracownikId
        from cdn.wypelementy
        where wpe_wplid = @Wyplata and WPE_PodstWypad <> 0
        group by wpe_tyub
     end
     else
     begin
      insert into @KXSYWZ
       select sum(wpe_sklwypadfirma) as SkladkaWypad, sum(wpe_podstwypad) as Podstawa, max(wpe_tyub) as Tyub, min(wpe_wpeid) as ElementId,
         max(wpe_wplid) as WyplataId, max(wpe_praid) as PracownikId
        from cdn.wypelementy
        where wpe_wplid = @Wyplata
        group by wpe_tyub
     end
     declare
      @Skladka decimal(14,2), @Podstawa decimal(14,2), @Tyub int, @Element int, @Parent int, @Pracownik int, @Skorygowano int
     set @Skorygowano = 0
     --kursor po elementach tabeli tymczasowej
     declare ELEMENTY cursor local fast_forward for
      select SkladkaWypad, Podstawa, Tyub, ElementId, WyplataId, PracownikId
       from @KXSYWZ
      open ELEMENTY
      while (1=1)
       begin --2
        fetch next from ELEMENTY into @Skladka, @Podstawa, @Tyub, @Element, @Parent, @Pracownik
        if @@fetch_status <> 0 break
        declare @NowaSkladka decimal(14,2), @Roznica decimal(14,2)
        --obliczenie składki wypadkowej dla kolejnego elementu
        set @NowaSkladka = @Podstawa * (@Procent / 100)
        set @Roznica = @NowaSkladka - @Skladka
 --select @NowaSkladka as 'NS', @Skladka as 'SS', @Podstawa as 'Podst', @Roznica as 'roznica'
        --jeśli nowa składka jest większa od starej, to zwiększamy składkę w danym elemencie
        if (@Roznica > 0)
         begin --3
          update cdn.wypelementy set wpe_sklwypadfirma = (wpe_sklwypadfirma + @Roznica)
           where wpe_wpeid = @Element
          set @Roznica = 0
          set @Skorygowano = 1
         end --3
        --jeśli nowa składka jest mniejsza od starej to tworzymy kursor elementów danej wypłaty
        --i zerujemy składkę dla każdego elementu dopóki nie zejdziemy z różnicy do zera
        else if (@Roznica < 0)
         begin --4
          update cdn.wypelementy set wpe_sklwypadfirma = (wpe_sklwypadfirma + @Roznica)
           where wpe_wpeid = @Element
          set @Roznica = 0
          set @Skorygowano = 1
         end --4
       end --2
      close ELEMENTY
     deallocate ELEMENTY
     delete from @KXSYWZ
      where WyplataId = @Wyplata
    end --1
  close WYPLATY
 deallocate WYPLATY
--/////////////////////////////////////////////////////////////////////////////////////////////////////
 declare @TEMPALLPAYS0 table (SkladkaWypad decimal(14,2), Podstawa decimal(14,2), Tyub int, PracownikId int, NadrzednyId int)
 insert into @TEMPALLPAYS0
  select wpe_sklwypadfirma as SkladkaWypad, wpe_podstwypad as Podstawa, wpe_tyub as Tyub, wpe_praid as PracownikId,
    pra_parentid = (case isnull(pra_parentid, 0) when 0 then pra_praid else pra_parentid end)
     from cdn.wypelementy join cdn.wyplaty on wpe_wplid = wpl_wplid join cdn.listyplac on wpl_lplid = lpl_lplid join cdn.prackod on wpl_praid = pra_praid
   where lpl_kategoria <> 8 and wpl_rok = @Rok and wpl_miesiac = @Miesiac and wpl_tryb not in (1, 2)
  select wpe_sklwypadfirma as SkladkaWypad, wpe_podstwypad as Podstawa, wpe_tyub as Tyub, wpe_praid as PracownikId,
   pra_parentid = (case isnull(pra_parentid, 0) when 0 then pra_praid else pra_parentid end)
     from cdn.wypelementy join cdn.wyplaty on wpe_wplid = wpl_wplid join cdn.listyplac on wpl_lplid = lpl_lplid join cdn.prackod on wpl_praid = pra_praid
   where lpl_kategoria <> 8 and wpl_rok = @Rok and wpl_miesiac = @Miesiac and wpl_tryb not in (1, 2)
 declare @TEMPALLPAYS table (SkladkaWypad decimal(14,2), Podstawa decimal(14,2), Tyub int, PracownikId int, NadrzednyId int)
 insert into @TEMPALLPAYS
  select sum(SkladkaWypad), sum(Podstawa), max(Tyub), max(PracownikId), NadrzednyId
     from @TEMPALLPAYS0
  group by NadrzednyId, Tyub
 --sprawdzenie zgodności składki w obrębie wszystkich wypłat
 declare
  @SkladkaWypadkowa decimal(14,2), @PodstawaWypadkowa decimal(14,2), @TytulUbezp int, @IdPracownik int, @Nadrzedny int
 --kursor po wypłatach pracowników zsumowanych dla konkretnego tytułu ubezpieczenia
 declare WYPLATY_FINAL cursor local fast_forward for
  select sum(SkladkaWypad), sum(Podstawa), max(Tyub), max(PracownikId), NadrzednyId from @TEMPALLPAYS group by NadrzednyId
  open WYPLATY_FINAL
   while (1=1)
    begin --6
     fetch next from WYPLATY_FINAL into @SkladkaWypadkowa, @PodstawaWypadkowa, @TytulUbezp, @IdPracownik, @Nadrzedny
     if @@fetch_status <> 0 break
     declare
      @SkladkaWypadkowaTemp decimal(14,2), @RoznicaTemp decimal(14,2)
     --wyliczenie globalnej składki dla danego tytułu ubezpieczenia
     set @SkladkaWypadkowaTemp = @PodstawaWypadkowa * (@Procent / 100)
     --wyliczenie różnicy
     set @RoznicaTemp = abs(@SkladkaWypadkowaTemp - @SkladkaWypadkowa)
     if @RoznicaTemp <> 0
      begin --7
      declare @MaxElement int
      if 0 < (
        select max(wpe_wpeid)
        from cdn.wypelementy join cdn.wyplaty on wpe_wplid = wpl_wplid join cdn.listyplac on wpl_lplid = lpl_lplid
        where lpl_kategoria <> 8 and lpl_dekid is null and lpl_kprid is null and lpl_zaksiegowana = 0
         and wpl_rok = @Rok and wpl_miesiac = @Miesiac
         and (wpe_praid = @IdPracownik or wpe_praid = @Nadrzedny) and wpe_tyub = @TytulUbezp
         and wpl_tryb not in (1, 2)
         and WPL_Archiwalna = 0
        )
       begin --8
        select @MaxElement = (max(wpe_wpeid))
         from cdn.wypelementy join cdn.wyplaty on wpe_wplid = wpl_wplid join cdn.listyplac on wpl_lplid = lpl_lplid
         where lpl_kategoria <> 8 and wpl_rok = @Rok and wpl_miesiac = @Miesiac
          and lpl_dekid is null and lpl_kprid is null and lpl_zaksiegowana = 0
          and (wpe_praid = @IdPracownik or wpe_praid = @Nadrzedny) and wpe_tyub = @TytulUbezp and wpl_tryb not in (1, 2) and WPL_Archiwalna = 0
        if (@SkladkaWypadkowa < @SkladkaWypadkowaTemp)
         begin --9
          update cdn.wypelementy
           set wpe_sklwypadfirma = wpe_sklwypadfirma + @RoznicaTemp
           where wpe_wpeid = @MaxElement
         end --9
        else
         begin --10
          declare
           @Skladka3 decimal(14,2), @Element3 int
          --kursor po elementach danej wypłaty dla konkretnego pracownika i tytułu ubezpieczenia
          declare ELEMENTY3 cursor local fast_forward for
           select wpe_sklwypadfirma, wpe_wpeid
            from cdn.wypelementy join cdn.wyplaty on wpe_wplid = wpl_wplid join cdn.listyplac on wpl_lplid = lpl_lplid
            where lpl_kategoria <> 8 and
             lpl_dekid is null and lpl_kprid is null and lpl_zaksiegowana = 0
             and wpl_rok = @Rok and wpl_miesiac = @Miesiac
             and (wpe_praid = @IdPracownik or wpe_praid = @Nadrzedny) and wpe_tyub = @TytulUbezp
                      and wpl_tryb not in (1, 2)
                      and WPL_Archiwalna = 0
           open ELEMENTY3
            while (1=1)
             begin --11
              fetch next from ELEMENTY3 into @Skladka3, @Element3
              if @@fetch_status <> 0 break
              if (@Skladka3 < @RoznicaTemp)
               begin --12
                update cdn.wypelementy set wpe_sklwypadfirma = 0
                 where wpe_wpeid = @Element3
                set @RoznicaTemp = @RoznicaTemp - @Skladka3
               end --12
              else
               begin --13
                update cdn.wypelementy set wpe_sklwypadfirma = isnull(@Skladka3,0) - @RoznicaTemp
                 where wpe_wpeid = @Element3
                set @RoznicaTemp = 0
               end --13
            end --11
           close ELEMENTY3
          deallocate ELEMENTY3
          update cdn.wypelementy
           set wpe_sklwypadfirma = wpe_sklwypadfirma - @RoznicaTemp
           where wpe_wpeid = @MaxElement
         end --10
        end --8
      end --7
   end --6
  close WYPLATY_FINAL
 deallocate WYPLATY_FINAL
 delete @TEMPALLPAYS
--/////////////////////////////////////////////////////////////////////////////////////////////////////
