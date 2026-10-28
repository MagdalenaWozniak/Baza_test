create PROCEDURE CDN.LiczEkwiwalent @PraId int, @CzyDodac int, @DataOd DateTime, @DataDo DateTime, @LiczbaGodzin int, @LiczbaMinut int
AS
BEGIN
 declare @normaDobowaDT datetime, @normaDobowaF real
 --DSi2018.6 [240367]
 --select TOP 1 @normaDobowaDT = PRE_ETANormaDobowa FROM cdn.PracEtaty WHERE PRE_DataOd <= @DataOd AND PRE_DataDo >= @DataDo AND PRE_PraId = @PraId
 select TOP 1 @normaDobowaDT = PRE_ETANormaDobowa FROM cdn.PracEtaty WHERE PRE_DataDo >= @DataDo AND PRE_PraId = @PraId
 set @normaDobowaF = CONVERT(real, @normaDobowaDT+2)*24
 --DSi2018.6 [239567]
 --set @LiczbaGodzinDT = @LiczbaGodzinDT + 2
 declare @LiczbaDni real
 --set @LiczbaDni = convert(real, @LiczbaGodzinDT)*3;
 --set @LiczbaDni = (@LiczbaGodzin + @LiczbaMinut/60.0)/@normaDobowaF
 set @LiczbaDni = (@LiczbaGodzin + 1.0*@LiczbaMinut/60.0)/@normaDobowaF
 declare @LiczbaGodzinDT datetime
 --set @LiczbaGodzinDT = CONVERT(datetime, @LiczbaDni/3.0)
 set @LiczbaGodzinDT = CONVERT(datetime, '1899-12-30 00:00:00', 120)
 set @LiczbaGodzinDT = DATEADD(hour, @LiczbaGodzin+48, @LiczbaGodzinDT)
 set @LiczbaGodzinDT = DATEADD(minute, @LiczbaMinut, @LiczbaGodzinDT)
 declare @PlnId int -- znalezione id
 set @PlnId = 0
 declare @pozostalyczas datetime, @ekwiwalentNaliczonyCzas datetime, @pozostaloF real, @ekwiwalentF real
 set @pozostaloF = 0
 select TOP 1 @PlnId = PLN_PlnId, @pozostaloF = PLN_PozostaloF, @pozostalyczas = PLN_PozostaloCzas, @ekwiwalentNaliczonyCzas = PLN_EkwiwalentCzas, @ekwiwalentF = PLN_EkwiwalentF
  from
   cdn.PracLimit
  where
   PLN_PraId = @PraId and
   PLN_LnbId = (SELECT LNB_LnbId FROM cdn.LimitNieobec WHERE LNB_Standardowy = 100) and
   --PLN_OkresOd <= @DataOd and
   --PLN_OkresDo >= @DataDo
   (PLN_OkresDo >= @DataOd and PLN_OkresOd <= @DataDo)
   and PLN_WaznyOd <= @DataDo
 ORDER BY
  PLN_WaznyOd DESC
 if @PlnId > 0
 begin
  declare @NowaLiczbaGodzin datetime, @NowyEkwiwalent datetime, @NowePozostaloF real, @NowyEkwiwalentF real
  if @CzyDodac = 0
  begin
   set @LiczbaDni = -@LiczbaDni
   if @LiczbaGodzinDT > @ekwiwalentNaliczonyCzas + 2
    set @NowyEkwiwalent = -2
   else
    set @NowyEkwiwalent = @ekwiwalentNaliczonyCzas - @LiczbaGodzinDT
  end
  else
  begin
   set @NowyEkwiwalent = @ekwiwalentNaliczonyCzas + @LiczbaGodzinDT
  end
  set @NowePozostaloF = @pozostaloF - @LiczbaDni
  set @NowyEkwiwalentF = @ekwiwalentF + @LiczbaDni
  if @NowyEkwiwalentF < 0
  begin
   set @NowePozostaloF = @NowePozostaloF - (0-@NowyEkwiwalentF)
   set @NowyEkwiwalentF = 0
  end
  --DSi2019.0 [244810]
  --set @NowaLiczbaGodzin = convert(datetime, abs((@NowePozostaloF*@normaDobowaF)/24)-2)
  set @NowaLiczbaGodzin = CONVERT(datetime, '1899-12-30 00:00:00', 120)
  set @NowaLiczbaGodzin = DATEADD(minute, @NowePozostaloF*@normaDobowaF*60, @NowaLiczbaGodzin)
  update CDN.PracLimit set
    PLN_PozostaloF = @NowePozostaloF,
    PLN_PozostaloCzas =  @NowaLiczbaGodzin,
    PLN_EkwiwalentF = @NowyEkwiwalentF,
    PLN_EkwiwalentCzas = @NowyEkwiwalent,
    PLN_TS_Mod = SYSDATETIME()
   WHERE
    PLN_PlnId = @PlnId
 end
END
