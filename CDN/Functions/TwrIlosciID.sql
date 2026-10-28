CREATE FUNCTION CDN.TwrIlosciID ( @TwrId INT, @MagId INT, @Data DATETIME )
 RETURNS     INT
AS
BEGIN
 DECLARE @TwIId Int
 IF IsNull(@MagId,0) = 0
    SELECT TOP 1 @TwIId = TwI_TwIId From CDN.TwrIlosci Where TwI_TwrId = @TwrId And TwI_MagId Is Null And TwI_Data <= @Data ORDER BY TwI_Data DESC
 ELSE
    SELECT TOP 1 @TwIId = TwI_TwIId From CDN.TwrIlosci Where TwI_TwrId = @TwrId And TwI_MagId = @MagId And TwI_Data <= @Data ORDER BY TwI_Data DESC
 RETURN @TwIId
END
