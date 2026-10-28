CREATE  PROCEDURE [CDN].[IGaleria_ImportKategorie]
  @IGK_IGKIdChr                     nvarchar(11),
  @IGK_ParentIdChr                  nvarchar(11),
  @IGK_Nazwa      nvarchar(50),
  @IGK_AktywnaChr                   nvarchar(50)
AS
  SET NOCOUNT ON
  DECLARE
  @IGK_IGKId                     INT,
  @IGK_ParentId                  INT,
  @IGK_Aktywna                   TINYINT
  SELECT
    @IGK_IGKId            = CONVERT(INT,@IGK_IGKIdChr),
    @IGK_ParentId         = CONVERT(INT,@IGK_ParentIdChr),
    @IGK_Aktywna          = CONVERT(TINYINT,@IGK_AktywnaChr)
  IF NOT EXISTS ( SELECT IGK_IGKId FROM CDN.IGaleriaKategorie WHERE IGK_IGKId = @IGK_IGKId)
    INSERT INTO [CDN].[IGaleriaKategorie]
           ([IGK_IGKId]
           ,[IGK_ParentId]
           ,[IGK_Nazwa]
           ,[IGK_Aktywna])
    VALUES
           (@IGK_IGKId
           ,@IGK_ParentId
           ,@IGK_Nazwa
           ,@IGK_Aktywna)
  ELSE
    UPDATE  CDN.IGaleriaKategorie
    SET IGK_ParentId = @IGK_ParentId
       ,IGK_Nazwa = @IGK_Nazwa
       ,IGK_Aktywna = @IGK_Aktywna
    WHERE
       IGK_IGKId = @IGK_IGKId
SET NOCOUNT OFF
