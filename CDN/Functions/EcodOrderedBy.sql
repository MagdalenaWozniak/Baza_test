CREATE FUNCTION CDN.EcodOrderedBy ( @mode INT, @FaId INT )
RETURNS     nvarchar(175)
AS
BEGIN
 DECLARE @gln VARCHAR(13), @typDok INT
 SELECT TOP 1 @gln = DAt_WartoscTxt FROM cdn.DokAtrybuty WHERE DAt_TrNId=@FaId AND DAt_Kod = 'ULTIMATECUSTOMERGLN'  ORDER BY DAT_DATID
 IF @gln IS NULL -- sprawdz skojarzone rezerwacje odbiorcy
 BEGIN
  SELECT @typDok = TrN_TypDokumentu FROM cdn.TraNag WHERE TrN_TrNId=@FaId
  IF @typDok = 302
  BEGIN
   DECLARE @ROId INT
   SELECT TOP 1 @ROId = ro.TrN_TrNId  FROM cdn.TraNag  As ro WHERE ro.TrN_TrNId IN (SELECT TrN_TrNId from cdn.Powiazania(@FaId, 302) WHERE TrN_TypDokumentu = 308)
   SELECT TOP 1 @gln = DAt_WartoscTxt FROM cdn.DokAtrybuty WHERE DAt_TrNId=@ROId AND DAt_Kod = 'ULTIMATECUSTOMERGLN'  ORDER BY DAT_DATID
  END
 END
 IF @gln IS NULL RETURN ''
 IF LTRIM(RTRIM(@gln)) = '' RETURN ''
 RETURN CDN.EcodCustomerItems(@mode, @gln)
END
