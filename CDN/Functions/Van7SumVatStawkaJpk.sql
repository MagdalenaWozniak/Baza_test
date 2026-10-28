create FUNCTION [CDN].[Van7SumVatStawkaJpk]
(
@VanId Int,
@Stawka1 decimal(15,2),
@Stawka2 decimal(15,2),
@Flaga int,
@DataOdint int,
@DataDoint int,
@Uwzglednij int,
@Wspolczynnik decimal(15,2)
)
RETURNS  decimal(15,2)
AS
BEGIN
declare @suma decimal(15,2)
if @Uwzglednij = 1
 select @suma = sum(case when Va7_Odliczenia = 1 then Va7_VAT else round(@Wspolczynnik / 100.00 * Va7_VAT,2) end)
 from cdn.VatTab7 where Va7_VaNID = @VanId and (Va7_stawka = @Stawka1 or Va7_stawka = @Stawka2) and Va7_Flaga = @Flaga and Va7_RokMiesiac BETWEEN  @DataOdint AND @DataDoint
 and Va7_Odliczenia in (1,2)
else
 select @suma = sum(Va7_VAT) from cdn.VatTab7 where Va7_VaNID = @VanId and (Va7_stawka = @Stawka1 or Va7_stawka = @Stawka2) and Va7_Flaga = @Flaga and Va7_RokMiesiac BETWEEN  @DataOdint AND @DataDoint
return @suma
END
