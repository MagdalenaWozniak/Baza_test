create function cdn.PobierzDateUrodzenia(@Pesel nvarchar(11))
returns datetime
 as
 begin
  declare
   @dt datetime,
   @m nvarchar(2),
   @y nvarchar(4),
   @d nvarchar(2),
   @date nvarchar(13),
   @m2 int
   set @d = substring(@Pesel, 5, 2)
   set @m = substring(@Pesel, 3, 2)
   set @y = substring(@Pesel, 1, 2)
   if @m > 0 and @m < 13
    set @y = '19' + @y
   else
   begin
    set @y = '20' + @y
    set @m2 = cast(@m as int)
    set @m2 = @m2 - 20
    set @m = CAST(@m2 as nvarchar(2))
   end
  set @date = @y + '-' + @m + '-' + @d
  set @dt = convert(datetime, @date, 120)
  return @dt
 end
