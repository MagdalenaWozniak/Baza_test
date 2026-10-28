CREATE PROCEDURE CDN.AnulowanieFzDoFrr
@TylkoAnulowanie  AS INT,
@TrnID            AS INT,
@TrnRodzaj        AS INT,
@TrnFaId          AS INT
AS
BEGIN
   DECLARE @Komunikat      NVARCHAR(250)
   -- anuluj korekty do FZ
   DECLARE @CzyBufor       INT
   DECLARE @FpId           INT
   DECLARE @FpRodzaj       INT
   DECLARE @FpFaId         INT
   DECLARE @Err     INT
   DECLARE @liczbaPKA      INT
    SET @Err = 0
 DECLARE wszystkieKorekty CURSOR LOCAL FAST_FORWARD FOR
    SELECT IsNull(TrN_TrNId, 0), IsNull(TrN_Bufor, -2), IsNull(TrN_Rodzaj, 0), IsNull(TrR_FaId, 0)
       FROM CDN.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId WHERE TrN_Korekta > 0 AND  TrN_ZwrId = @TrnID
  OPEN wszystkieKorekty
  WHILE 1=1
  BEGIN
   FETCH NEXT FROM wszystkieKorekty INTO @FpId, @CzyBufor, @FpRodzaj, @FpFaId
   IF @@FETCH_STATUS <> 0 BREAK
   IF @FpId > 0
   BEGIN
    IF @CzyBufor = 1 --  w buforze; kasuj
    BEGIN
     EXEC CDN.RozepnijPowiazaniaPrzedKasowaniem @FpId, @FpRodzaj, @FpFaId
     --SET @Err = @ERROR
     --IF @Err <> 0 GOTO KONIEC
     DELETE CDN.TraNag WHERE Trn_TrNId = @FpId --wykasuj
    END
    IF @CzyBufor = 0 --  anuluj
    BEGIN
     EXEC CDN.AnulowanieDokumentu @TylkoAnulowanie, @FpId, @FpRodzaj, @FpFaId
     --SET @Err = @ERROR
     --IF @Err <> 0 GOTO KONIEC
     UPDATE CDN.TraNag SET TrN_FaID=NULL, TrN_RelTrNId=NULL, TrN_Bufor=-1, TrN_TS_Mod = GETDATE() WHERE Trn_TrNId = @FpId --anulowanie dok
     DELETE CDN.TraNagRelacje WHERE TrR_TrNId = @FpId
     DELETE CDN.TraNagRelacje WHERE TrR_FaId = @FpId
    END
   END
  END
  CLOSE wszystkieKorekty
 DEALLOCATE wszystkieKorekty
 -- anuluj FZ
       BEGIN
  UPDATE CDN.TraNag SET TrN_FaID=NULL, TrN_RelTrNId=NULL, TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_Rodzaj = 301000
  WHERE Trn_TrNId = @TrnID --anulowanie FZ
       END
    -- nie anulujemy FRR tylko rozpinamy
 SELECT @FpId=IsNull(TrN_TrNId, 0), @FpRodzaj=IsNull(TrN_Rodzaj, 0), @FpFaId=IsNull(TrR_FaId, 0)
  FROM CDN.TraNag JOIN cdn.TraNagRelacje ON TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu=350 AND TrN_Korekta = 0 AND TrR_FaId=@TrnID
 UPDATE CDN.TraNag SET TrN_FaID=NULL, TrN_RelTrNId=NULL,  TrN_TS_Mod = GETDATE(), TrN_Rodzaj = 350000 WHERE Trn_TrNId = @FpId and TrN_Rodzaj = 350008 --anulowanie dok
        -- anulowanie FZ, jeżeli FZ powstało z FRR  powinno anulować PZ powstały z FZ
        -- PZ jest anulowany pod warunkiem, że jest tylko jeden (zgl. 90675)
 --anulowanie PZ i PKA
    DECLARE @liczbaPZ INT
    SET  @liczbaPZ = (SELECT Count(*) FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu=307 AND TrR_FaID =@TrnID);
    IF @liczbaPZ=1 -- PZ jest anulowany pod warunkiem, że jest tylko jeden (zgl. 90675)
 BEGIN
  -- anulowanie PKA zgł,http://www.cdn.com.pl/zgloszenie.asp?ID=92122
  SET  @liczbaPKA = (SELECT Count(*) FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE TrN_TypDokumentu=313 AND TrR_FaID =@TrnID);
  IF @liczbaPKA=1 -- PKA jest anulowany pod warunkiem, że jest tylko jeden (zgl. 90675)
  BEGIN
   SELECT @FpId=IsNull(TrN_TrNId, 0), @FpRodzaj=IsNull(TrN_Rodzaj, 0), @FpFaId=IsNull(TrR_FaId, 0)
   FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu=313 AND TrR_FaId =@TrnID
