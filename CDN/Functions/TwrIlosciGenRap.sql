CREATE FUNCTION CDN.TwrIlosciGenRap ( @TwrId INT, @MagKod NVARCHAR(20), @Data DATETIME )
 RETURNS     DECIMAL(15,4)
AS
BEGIN
 DECLARE @TwIIlosc DECIMAL(15,4), @MagId INT
 SELECT @Data = @Data - 1
 IF @MagKod = '<wszystkie>'
  BEGIN
  SELECT @MagId = NULL
  IF IsNull(@MagId,0) = 0
    SELECT TOP 1 @TwIIlosc = TwI_Ilosc From CDN.TwrIlosci Where TwI_TwrId = @TwrId And TwI_MagId Is Null And TwI_Data <= @Data ORDER BY TwI_Data DESC
  END
   IF @MagKod <> '<wszystkie>'
   BEGIN
    SELECT @MagId = Mag_MagId FROM CDN.Magazyny WHERE Mag_Symbol = @MagKod
    SELECT TOP 1 @TwIIlosc = TwI_Ilosc From CDN.TwrIlosci Where TwI_TwrId = @TwrId And TwI_MagId = @MagId And TwI_Data <= @Data ORDER BY TwI_Data DESC
   END
    IF @TwIIlosc IS NULL
      SELECT @TwIIlosc= 0
  RETURN @TwIIlosc
END
