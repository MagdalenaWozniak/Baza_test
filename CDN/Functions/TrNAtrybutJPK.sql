create FUNCTION [CDN].[TrNAtrybutJPK]
(
@TrNId Int,
@Atrybut nvarchar(100),
@CzyPustaWartoscOK int
)
RETURNS  int
AS
BEGIN
declare @suma int
if exists (
select * from cdn.DokAtrybuty where dat_trnid = @TrNId and Dat_Kod = @Atrybut and (DAt_WartoscTxt != '' or @CzyPustaWartoscOK = 1))
select @suma =1 else select @suma = 0
return @suma
END
