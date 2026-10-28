create procedure CDN.UrlopPracownikaOkres @PraID int, @OkresOd datetime, @OkresDo datetime
as
set nocount on
begin
 declare @Wynik decimal(15,2)
 set @Wynik = 0
 set @Wynik = (select COALESCE(SUM(WPE_Wartosc), 0) from cdn.WypElementy join cdn.TypWyplata on WPE_TwpId = TWP_TwpId join cdn.WypSkladniki on WPE_WpeId = WPS_WpeId where TWP_WliczUrlop = 2 --Wliczać
 and wps_praid = @PraID and ((WPS_DataOd between @OkresOd and @OkresDo) or (WPS_DataDo between @OkresOd and @OkresDo) or (WPS_DataOd > @OkresOd and WPS_DataDo < @OkresDo)
 or (WPS_DataOd > @OkresOd and WPS_DataDo < @OkresDo)) and WPS_PnbId is null )
 + @Wynik
 set @Wynik = (select COALESCE(SUM(WPE_Wartosc), 0) from cdn.WypElementy join cdn.TypWyplata on WPE_TwpId = TWP_TwpId join cdn.WypSkladniki on WPE_WpeId = WPS_WpeId where TWP_WliczUrlop = 3 --Wliczać jak zasadnicze
 and wps_praid = @PraID and ((WPS_DataOd between @OkresOd and @OkresDo) or (WPS_DataDo between @OkresOd and @OkresDo) or (WPS_DataOd > @OkresOd and WPS_DataDo < @OkresDo)
 or (WPS_DataOd > @OkresOd and WPS_DataDo < @OkresDo)) and WPS_PnbId is null )
 + @Wynik
 set @Wynik = (select COALESCE(SUM(WPE_Wartosc), 0) from cdn.WypElementy join cdn.TypWyplata on WPE_TwpId = TWP_TwpId join cdn.WypSkladniki on WPE_WpeId = WPS_WpeId where TWP_WliczUrlop = 4 --Wliczać po przeliczeniu
 and wps_praid = @PraID and ((WPS_DataOd between @OkresOd and @OkresDo) or (WPS_DataDo between @OkresOd and @OkresDo) or (WPS_DataOd > @OkresOd and WPS_DataDo < @OkresDo)
 or (WPS_DataOd > @OkresOd and WPS_DataDo < @OkresDo)) and WPS_PnbId is null )
 + @Wynik
 set @Wynik = (select COALESCE(SUM(WPE_Wartosc), 0) from cdn.WypElementy join cdn.TypWyplata on WPE_TwpId = TWP_TwpId join cdn.WypSkladniki on WPE_WpeId = WPS_WpeId where TWP_WliczUrlop = 5 --Wliczać aktualną wartość
 and wps_praid = @PraID and ((WPS_DataOd between @OkresOd and @OkresDo) or (WPS_DataDo between @OkresOd and @OkresDo) or (WPS_DataOd > @OkresOd and WPS_DataDo < @OkresDo)
 or (WPS_DataOd > @OkresOd and WPS_DataDo < @OkresDo)) and WPS_PnbId is null)
 + @Wynik
 select @Wynik
end
set nocount off
