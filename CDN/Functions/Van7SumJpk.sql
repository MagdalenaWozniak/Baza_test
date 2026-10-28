create FUNCTION [CDN].[Van7SumJpk]
(
@VanId Int,
@DataOdint int,
@DataDoint int
)
RETURNS  decimal(15,2)
AS
BEGIN
declare @suma decimal(15,2)
 select @suma = sum(Va7_Netto+Va7_VAT) from cdn.VatTab7 where Va7_VaNID = @VanId and Va7_RokMiesiac BETWEEN  @DataOdint AND @DataDoint
return @suma
END
