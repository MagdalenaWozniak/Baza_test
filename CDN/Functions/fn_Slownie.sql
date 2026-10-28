CREATE     FUNCTION CDN.fn_Slownie(@p_Num decimal(15,2),@p_Currency NVARCHAR(3), @p_Lang NVARCHAR(2))
RETURNS NVARCHAR(255)
AS
BEGIN
        DECLARE @mln integer
        DECLARE @tys integer
        DECLARE @jed integer
        DECLARE @gr  integer
        IF ISNULL(@p_Currency,'')='' set @p_Currency='PLN'
        SET @p_Num=Abs(@p_Num)
        SET @mln = (@p_Num/1000000)
        SET @tys = ((@p_Num - 1000000*@mln)/1000)
        SET @jed = (@p_Num - 1000000*@mln - 1000*@tys)
        SET @gr  = (100*(@p_Num - 1000000*@mln - 1000*@tys - @jed))
        RETURN
        CASE @p_Lang
                WHEN 'EN' Then CDN.SlownieSegmentEN(@mln, 'm ') + CDN.SlownieSegmentEN(@tys, 'thou. ') + CDN.SlownieSegmentEN(@jed, '')
                ELSE CDN.SlownieSegmentPL(@mln, 'mln. ') + CDN.SlownieSegmentPL(@tys, 'tys. ') + CDN.SlownieSegmentPL(@jed, '')
        END + @p_Currency +' '+REPLACE(SPACE(2-LEN(cast(@gr As NVARCHAR(2)))),' ','0') +cast(@gr As NVARCHAR)+'/100'
END
