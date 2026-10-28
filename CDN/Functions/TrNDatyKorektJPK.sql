create FUNCTION [CDN].[TrNDatyKorektJPK]
(
@TrNId Int
)
RETURNS  nVarchar(256)
AS
BEGIN
Declare @Opis AS nVarchar(256) -- It must not be MAX if you have few numbers
select @Opis = 'Od ' + convert(NVARCHAR(30),convert(date, min(TrN_DataOpe)) ,120) +' do ' +convert(NVARCHAR(30),convert(date, max(TrN_DataOpe)) ,120)
FROM  cdn.tranagrelacje
  left join cdn.tranag on trn_trnid = trr_faid
  where TrR_TrNId = @TrNId
return @Opis
END
