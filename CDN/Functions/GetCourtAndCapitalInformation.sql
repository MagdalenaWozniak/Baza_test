CREATE  FUNCTION CDN.GetCourtAndCapitalInformation(@pcID INT)
RETURNS NVARCHAR(350)
BEGIN
 DECLARE @CourtAndCapitalInformation NVARCHAR(350)
 SET @CourtAndCapitalInformation = ''
 DECLARE @tekst  nvarchar(254)
 SET @tekst = ''
 SET @tekst = cdn.PieczatkaFirmyWartosc(1174, @pcID)
 IF RTRIM(LTRIM(@tekst)) <> ''
  SET @CourtAndCapitalInformation = 'Kapitał wpłacony: ' + RTRIM(@tekst)
 SET @tekst = cdn.PieczatkaFirmyWartosc(1173, @pcID)
 IF RTRIM(LTRIM(@tekst)) <> ''
  SET @CourtAndCapitalInformation = 'Kapitał zakładowy: ' + RTRIM(@tekst) + ' ' + LTRIM(RTRIM(@CourtAndCapitalInformation))
 SET @tekst = cdn.PieczatkaFirmyWartosc(1171, @pcID)
 IF RTRIM(LTRIM(@tekst)) <> ''
  SET @CourtAndCapitalInformation = RTRIM(@tekst) + ' ' + LTRIM(RTRIM(@CourtAndCapitalInformation))
 Select @tekst = IsNull(Fir_Wartosc, '') From cdn.firma Where fir_numer=1172
 SET @tekst = cdn.PieczatkaFirmyWartosc(1172, @pcID)
 IF RTRIM(LTRIM(@tekst)) <> ''
  SET @CourtAndCapitalInformation = 'KRS: ' + RTRIM(@tekst) + ' ' + LTRIM(RTRIM(@CourtAndCapitalInformation))
 RETURN @CourtAndCapitalInformation
END
