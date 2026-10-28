CREATE PROCEDURE CDN.UstawRodzajDlaProForma
@TrnID            AS INT,
@TrNRodzaj        AS INT,
@TrnFaId          AS INT
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @PFid           INT
  DECLARE @PFrodzaj       INT
  SET   @PFrodzaj = 320000 -- zakładam, że nie ma fa zal
    --Jeśli anuluję FZAL, to na PF ustawić rodzaj 320000 jeśli  nie ma innej niezanulowanej FA zaliczkowej o takim samym FaId jak FaId właśnie anulowanej faktury zaliczkowej.
  -- IF @TrNRodzaj=302200 OR @TrNRodzaj=302009   --anulowana jest fa zaliczkowa Albo fa powstała z PF
  IF @TrNRodzaj/1000<>302
      GOTO  KONIEC
 --anulowana jest fa zaliczkowa albo fa powstała z PF
  IF @TrNRodzaj=302200 OR @TrNRodzaj=302202 --anulowana jest fa zaliczkowa lub jej korekta
    BEGIN
      SET   @PFid = @TrnFaId  --Id faktury proforma
      SET   @PFrodzaj = 320000 -- zakładam, że to ostatnia zal
      IF @PFid > 0
        BEGIN
          IF (EXISTS (SELECT TrN_TrNId FROM cdn.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId WHERE TrN_TrNId <> @TrnID AND TrN_Rodzaj IN (302200,302202) AND TrN_Bufor <> -1 AND TrR_FaId = @PFid))
            SET @PFrodzaj = 320200
          IF @PFrodzaj < 320000
            SET   @PFrodzaj = 320000
          UPDATE CDN.TraNag SET TrN_Rodzaj=@PFrodzaj WHERE TrN_TrNID = @PFid;
       END
    END
  ELSE                  --czy anulowana jest fa powstała z PF
    BEGIN
      DECLARE wszystkiePF CURSOR LOCAL FAST_FORWARD FOR
        SELECT IsNull(TrN_TrNId,0), IsNull(TrN_Rodzaj,320000) FROM cdn.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu = 320 AND TrR_FaId = @TrnID
        OPEN wszystkiePF
          WHILE 1=1
          BEGIN
            FETCH NEXT FROM wszystkiePF INTO @PFid, @PFrodzaj
            IF @@FETCH_STATUS <> 0 BREAK
            IF @PFid > 0
              BEGIN
                IF (EXISTS (SELECT TrN_TrNId FROM cdn.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId WHERE TrN_TrNId <> @TrnID AND TrN_Rodzaj IN (302200,302202) AND TrN_Bufor <> -1 AND TrR_FaId = @PFid))
                  SET @PFrodzaj = 320200
                IF @PFrodzaj < 320000
                   SET   @PFrodzaj = 320000
                UPDATE CDN.TraNag SET TrN_Rodzaj=@PFrodzaj WHERE TrN_TrNID = @PFid;
              END
          END
        CLOSE wszystkiePF
      DEALLOCATE wszystkiePF
    END
 KONIEC:
  SET NOCOUNT OFF;
  RETURN
END
