create function cdn.OkresZ3PierwszaNieobecnosc(@PraId int, @PnbId int, @DataOdGraniczna datetime, @DataNieobec datetime)
returns int
as
begin
declare @PnbOkresOd datetime
select @PnbOkresOd = PNB_OkresDo from cdn.PracNieobec where PNB_PnbId = @PnbId
declare @PnbIdCurrent int, @DataDoCurrent datetime
declare @PnbIdPrev int, @DataDoPrev datetime
--na wejściu obie pary zmiennych muszą być zainicjowane tak samo, ponieważ:
--jeśli kursor nic nie zwróci, to obowiązującą nieobecnością, będzie nieobecność wejściowa
--jeśli kursor ma wartości, to należy je porównać z nieobecnością wejściową
set @PnbIdPrev = @PnbId
if @PnbId > 0
 select @DataDoPrev = PNB_OkresDo from cdn.PracNieobec where PNB_PnbId = @PnbIdPrev
else
 select @DataDoPrev = @DataNieobec
set @PnbIdCurrent = @PnbId
set @DataDoCurrent = @DataDoPrev
declare @Diff smallint
if @PnbId > 0
begin
declare NIEOBECNOSCI cursor local fast_forward for
  select PNB_PnbId, PNB_OkresDo
   from cdn.PracNieobec join cdn.TypNieobec on PNB_TnbId = TNB_TnbId
   where PNB_PraId = @PraId and TNB_Typ = 8 and PNB_OkresOd < @PnbOkresOd and PNB_OkresOd > @DataOdGraniczna
   --order by PNB_PnbId desc
   order by PNB_OkresOd desc
 open NIEOBECNOSCI
  while (1=1)
  begin
   fetch next from NIEOBECNOSCI into @PnbIdCurrent, @DataDoCurrent
   if @@fetch_status <> 0
    break
   set @Diff = datediff(month, @DataDoCurrent, @DataDoPrev)
   --szukamy czy kolejna nieobecność, jest dalej niż 3 miesiące wstecz (z uwzgl. bież. m-c: 4)
   if (month(@DataDoCurrent) = month(@DataDoPrev)) or @Diff < 4
   begin
    set @PnbIdPrev = @PnbIdCurrent
    set @DataDoPrev = @DataDoCurrent
   end
   --jeśli nie ma, to przerywamy i zwracamy ostatnią zapamiętaną (Prev)
   else
   begin
    set @PnbIdCurrent = @PnbIdPrev
    set @DataDoCurrent = @DataDoPrev
    break
   end
  end
 close NIEOBECNOSCI
deallocate NIEOBECNOSCI
end
else
begin
declare NIEOBECNOSCI cursor local fast_forward for
  select PNB_PnbId, PNB_OkresDo
   from cdn.PracNieobec join cdn.TypNieobec on PNB_TnbId = TNB_TnbId
   where PNB_PraId = @PraId and TNB_Typ = 8 and PNB_OkresOd <  @DataNieobec and PNB_OkresOd > @DataOdGraniczna
 open NIEOBECNOSCI
  while (1=1)
  begin
   fetch next from NIEOBECNOSCI into @PnbIdCurrent, @DataDoCurrent
   if @@fetch_status <> 0
    break
   set @Diff = datediff(month, @DataDoCurrent, @DataDoPrev)
   --szukamy czy kolejna nieobecność, jest dalej niż 3 miesiące wstecz (z uwzgl. bież. m-c: 4)
   if (month(@DataDoCurrent) = month(@DataDoPrev)) or @Diff < 4
   begin
    set @PnbIdPrev = @PnbIdCurrent
    set @DataDoPrev = @DataDoCurrent
   end
   --jeśli nie ma to przerywamy i zwracamy ostatnią zapamiętaną (Prev)
   else
   begin
    set @PnbIdCurrent = @PnbIdPrev
    set @DataDoCurrent = @DataDoPrev
    break
   end
  end
 close NIEOBECNOSCI
deallocate NIEOBECNOSCI
end
 return @PnbIdCurrent
end
