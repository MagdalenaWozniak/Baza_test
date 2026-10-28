create function cdn.PodajPlec(@Imie nvarchar(30), @Pesel nvarchar(11))
returns nvarchar
 as
 begin
  if len(@Pesel) > 0
  begin
   declare @s10 nvarchar
   set @s10 = substring(@Pesel, 10, 1)
   if @s10 in ('1', '3', '5', '7', '9')
    return 'M'
   else if @s10 = 0
    goto LABEL_1
   else
    return 'K'
  end
LABEL_1:
  declare @s nvarchar
  set @s = substring(@Imie, len(@Imie), 1)
  if @s = 'a' and @Imie not in ('Bonawentura', 'Kosma', 'Kuba', 'Barnaba', 'Jarema', 'Zawisza', 'Żegota')
   return 'K'
  else if @Imie not in ('Beatrycze', 'Dolores', 'Doris', 'Inez')
   return 'M'
  return 'M'
 end
