Create procedure [CDN].OKasujKierownikaCentrum
@IdZapisu int
as
begin try
declare @s nvarchar(128)
declare @set int
 exec cdn.SynchStrPodlXL @pWynik = @set OUTPUT
 if @set = 1
  return
DELETE FROM CDN.CentraKierownicy
 WHERE CNK_CnkId = @IdZapisu
end try
begin catch
  set @s = '##OPT32407##%%element%%=kierownika centrum##'
        raiserror(@s, 16, 1)
end catch
