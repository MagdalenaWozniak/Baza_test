CREATE PROCEDURE CDN.OFF_AktualizujTwrGrupy
    @TwG_GIDNumerChr        nvarchar(11),
    @TwG_GIDTypChr          nvarchar(5),
    @TwG_GrONumerChr        nvarchar(11),
    @TwG_GrOTypChr          nvarchar(5),
    @TwG_Kod                nvarchar(50),
    @TwG_CzasModyfikacjiChr nvarchar(11)
AS
  SET NOCOUNT ON
 DECLARE
    @TwG_Nazwa          nvarchar(255),
    @TwG_GIDFirma       INT,
    @TwG_GIDNumer       INT,
    @TwG_GIDTyp         SMALLINT,
    @TwG_GIDLp          SMALLINT,
    @TwG_GrOFirma       INT,
    @TwG_GrONumer       INT,
    @TwG_GrOTyp         SMALLINT,
    @TwG_GrOLp          SMALLINT,
    @TwG_CzasModyfikacji INT
    SET  @TwG_Nazwa =''
    SELECT
    @TwG_GIDFirma        = 0,
    @TwG_GIDNumer        = CONVERT(INT,@TwG_GIDNumerChr),
    @TwG_GIDTyp          = CONVERT(SMALLINT,@TwG_GIDTypChr),
    @TwG_GIDLp           = 0,
    @TwG_GrOFirma        = 0,
    @TwG_GrONumer        = CONVERT(INT,@TwG_GrONumerChr),
    @TwG_GrOTyp          = CONVERT(SMALLINT,@TwG_GrOTypChr),
    @TwG_GrOLp           = 0,
    @TwG_CzasModyfikacji = CONVERT(INT,@TwG_CzasModyfikacjiChr)
    BEGIN
     IF @TwG_GIDTyp = -16
        DELETE FROM CDN.TwrGrupy WHERE TwG_GIDTyp = -16 and ISNULL(TwG_CzasModyfikacji,0)<>@TwG_CzasModyfikacji
     IF @TwG_GIDTyp = 16
        DELETE FROM CDN.TwrGrupy WHERE TwG_GIDTyp = 16 and TwG_GIDNumer = @TwG_GIDNumer and ISNULL(TwG_CzasModyfikacji,0)<>@TwG_CzasModyfikacji
    IF NOT Exists (select TwG_GIDNumer from Cdn.TwrGrupy where TwG_GIDNumer = @TwG_GIDNumer and TwG_GIDTyp = @TwG_GIDTyp and TwG_GrONumer = @TwG_GrONumer and TwG_GrOTyp = @TwG_GrOTyp and TwG_CzasModyfikacji = @TwG_CzasModyfikacji)
     BEGIN
     IF @TwG_GrONumer = -1
  BEGIN
              SET IDENTITY_INSERT CDN.TwrGrupy ON
              INSERT INTO Cdn.TwrGrupy(TwG_GIDTyp, TwG_GIDFirma, TwG_GIDNumer, TwG_GIDLp, TwG_GrOTyp, TwG_GrOFirma,
                                TwG_GrONumer, TwG_GrOLp, TwG_Kod, TwG_Nazwa, TwG_TwGID,TwG_CzasModyfikacji)
              VALUES          (@TwG_GIDTyp,@TwG_GIDFirma,@TwG_GIDNumer,@TwG_GIDLp,@TwG_GrOTyp,@TwG_GrOFirma,
                                @TwG_GrONumer,@TwG_GrOLp,@TwG_Kod,@TwG_Nazwa, 0,@TwG_CzasModyfikacji)
              SET IDENTITY_INSERT CDN.TwrGrupy OFF
        END
     ELSE
      INSERT INTO Cdn.TwrGrupy(TwG_GIDTyp, TwG_GIDFirma, TwG_GIDNumer, TwG_GIDLp, TwG_GrOTyp, TwG_GrOFirma,
                                TwG_GrONumer, TwG_GrOLp, TwG_Kod, TwG_Nazwa,TwG_CzasModyfikacji)
               VALUES          (@TwG_GIDTyp,@TwG_GIDFirma,@TwG_GIDNumer,@TwG_GIDLp,@TwG_GrOTyp,@TwG_GrOFirma,
                                @TwG_GrONumer,@TwG_GrOLp,@TwG_Kod,@TwG_Nazwa,@TwG_CzasModyfikacji)
     END
    END
  SET NOCOUNT OFF
