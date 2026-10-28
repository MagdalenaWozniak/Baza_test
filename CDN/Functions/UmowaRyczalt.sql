create function cdn.UmowaRyczalt (@TwpId int)
 returns int
as
begin
declare @STS int,
  @Umowa int,
  @PIT int,
  @PozPITA int,
  @PozIFT int
 select @STS = TWP_Standardowy, @Umowa = TWP_Umowa, @PIT = TWP_PdpId from CDN.TypWyplata where TWP_TwpId = @TwpId
 if (152 <= @STS and @STS < 200)
  return 1
 select @PozPITA = PDP_PIT8A, @PozIFT = PDP_IFT1 from cdn.PozDeklPIT where PDP_PdpId = @PIT
 if @PozPITA = 15
  return 1
 if @PozPITA = 100
  return 1
 if @PozIFT > 0
 begin
  if (@Umowa = 1 and @STS = 0)
   return 1
 end
 return 0;
end