--   FROM CDN.TraNag WHERE TrN_TypDokumentu=313 AND TrN_RelTrNID =@TrnID
   EXEC CDN.AnulowanieDokumentu @TylkoAnulowanie, @FpId, @FpRodzaj, @FpFaId
   --SET @Err = @ERROR
   --IF @Err <> 0 GOTO KONIEC
   UPDATE CDN.TraNag SET TrN_FaID=NULL, TrN_RelTrNId=NULL, TrN_Bufor=-1, TrN_TS_Mod = GETDATE() WHERE Trn_TrNId = @FpId --anulowanie dok
  END
  ELSE
  BEGIN
   UPDATE CDN.TraNag SET TrN_RelTrNId=null WHERE TrN_RelTrNId=@TrnID; --PKA
  END
  -- anulowanie PZ
  SELECT @FpId=IsNull(TrN_TrNId, 0), @FpRodzaj=IsNull(TrN_Rodzaj, 0), @FpFaId=IsNull(TrR_FaId, 0)
   FROM CDN.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNId = Trr_TrNId WHERE TrN_TypDokumentu=307 AND TrR_FaId=@TrnID
  EXEC CDN.AnulowanieDokumentu @TylkoAnulowanie, @FpId, @FpRodzaj, @FpFaId
  --SET @Err = @ERROR
  --IF @Err <> 0 GOTO KONIEC
  UPDATE CDN.TraNag SET TrN_FaID=NULL, TrN_RelTrNId=NULL, TrN_Bufor=-1, TrN_TS_Mod = GETDATE() WHERE Trn_TrNId = @FpId --anulowanie dok
 END
 ELSE
 BEGIN
  --rozepnij powiazania do dokumentow skojarzonych z FZ
  EXEC CDN.RozepnijPowiazaniaPrzedKasowaniem @TrNId, @TrNRodzaj, @TrNFaId
  --SET @Err = @ERROR
  --IF @Err <> 0 GOTO KONIEC
 END
       -- kasujemy relacje pomiędzy dokumentami z tabeli CDN.TraNagRelacje
       -- anuluj FZ, kasuj powiązania
        DELETE CDN.TraNagRelacje WHERE TrR_TrNId = @TrnID
 DELETE CDN.TraNagRelacje WHERE TrR_FaId = @TrnID
        -- anulowanie FZ, jeżeli FZ powstało z FRR  powinno anulować PZ powstały z FZ
        -- PZ jest anulowany pod warunkiem, że jest tylko jeden (zgl. 90675)
 -- anulowanie PZ i PKA, kasuj powiązania
       IF @liczbaPZ=1 AND @LiczbaPKA <> 1-- PZ jest anulowany pod warunkiem, że jest tylko jeden (zgl. 90675)
 BEGIN
  -- anulowanie PKA zgł,http://www.cdn.com.pl/zgloszenie.asp?ID=92122
  IF @liczbaPKA=1 -- PKA jest anulowany pod warunkiem, że jest tylko jeden (zgl. 90675)
  BEGIN
           DELETE CDN.TraNagRelacje WHERE TrR_TrNId = @FpId
                  DELETE CDN.TraNagRelacje WHERE TrR_FaId = @FpId
  END
  ELSE
  BEGIN
           DELETE CDN.TraNagRelacje WHERE TrR_TrNId = @TrnID
           DELETE CDN.TraNagRelacje WHERE TrR_FaId = @TrnID
  END
  -- anulowanie PZ
           DELETE CDN.TraNagRelacje WHERE TrR_TrNId = @FpId
           DELETE CDN.TraNagRelacje WHERE TrR_FaId = @FpId
 END
KONIEC:
 --SET NOCOUNT OFF;
 --IF @@TRANCOUNT <> 0  COMMIT TRAN
 --SELECT 0   -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
 RETURN
END
