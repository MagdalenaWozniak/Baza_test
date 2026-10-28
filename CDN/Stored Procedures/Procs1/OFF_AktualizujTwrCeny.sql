CREATE   PROCEDURE CDN.OFF_AktualizujTwrCeny
  @TwC_TwrNumerChr        nvarchar(11),
  @TwC_TwrLpChr           nvarchar(5),
  --@TwC_TwrTypChr          nvarchar(5),
  @TwC_Waluta             nvarchar(3),
  @TwC_TypChr             nvarchar(3),
  @TwC_WartoscChr         nvarchar(19),
  @Twr_TS_XL              nvarchar(30)
AS
  SET NOCOUNT ON
  DECLARE
    @TwC_TwCNumer        INT,
    @TwC_Typ             TINYINT,
    @TwC_Wartosc         DECIMAL(15,2),
    @TwC_TwrTyp          SMALLINT,
    @TwC_TwrFirma        INT,
    @TwC_TwrNumer        INT,
    @TwC_TwrLp           SMALLINT,
    @TwC_TwrId           INT,
    @Twr_TS_XLTowar      DateTime,
    @Komunikat           nvarchar(255)
  SELECT
    @TwC_Typ             = CONVERT(TINYINT,@TwC_TypChr),
    @TwC_Wartosc         = CONVERT(DECIMAL(15,2),@TwC_WartoscChr),
    @TwC_TwrTyp          = 16,
    @TwC_TwrFirma        = 0,
    @TwC_TwrNumer        = CONVERT(INT,@TwC_TwrNumerChr),
    @TwC_TwrLp           = CONVERT(SMALLINT,@TwC_TwrLpChr),
    @Twr_TS_XL           = CONVERT(DATETIME, @Twr_TS_XL, 120 )
    SET @TwC_TwCNumer = @TwC_TwrLp+1
  SELECT @TwC_TwrId = Twr_TwrId,@Twr_TS_XLTowar = Twr_TS_XL
    FROM cdn.Towary
    WHERE Twr_GIDNumer = @TwC_TwrNumer
--      AND Twr_GIDLp    = @TwC_TwrLp
  IF @Twr_TS_XL < @Twr_TS_XLTowar RETURN
  IF @TwC_TwrId IS NULL
    BEGIN
      SET @Komunikat = '##OPT34485##'--' Brak towaru  '
      RAISERROR( @Komunikat, 16, 1)
      RETURN
    END
  ELSE
     BEGIN
      INSERT INTO cdn.TwrCeny  (  TwC_TwrId,  TwC_TwCNumer,  TwC_Typ,  TwC_Wartosc,  TwC_Waluta, TwC_Aktualizacja, TwC_Zaokraglenie, TwC_Marza, TwC_MarzaWStu, TwC_Offset,  TwC_TwrTyp,  TwC_TwrFirma,  TwC_TwrNumer,  TwC_TwrLp )
        VALUES                 ( @TwC_TwrId, @TwC_TwCNumer, @TwC_Typ, @TwC_Wartosc, @TwC_Waluta,                0,             0.01,         0,             0,          0, @TwC_TwrTyp, @TwC_TwrFirma, @TwC_TwrNumer, @TwC_TwrLp )
     END
  SET NOCOUNT OFF
