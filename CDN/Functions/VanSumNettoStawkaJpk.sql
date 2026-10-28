create FUNCTION [CDN].[VanSumNettoStawkaJpk]
(
@VanId Int,
@Stawka1 decimal(15,2),
@Stawka2 decimal(15,2),
@Flaga int,
@Uwzglednij int,
@Wspolczynnik decimal(15,2)
)
RETURNS  decimal(15,2)
AS
BEGIN
declare @suma decimal(15,2)
if @Uwzglednij = 1
 select @suma = sum(case when Vat_Odliczenia = 1 then Vat_nettowal else round(@Wspolczynnik / 100.00 * Vat_nettowal,2) end)
 from cdn.VatTab where VaT_VaNID = @VanId and (VaT_stawka = @Stawka1 or VaT_stawka = @Stawka2) and VaT_Flaga = @Flaga
 and VaT_Odliczenia in (1,2)
else
 select @suma = sum(Vat_nettowal) from cdn.VatTab where VaT_VaNID = @VanId and (VaT_stawka = @Stawka1 or VaT_stawka = @Stawka2) and VaT_Flaga = @Flaga
return @suma
END
