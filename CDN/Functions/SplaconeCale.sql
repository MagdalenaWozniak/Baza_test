create function cdn.SplaconeCale (@Rodzaj tinyint, @Wartosc decimal(15,2), @Splacono decimal(15,2), @Splacone tinyint)
returns tinyint
 as
 begin
  if @Splacone = 1
   return 1
  if @Rodzaj = 0 and @Splacono = @Wartosc
   return 1
  return 0
 end
