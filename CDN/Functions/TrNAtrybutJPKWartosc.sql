create FUNCTION [CDN].[TrNAtrybutJPKWartosc]
(
@TrNId Int,
@Atrybut nvarchar(100)
)
RETURNS  nvarchar(100)
AS
BEGIN
declare @wartosc nvarchar(100)
select  @wartosc = DAt_WartoscTxt from cdn.DokAtrybuty where dat_trnid = @TrNId and Dat_Kod = @Atrybut
return @wartosc
END
