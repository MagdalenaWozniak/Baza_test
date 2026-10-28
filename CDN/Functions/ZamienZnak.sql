create function cdn.ZamienZnak(@_Wartosc nvarchar(128))
returns decimal(14,4)
 as
 begin
  declare @RetVal decimal(14,4)
  if len(rtrim(@_Wartosc)) > 0
  begin
   declare @i int, @char nvarchar(1), @newStr nvarchar(128)
   set @i = 0
   set @newStr = ''
   while @i <= len(rtrim(@_Wartosc))
   begin
    set @char = substring(@_Wartosc, @i, 1)
    if @char = ','
     set @char = '.'
    set @newStr = @newStr + @char
    set @i = @i + 1
   end
   set @RetVal = @newStr
  end
  return @RetVal
 end
