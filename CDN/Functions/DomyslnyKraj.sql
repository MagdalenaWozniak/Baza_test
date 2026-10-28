create function cdn.DomyslnyKraj(@Kraj nvarchar(40))
returns nvarchar(40)
 as
 begin
  if (len(@Kraj) = 0)
   return 'Polska'
  return @Kraj
 end
