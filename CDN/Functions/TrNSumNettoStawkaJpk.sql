create FUNCTION [CDN].[TrNSumNettoStawkaJpk]
(
@TrNId Int,
@Stawka1 decimal(15,2),
@Stawka2 decimal(15,2),
@Flaga int,
@odwrotne int
)
RETURNS  decimal(15,2)
AS
BEGIN
declare @suma decimal(15,2)
if @odwrotne = 1
 select @suma = sum(TrE_WartoscNettoWal) from cdn.traelem join cdn.tranag on tre_trnid = trn_trnid where tre_trnid = @TrNId and tre_stawka = @Stawka1  and Tre_Flaga = @Flaga and Tre_OdwrotneObciazenie = @odwrotne and TrN_Export = 5
else
 select @suma = sum(trv_nettowal) from cdn.travat where trv_trnid = @TrNId and (trv_stawka = @Stawka1 or trv_stawka = @Stawka2) and TrV_Flaga = @Flaga
return @suma
END
