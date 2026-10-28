CREATE PROCEDURE [CDN].[IGaleria_ImportDefAtrWartosci]
  @IGDW_IGAIdChr        nvarchar(11),
  @IGDW_IGDWIdChr        nvarchar(11),
  @IGDW_Wartosc      nvarchar(100),
  @IGDW_AktywnaChr                  nvarchar(2)
AS
  SET NOCOUNT ON
  DECLARE
  @IGDW_IGDWId               INT,
  @IGDW_IGAId                INT,
  @IGDW_Aktywna              TINYINT
  SELECT
    @IGDW_IGDWId          = CONVERT(INT,@IGDW_IGDWIdChr),
    @IGDW_IGAId           = CONVERT(INT,@IGDW_IGAIdChr),
    @IGDW_Aktywna          = CONVERT(TINYINT,@IGDW_AktywnaChr)
  IF NOT EXISTS ( SELECT IGDW_IGAId FROM CDN.IGaleriaDefAtrWartosci WHERE IGDW_IGDWId = @IGDW_IGDWId)
     INSERT INTO [CDN].[IGaleriaDefAtrWartosci]
           ([IGDW_IGDWId]
           ,[IGDW_IGAId]
           ,[IGDW_Wartosc]
           ,[IGDW_Aktywna])
     VALUES
           (@IGDW_IGDWId
           ,@IGDW_IGAId
           ,@IGDW_Wartosc
           ,@IGDW_Aktywna)
  ELSE
    UPDATE  CDN.IGaleriaDefAtrWartosci
    SET IGDW_IGAId          = @IGDW_IGAId
       ,IGDW_Wartosc        = @IGDW_Wartosc
       ,IGDW_Aktywna        = @IGDW_Aktywna
    WHERE
       IGDW_IGDWId = @IGDW_IGDWId
SET NOCOUNT OFF
