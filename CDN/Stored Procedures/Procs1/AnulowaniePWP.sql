CREATE PROCEDURE CDN.AnulowaniePWP
@TylkoAnulowanie AS INT,
@TrnID    AS INT,
@OperatorId         AS INT
AS
BEGIN
 BEGIN TRAN
 SET NOCOUNT ON
 DECLARE @Komunikat      NVARCHAR(250)
 DECLARE @Err         INT
 DECLARE @TrnRodzaj INT
    DECLARE @TrnFaId INT
    DECLARE @CzyKorekta INT
    DECLARE @VaNId  INT
    DECLARE @Bufor  INT
  DECLARE @Mag_Symbol     NVARCHAR(20)
    DECLARE @FpId           INT
    DECLARE @FpRodzaj       INT
    DECLARE @FpFaId         INT
    DECLARE @WynikString    NVARCHAR(512)
        SET @Err = 0
        SET @Mag_Symbol =''
    SELECT @Mag_Symbol=Mag_Symbol FROM Cdn.MagazynZakazy JOIN Cdn.TraNag ON MaZ_MagId=Trn_MagZrdId JOIN Cdn.Magazyny ON MaZ_MagId=Mag_MagId WHERE (Trn_TrnId = @TrnID OR Trn_FaId = @TrnID) AND MaZ_OpeId = @OperatorId
    IF @Mag_Symbol <> ''
    BEGIN
      SET @Komunikat ='##OPT34326##%%s1%%=' + @Mag_Symbol+ '##'--'Operator ma ustawiony zakaz na magazyn '+ @Mag_Symbol
      RAISERROR( @Komunikat, 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
 SELECT @CzyKorekta = IsNull(TrN_Korekta, 0), @TrnRodzaj=IsNull(TrN_Rodzaj, 0), @TrnFaId=IsNull(TrR_FaId, 0), @Bufor=IsNull(TrN_Bufor, 0), @VaNId=IsNull(TrN_VaNId, 0)
   FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrN_TrNId = @TrnID
    IF @Bufor = -1
    BEGIN
      SET @Komunikat ='##OPT34501##'--'Dokument jest już anulowany!'
      RAISERROR( @Komunikat, 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    IF @Bufor = 1
    BEGIN
      SET @Komunikat ='##OPT34170##'--'Dokument jest w buforze.'
      RAISERROR( @Komunikat, 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    IF @VaNId > 0
    BEGIN
      SET @Komunikat ='##OPT34502##'--'Dokument jest zaksięgowany.'
      RAISERROR( @Komunikat, 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
 IF  @CzyKorekta > 0
 BEGIN
            DECLARE wszystkieRWS CURSOR LOCAL FAST_FORWARD FOR
  SELECT IsNull(TrN_TrNId, 0), IsNull(TrN_Rodzaj, 0), IsNull(TrR_FaId, 0), IsNull(TrN_Korekta, 0)
  FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID=@TrnID AND TrR_TrNTyp = 318
  OPEN wszystkieRWS
  WHILE 1=1
  BEGIN
   FETCH NEXT FROM wszystkieRWS INTO @FpId, @FpRodzaj, @FpFaId, @CzyKorekta
   IF @@FETCH_STATUS <> 0 BREAK
   IF @FpId > 0
   BEGIN
    IF  @CzyKorekta > 0
    BEGIN
     EXEC CDN.AnulowanieKorektMagazynowych  @FpId, 0, @WynikString OUTPUT
     SET @Err = @WynikString
     IF @Err <> 0
     BEGIN
      GOTO KONIEC
     END
    END
    ELSE
    BEGIN
     EXEC CDN.AnulowanieDokumentu @TylkoAnulowanie, @FpId, @FpRodzaj, @FpFaId
     SET @Err = @@ERROR
     IF @Err <> 0
     BEGIN
      GOTO KONIEC
     END
    END
    UPDATE CDN.TraNag SET TrN_FaID=NULL, TrN_RelTrNId=NULL, TrN_Bufor=-1, TrN_TS_Mod = GETDATE() WHERE Trn_TrNId = @FpId --anulowanie dok
    IF CDN.IstniejaWZKK(@FpId)<> ''
       BEGIN
       SET @Komunikat = '##OPT34498##'--'Istnieją powiązane dokumenty WZKK!'
       RAISERROR( @Komunikat, 16, 1)
       ROLLBACK TRAN
       SET NOCOUNT OFF
       RETURN
       END
      -- wykasowanie subelementów kasowanego dokumentu i skojarzonej WZKK
      DELETE cdn.TraSElem
      FROM cdn.TraSElem  S
        JOIN cdn.TraElem E on  S.TrS_TrEId = E.TrE_TrEId
        JOIN cdn.TraNag N  on  N.TrN_TrNId = E.TrE_TrNId
      WHERE N.TrN_TrNId = @FpId OR  N.TrN_TrNId IN
         (SELECT WZKK.TrN_TrNID FROM CDN.TraNag WZKK
            WHERE WZKK.TrN_ZwrID = @FpId AND WZKK.TrN_Rodzaj
           IN (306061,306071,306072))
      -- anulowanie WZKK
      IF EXISTS ( SELECT * FROM CDN.TraNag join
      (select TrN_TrNID as TrNID, TrN_ZwrID as ZwrID from CDN.TraNag WHERE  TrN_ZwrIDWZKK = @FpId AND TrN_Rodzaj IN (306061,306071,306072)) as A on TrN_ZwrId = A.ZwRID
      where TrN_TrNID >TrNID and TrN_Bufor <> -1 AND TrN_Rodzaj NOT IN (306061,306071,306072))
      begin
       SET @Komunikat = '##OPT34441##'--'Nie można anulować dokumentu! Anulowany dokument jest powiązany z dokumentem WZKK (korekta kosztów) do którego istnieją późniejsze korekty. Anuluj późniejsze korekty.'
       RAISERROR( @Komunikat, 16, 1)
       ROLLBACK TRAN
       SET NOCOUNT OFF
       RETURN
      end
      UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null, TrN_ZwrID = NULL, TrN_ZwrIdWZKK = NULL WHERE  TrN_ZwrID = @FpId AND TrN_Rodzaj IN (306061,306071,306072);
      -- kasuję powiązania WZKK
      DELETE CDN.TraNagRelacje WHERE TrR_TrNID IN
      (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrID = @FpId AND TrN_Rodzaj IN (306061,306071,306072))
      DELETE CDN.TraNagRelacje WHERE TrR_FaID IN
      (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrID = @FpId AND TrN_Rodzaj IN (306061,306071,306072))
    DELETE CDN.TraNagRelacje WHERE TrR_TrNId = @FpId
    DELETE CDN.TraNagRelacje WHERE TrR_FaId = @FpId
   END
  END
  CLOSE wszystkieRWS
       DEALLOCATE wszystkieRWS
  EXEC CDN.AnulowanieKorektMagazynowych  @TrnID, 0,  @WynikString OUTPUT
  SET @Err = @WynikString
  IF @Err <> 0
  BEGIN
   GOTO KONIEC
  END
 END
 ELSE
 BEGIN
           DECLARE wszystkieRWS CURSOR LOCAL FAST_FORWARD FOR
  SELECT IsNull(TrN_TrNId, 0), IsNull(TrN_Rodzaj, 0), IsNull(TrR_FaId, 0), IsNull(TrN_Korekta, 0)
  FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID=@TrnID AND TrR_TrNTyp = 318
  OPEN wszystkieRWS
  WHILE 1=1
  BEGIN
   FETCH NEXT FROM wszystkieRWS INTO @FpId, @FpRodzaj, @FpFaId, @CzyKorekta
   IF @@FETCH_STATUS <> 0 BREAK
   IF @FpId > 0
   BEGIN
    IF  @CzyKorekta > 0
    BEGIN
     EXEC CDN.AnulowanieKorektMagazynowych  @FpId, 0, @WynikString OUTPUT
     SET @Err = @WynikString
     IF @Err <> 0
     BEGIN
      GOTO KONIEC
     END
    END
    ELSE
    BEGIN
     EXEC CDN.AnulowanieDokumentu @TylkoAnulowanie, @FpId, @FpRodzaj, @FpFaId
     SET @Err = @@ERROR
     IF @Err <> 0
     BEGIN
      GOTO KONIEC
     END
    END
    UPDATE CDN.TraNag SET TrN_FaID=NULL, TrN_RelTrNId=NULL, TrN_Bufor=-1, TrN_TS_Mod = GETDATE() WHERE Trn_TrNId = @FpId --anulowanie dok
    IF CDN.IstniejaWZKK(@FpId)<> ''
       BEGIN
       SET @Komunikat = '##OPT34498##'--'Istnieją powiązane dokumenty WZKK!'
       RAISERROR( @Komunikat, 16, 1)
       ROLLBACK TRAN
       SET NOCOUNT OFF
       RETURN
       END
      -- wykasowanie subelementów kasowanego dokumentu i skojarzonej WZKK
      DELETE cdn.TraSElem
      FROM cdn.TraSElem  S
        JOIN cdn.TraElem E on  S.TrS_TrEId = E.TrE_TrEId
        JOIN cdn.TraNag N  on  N.TrN_TrNId = E.TrE_TrNId
      WHERE N.TrN_TrNId = @FpId OR  N.TrN_TrNId IN
         (SELECT WZKK.TrN_TrNID FROM CDN.TraNag WZKK
            WHERE WZKK.TrN_ZwrID = @FpId AND WZKK.TrN_Rodzaj
           IN (306061,306071,306072))
      -- anulowanie WZKK
      IF EXISTS ( SELECT * FROM CDN.TraNag join
      (select TrN_TrNID as TrNID, TrN_ZwrID as ZwrID from CDN.TraNag WHERE  TrN_ZwrIDWZKK = @FpId AND TrN_Rodzaj IN (306061,306071,306072)) as A on TrN_ZwrId = A.ZwRID
      where TrN_TrNID >TrNID and TrN_Bufor <> -1 AND TrN_Rodzaj NOT IN (306061,306071,306072))
      begin
       SET @Komunikat = '##OPT34441##'--'Nie można anulować dokumentu! Anulowany dokument jest powiązany z dokumentem WZKK (korekta kosztów) do którego istnieją późniejsze korekty. Anuluj późniejsze korekty.'
       RAISERROR( @Komunikat, 16, 1)
       ROLLBACK TRAN
       SET NOCOUNT OFF
       RETURN
      end
      UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null, TrN_ZwrID = NULL, TrN_ZwrIdWZKK = NULL WHERE  TrN_ZwrID = @FpId AND TrN_Rodzaj IN (306061,306071,306072);
      -- kasuję powiązania WZKK
      DELETE CDN.TraNagRelacje WHERE TrR_TrNID IN
      (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrID = @FpId AND TrN_Rodzaj IN (306061,306071,306072))
      DELETE CDN.TraNagRelacje WHERE TrR_FaID IN
      (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrID = @FpId AND TrN_Rodzaj IN (306061,306071,306072))
    DELETE CDN.TraNagRelacje WHERE TrR_TrNId = @FpId
    DELETE CDN.TraNagRelacje WHERE TrR_FaId = @FpId
   END
  END
  CLOSE wszystkieRWS
       DEALLOCATE wszystkieRWS
  EXEC CDN.AnulowanieDokumentu @TylkoAnulowanie, @TrnID, @TrnRodzaj, @TrnFaId
  SET @Err = @@ERROR
  IF @Err <> 0
  BEGIN
   GOTO KONIEC
  END
 END
-- korekty PWP
   declare @PWPKId int
  DECLARE PWPKI CURSOR LOCAL FAST_FORWARD FOR
    SELECT TrN_TrNId from cdn.TraNag WHERE Trn_ZwrId = @TrnID and  isnull(TrN_ZwridWzkk,0) > 0
    OPEN PWPKI
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM PWPKI INTO @PWPKId
  IF @@FETCH_STATUS <> 0 BREAK
  exec CDN.AnulowaniePWP 1,@PWPKId,1
        SET @Err = @@ERROR
   IF @Err <> 0
   BEGIN
    GOTO KONIEC
   END
      END
    CLOSE PWPKI
  DEALLOCATE PWPKI
   DELETE cdn.TraSElem
  FROM cdn.TraSElem  S
       JOIN cdn.TraElem E on  S.TrS_TrEId = E.TrE_TrEId
       JOIN cdn.TraNag N  on  N.TrN_TrNId = E.TrE_TrNId
  WHERE TrN_ZwrIDWZKK = @TrnID AND TrN_Rodzaj IN (306061,306071,306072)
 UPDATE CDN.TraNag SET TrN_FaID=NULL, TrN_RelTrNId=NULL, TrN_Bufor=-1, TrN_TS_Mod = GETDATE() WHERE Trn_TrNId = @TrnID --anulowanie dok
 UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null, TrN_ZwrID = NULL, TrN_ZwrIdWZKK = NULL WHERE  TrN_ZwrIDWZKK = @TrnID AND TrN_Rodzaj IN (306061,306071,306072);
      -- kasuję powiązania WZKK
      DELETE CDN.TraNagRelacje WHERE TrR_TrNID IN
      (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrIDWZKK = @TrnID AND TrN_Rodzaj IN (306061,306071,306072))
      DELETE CDN.TraNagRelacje WHERE TrR_FaID IN
      (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrIDWZKK = @TrnID AND TrN_Rodzaj IN (306061,306071,306072))
        -- kasuję relacje
 DELETE CDN.TraNagRelacje WHERE TrR_TrNId = @TrnID
 DELETE CDN.TraNagRelacje WHERE TrR_FaId = @TrnID
 --
KONIEC:
 SET NOCOUNT OFF;
 IF @@TRANCOUNT <> 0
 BEGIN
  IF @Err <> 0
   ROLLBACK TRAN
  ELSE
   COMMIT TRAN
 END
 SELECT 0   -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
 RETURN
END
