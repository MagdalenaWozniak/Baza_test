create function cdn.KonwertujAdresWezla (@OldAdres varchar(255))
returns varchar(255)
 as
 begin
declare @AdresLen int, @Frag varchar(10), @Char varchar(6), @FragLen int, @NewAdres varchar(128), @i int
  set @i = 0
  set @AdresLen = LEN(@OldAdres)
  set @Char = ''
  set @Frag = ''
  set @NewAdres = ''
  set @FragLen = 0
  if @AdresLen > 1
  begin
   while @i <= @AdresLen
   begin
    set @Char = SUBSTRING(@OldAdres, @AdresLen - @i, 1)
    set @Frag = @Char + @Frag
    if @Char <> '.'
     set @FragLen = @FragLen + 1
    if @Char = '.'
    begin
     if @FragLen < 3
     begin
      if @FragLen = 1
       set @Char = '.' + SPACE(2)
      if @FragLen = 2
       set @Char = '.' + SPACE(1)
     end
     set @FragLen = 0
    end
    set @NewAdres = @Char + @NewAdres
    set @i = @i + 1
   end
  end
  return @NewAdres
 end
