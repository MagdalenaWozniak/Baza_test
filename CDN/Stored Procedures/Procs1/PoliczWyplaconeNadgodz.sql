--/////////////////////////////////////////////////////////////////////////////////////////////////////
create proc cdn.PoliczWyplaconeNadgodz
@PrcId int, @OkresOd datetime, @OkresDo datetime
as
begin
set nocount on
declare @idNadgodz50 int
declare @idNadgodz100 int
declare @idNadgodz50S int
declare @idNadgodz100S int
select @idNadgodz50S = twp_twpid from CDN.TypWyplata where TWP_Standardowy = 26
select @idNadgodz100S = twp_twpid from CDN.TypWyplata where TWP_Standardowy = 27
select @idNadgodz50 = twp_twpid from CDN.TypWyplata where TWP_Standardowy = 6
select @idNadgodz100 = twp_twpid from CDN.TypWyplata where TWP_Standardowy = 7
declare @Nadgodz50Min int
declare @Nadgodz100Min int
select @Nadgodz50Min = SUM(DATEDIFF(minute,CONVERT(DATETIME,'1899-12-30 00:00:00.000',120),WPS_OkresCzas)) from CDN.WypSkladniki join CDN.Wyplaty on WPS_WplId = WPL_WplId where WPL_Tryb in (0,3) and WPS_PraId = @PrcId and  WPS_TwpId in (@idNadgodz50S,@idNadgodz50)
and (WPS_DataOd BETWEEN  @OkresOd AND @OkresDo or WPS_DataDo BETWEEN  @OkresOd AND @OkresDo)
select @Nadgodz100Min = SUM(DATEDIFF(minute,CONVERT(DATETIME,'1899-12-30 00:00:00.000',120),WPS_OkresCzas)) from CDN.WypSkladniki join CDN.Wyplaty on WPS_WplId = WPL_WplId where WPL_Tryb in (0,3) and WPS_PraId = @PrcId and  WPS_TwpId in (@idNadgodz100S,@idNadgodz100)
and (WPS_DataOd BETWEEN  @OkresOd AND @OkresDo or WPS_DataDo BETWEEN  @OkresOd AND @OkresDo)
select ISNULL(@Nadgodz50Min,0),ISNULL(@Nadgodz100Min,0)
set nocount off
end
