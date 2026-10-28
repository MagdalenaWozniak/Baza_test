CREATE PROCEDURE CDN.OFF_AktualizujTwrPromocje
      @TPR_PrmIdChr                       nvarchar(11)    ,
      @TPR_TwrTypChr                      nvarchar(5)     ,
      @TPR_TwrNumerChr                    nvarchar(11)    ,
      @TPR_TwgTypChr                      nvarchar(5)     ,
      @TPR_TwgNumerChr                    nvarchar(11)    ,
      @TPR_TypChr                         nvarchar(11)    ,
      @TPR_WartoscChr                     nvarchar(20)    ,
      @TPR_ProgChr                        nvarchar(20)    ,
      @TPR_Waluta                         nvarchar(3)     ,
      @TPR_FlagaNB                        nvarchar(1)     ,
      @TPR_Notatki                        nvarchar(200)   ,
      @TPR_ZstIDChr                       nvarchar(11)    ,
      @TPR_LPChr                          nvarchar(11)    ,
      @TPR_TS_XL                          nvarchar(11)    ,
      @TPR_RodzajCenyChr                  nvarchar(11)
AS
  SET NOCOUNT ON
  DECLARE
      @TPR_PrmId                       INTEGER        ,
      @TPR_TwrTyp                      SMALLINT       ,
      @TPR_TwrFirma                    INTEGER        ,
      @TPR_TwrNumer                    INTEGER        ,
      @TPR_TwrLp                       SMALLINT       ,
      @TPR_TwgTyp                      SMALLINT       ,
      @TPR_TwgFirma                    INTEGER        ,
      @TPR_TwgNumer                    INTEGER        ,
      @TPR_TwgLp                       SMALLINT       ,
      @TPR_Typ                         INTEGER        ,
      @TPR_Wartosc                     DECIMAL(15,4)  ,
      @TPR_Prog                        DECIMAL(15,4)  ,
      @TPR_ZstID                       INTEGER        ,
      @TPR_LP                          INTEGER        ,
      @Prm_LastMod                     INTEGER        ,
      @TPR_RodzajCeny                  INTEGER        ,
      @Komunikat                       nvarchar(255)
 SELECT
      @TPR_PrmId   = CONVERT(INTEGER,@TPR_PrmIdChr),
      @TPR_TwrTyp  = CONVERT(SMALLINT,@TPR_TwrTypChr),
      @TPR_TwrFirma= 0,
      @TPR_TwrNumer= CONVERT(INTEGER,@TPR_TwrNumerChr),
      @TPR_TwrLp   = 0,
      @TPR_TwgTyp  = CONVERT(SMALLINT,@TPR_TwgTypChr),
      @TPR_TwgFirma= 0,
      @TPR_TwgNumer= CONVERT(INTEGER,@TPR_TwgNumerChr),
      @TPR_TwgLp   = 0,
      @TPR_Typ     = CONVERT(INTEGER,@TPR_TypChr),
      @TPR_Wartosc = CONVERT(DECIMAL(15,4),@TPR_WartoscChr),
      @TPR_Prog    = CONVERT(DECIMAL(15,4),@TPR_ProgChr),
      @TPR_ZstID   = CONVERT(INTEGER,@TPR_ZstIDChr),
      @TPR_RodzajCeny = CONVERT(INTEGER,@TPR_RodzajCenyChr),
      @TPR_LP      = CONVERT(INTEGER,@TPR_LPChr)
      select @Prm_LastMod = Prm_LastMod from CDN.PrmKarty where PRM_Id = @TPR_PrmId
      IF @Prm_LastMod <> CONVERT(INTEGER,@TPR_TS_XL) RETURN
      INSERT INTO CDN.TwrPromocje( TPR_PrmId ,TPR_TwrTyp ,TPR_TwrFirma ,TPR_TwrNumer ,TPR_TwrLp ,TPR_TwgTyp ,TPR_TwgFirma ,TPR_TwgNumer ,TPR_TwgLp ,TPR_Typ ,TPR_Wartosc ,TPR_Prog ,TPR_Waluta ,TPR_FlagaNB ,TPR_Notatki ,TPR_ZstID,TPR_LP,TPR_RodzajCeny)
      VALUES                     ( @TPR_PrmId,@TPR_TwrTyp,@TPR_TwrFirma,@TPR_TwrNumer,@TPR_TwrLp,@TPR_TwgTyp,@TPR_TwgFirma,@TPR_TwgNumer,@TPR_TwgLp,@TPR_Typ,@TPR_Wartosc,@TPR_Prog,@TPR_Waluta,@TPR_FlagaNB,@TPR_Notatki,@TPR_ZstID,@TPR_LP,@TPR_RodzajCeny)
  SET NOCOUNT OFF
