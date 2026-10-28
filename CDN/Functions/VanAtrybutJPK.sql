create FUNCTION [CDN].[VanAtrybutJPK]
(
@VanId Int,
@Atrybut nvarchar(100),
@CzyPustaWartoscOK int
)
RETURNS  int
AS
BEGIN
declare @suma int
if exists (
select * from cdn.DokAtrybuty left join cdn.defatrybuty on dat_deaid = dea_deaid  where dat_vanid = @VanId and dea_Kod = @Atrybut  and (DAt_WartoscTxt != '' or @CzyPustaWartoscOK = 1))
select @suma =1 else select @suma = 0
return @suma
END
