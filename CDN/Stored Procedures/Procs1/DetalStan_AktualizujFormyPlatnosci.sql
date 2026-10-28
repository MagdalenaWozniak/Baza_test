CREATE PROCEDURE [CDN].[DetalStan_AktualizujFormyPlatnosci]
            @OptimaId int
           ,@StanDetalID int
           ,@Nazwa nvarchar(20)
           ,@NieAktywny tinyint
           ,@Domyslna tinyint
           ,@Gotowka tinyint
           ,@TypGotowka tinyint
           ,@Termin smallint
           ,@BnkNazwa NVARCHAR(50)
           ,@RachunekNr NVARCHAR(51)
     ,@TerminalPlatniczy smallint
           ,@DateTSSynchr DATETIME
AS
SET NOCOUNT ON
DECLARE
  @DSFPl_DSFPlId INT
 --nieaktywny dla wszystkich operatorow
 UPDATE CDN.DetalStanFormyPlatnosci SET DSFPl_NieAktywny = 1 Where DSFPl_NieAktywny = 0 and  DSFPl_TS_Mod < @DateTSSynchr and DSFPl_StanDetalID = @StanDetalID
  SELECT @DSFPl_DSFPlId = DSFPl_DSFPlId
    FROM CDN.DetalStanFormyPlatnosci
    WHERE DSFPl_OptimaId = @OptimaId and DSFPl_StanDetalID = @StanDetalID
  IF @DSFPl_DSFPlId IS NULL
    BEGIN
       INSERT INTO CDN.DetalStanFormyPlatnosci (
            DSFPl_OptimaId
           ,DSFPl_StanDetalID
           ,DSFPl_Nazwa
           ,DSFPl_NieAktywny
           ,DSFPl_Domyslna
           ,DSFPl_Gotowka
           ,DSFPl_TypGotowka
           ,DSfPl_Termin
           ,DSfPl_BnkNazwa
           ,DSfPl_RachunekNr
     ,DSfPl_TerminalPlatniczy
           ,DSFPl_TS_Mod
           )
  VALUES (
            @OptimaId,
            @StanDetalID,
            @Nazwa,
            @NieAktywny,
            @Domyslna,
            @Gotowka,
            @TypGotowka,
            @Termin,
            @BnkNazwa,
            @RachunekNr,
   @TerminalPlatniczy,
            @DateTSSynchr
         )
    END
  ELSE
 BEGIN
     UPDATE  CDN.DetalStanFormyPlatnosci
   SET
            DSFPl_Nazwa = @Nazwa
           ,DSFPl_NieAktywny = @NieAktywny
           ,DSFPl_Domyslna = @Domyslna
           ,DSFPl_Gotowka = @Gotowka
           ,DSFPl_TypGotowka = @TypGotowka
           ,DSFPl_Termin =@Termin
           ,DSfPl_BnkNazwa = @BnkNazwa
           ,DSfPl_RachunekNr = @RachunekNr
     ,DSfPl_TerminalPlatniczy = @TerminalPlatniczy
           ,DSFPl_TS_Mod = @DateTSSynchr
  WHERE @DSFPl_DSFPlId = DSFPl_DSFPlId
      END
  SET NOCOUNT OFF
