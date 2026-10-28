CREATE PROCEDURE CDN.OFF_DodajElementSchOpak
  @SOE_SONIdChr        nvarchar(11),
  @SOE_LpChr           nvarchar(11),
  @SOE_TwrGidNumerChr  nvarchar(11),
  @SOE_IloscChr        nvarchar(21),
  @SON_TS_XL           nvarchar(30)
AS
  SET NOCOUNT ON
  DECLARE
    @SOE_SONId         INT,
    @SOE_Lp            INT,
    @SOE_TwrGidNumer   INT,
    @SOE_Ilosc         DECIMAL(15,4),
    @SON_TS_XLNag      DateTime,
    @SON_SONID         INT,
    @SOE_TwrId         INT,
    @Komunikat         nvarchar(255)
  SELECT
    @SOE_SONId           = CONVERT(INT,@SOE_SONIdChr),
    @SOE_Lp              = CONVERT(INT,@SOE_LpChr),
    @SOE_TwrGidNumer     = CONVERT(INT,@SOE_TwrGidNumerChr),
    @SOE_Ilosc           = CONVERT(DECIMAL(15,4),@SOE_IloscChr),
    @SON_TS_XL           = CONVERT(DATETIME, @SON_TS_XL, 120 )
  SELECT @SON_TS_XLNag = SON_TS_XL,@SON_SONID = SON_SONID
    FROM CDN.SchematyOpakNag
    WHERE SON_SONId = @SOE_SONId
  IF @SON_TS_XL <> @SON_TS_XLNag RETURN
  IF @SON_SONID IS NULL
    BEGIN
      SET @Komunikat = '##OPT34496##'--' Brak nagłówka schematu opakowań. '
      RAISERROR( @Komunikat, 16, 1)
      RETURN
    END
  ELSE
    BEGIN
    SELECT @SOE_TwrId=Twr_TwrId FROM Cdn.Towary WHERE  Twr_GidNumer = @SOE_TwrGidNumer
    IF @SOE_TwrId IS NULL
    BEGIN
      SET @Komunikat = '##OPT34497##'--' Brak towaru który występuje w schemacie. '
      RAISERROR( @Komunikat, 16, 1)
      RETURN
    END
    IF EXISTS
     ( SELECT SOE_SONId FROM CDN.SchematyOpakElem  WHERE
              SOE_SONId = @SOE_SONId
          AND SOE_Lp    = @SOE_Lp
     )
       UPDATE CDN.SchematyOpakElem
       SET  SOE_TwrId=@SOE_TwrId,  SOE_Ilosc=@SOE_Ilosc
        WHERE SOE_SONId = @SOE_SONId
          AND SOE_Lp    = @SOE_Lp
    ELSE
     BEGIN
      INSERT INTO CDN.SchematyOpakElem (  SOE_SONId,SOE_Lp,SOE_TwrId,SOE_Ilosc)
        VALUES                         ( @SOE_SONId,@SOE_Lp,@SOE_TwrId,@SOE_Ilosc )
     END
    END
  SET NOCOUNT OFF
