create procedure CDN.PodpowiedzGodzEkwiwalentu @pracId int, @dtPodstawowyOkresOd datetime, @dtPodstawowyOkresDo datetime
as
begin
 declare @czyTymczasowy int, @dtGodziny datetime, @dtDni real, @typLimitu int
 select top 1 @czyTymczasowy = PRE_Tymczasowy FROM cdn.PracEtaty where PRE_PraId = @pracId and PRE_DowWaznyDo >= @dtPodstawowyOkresDo order by PRE_DataDo ASC
 if @czyTymczasowy <> 1
  set @czyTymczasowy = 0
 if (select count(PLN_PraId) from cdn.PracLimit where PLN_PraId = @pracId) > 0
 begin
  select TOP 1
   @dtGodziny = PLN_PozostaloCzas, @dtDni = PLN_PozostaloF, @typLimitu = LNB_Standardowy
  from
   cdn.PracLimit
  join
   cdn.LimitNieobec on PLN_LnbId = LNB_LnbId
  where
   PLN_PraId = @pracId
   and PLN_WaznyOd <= @dtPodstawowyOkresDo --and PLN_OkresOd <= @dtPodstawowyOkresOd
   and (PLN_OkresDo >= @dtPodstawowyOkresOd and PLN_OkresOd <= @dtPodstawowyOkresDo)
   and (LNB_Standardowy = 100 or LNB_Standardowy = 102)
  order by
   PLN_WaznyOd desc
  if @typLimitu = 102
   set @czyTymczasowy = 1
  else
  begin
   set @czyTymczasowy = 0
   set @dtDni = 1
  end
  if @dtDni <= 0
  begin
   -- warunek na mniejszosc podstawowego okresu wynika ze zmian w sposobie naliczania wprowadzonych 1 czerwca 2017
   -- 100 - Wypoczynkowy, 102 - Wypoczynkowy tymczasowy
   if @typLimitu = 100 or (@typLimitu = 102 and @dtPodstawowyOkresOd <  CONVERT(datetime, '2017-06-01', 120))
    set @dtGodziny = CONVERT(datetime, '1899-12-30', 120)
  end
  if @dtDni < 0 and @typLimitu = 102
   set @dtDni = 0
 end
 else
 begin
  if @czyTymczasowy != 1 or (@czyTymczasowy = 0 and @dtPodstawowyOkresOd < CONVERT(datetime, '2017-06-01', 120))
   set @dtGodziny = CONVERT(datetime, '1899-12-30', 120)
  else
  begin
   set @dtGodziny = convert(datetime, convert(int, @dtGodziny) * convert(int, @dtDni))
   if datepart(minute, @dtGodziny) != 0
   begin
    set @dtGodziny = convert(datetime, datepart(year, @dtGodziny)+'-'+datepart(month, @dtGodziny)+'-'+datepart(day, @dtGodziny)+' '+datepart(hour, @dtGodziny)+':00:00', 120)
    set @dtGodziny = @dtGodziny + CONVERT(datetime, '1899-12-30 01:00:00', 120)
   end
  end
 end
 if @dtDni < 0
 begin
  set @dtDni = 0
 end
 select @dtGodziny, @dtDni
end
