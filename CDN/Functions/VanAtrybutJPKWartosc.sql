create FUNCTION [CDN].[VanAtrybutJPKWartosc]
(
@VanId Int,
@Atrybut nvarchar(100)
)
RETURNS  nvarchar(100)
AS
BEGIN
declare @wartosc nvarchar(100)
select  @wartosc = DAt_WartoscTxt from cdn.DokAtrybuty left join cdn.defatrybuty on dat_deaid = dea_deaid where dat_vanid = @VanId and dea_Kod = @Atrybut
return @wartosc
END
