CREATE PROCEDURE [CDN].[AnulowanieKorektMagazynowych]
@FaID             AS INT
,@Czykon          AS INT
, @WynikString nvarchar(512) OUTPUT
AS
BEGIN
 --BEGIN TRAN;
 --SET NOCOUNT ON;
  DECLARE @Komunikat      NVARCHAR(250)
  DECLARE @TrE_TrEId      INT
  DECLARE @TrE_TwrId      INT
  DECLARE @TrE_TwrKod     NVARCHAR(50)
  DECLARE @TrE_TwrNazwa   NVARCHAR(255)
  DECLARE @TrE_DataOpe    DATETIME
  DECLARE @KaucjeZwrId   INT
  DECLARE @Numery   NVARCHAR(255)
  DECLARE @PWPKId   INT
  DECLARE @Err         INT
  SET @WynikString = ''
  SET @Numery = ''
  SET @KaucjeZwrId = NULL
  SELECT @KaucjeZwrId = TrN_ZwrId FROM CDN.TraNag WHERE TrN_TrNID=@FaID AND TrN_TypDokumentu IN (313, 314);
  IF EXISTS(SELECT A.TrS_TrSId
   FROM cdn.TraSElem  A
   JOIN cdn.TraSElem B ON A.TrS_ZwrId = B.TrS_TrSId AND A.TrS_Rodzaj IN (306061,306071,306072)
        JOIN cdn.TraElem E  ON B.TrS_TrEId = E.TrE_TrEId
   JOIN cdn.TraNag N   ON N.TrN_TrNId = E.TrE_TrNId
            WHERE N.TrN_TrNId = @FaID
      )
 BEGIN
  SELECT TOP 1 @Numery = IsNull(SZ.TrN_NumerPelny, '')
   FROM cdn.TraSElem  A
   JOIN cdn.TraSElem  B ON A.TrS_ZwrId = B.TrS_TrSId AND A.TrS_Rodzaj IN (306061,306071,306072)
        JOIN cdn.TraElem  BE ON A.TrS_TrEId = BE.TrE_TrEId
   JOIN cdn.TraNag   BN  ON BN.TrN_TrNId = BE.TrE_TrNId
   JOIN cdn.TraNag   SZ  ON SZ.TrN_TrNId = BN.TrN_ZwrIdWZKK
        JOIN cdn.TraElem  E ON B.TrS_TrEId = E.TrE_TrEId
   JOIN cdn.TraNag   N  ON N.TrN_TrNId = E.TrE_TrNId
            WHERE N.TrN_TrNId = @FaID
  --@Numery = IsNull(WZKK.TrN_NumerPelny, '')
  IF RTRIM(@Numery) = ''
   SET @Komunikat = '##OPT34498##'--'Istnieją powiązane dokumenty WZKK!'
  ELSE
   SET @Komunikat = '##OPT34499##%%s1%%=' + @Numery+ '##'--'Istnieją powiązane dokumenty WZKK! (Musisz najpierw anulować dokument: ' + RTRIM(@Numery) + ')'
      GOTO KOMUNIKAT
    END
  -- wykasowanie subelementów kasowanego dokumentu i skojarzonej WZKK
  DELETE cdn.TraSElem
  FROM cdn.TraSElem  S
       JOIN cdn.TraElem E on  S.TrS_TrEId = E.TrE_TrEId
       JOIN cdn.TraNag N  on  N.TrN_TrNId = E.TrE_TrNId
  WHERE N.TrN_TrNId = @FaID OR  N.TrN_TrNId IN
                                    (SELECT WZKK.TrN_TrNID FROM CDN.TraNag WZKK
                                          WHERE WZKK.TrN_ZwrIDWZKK = @FaID AND WZKK.TrN_Rodzaj
                                            IN (306061,306071,306072))
  -- sprawdzenie poprawności
  DECLARE EKI CURSOR LOCAL FAST_FORWARD FOR
    SELECT TrE_TrEId, TrE_TwrId, TrE_DataOpe, Max(TrE_TwrKod),MAX(TrE_TwrNazwa)
    FROM cdn.TraElem E
         JOIN cdn.TraNag N on  N.TrN_TrNId = E.TrE_TrNId JOIN CDN.TraNagRelacje R ON N.TrN_TrNId = R.TrR_TrNId
    WHERE R.TrR_FaId = @FaId
    GROUP BY TrE_TrEId, TrE_TwrId, TrE_DataOpe
    OPEN EKI
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM EKI INTO @TrE_TrEId, @TrE_TwrId, @TrE_DataOpe, @TrE_TwrKod, @TrE_TwrNazwa
        IF @@FETCH_STATUS <> 0 BREAK
        SET @Komunikat = CDN.TwrZasobyErr ( @TrE_TrEId, @TrE_TwrId, @TrE_TwrKod,@TrE_TwrNazwa, @TrE_DataOpe )
        IF @Komunikat <> '' GOTO KOMUNIKAT
      END
    CLOSE EKI
  DEALLOCATE EKI
  -- anulowanie WZKK
  IF EXISTS ( SELECT * FROM CDN.TraNag join
  (select TrN_TrNID as TrNID, TrN_ZwrID as ZwrID from CDN.TraNag WHERE  TrN_ZwrIDWZKK = @FaID AND TrN_Rodzaj IN (306061,306071,306072)) as A on TrN_ZwrId = A.ZwRID
  where TrN_TrNID >TrNID and TrN_Bufor <> -1 AND TrN_Rodzaj NOT IN (306061,306071,306072))
  begin
  SET @Komunikat = '##OPT34441##'--'Nie można anulować dokumentu! Anulowany dokument jest powiązany z dokumentem WZKK (korekta kosztów) do którego istnieją późniejsze korekty. Anuluj późniejsze korekty.'
  GOTO KOMUNIKAT
  end
  UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null, TrN_ZwrID = NULL, TrN_ZwrIdWZKK = NULL WHERE  TrN_ZwrIDWZKK = @FaID AND TrN_Rodzaj IN (306061,306071,306072);
  -- kasuję powiązania WZKK
  DELETE CDN.TraNagRelacje WHERE TrR_TrNID IN
  (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrIDWZKK = @FaID AND TrN_Rodzaj IN (306061,306071,306072))
  DELETE CDN.TraNagRelacje WHERE TrR_FaID IN
  (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrIDWZKK = @FaID AND TrN_Rodzaj IN (306061,306071,306072))
  -- anulowanie powiązanych dokumentów magazynowych
  /* SO wykomentowalem bo anulowalo za duzo dokumentu w przypadku PZ -> PKA -> PKK -> PKK i anulacja ostatniego
  UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null
  FROM CDN.TraNag JOIN CDN.TraNagRelacje  ON TrN_TrNId = TrR_TrNId
  WHERE  TrN_ZwrId IS NOT NULL AND TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje ON TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @FaID) AND TrN_TypDokumentu IN (306,307,313,314);
  */
        DELETE cdn.TraNagRelacje WHERE TrR_TrNID = @FaID
        DELETE cdn.TraNagRelacje WHERE TrR_FaID = @FaID
  -- kasuję powiązania dokumentów magazynowych
 -- DELETE CDN.TraNagRelacje WHERE TrR_TrNID IN (SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @FaID) AND TrN_TypDokumentu IN (306,307,313,314))
