CREATE PROCEDURE [CDN].[DetalStan_PobierzWolnyNumer]
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
 SELECT @Min = MAX(dstrn_numernr) FROM CDN.DetalStanTraNag WHERE dstrn_Datadok < @Data AND Dstrn_NumerString = @String AND Dstrn_StanDetalId = @PosId AND DSTrN_TypDokumentu = @Typ
 IF @Min IS NULL
 BEGIN
  SELECT @Min = MIN(dstrn_numernr) FROM CDN.DetalStanTraNag WHERE dstrn_Datadok = @Data AND Dstrn_NumerString = @String AND Dstrn_StanDetalId = @PosId AND DSTrN_TypDokumentu = @Typ
  IF @Min IS NOT NULL AND @Min > 1
   SET @Min = 1
 END
 IF @Min IS NULL
 BEGIN
  SELECT @Numer = ISNULL(MAX(ISNULL(dstrn_numernr,0)),0)+1 FROM CDN.DetalStanTraNag WHERE Dstrn_NumerString = @String AND Dstrn_StanDetalId = @PosId AND DSTrN_TypDokumentu = @Typ
 END
 IF @Min IS NOT NULL
 BEGIN
  IF NOT EXISTS (SELECT Dstrn_numernr from CDN.DetalStanTraNag WHERE Dstrn_numernr = 1 AND DsTrN_Anulowany = 0 AND Dstrn_NumerString = @String AND Dstrn_StanDetalId = @PosId AND DSTrN_TypDokumentu = @Typ)
  BEGIN
   SET @Numer = 1
  END
  ELSE
  BEGIN
   SELECT @Numer = Dstrn_numernr from CDN.DetalStanTraNag WHERE Dstrn_numernr = @Min AND DsTrN_Anulowany = 0 AND Dstrn_NumerString = @String AND Dstrn_StanDetalId = @PosId AND DSTrN_TypDokumentu = @Typ
   IF @@ROWCOUNT = 0
   BEGIN
    SET @Numer = @Min
   END
   ELSE IF @Min > @Max
   BEGIN
    SELECT @Numer = ISNULL(MAX(ISNULL(dstrn_numernr,0)),0)+1 FROM CDN.DetalStanTraNag WHERE Dstrn_NumerString = @String AND Dstrn_StanDetalId = @PosId AND DSTrN_TypDokumentu = @Typ
   END
   ELSE
   BEGIN
       SELECT @Min =min(Dstrn_numernr) FROM DetalStanTraNag WHERE DsTrN_Anulowany = 0 AND Dstrn_NumerString = @String AND Dstrn_StanDetalId = @PosId AND DSTrN_TypDokumentu = @Typ
    IF @Min =1
    BEGIN
     SELECT @Min =min(t1.Dstrn_numernr)+1 FROM DetalStanTraNag as t1 LEFT OUTER JOIN DetalStanTraNag as t2 ON
      (t1.Dstrn_numernr+1=t2.Dstrn_numernr
      AND t1.DsTrN_Anulowany = t2.DsTrN_Anulowany AND t1.Dstrn_NumerString = t2.Dstrn_NumerString AND t1.Dstrn_StanDetalId = t2.Dstrn_StanDetalId AND t1.DSTrN_TypDokumentu = t2.DSTrN_TypDokumentu)
     WHERE t2.Dstrn_numernr IS NULL
      AND t1.dstrn_Datadok >= @Data
      AND t1.DsTrN_Anulowany = 0 AND t1.Dstrn_NumerString = @String AND t1.Dstrn_StanDetalId = @PosId AND t1.DSTrN_TypDokumentu = @Typ
     IF @Min IS NULL
     BEGIN
      SELECT @Min = ISNULL(MAX(ISNULL(dstrn_numernr,0)),0)+1 FROM CDN.DetalStanTraNag WHERE Dstrn_NumerString = @String AND Dstrn_StanDetalId = @PosId AND DSTrN_TypDokumentu = @Typ
     END
     IF @Min-1 > @Max
     BEGIN
      SELECT @Numer = ISNULL(MAX(ISNULL(dstrn_numernr,0)),0)+1 FROM CDN.DetalStanTraNag WHERE Dstrn_NumerString = @String AND Dstrn_StanDetalId = @PosId AND DSTrN_TypDokumentu = @Typ
     END
     ELSE
      SET @Numer = @Min
    END
     ELSE
      SET @Min =1
   END
  END
 END
 SELECT @Numer
 SET NOCOUNT OFF
END
