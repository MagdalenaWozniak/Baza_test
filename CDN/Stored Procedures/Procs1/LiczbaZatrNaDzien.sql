create procedure CDN.LiczbaZatrNaDzien(@dt datetime)
as
begin
if @dt is null
 set @dt = getdate()
-- Liczba zatrudnionych na dzień (Comarch HRM)
declare @MyId int
set @MyId = 203
declare @etaty int
declare @umowy int
declare @razem int
declare @dostep int
declare @umowydostep int
set @etaty =
(
 select count(*) as etaty
  from cdn.pracetaty
  where pre_typpracownika=0
   and @dt between pre_dataod and pre_datado and @dt between pre_zatrudnionyod and pre_zatrudnionydo
)
set @umowy =
(
 select COUNT(distinct UMW_PraId) as umowy
  from cdn.Umowy
  where @dt between UMW_DataOd and UMW_DataDo
   and not exists
   (
    select * from cdn.pracetaty
     where UMW_PraId = PRE_PraId and @dt between pre_dataod
     and pre_datado and @dt between pre_zatrudnionyod and pre_zatrudnionydo
   )
)
--sprawdzenie czy pracownik nie jest zatrudniony na etat oraz nie ma umowy ale ma dodatkowy dostęp
set @dostep =
(
 select count(*)
  from cdn.PracKod left outer join cdn.pracetaty on PRE_PraId = PRA_PraId
  where pre_typpracownika = 0
   and
   (PRA_EPDostep > 0 and @dt between PRA_EPDostepOkresOd and PRA_EPDostepOkresDo)
     and ((@dt between pre_dataod and pre_datado)
     and ((@dt < pre_zatrudnionyod or @dt > pre_zatrudnionydo) or (PRE_ZatrudnionyOd is null)))
    and
    (
    not exists (select top 1 * from cdn.Umowy where UMW_PraId = PRA_PraId and (@dt > UMW_DataOd and @dt <= UMW_DataDo) or UMW_DataOd is null
    )
    and exists
    (
     select * from cdn.Umowy where UMW_PraId = PRA_PraId and @dt >= UMW_DataDo
    ))
)
declare @dosteprazem int, @bezzatr int
--sprawdzenie czy pracownik nie jest zatrudniony na etat ale ma dodatkowy dostęp
set @bezzatr =
(
 select count(*)
  from cdn.PracKod left outer join cdn.pracetaty on PRE_PraId = PRA_PraId
  where pre_typpracownika = 0
   and (PRA_EPDostep > 0 and @dt between PRA_EPDostepOkresOd and PRA_EPDostepOkresDo)
         and ((@dt between pre_dataod and pre_datado)
   and (PRE_ZatrudnionyOd is null or PRE_ZatrudnionyOd is not null and PRE_ZatrudnionyDo < @dt))
   and not exists (select umw_umwid from cdn.umowy where UMW_PraId = PRA_PraId)
)
set @umowydostep =
(
 select COUNT(distinct UMW_PraId) as umowy
  from cdn.Umowy join cdn.PracKod on UMW_PraId = PRA_PraId
  where @dt between UMW_DataOd and UMW_DataDo
   and not exists
   (
    select * from cdn.pracetaty
     where UMW_PraId = PRE_PraId and @dt between pre_dataod
     and pre_datado and @dt between pre_zatrudnionyod and pre_zatrudnionydo
   )
   and
   (PRA_EPDostep > 0 and @dt between PRA_EPDostepOkresOd and PRA_EPDostepOkresDo)
)
declare @uwzglumowy int
set @uwzglumowy = (select isnull(fir_wartosc, 0) from cdn.firma where fir_numer = 2203)
if (@uwzglumowy > 0)
begin
set @razem = @etaty + @umowy + @dostep + @bezzatr
end
else
begin
set @dostep = @dostep + @umowydostep
set @razem = @etaty + @dostep + @bezzatr
set @umowy = 0
end
select @etaty as Etaty, @umowy as Umowy, @dostep + @bezzatr as 'Dodatkowy dostęp', @razem as Razem
end
