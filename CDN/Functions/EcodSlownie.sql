CREATE   FUNCTION CDN.EcodSlownie(@p_Num decimal(15,2))
RETURNS nvarchar(255)
AS
BEGIN
        DECLARE @mln integer
        DECLARE @tys integer
        DECLARE @jed integer
        DECLARE @gr  integer
  DECLARE @segment nvarchar(255)
  IF @p_Num < 0
   SET @segment = 'minus '
  ELSE
   SET @segment = ''
        SET @p_Num = Abs(@p_Num)
        SET @mln = (@p_Num/1000000)
        SET @tys = ((@p_Num - 1000000*@mln)/1000)
        SET @jed = (@p_Num - 1000000*@mln - 1000*@tys)
        SET @gr  = (100*(@p_Num - 1000000*@mln - 1000*@tys - @jed))
  SET @segment = @segment +
   RTrim(CDN.SlownieSegmentPL(@mln, 'mln. ') +
   CDN.SlownieSegmentPL(@tys, 'tys. ') +
   CDN.SlownieSegmentPL(@jed, ''))  +
   ', '        +
   REPLACE(SPACE(2-LEN(cast(@gr As nvarchar(2)))),' ','0') +cast(@gr As nvarchar)+'/100' +
   ' PLN'
  RETURN @segment
END
