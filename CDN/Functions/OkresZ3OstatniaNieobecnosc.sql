create function cdn.OkresZ3OstatniaNieobecnosc(@Tryb tinyint, @PraId int, @DataOdGraniczna datetime, @DataNieobec datetime)
returns int
as
begin
 declare @RetVal int
 declare @m int, @m3 int, @y int
 set @m = month(@DataNieobec)
 set @y = year(@DataNieobec)
 set @m3 = month(dateadd(month, -3, @DataNieobec))
 if @m3 > @m
  set @y -= 1
 if @Tryb = 0
  select @RetVal = max(PNB_PnbId) from cdn.PracNieobec
   join cdn.TypNieobec on PNB_TnbId = TNB_TnbId
   where PNB_PraId = @PraId and TNB_Typ = 8 and PNB_OkresOd > @DataOdGraniczna and PNB_OkresDo <= @DataNieobec
    and ((month(@DataNieobec) = month(PNB_OkresDo) and year(@DataNieobec) = year(PNB_OkresDo)) or (PNB_OkresDo >= cdn.CreateDateFromParts(@y, @m3, 1)))
 else
  select @RetVal = max(PNB_PnbId) from cdn.PracNieobec
   join cdn.TypNieobec on PNB_TnbId = TNB_TnbId
   where PNB_PraId = @PraId and TNB_Typ = 8 and PNB_OkresOd > @DataOdGraniczna
    and ((month(@DataNieobec) = month(PNB_OkresDo) and year(@DataNieobec) = year(PNB_OkresDo)) or (PNB_OkresDo >= cdn.CreateDateFromParts(@y, @m3, 1)))
 return  @RetVal
end
