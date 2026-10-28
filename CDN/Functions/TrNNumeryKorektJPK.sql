create FUNCTION CDN.TrNNumeryKorektJPK
(
@TrNId Int
)
RETURNS nVarchar(257)
AS
BEGIN
Declare @Numbers AS nVarchar(257)
SELECT  @Numbers = COALESCE(@Numbers + ',', '') + TrN_NumerPelny
FROM   cdn.tranagrelacje   left join cdn.tranag on trn_trnid = trr_faid
  where TrR_TrNId = @TrNId
return @Numbers
END
