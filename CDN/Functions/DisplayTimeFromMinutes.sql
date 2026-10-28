CREATE FUNCTION cdn.DisplayTimeFromMinutes(@minutes INT)
RETURNS NVARCHAR(20)
AS
BEGIN
DECLARE @hours int, @mins int
DECLARE @mm NVARCHAR(2)
SET @hours=@minutes / 60
SET @mins=@minutes % 60
SET @mm = CAST(@mins As NVARCHAR(2))
SET @mm = CASE WHEN LEN(@mm)<2 THEN REPLICATE('0', 2 - LEN(@mm)) + @mm ELSE @mm END
RETURN RTRIM(CAST(@hours as char(18))) + ':' + @mm
END
