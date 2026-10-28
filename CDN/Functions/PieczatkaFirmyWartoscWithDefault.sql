CREATE FUNCTION CDN.PieczatkaFirmyWartoscWithDefault(@firNumer INT, @pieczatkaId INT, @defaultValue NVARCHAR(512))
  RETURNS     NVARCHAR(512)
  AS
  BEGIN
   DECLARE @result NVARCHAR(512)
   SET @result = CDN.PieczatkaFirmyWartosc(@firNumer, @pieczatkaId)
   IF @result IS NULL OR @result = '' SET @result = @defaultValue
   RETURN @result
  END
