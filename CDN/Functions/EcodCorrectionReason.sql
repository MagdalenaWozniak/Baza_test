CREATE FUNCTION CDN.EcodCorrectionReason( @faId INT )
RETURNS NVARCHAR(350)
AS
BEGIN
 DECLARE  @correctionReason  NVARCHAR(350)
 SELECT  TOP 1 @correctionReason = CAST(DAT_WartoscTxt AS NVARCHAR(350)) FROM cdn.DokAtrybuty WHERE DAt_TrNId=@faId AND DAt_Kod = 'CORRECTIONREASON' ORDER BY DAT_DATID
 IF @correctionReason IS NULL
  SELECT TOP 1 @correctionReason = CAST(IsNull(TrN_Opis, '')  AS NVARCHAR(350)) FROM cdn.TraNag  WHERE TrN_TrNId = @faID
 IF @correctionReason IS NULL   SET @correctionReason = N''
 RETURN @correctionReason
END
