Create procedure [CDN].OKasujKierownikowCentrum
as
begin try
declare @s nvarchar(128)
declare @set int
 exec cdn.SynchStrPodlXL @pWynik = @set OUTPUT
 if @set = 1
  return
DELETE FROM CDN.CentraKierownicy where CNK_Rodzaj = 0
end try
begin catch
  set @s = '##OPT32407##%%element%%=kierownika centrum##'
        raiserror(@s, 16, 1)
end catch
