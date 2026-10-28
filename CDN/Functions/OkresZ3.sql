create function cdn.OkresZ3(@PraId int, @DataNieobec datetime)
returns @PeriodZ3 table
 (
  OkresPrzed datetime,
  OkresPo datetime,
  Debug nvarchar(128)
 )
as
begin
 declare @OkresPrzed datetime, @OkresPo datetime
 declare @PreId int, @EtatL int, @EtatM int
 declare @PreIdPrev int, @EtatLPrev int, @EtatMPrev int
 declare @DataOdGraniczna datetime, @OkresOd datetime, @ZatrudOd datetime
 set @PreIdPrev = 0
 set @EtatLPrev = 0
 set @EtatMPrev = 0
 --sprawdzanie daty ostatniej zmiany wymiaru etatu i ustawienie DataOdGraniczna
 declare HISTORIA cursor local fast_forward for
   select PRE_PreId, PRE_ETAEtatL, PRE_ETAEtatM, PRE_DataOd, PRE_ZatrudnionyOd
    from cdn.PracEtaty
    where PRE_PraId = @PraId and PRE_DataOd < @DataNieobec
  open HISTORIA
   while (1=1)
   begin
    fetch next from HISTORIA
     into @PreId, @EtatL, @EtatM, @OkresOd, @ZatrudOd
    if @@fetch_status <> 0
     break
    if @PreIdPrev <> 0
    begin
     if (@EtatL <> @EtatLPrev) or (@EtatM <> @EtatMPrev)
     begin
      set @DataOdGraniczna = @OkresOd
      --break --nie możemy za wcześnie kończyć sprawdzanie wymiarów
     end
    end
    set @PreIdPrev = @PreId
    set @EtatLPrev = @EtatL
    set @EtatMPrev = @EtatM
   end
  close HISTORIA
 deallocate HISTORIA
 declare @DataGranicznaRownaZatrudOd tinyint
 set @DataGranicznaRownaZatrudOd = 0
 if @DataOdGraniczna is null
 begin
  set @DataOdGraniczna = @ZatrudOd
  set @DataGranicznaRownaZatrudOd = 1
 end
 --sprawdzenie nieobecności na dzień DataNieobec
 declare @JestNieobecZUS int, @OstatniaNieobecnosc int, @PierwszaNieobecnosc int, @PierwszaNieobecnoscDataOd datetime
 set @JestNieobecZUS = 0
 set @OstatniaNieobecnosc = 0
 set @PierwszaNieobecnosc = 0
 declare @UstawionaPierwszaNieobecnosc tinyint
 set @UstawionaPierwszaNieobecnosc = 0
 --czy jest nieobecność typu ZUS
 select @JestNieobecZUS = PNB_PnbId from cdn.PracNieobec
  join cdn.TypNieobec on PNB_TnbId = TNB_TnbId
  where PNB_PraId = @PraId and TNB_Typ = 8 and (@DataNieobec >= PNB_OkresOd and @DataNieobec <= PNB_OkresDo)
 if @JestNieobecZUS > 0 --w podanym dniu jest faktycznie nieobecność
 begin
  --czy miesiąc z DataNieobec jest zgodny z miesiącem daty zatrudnienia
  if (year(@ZatrudOd) = year(@DataNieobec)) and (month(@ZatrudOd) = month(@DataNieobec))
  begin
   insert into @PeriodZ3 (OkresPrzed, OkresPo, Debug)
    values (cdn.CreateDateFromParts(year(@DataNieobec), month(@DataNieobec), 1), dateadd(day, -1, cdn.CreateDateFromParts(year(@DataNieobec), month(@DataNieobec) + 1, 1)), 10)
   return
  end
  else
  --sprawdzanie nieobecności wstecz co 3 mies.
  begin
   --select @PierwszaNieobecnosc = cdn.OkresZ3PierwszaNieobecnosc(@PraId, 0, @DataOdGraniczna, @DataNieobec)
   select @OstatniaNieobecnosc = cdn.OkresZ3OstatniaNieobecnosc(0, @PraId, @DataOdGraniczna, @DataNieobec)
   --insert into @PeriodZ3 (OkresPrzed, OkresPo, Debug) values (@OkresPrzed, @OkresPo, @OstatniaNieobecnosc)
   if @OstatniaNieobecnosc > 0
    select @PierwszaNieobecnosc = cdn.OkresZ3PierwszaNieobecnosc(@PraId, @OstatniaNieobecnosc, @DataOdGraniczna, null)
   --if @PierwszaNieobecnosc <= 0
   -- set @PierwszaNieobecnosc = @JestNieobecZUS
   if @PierwszaNieobecnosc > 0
   begin
    select @PierwszaNieobecnoscDataOd = PNB_OkresOd from cdn.PracNieobec where PNB_PnbId = @PierwszaNieobecnosc
    set @UstawionaPierwszaNieobecnosc = 1
   end
   declare @ZatrudOdMiesPlus1 datetime
   set @ZatrudOdMiesPlus1 = dateadd(month, 1, @ZatrudOd)
   --jeśli znalazł wcześniejszą nieobecność
   --to podmieniamy główną nieobecność
   if @PierwszaNieobecnosc > 0
    set @DataNieobec = @PierwszaNieobecnoscDataOd
   if (year(@ZatrudOdMiesPlus1) = year(@DataNieobec)) and (month(@ZatrudOdMiesPlus1) = month(@DataNieobec))
   begin
    declare @NastepnyMies tinyint
    set @NastepnyMies = cdn.SprawdzDniPracy(@ZatrudOd, @PraId)
    if(@NastepnyMies > 0)
    begin
     insert into @PeriodZ3 (OkresPrzed, OkresPo, Debug)
      values (cdn.CreateDateFromParts(year(@DataNieobec), month(@DataNieobec), 1), dateadd(day, -1, cdn.CreateDateFromParts(year(@DataNieobec), month(@DataNieobec) + 1, 1)), 20)
     return
    end
   end
   --czy miesiąc z DataNieobec jest zgodny z miesiącem daty zatrudnienia
   if (year(@ZatrudOd) = year(@DataNieobec)) and (month(@ZatrudOd) = month(@DataNieobec))
   begin
    insert into @PeriodZ3 (OkresPrzed, OkresPo, Debug)
     values (cdn.CreateDateFromParts(year(@DataNieobec), month(@DataNieobec), 1), dateadd(day, -1, cdn.CreateDateFromParts(year(@DataNieobec), month(@DataNieobec) + 1, 1)), 30)
    return
   end
  end
 end
 else --nie ma nieobecności typu ZUS na DataNieobec
 begin
  declare @DataZwolnienia datetime
  set @DataZwolnienia = null
  select @DataZwolnienia = max(PRE_ZatrudnionyDo) from cdn.PracEtaty
   where PRE_PraId = @PraId and PRE_ZatrudnionyDo < convert(datetime, '2900-12-31', 120)
    and PRE_DataOd < @DataNieobec and PRE_DataDo > @DataNieobec
  --czy DataNieobec przypada po dacie zwolnienia
  if @DataNieobec > @DataZwolnienia
  begin
   --szukanie ostatniej nieobecności typu ZUS
   select @OstatniaNieobecnosc = cdn.OkresZ3OstatniaNieobecnosc(0, @PraId, @DataOdGraniczna, @DataNieobec)
 --insert into @PeriodZ3 (OkresPrzed, OkresPo, Debug) values (@OkresPrzed, @OkresPo, @OstatniaNieobecnosc)
   if @OstatniaNieobecnosc > 0
   begin
    select @PierwszaNieobecnosc = cdn.OkresZ3OstatniaNieobecnosc(1, @PraId, @DataOdGraniczna, @OstatniaNieobecnosc)
    if @PierwszaNieobecnosc > 0
    begin
     --sprawdzanie nieobecności wstecz co 3 mies.
     select @PierwszaNieobecnosc = cdn.OkresZ3PierwszaNieobecnosc(@PraId, @PierwszaNieobecnosc, @DataOdGraniczna, null)
     if @PierwszaNieobecnosc > 0
      set @UstawionaPierwszaNieobecnosc = 1
    end
    else
     set @PierwszaNieobecnosc = @OstatniaNieobecnosc
   end
   else
    --ostatni dzień m-ca w m-cu daty zwolnienia
    select @PierwszaNieobecnoscDataOd = dateadd(day, -1, cdn.CreateDateFromParts(year(@DataZwolnienia), month(@DataZwolnienia) + 1, 1))
  end
  else --DataNieobec nie przypada po dacie zwolnienia
  begin
   insert into @PeriodZ3 (OkresPrzed, OkresPo, Debug)
    values (null, null, 40)
   return
  end
 end
 declare @PierwszaNieobecRownaDataNieobec tinyint
 set @PierwszaNieobecRownaDataNieobec = 0
 if @UstawionaPierwszaNieobecnosc > 0
 begin
  select @PierwszaNieobecnoscDataOd = PNB_OkresOd from cdn.PracNieobec where PNB_PnbId = @PierwszaNieobecnosc
  --ostatni dzień poprzedniego m-ca
  --if @DataZwolnienia is not null
   --select @PierwszaNieobecnoscDataOd = dateadd(day, -1, cdn.CreateDateFromParts(year(@DataZwolnienia), month(@DataZwolnienia), 1))
 end
 else
 begin
  if @JestNieobecZUS > 0
  begin
   select @PierwszaNieobecnoscDataOd = PNB_OkresOd from cdn.PracNieobec where @DataNieobec >= PNB_OkresOd and @DataNieobec <= PNB_OkresDo
  end
  else
   set @PierwszaNieobecnoscDataOd = @DataNieobec
 --insert into @PeriodZ3 (OkresPrzed, OkresPo, Debug) values (null, null, @PierwszaNieobecnoscDataOd)
  set @UstawionaPierwszaNieobecnosc = 1
  if @PierwszaNieobecnoscDataOd > @DataZwolnienia
   set @PierwszaNieobecRownaDataNieobec = 1
 end
 --ustalenie OkresPrzed na 12 wstecz (albo z danych prac./konf.)
 if @PierwszaNieobecnoscDataOd is not null
 begin
  declare @IleWstecz int, @ChorMiesKorekta tinyint
  set @IleWstecz = 12
  set @ChorMiesKorekta = 0
  --z danych pracownika
  select top 1 @ChorMiesKorekta = PRE_ABSChorMiesKorekta, @IleWstecz = PRE_ABSChor6M from cdn.PracEtaty
   where PRE_PraId = @PraId and PRE_DataDo > convert(datetime, '2990-12-31', 120) and PRE_ABSChorMiesKorekta = 1
  if @ChorMiesKorekta = 0 --z konfiguracji
   select top 1 @IleWstecz = CFW_Wartosc from cdn.CfgKlucze join cdn.CfgWartosci on CFK_CfkId = CFW_CfkId
    where CFK_Nazwa like 'Chor.Mies.PodstZas' order by CFK_OkresDo desc
  set @IleWstecz = @IleWstecz * (-1)
  select @OkresPrzed = dateadd(month, @IleWstecz, cdn.CreateDateFromParts(year(@PierwszaNieobecnoscDataOd), month(@PierwszaNieobecnoscDataOd), 1))
  if @PierwszaNieobecnoscDataOd < @DataOdGraniczna
  begin
   set @OkresPo = @OkresPrzed
   --jeśli data graniczna zaczyna się pierwszego dnia m-ca
   if day(@DataOdGraniczna) = 1
    set @OkresPrzed = @DataOdGraniczna
   --jeśli nie, to pobieramy pierwszy dzień kolejnego m-ca
   else
    set @OkresPrzed = cdn.CreateDateFromParts(year(@DataOdGraniczna), month(@DataOdGraniczna) + 1, 1)
   --sprawdzenie czy OkresPrzed i OkresPo to co najmniej jeden miesiąc
   declare @Mies int
   select @Mies = datediff(month, @OkresPrzed, @OkresPo)
   if @Mies > 0
   begin
    insert into @PeriodZ3 (OkresPrzed, OkresPo, Debug)
     values (@OkresPrzed, @OkresPo, 50)
    return
   end
   else
   begin
    if @PierwszaNieobecnoscDataOd != null
     set @OkresPrzed = @PierwszaNieobecnoscDataOd
    else
    begin
     set @OkresPrzed = cdn.CreateDateFromParts(year(@DataZwolnienia), month(@DataZwolnienia), 1)
     set @OkresPo = dateadd(day, -1, cdn.CreateDateFromParts(year(@DataZwolnienia), month(@DataZwolnienia) + 1, 1))
    end
   end
   insert into @PeriodZ3 (OkresPrzed, OkresPo, Debug)
    values (@OkresPrzed, @OkresPo, 60)
   return
  end
  else
  begin
   set @IleWstecz *= -1
   set @OkresPo = dateadd(month, @IleWstecz, cdn.CreateDateFromParts(year(@OkresPrzed), month(@OkresPrzed), 1) - 1)
   --ograniczamy do daty zatrudnienia i sprawdzamy, czy zatrudnienie było od pierwszych dni roboczych
   set @DataNieobec = @PierwszaNieobecnoscDataOd
   if @OkresPrzed < @ZatrudOd
   begin
    set @OkresPrzed = @ZatrudOd
    set @NastepnyMies = cdn.SprawdzDniPracy(@ZatrudOd, @PraId)
    if(@NastepnyMies > 0)
     set @OkresPrzed = dateadd(month, 1, cdn.CreateDateFromParts(year(@ZatrudOd), month(@ZatrudOd), 1))
    else
     set @OkresPrzed = dateadd(month, 0, cdn.CreateDateFromParts(year(@ZatrudOd), month(@ZatrudOd), 1))
   end
   --czy miesiąc z DataNieobec jest zgodny z miesiącem daty zatrudnienia
   if (year(@ZatrudOd) = year(@DataNieobec)) and (month(@ZatrudOd) = month(@DataNieobec))
   begin
    insert into @PeriodZ3 (OkresPrzed, OkresPo, Debug)
     values (cdn.CreateDateFromParts(year(@DataNieobec), month(@DataNieobec), 1), dateadd(day, -1, cdn.CreateDateFromParts(year(@DataNieobec), month(@DataNieobec) + 1, 1)), 70)
    return
   end
   --sprawdzenie czy OkresPrzed jest po dacie zmiany wymiaru
   if @OkresPrzed < @DataOdGraniczna
   begin
    set @OkresPrzed = @DataOdGraniczna
   end
   --if @PierwszaNieobecRownaDataNieobec > 0
   --begin
    --set @OkresPo = cdn.CreateDateFromParts(year(@DataZwolnienia), month(@DataZwolnienia) + 1, 1) - 1
   --end
   --jeśli data graniczna nie zaczyna się pierwszego dnia m-ca
   if day(@OkresPrzed) > 1
   begin
    if cdn.SprawdzDniPracy(@ZatrudOd, @PraId) > 0
     set @OkresPrzed = cdn.CreateDateFromParts(year(@OkresPrzed), month(@OkresPrzed) + 1, 1)
    else
     set @OkresPrzed = cdn.CreateDateFromParts(year(@OkresPrzed), month(@OkresPrzed), 1)
   end
   declare @m int, @y int
   if @OkresPo < @OkresPrzed or @OkresPo is null
   begin
    set @m = month(@OkresPrzed)
    set @y = year(@OkresPrzed)
    if @m = 12
    begin
     set @m = 0
     set @y += 1
    end
    set @OkresPo = dateadd(month, @IleWstecz, cdn.CreateDateFromParts(@y, @m + 1, 1) - 1)
   end
   --jeśli @OkresPo > @DataNieobec, ograniczamy do miesiąca nieobecności
   if year(@OkresPo) > year(@DataNieobec) or (year(@OkresPo) = year(@DataNieobec) and month(@OkresPo) > month(@DataNieobec))
   begin
    set @m = month(@OkresPrzed)
    set @y = year(@OkresPrzed)
    if @m = 12
    begin
     set @m = 0
     set @y += 1
    end
    set @OkresPo = dateadd(month, 0, cdn.CreateDateFromParts(@y, @m + 1, 1) - 1)
   end
   if day(@DataOdGraniczna) > 1
   begin
    if @DataNieobec > @DataOdGraniczna
    begin
     declare @temp_ilewstecz int
     set @temp_ilewstecz = datediff(month, @DataNieobec, @DataOdGraniczna)
     set @temp_ilewstecz *= -1
     if @temp_ilewstecz < @IleWstecz
     begin
      if (month(@DataOdGraniczna) < month(@DataNieobec) and year(@DataOdGraniczna) = year(@DataNieobec)) or (year(@DataOdGraniczna) < year(@DataNieobec))
      begin
       set @OkresPrzed = cdn.CreateDateFromParts(year(@DataOdGraniczna), month(@DataOdGraniczna), 1)
       set @OkresPo = cdn.CreateDateFromParts(year(@DataOdGraniczna), month(@DataOdGraniczna) + 1, 1) - 1                 if @DataGranicznaRownaZatrudOd > 0
       begin
        declare @BylyDniPracy tinyint
        set @BylyDniPracy = cdn.SprawdzDniPracy(@DataOdGraniczna, @PraId)
        if day(@DataOdGraniczna) > 1 and @BylyDniPracy = 1
        begin
         set @OkresPrzed = dateadd(month, 1, @OkresPrzed)
         set @OkresPo = dateadd(month, 1, @OkresPo)
         set @OkresPo = cdn.CreateDateFromParts(year(@OkresPo), month(@OkresPo) + 1, 1) - 1
         if @temp_ilewstecz > 0
          set @OkresPo = dateadd(month, @temp_ilewstecz - 2, @OkresPo)
        end
        else
        begin
         if @temp_ilewstecz > 0
         begin
          set @OkresPo = dateadd(month, @temp_ilewstecz - 1, @OkresPo)
          set @OkresPo = cdn.CreateDateFromParts(year(@OkresPo), month(@OkresPo) + 1, 1) - 1
         end
        end
       end
       else
       begin
        set @OkresPrzed = dateadd(month, 1, @OkresPrzed)
        set @OkresPo = dateadd(month, 1, @OkresPo)
        set @OkresPo = cdn.CreateDateFromParts(year(@OkresPo), month(@OkresPo) + 1, 1) - 1
        if @temp_ilewstecz > 0
         set @OkresPo = dateadd(month, @temp_ilewstecz - 2, @OkresPo)
       end
      end
      else if (month(@DataOdGraniczna) = month(@DataNieobec) and year(@DataOdGraniczna) = year(@DataNieobec))
      begin
       set @OkresPrzed = cdn.CreateDateFromParts(year(@DataOdGraniczna), month(@DataOdGraniczna), 1)
       set @OkresPo = cdn.CreateDateFromParts(year(@DataOdGraniczna), month(@DataOdGraniczna) + 1, 1) - 1
      end
     end
    end
   end
   if @OkresPo < @OkresPrzed
    set @OkresPo = cdn.CreateDateFromParts(year(@OkresPrzed), month(@OkresPrzed) + 1, 1) - 1
   --insert into @PeriodZ3 (OkresPrzed, OkresPo, Debug) values (@OkresPrzed, @OkresPo, '')
   insert into @PeriodZ3 (OkresPrzed, OkresPo, Debug)
    values (@OkresPrzed, @OkresPo, 80)
   return
  end
 end
 return
end
