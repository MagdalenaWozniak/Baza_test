create function cdn.UtworzAdresWezla (@BiezAdres varchar(255), @LP int)
returns varchar(255)
 as
 begin
  declare
   @Adres varchar(255),
   @Node varchar(255),
   @strLP varchar(64),
   @i int
  set @Node = ''
  set @strLP = convert(varchar(64), @LP, 120)
  set @i = 0
  if len(@strLP) < 3
  begin
   while @i < (3 - len(@strLP))
   begin
    set @Node = @Node + ' '
    set @i = @i + 1
   end
  end
  set @Node = @Node + rtrim(@strLP)
  if @BiezAdres = ''
   set @Adres = @Node
  else
   set @Adres = @BiezAdres + '.' + @Node
  return @Adres
 end
