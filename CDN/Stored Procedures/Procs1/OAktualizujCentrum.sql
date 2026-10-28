create procedure [CDN].OAktualizujCentrum
@OptimaId int,
@Kod varchar(40),
@Nazwa varchar(254),
@ParentId int,
@Nieaktywny smallint
as
begin try
declare @set int
 exec cdn.SynchStrPodlXL @pWynik = @set OUTPUT
 if @set = 1
  return
declare @s nvarchar(128)
UPDATE [CDN].[Centra]
   SET [CNT_Kod] = @Kod
      ,[CNT_Nazwa] = @Nazwa
      ,[CNT_ParentId] = @ParentId
      ,[CNT_Nieaktywny] = @Nieaktywny
   ,[CNT_OpeModId] = cdn.GetXLOperatorID()
      ,[CNT_TS_Mod] = getdate()
 WHERE CNT_CntId = @OptimaId
 --[logowanie]
 declare @oid int
 set @oid = cdn.GetXLOperatorID()
 if @oid > 0
 begin
  exec CDN.RejestrOperacjiContextInfo @oid
  exec CDN.RejestrOperacjiDodaj 24503, 0, @OptimaId, @Nazwa, 2, ''
 end
end try
begin catch
  set @s = '##OPT32408##%%element%%=centrum##'
        raiserror(@s, 16, 1)
end catch
