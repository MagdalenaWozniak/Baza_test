CREATE  FUNCTION CDN.FirmaCfgWartosc(@firNumer INT, @pcId INT)
RETURNS NVARCHAR(512)
BEGIN
  IF @pcId = 0  RETURN CAST(LTRIM(RTRIM(IsNull((SELECT Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer=@firNumer), ''))) AS NVARCHAR(512))
  RETURN cdn.PieczatkaFirmyWartosc(@firNumer, @pcId)
END
