create function cdn.OpiekaDni(@praid int, @year int, @rodzaj int, @current_pnbid int)
 returns int
as
begin
 declare
  @retval int,
  @dtFirst varchar(10),
  @dtLast varchar(10)
 set @dtFirst = cast(@year as varchar) + '-01' + '-01'
 set @dtLast = cast(@year as varchar) + '-12' + '-31'
 if @rodzaj = 0
 begin
  select @retval =
   sum(
    case
     when year(PNB_OkresOd) <> @year and year(PNB_OkresDo) = @year
      then datediff(dd, convert(datetime, @dtFirst, 120), PNB_OkresDo) + 1
     when year(PNB_OkresOd) = @year and year(PNB_OkresDo) <> @year
      then -datediff(dd, convert(datetime, @dtLast, 120), PNB_OkresOd)
     when year(PNB_OkresOd) <> @year and year(PNB_OkresDo) <> @year
      then 0
     when year(PNB_OkresOd) = @year and year(PNB_OkresDo) = @year
      then PNB_DniKalend
    end
   )
    from cdn.PracNieobec
     join cdn.TypNieobec on PNB_TnbId = TNB_TnbId
    where
     PNB_PraId = @praid
     and TNB_Standardowy = 212
     and PNB_Tryb <> 1
     and (year(PNB_OkresOd) = @year or year(PNB_OkresDo) = @year)
     and pnb_pnbid <> @current_pnbid
 end
 else
 begin
  select @retval =
   sum(
    case
     when year(PNB_OkresOd) <> @year and year(PNB_OkresDo) = @year
      then datediff(dd, convert(datetime, @dtFirst, 120), PNB_OkresDo) + 1
     when year(PNB_OkresOd) = @year and year(PNB_OkresDo) <> @year
      then -datediff(dd, convert(datetime, @dtLast, 120), PNB_OkresOd)
     when year(PNB_OkresOd) <> @year and year(PNB_OkresDo) <> @year
      then 0
     when year(PNB_OkresOd) = @year and year(PNB_OkresDo) = @year
      then PNB_DniKalend
    end
   )
    from cdn.PracNieobec
     join cdn.TypNieobec on PNB_TnbId = TNB_TnbId
    where
     PNB_PraId = @praid
     and TNB_Standardowy = 212
     and PNB_Tryb <> 1
     and PNB_Przyczyna = 10
     and (year(PNB_OkresOd) = @year or year(PNB_OkresDo) = @year)
     and pnb_pnbid <> @current_pnbid
 end
 return @retval
end
