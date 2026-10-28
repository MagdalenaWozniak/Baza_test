CREATE     FUNCTION CDN.SlownieSegmentPL(@p_Num integer,@p_part NVARCHAR(10))
RETURNS NVARCHAR(50)
AS
BEGIN
IF @p_Num=0   Return ''
If @p_Num=1   Return 'jeden ' + @p_part
IF @p_Num>999 Return 'Błędna liczba (>999)'
DECLARE @set INTEGER, @dzi INTEGER, @jed INTEGER
DECLARE @segment NVARCHAR(255)
SET @segment = ''
SET @set = (@p_Num/100)
SET @dzi = (@p_Num - 100*@set)/10
SET @jed = (@p_Num - 100*@set - 10*@dzi)
SET @segment = CASE @set
        WHEN 9 THEN     'dziewięćset '
        WHEN 8 THEN     'osiemset '
        WHEN 7 THEN     'siedemset '
        WHEN 6 THEN     'sześćset '
        WHEN 5 THEN     'pięćset '
        WHEN 4 THEN     'czterysta '
        WHEN 3 THEN     'trzysta '
        WHEN 2 THEN     'dwieście '
        WHEN 1 THEN     'sto '
        ELSE ''
END
SET @segment = @segment + CASE @dzi
        WHEN 9 THEN     'dziewięćdziesiąt '
        WHEN 8 THEN     'osiemdziesiąt '
        WHEN 7 THEN     'siedemdziesiąt '
        WHEN 6 THEN     'sześćdziesiąt '
        WHEN 5 THEN     'pięćdziesiąt '
        WHEN 4 THEN     'czterdzieści '
        WHEN 3 THEN     'trzydzieści '
        WHEN 2 THEN     'dwadzieścia '
        WHEN 1 THEN
                CASE @jed
                        WHEN 9 THEN     'dziewiętnaście '
                        WHEN 8 THEN     'osiemnaście '
                        WHEN 7 THEN     'siedemnaście '
                        WHEN 6 THEN     'szesnaście '
                        WHEN 5 THEN     'piętnaście '
                        WHEN 4 THEN     'czternaście '
                        WHEN 3 THEN     'trzynaście '
                        WHEN 2 THEN     'dwanaście '
                        WHEN 1 THEN     'jedenaście '
                        WHEN 0 THEN     'dziesięć '
                END
        ELSE ''
        END
If @dzi <> 1
BEGIN
  SET @segment = @segment + CASE @jed
                WHEN 9 THEN 'dziewięć '
                WHEN 8 THEN 'osiem '
                WHEN 7 THEN 'siedem '
                WHEN 6 THEN 'sześć '
                WHEN 5 THEN 'pięć '
                WHEN 4 THEN 'cztery '
                WHEN 3 THEN 'trzy '
                WHEN 2 THEN 'dwa '
                WHEN 1 THEN 'jeden '
    ELSE ''
        END
END
RETURN (@segment + @p_part)
END
