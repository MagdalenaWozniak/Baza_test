CREATE PROCEDURE [CDN].[IGaleria_ImportFormyPlatnosci]
  @TypChr                nvarchar(2),
  @IGFPl_IGFPlIdChr                 nvarchar(11),
  @IGFPl_Nazwa      nvarchar(50),
  @IGFPl_AktywnaChr                 nvarchar(2)
AS
  SET NOCOUNT ON
  DECLARE
  @Typ                             INT,
  @IGFPl_IGFPlId                   INT,
  @IGFPl_Aktywna                   TINYINT,
  @ESS_ESSID                       INT
  SELECT
    @Typ                  = CONVERT(INT,@TypChr),
    @IGFPl_IGFPlId        = CONVERT(INT,@IGFPl_IGFPlIdChr),
    @IGFPl_Aktywna        = CONVERT(TINYINT,@IGFPl_AktywnaChr)
  IF @Typ <> 2
  RETURN
  select  top 1  @ESS_ESSID = ESS_ESSId from cdn.eSklepStanowiska where ESS_typ = 2
  IF @ESS_ESSID IS NULL
  RETURN
  IF NOT EXISTS ( SELECT ESF_IGFPlId FROM CDN.eSklepFormyPlatnosci WHERE ESF_IGFPlId = @IGFPl_IGFPlId AND ESF_ESSId = @ESS_ESSID)
   INSERT INTO [CDN].[eSklepFormyPlatnosci]
           ([ESF_ESSId]
           ,[ESF_IGFPlId]
           ,[ESF_FPlId]
           ,[ESF_Nazwa]
           ,[ESF_Aktywna])
     VALUES
           (@ESS_ESSID
           ,@IGFPl_IGFPlId
           ,0
           ,@IGFPl_Nazwa
           ,@IGFPl_Aktywna)
  ELSE
    UPDATE  CDN.eSklepFormyPlatnosci
    SET ESF_Nazwa = @IGFPl_Nazwa
       ,ESF_Aktywna = @IGFPl_Aktywna
    WHERE
       ESF_IGFPlId = @IGFPl_IGFPlId AND ESF_ESSId = @ESS_ESSID
SET NOCOUNT OFF
