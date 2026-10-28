Create procedure [CDN].OAktualizujPracownikaCentrum
@IdCentrum int,
@IdPracownika int,
@OkresOd datetime,
@OkresDo datetime
as
begin try
declare @s nvarchar(128)
declare @set int
 exec cdn.SynchStrPodlXL @pWynik = @set OUTPUT
 if @set = 1
  return
UPDATE [CDN].PracEtaty
   SET PRE_CntId = @IdCentrum
 WHERE PRE_PraId = @IdPracownika
 and PRE_DataOd = @OkresOd and Pre_DataDo = @OkresDo
end try
begin catch
  set @s = '##OPT32408##%%element%%=centrum##'
        raiserror(@s, 16, 1)
end catch
