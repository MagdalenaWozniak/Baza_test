Create procedure [CDN].OZnajdzKierownikaCentrum
@IdCentrum int,
@OkresOd datetime,
@OkresDo datetime,
@PracId int,
@Rodzaj bit
as
begin try
declare @s nvarchar(128)
declare @set int
 exec cdn.SynchStrPodlXL @pWynik = @set OUTPUT
 if @set = 1
  return
  if @Rodzaj = 0
  begin
 select * from cdn.CentraKierownicy where
   CNK_Rodzaj = 0
   and
   (
   (@OkresOd between CNK_OkresOd and CNK_OkresDo) or
   (@OkresDo between CNK_OkresOd and CNK_OkresDo) or
   (@OkresOd < CNK_OkresOd and  @OkresDo > CNK_OkresDo)
   )
   and CNK_CntId = @IdCentrum
   UNION ALL
  select * from cdn.CentraKierownicy where
   CNK_Rodzaj = 1 and CNK_PraId = @PracId
   and
   (
   (@OkresOd between CNK_OkresOd and CNK_OkresDo) or
   (@OkresDo between CNK_OkresOd and CNK_OkresDo) or
   (@OkresOd < CNK_OkresOd and  @OkresDo > CNK_OkresDo)
   )
   and CNK_CntId = @IdCentrum
  end
  else if @Rodzaj = 1
  begin
   select * from cdn.CentraKierownicy where
   CNK_Rodzaj in (0,1) and CNK_PraId = @PracId
   and
   (
   (@OkresOd between CNK_OkresOd and CNK_OkresDo) or
   (@OkresDo between CNK_OkresOd and CNK_OkresDo) or
   (@OkresOd < CNK_OkresOd and  @OkresDo > CNK_OkresDo)
   )
   and CNK_CntId = @IdCentrum
  end
end try
begin catch
end catch
