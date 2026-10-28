CREATE  FUNCTION CDN.CzasPracyWNocy(@Strefa int,@God datetime,@Gdo datetime,@Nod datetime,@Ndo datetime)
RETURNS INT
AS
BEGIN
  if isnull(@Strefa,1)=1 return 0
  if @Gdo<=@God set @Gdo=dateadd(day,1,@Gdo)
  -- TFS:154711
   if @Ndo > dateadd(HH,24,@Nod) set @Ndo=dateadd(HH,-24,@Ndo)
  --
  return isnull(datediff(minute,case when @God>dateadd(day,-1,@Ndo) then null else @God end,case when @Gdo>dateadd(day,-1,@Ndo) then dateadd(day,-1,@Ndo) else @Gdo end),0)
  + isnull(datediff(minute,case when @God<@Nod then @Nod when @God>@Ndo then null else @God end,case when @Gdo<@Nod then null when @Gdo>@Ndo then @Ndo else @Gdo end),0)
 -- TFS:154711
  + isnull(datediff(minute,case when @God>@Nod then @Nod when @God>@Ndo then null end,case when @Gdo<dateadd(day,1,@Ndo) then null when @Gdo>@Ndo then @Ndo end),0)
 --
END
