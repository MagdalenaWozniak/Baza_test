CREATE FUNCTION [CDN].[TraNagRelacjeFaId] ( @TrNId INT,@TypDokSzuk INT, @Flaga INT)
  RETURNS INT
 AS
  BEGIN
  -- zmienne pomocnicze
  DECLARE
    @FaId   INT,
    @TrN_TypDokumentu INT
    SET @FaId = 0
    -- odczytanie typu dokumentu
    SELECT @TrN_TypDokumentu = TrN_TypDokumentu FROM cdn.TraNag WHERE TrN_TrNId = @TrNId
    IF EXISTS(SELECT TrR_TrRID FROM CDN.TraNagRelacje WHERE trr_trnid = @TrNId)
    BEGIN
      IF @TypDokSzuk = 0
      BEGIN
            IF @TrN_TypDokumentu = 302
              SELECT TOP 1 @FaId = TrR_FaID FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId AND TrR_FATyp = 305
            IF @TrN_TypDokumentu = 303
              SELECT TOP 1 @FaId = TrR_FaID FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId
            IF @TrN_TypDokumentu = 304
              SELECT TOP 1 @FaId = TrR_FaID FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId
            IF @TrN_TypDokumentu = 305
              SELECT TOP 1 @FaId = TrR_FaID FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId AND TrR_FATyp = 302
            IF @TrN_TypDokumentu = 306
              SELECT TOP 1 @FaId = TrR_FaID FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId AND TrR_FATyp <> 308 AND ISNULL(TrR_Flaga,0) = @Flaga
            IF @TrN_TypDokumentu = 307
              SELECT TOP 1 @FaId = TrR_FaID FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId AND TrR_FATyp <> 309 AND ISNULL(TrR_Flaga,0) = @Flaga
            IF @TrN_TypDokumentu = 308
              SELECT TOP 1 @FaId = TrR_FaID FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId AND TrR_FATyp <> 309
            IF @TrN_TypDokumentu = 309
              SELECT TOP 1 @FaId = TrR_FaID FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId AND TrR_FATyp <> 308
            IF @TrN_TypDokumentu = 311
              SELECT TOP 1 @FaId = TrR_FaID FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId AND TrR_FATyp not in (303,304)
            IF @TrN_TypDokumentu = 313
              SELECT TOP 1 @FaId = TrR_FaID FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId AND ISNULL(TrR_Flaga,0) = @Flaga
            IF @TrN_TypDokumentu = 314
              SELECT TOP 1 @FaId = TrR_FaID FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId AND ISNULL(TrR_Flaga,0) = @Flaga
            IF @TrN_TypDokumentu = 318
              SELECT TOP 1 @FaId = TrR_FaID FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId
            IF @TrN_TypDokumentu = 320
              SELECT TOP 1 @FaId = TrR_FaID FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId AND TrR_FATyp not in (308,309,306) AND ISNULL(TrR_Flaga,0) = @Flaga
            IF @TrN_TypDokumentu = 321
              SELECT TOP 1 @FaId = TrR_FaID FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId
            IF @TrN_TypDokumentu = 322
              SELECT TOP 1 @FaId = TrR_FaID FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId AND TrR_FATyp <> 321
            IF @TrN_TypDokumentu = 345
              SELECT TOP 1 @FaId = TrR_FaID FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId
            IF @TrN_TypDokumentu = 350
              SELECT TOP 1 @FaId = TrR_FaID FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId
      END
      ELSE
      BEGIN
             SELECT TOP 1 @FaId = TrR_FaID FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId AND TrR_FATyp = @TypDokSzuk AND ISNULL(TrR_Flaga,0) = @Flaga
      END
    END
    RETURN @FaId
  END
