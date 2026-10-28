CREATE     FUNCTION CDN.SlownieSegmentEN(@p_Num integer,@p_part NVARCHAR(10))
RETURNS NVARCHAR(50)
AS
BEGIN
IF @p_Num=0   Return ''
If @p_Num=1   Return 'one ' + @p_part
IF @p_Num>999 Return 'Wrong number (>999)'
DECLARE @set INTEGER, @dzi INTEGER, @jed INTEGER
DECLARE @segment NVARCHAR(255)
SET @segment = ''
SET @set = (@p_Num/100)
SET @dzi = (@p_Num - 100*@set)/10
SET @jed = (@p_Num - 100*@set - 10*@dzi)
SET @segment = CASE @set
        WHEN 9 THEN     'nine hundred '
        WHEN 8 THEN     'eight hundred '
        WHEN 7 THEN     'seven hundred '
        WHEN 6 THEN     'six hundred '
        WHEN 5 THEN     'five hundred '
        WHEN 4 THEN     'four hundred '
        WHEN 3 THEN     'three hundred '
        WHEN 2 THEN     'two hundred '
        WHEN 1 THEN     'one hundred '
        ELSE ''
END
SET @segment = @segment + CASE @dzi
        WHEN 9 THEN     'ninety '
        WHEN 8 THEN     'eighty '
        WHEN 7 THEN     'seventy '
        WHEN 6 THEN     'sixty '
        WHEN 5 THEN     'fifty '
        WHEN 4 THEN     'forty '
        WHEN 3 THEN     'thirty '
        WHEN 2 THEN     'twenty '
        WHEN 1 THEN
                CASE @jed
                        WHEN 9 THEN     'nineteen '
                        WHEN 8 THEN     'eighteen '
                        WHEN 7 THEN     'seventeen '
                        WHEN 6 THEN     'sixteen '
                        WHEN 5 THEN     'fifteen '
                        WHEN 4 THEN     'fourteen '
                        WHEN 3 THEN     'thirteen '
                        WHEN 2 THEN     'twelve '
                        WHEN 1 THEN     'eleven '
                        WHEN 0 THEN     'ten '
                END
        ELSE ''
        END
If @dzi <> 1
BEGIN
  SET @segment = @segment + CASE @jed
                WHEN 9 THEN 'nine '
                WHEN 8 THEN 'eight '
                WHEN 7 THEN 'seven '
                WHEN 6 THEN 'six '
                WHEN 5 THEN 'five '
                WHEN 4 THEN 'four '
                WHEN 3 THEN 'three '
                WHEN 2 THEN 'two '
                WHEN 1 THEN 'one '
    ELSE ''
                END
END
RETURN (@segment + @p_part)
END
