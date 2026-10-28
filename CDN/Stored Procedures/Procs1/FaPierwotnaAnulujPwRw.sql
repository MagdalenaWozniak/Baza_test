CREATE PROCEDURE CDN.FaPierwotnaAnulujPwRw
@TrnID            AS INT
AS
BEGIN
 SET NOCOUNT ON;
   DECLARE @CzyBufor       INT
        DECLARE @FpId           INT
        DECLARE @FpRodzaj       INT
        DECLARE @FpFaId         INT
 DECLARE wszystkiePwRw CURSOR LOCAL FAST_FORWARD FOR
   SELECT IsNull(TrN_TrNId, 0), IsNull(TrN_Bufor, -2), IsNull(TrN_Rodzaj, 0), IsNull(TrN_FaId, 0)
   FROM CDN.TraNag JOIN CDN.TraNagRelacje on TrN_TrNId = TrR_TrNId
                        WHERE TrR_FaId = @TrnID  and trn_korekta != 6
                        --WHERE TrN_RelTrNId = @TrnID
  OPEN wszystkiePwRw
   WHILE 1=1
   BEGIN
    FETCH NEXT FROM wszystkiePwRw INTO @FpId, @CzyBufor, @FpRodzaj, @FpFaId
    IF @@FETCH_STATUS <> 0 BREAK
    IF @FpId > 0
     BEGIN
      IF @CzyBufor = 1 -- PW/RW w buforze; kasuj
       BEGIN
        EXEC CDN.RozepnijPowiazaniaPrzedKasowaniem @FpId, @FpRodzaj, @FpFaId
        DELETE CDN.TraNag WHERE Trn_TrNId = @FpId --wykasuj
       END
      IF @CzyBufor = 0 -- PW/RW anuluj
       BEGIN
        UPDATE CDN.TraNag SET TrN_FaID=NULL, TrN_RelTrNId=NULL, TrN_Bufor=-1, TrN_TS_Mod = GETDATE() WHERE Trn_TrNId = @FpId --anulowanie
                                                                DELETE CDN.TraNagRelacje WHERE TrR_TrNId = @FpId
        DELETE CDN.TraNagRelacje WHERE TrR_FaId = @FpId
       END
     END
   END
  CLOSE wszystkiePwRw
 DEALLOCATE wszystkiePwRw
 KONIEC:
  SET NOCOUNT OFF;
  RETURN
END
