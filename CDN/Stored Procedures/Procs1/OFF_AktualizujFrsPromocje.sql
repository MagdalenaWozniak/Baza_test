CREATE PROCEDURE CDN.OFF_AktualizujFrsPromocje
      @FPR_PrmIdChr                       nvarchar(11),
      @FPR_FrsIdChr                       nvarchar(11),
      @FPR_TS_XL                          nvarchar(11)
AS
  SET NOCOUNT ON
  DECLARE
      @FPR_PrmId                       INTEGER        ,
      @FPR_FrsId                       INTEGER        ,
      @Prm_LastMod                     INT        ,
      @Komunikat                       nvarchar(255)
 SELECT
      @FPR_PrmId        = CONVERT(INTEGER,@FPR_PrmIdChr)       ,
      @FPR_FrsId        = CONVERT(INTEGER,@FPR_FrsIdChr)
   select @Prm_LastMod = Prm_LastMod from CDN.PrmKarty where PRM_Id = @FPR_PrmId
   IF @Prm_LastMod <> CONVERT(INTEGER,@FPR_TS_XL) RETURN
      INSERT INTO CDN.FrsPromocje( FPR_PrmId ,FPR_FrsId )
      VALUES                     ( @FPR_PrmId,@FPR_FrsId)
  SET NOCOUNT OFF
