-- Funkcja pomocnicza odczytująca typ skojarzenia dokumentó FA/PA/FZ dla potrzeb wykresów
create FUNCTION [CDN].[TypSkojarzenia2] ( @TrN_TrNId INT, @TrE_TrEId INT )
  RETURNS INT
 AS
  BEGIN
  -- zmienne pomocnicze
  DECLARE
    @TypSkojarzenia   INT,
    @TrN_TypDokumentu INT
    SET @TypSkojarzenia = 0
    -- odczytanie typu dokumentu
    SELECT @TrN_TypDokumentu = TrN_TypDokumentu FROM cdn.TraNag WHERE TrN_TrNId = @TrN_TrNId
    -- paragony
    IF @TrN_TypDokumentu = 305
      BEGIN
        -- paragony skojarzone z FA
        IF EXISTS ( /*SELECT *
                      FROM cdn.TraNag PA
                      JOIN cdn.TraNagRelacje REL ON PA.TrN_TrNId = REL.TrR_TrNId
                      WHERE PA.TrN_TrNId = @TrN_TrNId AND REL.TrR_FATyp = 302 AND REL.TrR_TrNTyp = 305
                      SELECT REL.Trr_TrRID
                      FROM cdn.TraNagRelacje REL
                      WHERE REL.TrR_TrNId = @TrN_TrNId AND REL.TrR_FATyp = 302 AND REL.TrR_TrNTyp = 305*/
                      select * from cdn.TraElem as FA where FA.Tre_PatReId = @TrE_TrEId
                   )
          SET @TypSkojarzenia = 305302
        -- paragony nie skojarzone z FA
        ELSE
          SET @TypSkojarzenia = 305000
      END
    -- FA
    ELSE IF @TrN_TypDokumentu = 302
      BEGIN
        -- FA  skojarzone z WZ, RW
        IF EXISTS ( /*SELECT *
                      FROM cdn.TraNag FA
                           JOIN cdn.TraNagRelacje REL ON FA.TrN_TrNId = REL.TrR_TrNId
                           WHERE FA.TrN_TrNId = @TrN_TrNId AND REL.TrR_FATyp = 306 AND REL.TrR_TrNTyp = 302*/
                     SELECT REL.Trr_TrRID
                      FROM cdn.TraNagRelacje REL
                      WHERE REL.TrR_TrNId = @TrN_TrNId AND ( REL.TrR_FATyp in (306,304) ) AND REL.TrR_TrNTyp = 302
                   )
          SET @TypSkojarzenia = 302306
        -- FA nie skojarozne z WZ
        ELSE
          SET @TypSkojarzenia = 302000
      END
    -- FZ
    ELSE IF @TrN_TypDokumentu = 301
      BEGIN
        -- FZ  skojarzone z PZ
        IF EXISTS (/* SELECT *
                      FROM cdn.TraNag FZ
                           JOIN cdn.TraNagRelacje REL ON FZ.TrN_TrNId = REL.TrR_TrNId
                           WHERE FZ.TrN_TrNId = @TrN_TrNId AND REL.TrR_FATyp = 307 AND REL.TrR_TrNTyp = 301*/
              SELECT REL.Trr_TrRID
                      FROM cdn.TraNagRelacje REL
                      WHERE REL.TrR_TrNId = @TrN_TrNId AND REL.TrR_FATyp = 307 AND REL.TrR_TrNTyp = 301
                   )
          SET @TypSkojarzenia = 301307
        -- FZ nie skojarozne z PZ
        ELSE
          SET @TypSkojarzenia = 301000
      END
    RETURN @TypSkojarzenia
  END
