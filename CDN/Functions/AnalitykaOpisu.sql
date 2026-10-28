CREATE FUNCTION CDN.AnalitykaOpisu(@opis nvarchar(4000), @wymiar nvarchar(4000))
RETURNS nvarchar(4000)
AS
BEGIN
 declare @Result nvarchar(4000) = '';
 declare @Kod nvarchar(4000) = '';
 declare @Operator nvarchar(1) = NULL;
 declare @a int = charindex('<', @opis, 0);
 declare @b int = charindex('>', @opis, 0);
 while @a <> 0 and @b <> 0
 begin
  declare @single nvarchar(4000) = SubString(@opis, @a+1, @b-@a-1);
  if @wymiar is not null
  begin
   set @Kod = CDN.KodWymiaru(@single);
   if Upper(@Kod) = Upper(@wymiar)
   begin
    set @Result = CDN.AnalitykaWymiaru(@single);
    break;
   end
  end
  else
  begin
   if LEN(@Result) = 0
    set @Operator = '';
   else
    set @Operator = '-';
   set @Result = @Result + @Operator + CDN.AnalitykaWymiaru(@single);
  end
  set @a = charindex('<', @opis,  @b+1);
  set @b = charindex('>', @opis,  @b+1);
 end
 return @Result
END
