CREATE PROCEDURE [CDN].[DetalStan_PobierzWolnyNumerKB]
@PosId INT,
@String NVARCHAR(30),
@Typ  INT,
@Data DATETIME
AS
BEGIN
SET NOCOUNT ON
DECLARE @Min INT
DECLARE @Max INT
DECLARE @Numer INT
DECLARE @Licznik INT
SELECT @Min = MAX(DSZKB_numernr) FROM CDN.DetalStanZapisyKB WHERE DSZKB_Datadok < @Data AND DSZKB_NumerString = @String AND DSZKB_StanDetalId = @PosId AND DSZKB_TypDokumentu = @Typ
IF @Min IS NULL
BEGIN
 SELECT @Min = MIN(DSZKB_numernr) FROM CDN.DetalStanZapisyKB WHERE DSZKB_Datadok = @Data AND DSZKB_NumerString = @String AND DSZKB_StanDetalId = @PosId AND DSZKB_TypDokumentu = @Typ
 IF @Min IS NOT NULL AND @Min > 1
  SET @Min = 1
END
IF @Min IS NULL
  BEGIN
   SELECT @Numer = ISNULL(MAX(ISNULL(DSZKB_NumerNr,0)),0)+1 FROM CDN.DetalStanZapisyKB WHERE DSZKB_NumerString = @String AND DSZKB_StanDetalID = @PosId AND DSZKB_TypDokumentu = @Typ
  END
IF NOT EXISTS (SELECT DSZKB_DSZKBID from cdn.DetalStanZapisyKB where DSZKB_NumerNr < @Min) AND @Min IS NOT NULL
 BEGIN
  SET @Licznik = 1
  WHILE 1=1
   BEGIN
    IF NOT EXISTS (SELECT DSZKB_NumerNr from CDN.DetalStanZapisyKB WHERE DSZKB_NumerNr = @Licznik AND DSZKB_NumerString = @String AND DSZKB_StanDetalID = @PosId AND DSZKB_TypDokumentu = @Typ)
     BEGIN
        SET @Numer = @Licznik
           BREAK
     END
      ELSE
        WHILE 1=1
           BEGIN
            SELECT @Numer = DSZKB_NumerNr from CDN.DetalStanZapisyKB WHERE DSZKB_NumerNr = @Min AND DSZKB_NumerString = @String AND DSZKB_StanDetalID = @PosId AND DSZKB_TypDokumentu = @Typ
             IF @@ROWCOUNT = 0
              BEGIN
              SET @Numer = @Min+1
              BREAK
              END
            IF @Min > @Max
             BEGIN
               SELECT @Numer = ISNULL(MAX(ISNULL(DSZKB_NumerNr,0)),0)+1 FROM CDN.DetalStanZapisyKB WHERE DSZKB_NumerString = @String AND DSZKB_StanDetalID = @PosId AND DSZKB_TypDokumentu = @Typ
              BREAK
             END
          ELSE
            SET @Min = @Min + 1
           END
        IF @Licznik > @Min BREAK
       ELSE
        SET @Licznik = @Licznik + 1
    END
 END
ELSE IF @Min IS NOT NULL
  BEGIN
   WHILE 1=1
     BEGIN
       SELECT @Numer = DSZKB_numernr from CDN.DetalStanZapisyKB WHERE DSZKB_numernr = @Min AND DSZKB_NumerString = @String AND DSZKB_StanDetalID = @PosId AND DSZKB_TypDokumentu = @Typ
        IF @@ROWCOUNT = 0
          BEGIN
              SET @Numer = @Min
              BREAK
          END
        IF @Min > @Max
         BEGIN
           SELECT @Numer = ISNULL(MAX(ISNULL(DSZKB_numernr,0)),0)+1 FROM CDN.DetalStanZapisyKB WHERE DSZKB_NumerString = @String AND DSZKB_StanDetalId = @PosId AND DSZKB_TypDokumentu = @Typ
          BREAK
         END
    ELSE
   SET @Min = @Min + 1
     END
  END
SELECT @Numer
SET NOCOUNT OFF
END
