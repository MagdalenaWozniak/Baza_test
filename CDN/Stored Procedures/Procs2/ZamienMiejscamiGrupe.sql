create procedure cdn.ZamienMiejscamiGrupe @Up int, @GrupaIn int
 as
 set nocount on
 declare @PriorytetIn int,
    @PriorytetOut int,
    @GrupaOut int
 select @PriorytetIn = gpr_priorytet from cdn.grupypotracen where gpr_gprid = @GrupaIn
 if @Up > 0
  begin
   select @GrupaOut = gpr_gprid, @PriorytetOut =  gpr_priorytet from cdn.grupypotracen where gpr_priorytet = (select max(gpr_priorytet) from cdn.grupypotracen    where gpr_priorytet < @PriorytetIn)
  end
 else
  begin
   select @GrupaOut = gpr_gprid, @PriorytetOut =  gpr_priorytet from cdn.grupypotracen where gpr_priorytet = (select min(gpr_priorytet) from cdn.grupypotracen    where gpr_priorytet > @PriorytetIn)
  end
 if @GrupaOut is not null
  begin
   update cdn.grupypotracen set gpr_priorytet = @PriorytetIn where gpr_gprid = @GrupaOut
   update cdn.grupypotracen set gpr_priorytet = @PriorytetOut where gpr_gprid = @GrupaIn
  end
 set nocount off
