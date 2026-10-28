create function cdn.SprawdzDniPracy(@ZatrudOd datetime, @PraId int)
returns tinyint
as
begin
    declare @BylyDniPracy tinyint
 set @BylyDniPracy = 0
 if(day(@ZatrudOd) > 1)
 begin
  declare @i int
  set @i = 1
  declare @temp_date datetime
  while(@i < day(@ZatrudOd))
  begin
   set @temp_date = cdn.CreateDateFromParts(year(@ZatrudOd), month(@ZatrudOd), @i)
   --sprawdzanie, czy w przypadku zatrudnienia > niż 1 dzień m-ca występują dni robocze
   --jeśli tak, to pobierany jest następny m-c w stos. do m-ca zatrud.
   if(datepart(WEEKDAY, @temp_date) = 7 or datepart(WEEKDAY, @temp_date) = 1)
   begin
    if(select top 1 PPL_TypDnia from cdn.PracPlanDni where PPL_PraId = @PraId and PPL_Data = @temp_date) = 1
    begin
     set @BylyDniPracy = 1
     break
    end
    if(select top 1 KAD_TypDnia from cdn.KalendDni where KAD_Data = @temp_date) = 1
    begin
     set @BylyDniPracy = 1
     break
    end
   end
   else
   begin
    declare @ppl_td int
    declare @kad_td int
    select top 1 @ppl_td = PPL_TypDnia from cdn.PracPlanDni where PPL_PraId = @PraId and PPL_Data = @temp_date and PPL_TypDnia in (2, 3)
    select top 1 @kad_td = KAD_TypDnia from cdn.KalendDni where KAD_Data = @temp_date and KAD_TypDnia in (2, 3)
    if @ppl_td is null and @kad_td is null
    begin
     set @BylyDniPracy = 1
     break
    end
   end
   set @i = @i + 1
  end
 end
 return @BylyDniPracy
end
