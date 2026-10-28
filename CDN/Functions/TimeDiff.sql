CREATE FUNCTION cdn.TimeDiff( @dataOd DATETIME,  @dataDo DATETIME)
RETURNS NVARCHAR(16)
AS
BEGIN
 DECLARE @kod NVARCHAR(16), @hh NVARCHAR(10),  @mm NVARCHAR(2)
 DECLARE @mi INT
 SELECT @mi = DateDiff(mi, @dataOd, @dataDo)
    SET @hh = Cast(@mi/60 As NVARCHAR(10))
 SET @hh = CASE WHEN LEN(@hh)<2 THEN REPLICATE(N'0', 2 - LEN(@hh)) + @hh ELSE @hh END
    SET @mm = Cast(@mi%60 As NVARCHAR(2))
 SET @mm = CASE WHEN LEN(@mm)<2 THEN REPLICATE(N'0', 2 - LEN(@mm)) + @mm ELSE @mm END
 SET @kod = @hh + N':' + @mm + N':00'
 RETURN LTRIM(RTRIM(@kod))
END
