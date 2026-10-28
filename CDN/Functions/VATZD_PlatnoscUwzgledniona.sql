CREATE FUNCTION CDN.VATZD_PlatnoscUwzgledniona( @TerminPlatnosci DateTime, @VaNId Int)
RETURNS int
AS
BEGIN
 declare @status int
  set @TerminPlatnosci = cdn.fn_GetWorkingDayAfter(@TerminPlatnosci);
 if exists( select * from cdn.VATZD join CDN.DeklNag on (VaZ_DkNId=DkN_DkNID)
    where DkN_Finalna = 1 and VAZ_VaNId = @VaNId and VaZ_Termin = @TerminPlatnosci )
  set @status = 1
 else
  set @status = 0
 return @status
END
