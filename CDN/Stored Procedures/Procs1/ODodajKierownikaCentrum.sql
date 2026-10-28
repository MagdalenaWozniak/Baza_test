Create procedure [CDN].ODodajKierownikaCentrum
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
INSERT INTO [CDN].[CentraKierownicy]
           ([CNK_PraId]
           ,[CNK_CntId]
           ,[CNK_Rodzaj]
           ,[CNK_Kod]
           ,[CNK_OkresOd]
           ,[CNK_OkresDo]
           ,[CNK_OpeZalId]
           ,[CNK_StaZalId]
           ,[CNK_TS_Zal]
           ,[CNK_OpeModId]
           ,[CNK_StaModId]
           ,[CNK_TS_Mod])
     VALUES
           (@IdPracownika
           ,@IdCentrum
           ,@Rodzaj
           ,''
           ,@OkresOd
           ,@OkresDo
           ,cdn.GetXLOperatorID()
           ,1
           ,getdate()
           ,cdn.GetXLOperatorID()
           ,1
           ,getdate())
end try
begin catch
  set @s = '##OPT32409##%%element%%=kierownika centrum##'
        raiserror(@s, 16, 1)
end catch
