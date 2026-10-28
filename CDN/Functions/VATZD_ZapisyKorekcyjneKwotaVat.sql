CREATE FUNCTION CDN.VATZD_ZapisyKorekcyjneKwotaVat( @DataOd DateTime, @DataDo DateTime, @Wspolczynnik decimal (15,2), @Tryb int)
RETURNS decimal(15,2)
AS
BEGIN
 declare @Result decimal (15,2) = 0;
 declare @sumaOdliczeniaTak decimal (15,2) = 0;
 declare @sumaOdliczeniaWarunkowo decimal (15,2) = 0;
 set @Wspolczynnik = @Wspolczynnik / 100.00;
 set @dataOd = DATEADD(day, -Day(@dataOd) + 1, @dataOd);
 set @dataDo = DATEADD(day, -Day(@dataDo) + 1, @dataDo);
 while (@dataOd <= @dataDo)
 begin
  if @Tryb = 1
  begin
   select
    @sumaOdliczeniaWarunkowo = @sumaOdliczeniaWarunkowo + IsNull(Sum(VatWarunkowo), 0),
    @sumaOdliczeniaTak = @sumaOdliczeniaTak + IsNull(Sum(VatTak), 0)
   from
   (
    select
    sum(case when VaT_Odliczenia=2 then VaT_VatDoVat else 0 end) as VatWarunkowo,
    sum(case when VaT_Odliczenia=1 then VaT_VatDoVat else 0 end) as VatTak
    from cdn.VatTab join CDN.VATZD_ZapisyKorekcyjne(@DataOd, @dataOd) on (VaNId = VaT_VaNId)
    where VaT_Odliczenia in (1,2)
    group by SrcVaNId
   ) V
   where (@Wspolczynnik*V.VatWarunkowo+V.VatTak) < 0;
  end
  else if @Tryb = 2
  begin
   select
    @sumaOdliczeniaWarunkowo = @sumaOdliczeniaWarunkowo + IsNull(Sum(VatWarunkowo), 0),
    @sumaOdliczeniaTak = @sumaOdliczeniaTak + IsNull(Sum(VatTak), 0)
   from
   (
    select
    sum(case when VaT_Odliczenia=2 then VaT_VatDoVat else 0 end) as VatWarunkowo,
    sum(case when VaT_Odliczenia=1 then VaT_VatDoVat else 0 end) as VatTak
    from cdn.VatTab join CDN.VATZD_ZapisyKorekcyjne(@DataOd, @dataOd) on (VaNId = VaT_VaNId)
    where VaT_Odliczenia in (1,2)
    group by SrcVaNId
   ) V
   where (@Wspolczynnik*V.VatWarunkowo+V.VatTak) > 0;
  end
  set @dataOd = DATEADD(month, 1, @dataOd);
 end
 Set @Result = @Wspolczynnik * IsNull(@sumaOdliczeniaWarunkowo, 0) + IsNull(@sumaOdliczeniaTak,0);
 return @Result
END
