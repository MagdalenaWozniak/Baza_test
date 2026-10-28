CREATE PROCEDURE CDN.OFF_AktualizujKntPromocje
      @KPR_PrmIdChr                     nvarchar(11) ,
      @KPR_KntTypChr                    nvarchar(5)  ,
      @KPR_KntNumerChr                  nvarchar(11) ,
      @KPR_KngTypChr                    nvarchar(5)  ,
      @KPR_KngNumerChr                  nvarchar(11) ,
      @KPR_TypChr                       nvarchar(11) ,
      @KPR_WartoscChr                   nvarchar(20) ,
      @KPR_TS_XL                        nvarchar(11)
AS
  SET NOCOUNT ON
  DECLARE
      @KPR_PrmId                       INT        ,
      @KPR_KntTyp                      SMALLINT   ,
      @KPR_KntFirma                    INT        ,
      @KPR_KntNumer                    INT        ,
      @KPR_KntLp                       SMALLINT   ,
      @KPR_KngTyp                      SMALLINT   ,
      @KPR_KngFirma                    INT        ,
      @KPR_KngNumer                    INT        ,
      @KPR_KngLp                       SMALLINT   ,
      @KPR_Typ                         INT        ,
      @KPR_Wartosc                     DECIMAL (15,4) ,
      @Prm_LastMod                     INT        ,
      @Komunikat                       nvarchar(255)
 SELECT
      @KPR_PrmId        = CONVERT(INT,@KPR_PrmIdChr),
      @KPR_KntTyp       = CONVERT(SMALLINT,@KPR_KntTypChr),
      @KPR_KntFirma     = 0,
      @KPR_KntNumer     = CONVERT(INT,@KPR_KntNumerChr),
      @KPR_KntLp        = 0,
      @KPR_KngTyp       = CONVERT(SMALLINT,@KPR_KngTypChr),
      @KPR_KngFirma     = 0,
      @KPR_KngNumer     = CONVERT(INT,@KPR_KngNumerChr),
      @KPR_KngLp        = 0,
      @KPR_Typ          = CONVERT(INTEGER,@KPR_TypChr),
      @KPR_Wartosc      = CONVERT(DECIMAL(15,4),@KPR_WartoscChr)
      select @Prm_LastMod = Prm_LastMod from CDN.PrmKarty where PRM_Id = @KPR_PrmId
      IF @Prm_LastMod <> CONVERT(INTEGER,@KPR_TS_XL) RETURN
      INSERT INTO CDN.KntPromocje( KPR_PrmId ,KPR_KntTyp ,KPR_KntFirma ,KPR_KntNumer ,KPR_KntLp ,KPR_KngTyp ,KPR_KngFirma ,KPR_KngNumer ,KPR_KngLp ,KPR_Typ ,KPR_Wartosc)
      VALUES                     ( @KPR_PrmId,@KPR_KntTyp,@KPR_KntFirma,@KPR_KntNumer,@KPR_KntLp,@KPR_KngTyp,@KPR_KngFirma,@KPR_KngNumer,@KPR_KngLp,@KPR_Typ,@KPR_Wartosc)
  SET NOCOUNT OFF
