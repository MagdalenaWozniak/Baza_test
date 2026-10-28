CREATE PROCEDURE CDN.OFF_AktualizujKntGrupy
    @KnG_GIDNumerChr        nvarchar(11),
    @KnG_GIDTypChr          nvarchar(5),
    @KnG_GrONumerChr        nvarchar(11),
    @KnG_GrOTypChr          nvarchar(5),
    @KnG_Akronim            nvarchar(50),
    @KnG_CzasModyfikacjiChr nvarchar(11)
AS
  SET NOCOUNT ON
 DECLARE
    @KnG_Nazwa          nvarchar(255),
    @KnG_GIDFirma       INT,
    @KnG_GIDNumer       INT,
    @KnG_GIDTyp         SMALLINT,
    @KnG_GIDLp          SMALLINT,
    @KnG_GrOFirma       INT,
    @KnG_GrONumer       INT,
    @KnG_GrOTyp         SMALLINT,
    @KnG_GrOLp          SMALLINT,
    @KnG_CzasModyfikacji INT
    SET  @KnG_Nazwa =''
    SELECT
    @KnG_GIDFirma        = 0,
    @KnG_GIDNumer        = CONVERT(INT,@KnG_GIDNumerChr),
    @KnG_GIDTyp          = CONVERT(SMALLINT,@KnG_GIDTypChr),
    @KnG_GIDLp           = 0,
    @KnG_GrOFirma        = 0,
    @KnG_GrONumer        = CONVERT(INT,@KnG_GrONumerChr),
    @KnG_GrOTyp          = CONVERT(SMALLINT,@KnG_GrOTypChr),
    @KnG_GrOLp           = 0,
    @KnG_CzasModyfikacji = CONVERT(INT,@KnG_CzasModyfikacjiChr)
    BEGIN
       IF @KnG_GIDTyp = -32
          DELETE FROM CDN.KntGrupy WHERE KnG_GIDTyp = -32 and KnG_CzasModyfikacji<>@KnG_CzasModyfikacji
       IF @KnG_GIDTyp = 32
          DELETE FROM CDN.KntGrupy WHERE KnG_GIDTyp = 32 and KnG_GIDNumer = @KnG_GIDNumer and KnG_CzasModyfikacji<>@KnG_CzasModyfikacji
      IF NOT Exists (select KnG_GIDNumer from Cdn.KntGrupy where KnG_GIDNumer = @KnG_GIDNumer and KnG_GIDTyp = @KnG_GIDTyp and KnG_GrONumer = @KnG_GrONumer and KnG_GrOTyp = @KnG_GrOTyp and KnG_CzasModyfikacji = @KnG_CzasModyfikacji)
        INSERT INTO Cdn.KntGrupy(KnG_GIDTyp, KnG_GIDFirma, KnG_GIDNumer, KnG_GIDLp, KnG_GrOTyp, KnG_GrOFirma,
                                KnG_GrONumer, KnG_GrOLp, KnG_Akronim,KnG_CzasModyfikacji)
               VALUES          (@KnG_GIDTyp,@KnG_GIDFirma,@KnG_GIDNumer,@KnG_GIDLp,@KnG_GrOTyp,@KnG_GrOFirma,
                                @KnG_GrONumer,@KnG_GrOLp,@KnG_Akronim,@KnG_CzasModyfikacji)
    END
  SET NOCOUNT OFF
