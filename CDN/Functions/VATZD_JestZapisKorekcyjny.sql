CREATE FUNCTION CDN.VATZD_JestZapisKorekcyjny( @DeNId int)
RETURNS int
AS
BEGIN
 declare @Result int; Set @Result = 0;
 if exists(
  select * from cdn.VatNag where VaN_VaNId in (
  select DkE_WartoscL from cdn.DeklElem
  where
  DkE_DkNID = @DeNId
  and DkE_Numer = 1
  union
  select VaZ_VaNId_ZK from CDN.VatZD
  where
  VaZ_DkNId = @DeNId and VaZ_VaNId_ZK is Not Null
  )
 )
  Set @Result = 1;
 else
  Set @Result = 0;
 return @Result
END
