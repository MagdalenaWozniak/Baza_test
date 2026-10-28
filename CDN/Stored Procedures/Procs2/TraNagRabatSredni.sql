-- Rabat średni nagłówka
CREATE PROCEDURE CDN.TraNagRabatSredni
  @TrN_TrNId_Doc    INT
AS
  BEGIN
    SET NOCOUNT ON
    DECLARE
      @TrN_RazemBruttoWalPrzed DECIMAL (20,2),
      @TrN_RazemBruttoWalPo    DECIMAL (20,2),
      @TrN_Rabat_Doc           DECIMAL (20,2)
    IF EXISTS ( SELECT * FROM cdn.TraElem WHERE TrE_TrNId = @TrN_TrNId_Doc )
      BEGIN
        SELECT
          @TrN_RazemBruttoWalPrzed = SUM(ISNULL(TrE_IloscJM,0) * ISNULL(TrE_Cena0WD,0)),
          @TrN_RazemBruttoWalPo = SUM(ISNULL(TrE_WartoscBruttoWal,0))
        FROM cdn.TraElem WHERE TrE_TrNId = @TrN_TrNId_Doc
        IF @TrN_RazemBruttoWalPrzed <> 0
          BEGIN
            SET @TrN_Rabat_Doc  = ( @TrN_RazemBruttoWalPrzed - @TrN_RazemBruttoWalPo ) / @TrN_RazemBruttoWalPrzed * 100
            IF @TrN_Rabat_Doc NOT BETWEEN -999.99 AND 999.99
              SET @TrN_Rabat_Doc = CASE WHEN @TrN_Rabat_Doc < 0 THEN -999.99 ELSE  999.99 END
            UPDATE CDN.TraNag SET TrN_Rabat = @TrN_Rabat_Doc WHERE TrN_TrNId = @TrN_TrNId_Doc
          END
      END
    ELSE
      UPDATE CDN.TraNag SET TrN_Rabat = 0 WHERE TrN_TrNId = @TrN_TrNId_Doc
    SET NOCOUNT OFF
  END
