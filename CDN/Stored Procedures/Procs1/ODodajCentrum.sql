create procedure [CDN].[ODodajCentrum]
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
declare @Poziom smallint,
   @AdresWezla varchar(255),
   @LP int,
   @AddMet tinyint
  set @Poziom = 1
  set @AdresWezla = ''
  set @AddMet = 0
  if @ParentId > 0
  begin
   set @AddMet = 1
   select @Poziom = CNT_Poziom + 1, @AdresWezla = CNT_AdresWezla from cdn.[Centra] where CNT_CntId = @ParentId
   select @LP = max(CNT_Lisc) from cdn.Centra where CNT_ParentId = @ParentId
  end
  else
  begin
   select @Poziom = CNT_Poziom + 1, @AdresWezla = CNT_AdresWezla from cdn.[Centra] where CNT_CntId = 3
   select @LP = max(CNT_Lisc) from cdn.Centra where CNT_ParentId = 3
   set @ParentId = 3
  end
  if @LP is null
   set @LP = 1
  else
   set @LP = @LP + 1
  set @AdresWezla = cdn.UtworzAdresWezla(@AdresWezla, @LP)
INSERT INTO [CDN].[Centra]
           ([CNT_Kod]
           ,[CNT_Nazwa]
           ,[CNT_ParentId]
           ,[CNT_Nieaktywny]
           ,[CNT_AdresWezla]
           ,[CNT_Poziom]
           ,[CNT_Lisc]
           ,[CNT_AddMethod]
           ,[CNT_ImpId]
           ,[CNT_Last]
           ,[CNT_OpeZalId]
           ,[CNT_StaZalId]
           ,[CNT_TS_Zal]
           ,[CNT_OpeModId]
           ,[CNT_StaModId]
           ,[CNT_TS_Mod])
     VALUES
           (@Kod
           ,@Nazwa
           ,@ParentId
           ,@Nieaktywny
           ,@AdresWezla
           ,@Poziom
           ,@LP
           ,1
           ,0
           ,0
           ,cdn.GetXLOperatorID()
           ,1
           ,getdate()
           ,cdn.GetXLOperatorID()
           ,1
           ,getdate())
 --[logowanie]
 declare @obj_id int
 set @obj_id = scope_identity()
 declare @oid int
 set @oid = cdn.GetXLOperatorID()
 if @oid > 0
 begin
  exec CDN.RejestrOperacjiContextInfo @oid
  exec CDN.RejestrOperacjiDodaj 24503, 0, @obj_id, @Nazwa, 1, ''
 end
end try
begin catch
  set @s = '##OPT32409##%%element%%=centrum##'
        raiserror(@s, 16, 1)
end catch