--  DELETE CDN.TraNagRelacje WHERE TrR_FaID IN  (SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @FaID) AND TrN_TypDokumentu IN (306,307,313,314))
  -- anulowanie dokumentu
  UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_RelTrNId=null, TrN_FaId = NULL WHERE TrN_TrNId = @FaID;
  -- SO, usuwam zmiany z ustawianiem zwrid na nulla
  -- UPDATE CDN.TraNag SET TrN_ZwrId = NULL WHERE TrN_TrNId = @FaID;
  -- kasuję powiązania dokumentów magazynowych tylko w jedną stronę, a następnie w druga stronę są kasowane w procedurze sp_AnulowanieDokumentu
  DELETE CDN.TraNagRelacje WHERE TrR_TrNID IN (SELECT TrN_TrNID FROM CDN.TraNag WHERE TrN_TrNId = @FaID AND TrN_TypDokumentu NOT IN(317,318))
  DELETE CDN.TraNagRelacje WHERE TrR_FaID IN (SELECT TrN_TrNID FROM CDN.TraNag WHERE TrN_TrNId = @FaID AND TrN_TypDokumentu NOT IN(317,318))
  IF @KaucjeZwrId IS NOT NULL
 BEGIN
  EXEC CDN.Ustaw_ZwroconoCalaIlosc @KaucjeZwrId
 END
 DECLARE @idpwpk int, @Poziom int = 0
  DECLARE @PWPKOR     TABLE ( TrNId INT, Poziom INT )
  INSERT INTO @PWPKOR ( TrNId, Poziom )
  select @FaId, @Poziom
