CREATE FUNCTION CDN.VATZD_ZapisKorekcyjnyKwotaVatFromId_2017( @DataOd DateTime, @DataDo DateTime, @VaNId int, @Wspolczynnik decimal(15,4), @Tryb int)
RETURNS decimal(15,2)
AS
BEGIN
 declare @Result decimal (15,2) = 0;
 declare @sumaOdliczeniaTak decimal (15,2) = 0;
 declare @sumaOdliczeniaWarunkowo decimal (15,2) = 0;
 declare @srcSumaOdliczeniaTak decimal (15,2) = 0;
 declare @srcSumaOdliczeniaWarunkowo decimal (15,2) = 0;
 declare @srcSuma decimal (15,2) = 0;
 declare @srcVaNId int = 0;
 select @srcVaNId = VaZ_VaNId from cdn.vatzd where VaZ_VaNId_ZK = @VaNId;
 set @Wspolczynnik = @Wspolczynnik / 100.00;
 select
  @srcSumaOdliczeniaTak = sum(case when VaT_Odliczenia=1 then VaT_VatDoVat else 0 end),
  @srcSumaOdliczeniaWarunkowo = sum(case when VaT_Odliczenia=2 then VaT_VatDoVat else 0 end)
 from cdn.VatTab
 join CDN.VATZD_ZapisyKorekcyjne(@DataOd, @DataDo) on (VaNId = VaT_VaNId)
 where SrcVaNId = @srcVaNId and VaT_Odliczenia in (1,2)
 set @srcSuma = @Wspolczynnik * IsNull(@srcSumaOdliczeniaWarunkowo, 0) + IsNull(@srcSumaOdliczeniaTak,0);
 if @Tryb = 1 and @srcSuma < 0
 begin
  select
   @sumaOdliczeniaTak = sum(case when VaT_Odliczenia=1 then VaT_VatDoVat else 0 end),
   @sumaOdliczeniaWarunkowo = sum(case when VaT_Odliczenia=2 then VaT_VatDoVat else 0 end)
  from cdn.VatTab
  where VaT_VaNId = @VaNId and VaT_Odliczenia in (1,2);
 end
 else if @Tryb = 2 and @srcSuma > 0
 begin
  select
   @sumaOdliczeniaTak = sum(case when VaT_Odliczenia=1 then VaT_VatDoVat else 0 end),
   @sumaOdliczeniaWarunkowo = sum(case when VaT_Odliczenia=2 then VaT_VatDoVat else 0 end)
  from cdn.VatTab
  where VaT_VaNId = @VaNId and VaT_Odliczenia in (1,2);
 end
 Set @Result = @Wspolczynnik * IsNull(@sumaOdliczeniaWarunkowo, 0) + IsNull(@sumaOdliczeniaTak,0);
 return @Result
END
