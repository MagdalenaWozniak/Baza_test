CREATE PROCEDURE CDN.OFF_AktualizujPltPromocje
      @PPr_PrmIDChr                       nvarchar(11) ,
      @PPr_PltIDChr                       nvarchar(11) ,
      @PPr_WartoscChr                     nvarchar(20) ,
      @PPr_TS_XL                          nvarchar(11)
AS
  SET NOCOUNT ON
  DECLARE
      @PPr_PrmID                       INTEGER       ,
      @PPr_PltID                       INTEGER       ,
      @PPr_Wartosc                     DECIMAL(15,4) ,
      @Prm_LastMod                     INT        ,
      @Komunikat                       nvarchar(255)
 SELECT
      @PPr_PrmID        = CONVERT(INTEGER,@PPr_PrmIDChr)       ,
      @PPr_PltID        = CONVERT(INTEGER,@PPr_PltIDChr)       ,
      @PPr_Wartosc      = CONVERT(DECIMAL(15,4),@PPr_WartoscChr)
   select @Prm_LastMod = Prm_LastMod from CDN.PrmKarty where PRM_Id = @PPr_PrmId
   IF @Prm_LastMod <> CONVERT(INTEGER,@PPr_TS_XL) RETURN
      INSERT INTO CDN.PltPromocje( PPr_PrmID ,PPr_PltID ,PPr_Wartosc)
      VALUES                     ( @PPr_PrmID,@PPr_PltID,@PPr_Wartosc)
  SET NOCOUNT OFF
