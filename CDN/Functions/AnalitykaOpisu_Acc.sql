CREATE FUNCTION CDN.AnalitykaOpisu_Acc(@opis nvarchar(4000), @wymiar nvarchar(4000))
RETURNS nvarchar(4000)
AS
BEGIN
 declare @Result nvarchar(4000) = CDN.AnalitykaOpisu(@opis, @wymiar);
  IF CHARINDEX(' ', @Result) <> 0
    set @Result = REPLACE ( @Result, ' ' , '_') ;
  -- 238913
  --if CHARINDEX('-', @Result) <> 0
  --  set @Result = REPLACE ( @Result, '-' , '_') ;
  if CHARINDEX('.', @Result) <> 0
    set @Result = REPLACE ( @Result, '.' , '_') ;
  if CHARINDEX('''', @Result ) <> 0
    set @Result = REPLACE ( @Result, '''' , '_') ;
 return @Result
END
