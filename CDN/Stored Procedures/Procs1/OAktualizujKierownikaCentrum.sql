Create procedure [CDN].OAktualizujKierownikaCentrum
@IdZapisu int,
@IdCentrum int,
@IdPracownika int,
@Rodzaj smallint,
@OkresOd datetime,
@OkresDo datetime
as
begin try
declare @s nvarchar(128)
declare @set int
 exec cdn.SynchStrPodlXL @pWynik = @set OUTPUT
 if @set = 1
  return
UPDATE [CDN].[CentraKierownicy]
   SET [CNK_PraId] = @IdPracownika
      ,[CNK_CntId] = @IdCentrum
      ,[CNK_Rodzaj] = @Rodzaj
      ,[CNK_OkresOd] = @OkresOd
      ,[CNK_OkresDo] = @OkresDo
   ,[CNK_OpeModId] = cdn.GetXLOperatorID()
      ,[CNK_TS_Mod] = getdate()
 WHERE CNK_CnkId = @IdZapisu
end try
begin catch
  set @s = '##OPT32408##%%element%%=centrum##'
        raiserror(@s, 16, 1)
end catch
