CREATE  FUNCTION CDN.FirmaNazwaZPieczatki(@pcId INT)
RETURNS NVARCHAR(175)
BEGIN
 RETURN Cast(cdn.PieczatkaFirmyWartosc(1156, @pcId)
  + ' ' +  cdn.PieczatkaFirmyWartosc(1157, @pcId)
  + ' ' +  cdn.PieczatkaFirmyWartosc(2166, @pcId)
 As NVARCHAR(175))
END
