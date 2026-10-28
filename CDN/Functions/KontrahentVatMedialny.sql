CREATE FUNCTION CDN.KontrahentVatMedialny (@DokId int)
returns int
as
begin
declare @result int
set @result = 0
if((select VaN_PodmiotTyp from cdn.VatNag where VaN_VaNID = @DokId) = 1)
  select @result = isnull(Knt_Medialny, 0)
  from cdn.kontrahenci join cdn.vatnag on Knt_KntId = VaN_PodID
  where Knt_KntId = VaN_PodID and VaN_VaNID = @DokId
return @result
end
