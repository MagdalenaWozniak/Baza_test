create procedure CDN.AktualizujKwoteCalkowita @AhwId int, @AdfId int
as
set nocount on
declare @RodzajAkordu int
select @RodzajAkordu = adf_rodzaj from cdn.akorddefinicja where adf_adfid = @AdfId
declare @Kwota decimal(14,2),
  @Rok int,
  @Miesiac int
select @Kwota = ahw_kwota, @Rok = ahw_rok, @Miesiac = ahw_miesiac
 from cdn.akordyhistwartosci where ahw_ahwid = @AhwId
if @RodzajAkordu = 2
begin
 update cdn.akordyhistwartosci
  set ahw_kwota = @Kwota
  from cdn.akordyhistwartosci
   join cdn.akordyhist on ahw_akhid = akh_akhid
   join cdn.akorddefinicja on akh_adfid = adf_adfid
  where adf_adfid = @AdfId
   and ahw_rok = @Rok
   and ahw_miesiac = @Miesiac
end
set nocount off
