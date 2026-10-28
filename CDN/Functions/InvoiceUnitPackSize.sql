CREATE FUNCTION CDN.InvoiceUnitPackSize( @TrEId INT )
RETURNS FLOAT
AS
BEGIN
 IF CDN.PackInUse(@TrEId) = 1
 BEGIN
  DECLARE @packSize FLOAT
  SELECT @packSize = TrE_Ilosc/TrE_IloscJM
  FROM cdn.TraElem WHERE TrE_TrEId = @TrEId
  IF @packSize IS null
   SET @packSize = 1
  RETURN ROUND(@packSize,4)
 END
 RETURN 1
END