WHILE @Poziom is NOT NULL
BEGIN
if exists (SELECT TrN_TrNId from cdn.TraNag WHERE TrN_ZwridWzkk in (select TrNId from @PWPKOR where Poziom = @Poziom) and trn_typdokumentu = 317)
begin
INSERT INTO @PWPKOR(TrNId, Poziom ) SELECT TrN_TrNId,@Poziom + 1 from cdn.TraNag WHERE TrN_ZwridWzkk in (select TrNId from @PWPKOR where Poziom = @Poziom) and trn_typdokumentu = 317
  SET @Poziom = @Poziom + 1
end
else
 set @Poziom = null
END
  DECLARE PWPKI CURSOR LOCAL STATIC FORWARD_ONLY FOR
    SELECT TrNId from @PWPKOR
    OPEN PWPKI
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM PWPKI INTO @PWPKId
  IF @@FETCH_STATUS <> 0 BREAK
   -- wykasowanie subelementów kasowanego dokumentu i skojarzonej WZKK
      DELETE cdn.TraSElem
      FROM cdn.TraSElem  S
        JOIN cdn.TraElem E on  S.TrS_TrEId = E.TrE_TrEId
        JOIN cdn.TraNag N  on  N.TrN_TrNId = E.TrE_TrNId
      WHERE N.TrN_TrNId = @PWPKId OR  N.TrN_TrNId IN
         (SELECT WZKK.TrN_TrNID FROM CDN.TraNag WZKK
            WHERE WZKK.TrN_ZwrIDWZKK = @PWPKId AND WZKK.TrN_Rodzaj
           IN (306061,306071,306072))
      -- anulowanie WZKK
      IF EXISTS ( SELECT * FROM CDN.TraNag join
      (select TrN_TrNID as TrNID, TrN_ZwrID as ZwrID from CDN.TraNag WHERE  TrN_ZwrIDWZKK = @PWPKId AND TrN_Rodzaj IN (306061,306071,306072)) as A on TrN_ZwrId = A.ZwRID
      where TrN_TrNID >TrNID and TrN_Bufor <> -1 AND TrN_Rodzaj NOT IN (306061,306071,306072))
      begin
       SET @Komunikat = '##OPT34441##'--'Nie można anulować dokumentu! Anulowany dokument jest powiązany z dokumentem WZKK (korekta kosztów) do którego istnieją późniejsze korekty. Anuluj późniejsze korekty.'
       RAISERROR( @Komunikat, 16, 1)
       ROLLBACK TRAN
       SET NOCOUNT OFF
       RETURN
      end
      UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null, TrN_ZwrID = NULL, TrN_ZwrIdWZKK = NULL WHERE  TrN_ZwrIDWZKK = @PWPKId AND TrN_Rodzaj IN (306061,306071,306072);
      -- kasuję powiązania WZKK
      DELETE CDN.TraNagRelacje WHERE TrR_TrNID IN
      (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrIDWZKK = @PWPKId AND TrN_Rodzaj IN (306061,306071,306072))
      DELETE CDN.TraNagRelacje WHERE TrR_FaID IN
      (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrIDWZKK = @PWPKId AND TrN_Rodzaj IN (306061,306071,306072))
  exec CDN.AnulowaniePWP 1,@PWPKId,1
        SET @Err = @@ERROR
   IF @Err <> 0
   BEGIN
    GOTO KOMUNIKAT
   END
      END
    CLOSE PWPKI
  DEALLOCATE PWPKI
  KOMUNIKAT:
  IF @Komunikat <> ''
    BEGIN
   --IF @@TRANCOUNT <> 0  ROLLBACK TRAN
      set @WynikString = @Komunikat
   if @Czykon = 0
      RAISERROR( @Komunikat, 16, 1)
     -- SET NOCOUNT OFF
      RETURN
    END
  --SET NOCOUNT OFF;
  --IF @@TRANCOUNT <> 0  COMMIT TRAN
END
