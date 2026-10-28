CREATE PROCEDURE CDN.AnulowanieDokumentu
@TylkoAnulowanie  AS INT,
@TrnID            AS INT,
@TrnRodzaj        AS INT,
@TrnFaId          AS INT
AS
BEGIN
/* @TylkoAnulowanie=0   -  bez anulowania dokumentów, tylko rozpinanie i zmiana rodzaju
   @TylkoAnulowanie=1   -  anulowanie dokumentów i rozpinanie powiązanych
   @TylkoAnulowanie=2   -  O!O anulowanie dokumentów handlowych i magazynowych (O!O)
   @TylkoAnulowanie=4   -  O!O anulowanie tylko FA (PA i WZ zostają)
   @TylkoAnulowanie=8   -  anulowanie tylko FA i PA (WZ zostają)
*/
 DECLARE @Komunikat      NVARCHAR(250)
 DECLARE @idPow          INT
 DECLARE @RodzajPF       INT
 DECLARE @Wynik          INT
 DECLARE @WynikString    NVARCHAR(512)
 DECLARE @KaucjeZwrId    INT
 DECLARE @FaPfZal        INT
 DECLARE @PFzWZ          INT
 DECLARE @Rodzaj         INT
 DECLARE @Typ            INT
 DECLARE @TrNIdKonwersji INT
 DECLARE @Orginalny      INT
 DECLARE @FaId           INT
 DECLARE @FaTyp          INT
 DECLARE @TrNMagId       INT
 DECLARE @WZId           INT
 DECLARE @PowiazanyId    INT
 DECLARE @TrNIdPoziom    INT
 --tabele dla obsługi starych rezerwacji
 DECLARE @TrN TABLE ( TrNId INT)
 DECLARE @RO TABLE ( ROZDTrNId INT)
 SET @KaucjeZwrId = NULL
 SET @FaPfZal = 0
    IF CDN.IstniejaWZKK(@TrnID) <> ''
    BEGIN
  SET @Komunikat = '##OPT34498##'--'Istnieją powiązane dokumenty WZKK!'
        GOTO KOMUNIKAT
    END
--anulowanie FA kiedy było FA->PF wystawione w wersji <16 trzeba zbudowac relacje PF-WZ
IF  @TrnRodzaj/1000  = 302 -- anulowanie FZ, FS i PA przeniesione na serwer
     BEGIN
if  ( select TOP 1 1 from cdn.tranag where trn_trnid in (select TrR_FAId from CDN.TraNagRelacje WHERE TrR_TrNId = @TrnID and TrR_FATyp = 320 and TrR_TrNTyp = 302) and trn_zwroconocalailosc = 5) = 1
begin
update cdn.tranag set trn_zwroconocalailosc = 0 where trn_trnid in (select TrR_FAId from CDN.TraNagRelacje WHERE TrR_TrNId = @TrnID and TrR_FATyp = 320 and TrR_TrNTyp = 302)
declare @WZzFPFTable table (Id int)
insert into @WZzFPFTable
select tre_treid
from cdn.traelem
join cdn.tranag a on tre_trnid = a.trn_trnid
where a.trn_typdokumentu = 320 and
a.trn_trnid in (select TrR_FAId from CDN.TraNagRelacje WHERE TrR_TrNId = @TrnID and TrR_FATyp = 320 and TrR_TrNTyp = 302) and
exists(select trr_trnid from cdn.tranagrelacje join cdn.tranag b on b.trn_trnid = trr_faid where trr_trnid = a.TrN_TrNId and trr_fatyp = 306 and trn_bufor <> -1 and trn_korekta = 0)
declare @id int
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
 select distinct Id from @WZzFPFTable
 OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
          @ID
 IF @@FETCH_STATUS <> 0 BREAK
        INSERT INTO CDN.TraElemRelacje (TeR_ParentTyp,TeR_ParentId,TeR_ChildTyp,TeR_ChildId,TeR_Flaga)
            SELECT  b.TrE_TypDokumentu,b.TrE_TrEId,a.TrE_TypDokumentu,a.TrE_TrEId,0
            FROM CDN.TraElem a
            Join cdn.tranag on tre_trnid = trn_trnid
            JOIN CDN.tranagrelacje on TrR_TrNID = a.TrE_TrNID AND TrR_FaTyp =320 AND TrR_TrNTyp = 306
            JOIN CDN.traelem b on TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow
            WHERE b.TrE_TrEId = @ID AND TrN_Bufor <> -1 AND TrN_Korekta = 0 AND a.TrE_TrEId not in (SELECT TeR_ChildId FROM CDN.TraElemRelacje WHERE TeR_ParentId = @ID)
            AND a.TrE_TrEId not in (SELECT TeR_ParentId FROM CDN.TraElemRelacje WHERE TeR_ChildId = @ID)
            ORDER BY TrR_TrRId DESC
END
    CLOSE Dodawane
    DEALLOCATE Dodawane
DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
 select distinct tre_trnid from cdn.traelemrelacje
join cdn.traelem on tre_treid = ter_childid
where ter_childtyp = 306 and ter_parenttyp = 320
 OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
          @id
 IF @@FETCH_STATUS <> 0 BREAK
       exec cdn.UstawWydaneIlosciDlaPF  @id
END
    CLOSE Dodawane
    DEALLOCATE Dodawane
end
END
 IF  @TrnRodzaj/1000 = 313 OR @TrnRodzaj/1000 = 314 --anulowanie FA powstałej z PF jeśli istnieją FAZAL tylko rozpina powiązanie FA z PF
 BEGIN
  SELECT @KaucjeZwrId = TrN_ZwrId FROM CDN.TraNag WHERE TrN_TrNID=@TrnID;
 END
 IF  @TrnRodzaj/1000 = 302 --anulowanie FA powstałej z PF jeśli istnieją FAZAL tylko rozpina powiązanie FA z PF
     BEGIN
      --SET @FaPfZal = CDN.IstniejaFaZal(@TrnID)
      SELECT @PFzWZ = count(TrN_TrNId) FROM cdn.TraNag JOIN cdn.TraNagRelacje  ON TrN_TrNId = TrR_TrNId
            WHERE  TrR_FaId = @TrnID AND TrN_Rodzaj =306010 --szukamy dla FSPF czy sa WZ zeby je przepiac z PF na FS
--    SELECT @PFzWZ = count(TrN_TrNId) FROM cdn.TraNag WHERE  TrN_FaId = @TrnID AND TrN_Rodzaj =306010 --szukamy dla FSPF czy sa WZ zeby je przepiac z PF na FS
     END
    IF  @TylkoAnulowanie=4  --O!O anulowanie FA - PA i WZ pozostają powiązane
    BEGIN
--RT 16  EXEC CDN.UstawRodzajDlaProForma @TrnID, @TrnRodzaj, @TrnFaId
  -- ustawiamy rodzaj
    UPDATE CDN.TraNag SET TrN_Rodzaj=CDN.UstalRodzajPrzedKonwersja(TrN_TrNId, TrN_Rodzaj, TrN_TypDokumentu, @TrnID) FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID =@TrnID AND (TrN_TypDokumentu=306 or  TrN_TypDokumentu=307);
--  UPDATE CDN.TraNag SET TrN_Rodzaj=CDN.fn_UstalRodzajPrzedKonwersja(TrN_TrNId, TrN_Rodzaj, TrN_TypDokumentu, @TrnID) WHERE TrN_FaID =@TrnID AND (TrN_TypDokumentu=306 or  TrN_TypDokumentu=307);
     -- przywracam powiązanie WZ-tek z PAragonem
--        UPDATE cdn.TraNag SET TrN_FaID=(SELECT TOP 1 TrN_TrNId FROM cdn.TraNag WHERE TrN_FaID=@TrnID AND TrN_TypDokumentu=305) WHERE TrN_FaID=@TrnID AND (TrN_TypDokumentu=306 or  TrN_TypDokumentu=307);
        -- przywracam powiązanie WKA z PAragonem
--        UPDATE cdn.TraNag SET TrN_RelTrNId=(SELECT TOP 1 TrN_TrNId FROM cdn.TraNag WHERE TrN_FaID=@TrnID AND TrN_TypDokumentu=305) WHERE TrN_RelTrNId=@TrnID AND TrN_TypDokumentu=314;
        -- rozpinam powiązanie PA z FA
--      UPDATE CDN.TraNag SET TrN_FaID=null WHERE TrN_FaID =@TrnID AND TrN_TypDokumentu=305;
        UPDATE CDN.TraNag SET TrN_FaID=null FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID =@TrnID AND TrN_TypDokumentu=305
  -- numer obcy na zapisie KB
        update cdn.BnkZdarzenia set BZd_NumerObcy = '' from cdn.BnkZdarzenia JOIN cdn.TraNagRelacje  on BZd_DokumentId = TrR_TrNId WHERE TrR_FaID =@TrnID AND TrR_TrNTyp=305 AND BZd_DokumentTyp = 1
  -- przepinamy rezerwacje na paragon
  if @TrnRodzaj = 302006
  begin
         update TraS set trs_treid = PA.TrE_TrEId from  cdn.TraSElem TraS
           join cdn.TraElem FA on FA.tre_treid = trs_treid
           left join cdn.tranagrelacje on FA.TrE_TrNId =  TrR_FAId and TrR_FaTyp = 302 and TrR_TrNTyp= 305
           left join cdn.TraElem PA on PA.TrE_TrNId = TrR_TRNID and FA.TrE_LpPow = PA.TrE_LpPow
           where TrR_FAId = @TrnID  and ISNULL(PA.TrE_TrEId,0) > 0 and PA.TrE_WyborDostaw = 0
        update TraS set tsd_treid = PA.TrE_TrEId from  cdn.TraSElemDost TraS
           join cdn.TraElem FA on FA.tre_treid = tsd_treid
           left join cdn.tranagrelacje on FA.TrE_TrNId =  TrR_FAId and TrR_FaTyp = 302 and TrR_TrNTyp= 305
           left join cdn.TraElem PA on PA.TrE_TrNId = TrR_TRNID and FA.TrE_LpPow = PA.TrE_LpPow
           where TrR_FAId = @TrnID  and ISNULL(PA.TrE_TrEId,0) > 0
  end
        -- anuluję FA
        UPDATE CDN.TraNag SET TrN_FaID=NULL, TrN_RelTrNId=null, TrN_Bufor=-1, TrN_TS_Mod = GETDATE() WHERE Trn_TrNId = @TrnID --anulowanie
  -- przepinamy wzkk
        UPDATE WZKK SET WZKK.TrN_ZwrId     = Pa.TrN_TrnID from cdn.TraNag WZKK
           left join cdn.tranagrelacje on WZKK.TrN_ZwrId =  TrR_FAId and TrR_FaTyp = 302 and TrR_TrNTyp= 305
           left join cdn.TraNag Pa on TrR_TrNId = Pa.TrN_TrNID
           where TrR_FAId = @TrnID and WZKK.TrN_Rodzaj in (306061,306071,306072) and WZKK.TrN_Bufor = 0
   IF @TylkoAnulowanie = 4
     BEGIN
        UPDATE CDN.TraNag SET TrN_Rodzaj=case when ISNULL(RelPA.TrR_FaId,0)>0 then 306006 else TrN_TypDokumentu*1000 end, TrN_FaId = NULL FROM CDN.TraNag
        JOIN cdn.TraNagRelacje RelWZ  on TrN_TrNId = RelWZ.TrR_TrNId
        left Join cdn.TraNagRelacje RelPA  on RelWZ.TrR_TrNId = RelPA.TrR_TrNId and RelPA.TrR_FaTyp = 305
        WHERE RelWZ.TrR_FaID =@TrnID AND TrN_TypDokumentu=306;
  update cdn.TraNag set TrN_Rodzaj = 305004, trn_statusint = case when (trn_statusint & 4) / 4  != 1 then trn_statusint+4 else trn_statusint end
        where TrN_TrNID in(
        select trn_trnid  from cdn.TraNagRelacje
        left join cdn.TraNag on TrR_TrNId = trn_trnid
        where TrR_FaTyp = 306 and TrR_TrNTyp = 305
        and TrR_TrNId in (select trr_faid from cdn.TraNagRelacje WHERE  TrR_TrNId = @TrnID AND TrR_FaTyp = 305 AND TrR_TrNTyp = 302)
        and TrN_Rodzaj = 305000 and TrN_StatusInt = 2)
        UPDATE CDN.TraNag SET TrN_Rodzaj=TrN_TypDokumentu*1000, TrN_FaId = NULL FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID =@TrnID AND TrN_TypDokumentu=307;
        DELETE CDN.TraNagRelacje WHERE TrR_TrNId = @TrnID
        DELETE CDN.TraNagRelacje WHERE TrR_FaId = @TrnID
        UPDATE CDN.TraNag SET TrN_Rodzaj=CDN.UstalRodzajPrzedKonwersja(TrN_TrNId, TrN_Rodzaj, TrN_TypDokumentu,0) FROM CDN.TraNag  WHERE TrN_TrNID =@TrnID
     END
        IF @TrnRodzaj = 302202   -- anulowanie fa zal korekta zgł 66222
        BEGIN
   EXEC CDN.InicjalizujFAZal @TrnFaId, 1, @Wynik OUTPUT
            IF @Wynik = 1
            BEGIN
    SET @Komunikat = '##OPT34500##'--'Wartość anulowanego dokumentu jest większa niż wartość wpłaconych zaliczek!'
                GOTO KOMUNIKAT
            END
        END
        GOTO KONIEC
    END
    IF  @TrnRodzaj/1000 IN (301, 302, 305) -- anulowanie FZ, FS i PA przeniesione na serwer
     BEGIN
         -- wykasowanie subelementów kasowanego dokumentu i skojarzonej WZKK
         DELETE cdn.TraSElem
         FROM cdn.TraSElem  S
           JOIN cdn.TraElem E on  S.TrS_TrEId = E.TrE_TrEId
           JOIN cdn.TraNag N  on  N.TrN_TrNId = E.TrE_TrNId
         WHERE N.TrN_TrNId = @WZId OR  N.TrN_TrNId IN
                                    (SELECT WZKK.TrN_TrNID FROM CDN.TraNag WZKK
                                          WHERE WZKK.TrN_ZwrID = @TrnID AND WZKK.TrN_Rodzaj
                                            IN (306061,306071,306072))
         -- anulowanie WZKK
         IF EXISTS ( SELECT * FROM CDN.TraNag join
         (select TrN_TrNID as TrNID, TrN_ZwrID as ZwrID from CDN.TraNag WHERE  TrN_ZwrIDWZKK = @TrnID AND TrN_Rodzaj IN (306061,306071,306072)) as A on TrN_ZwrId = A.ZwRID
         where TrN_TrNID >TrNID and TrN_Bufor <> -1 AND TrN_Rodzaj NOT IN (306061,306071,306072))
         begin
    SET @Komunikat = '##OPT34441##'--'Nie można anulować dokumentu! Anulowany dokument jest powiązany z dokumentem WZKK (korekta kosztów) do którego istnieją późniejsze korekty. Anuluj późniejsze korekty.'
    GOTO KOMUNIKAT
   end
        UPDATE CDN.TraNag SET TrN_FaID=NULL, TrN_RelTrNId=NULL, TrN_Bufor=-1, TrN_TS_Mod = GETDATE() WHERE Trn_TrNId = @TrnID --anulowanie
        UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null  FROM CDN.TraNag JOIN CDN.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu =305;
 IF @TrNRodzaj <> 302004 AND @TylkoAnulowanie = 1
   BEGIN
       DELETE FROM @TrN
       INSERT INTO @TrN (TrNId)
       SELECT D.Trr_TrNId FROM CDN.TraNagRelacje D  JOIN CDN.TraNagRelacje C on C.TrR_TrNId = D.TrR_FaId
              JOIN CDN.TraNagRelacje B on C.trr_trnid = B.TrR_TrNId
              JOIN CDN.TraNag E on B.TrR_TrNId = E.TrN_TrNId
              JOIN CDN.TraNag F on D.TrR_TrNId = F.TrN_TrNId
              WHERE B.TrR_FaID = @TrNId AND B.TrR_TrNTyp =305 and E.TrN_Bufor = -1 AND D.Trr_TrNTyp = 308 AND F.TrN_Rodzaj = 308008
        UPDATE CDN.TraNag SET TrN_ZwroconoCalaIlosc = 0, TrN_Rodzaj = TrN_TypDokumentu * 1000 WHERE TrN_TrNID IN (SELECT TrNId FROM @TrN) AND ISNULL(TrN_ZwroconoCalaIlosc,0) < 4
        UPDATE CDN.TraElem SET Tre_Aktywny = 1 WHERE TrE_Aktywny = 1 AND TrE_TrNid IN (SELECT TrNId FROM @TrN)
       DELETE FROM @TrN
   END
/*
        UPDATE CDN.TraNag SET TrN_ZwroconoCalaIlosc = 0, TrN_Rodzaj = TrN_TypDokumentu * 1000 WHERE TrN_TrNID IN (SELECT D.Trr_TrNId FROM CDN.TraNagRelacje D
              JOIN CDN.TraNagRelacje C ON C.TrR_TrNId = D.TrR_FaId
              JOIN CDN.TraNagRelacje B ON C.trr_trnid = B.TrR_TrNId
              JOIN CDN.TraNag E ON B.TrR_TrNId = E.TrN_TrNId
              JOIN CDN.TraNag F ON D.TrR_TrNId = F.TrN_TrNId
              WHERE B.TrR_FaID = @TrNId AND B.TrR_TrNTyp =305 and E.TrN_Bufor = -1 AND D.Trr_TrNTyp = 308 AND F.TrN_Rodzaj = 308008)
        UPDATE CDN.TraElem SET Tre_Aktywny = 1 WHERE TrE_Aktywny = 1 AND TrE_TrNid IN (SELECT D.Trr_TrNId FROM CDN.TraNagRelacje D
              JOIN CDN.TraNagRelacje C on C.TrR_TrNId = D.TrR_FaId
              JOIN CDN.TraNagRelacje B on C.trr_trnid = B.TrR_TrNId
              JOIN CDN.TraNag E on B.TrR_TrNId = E.TrN_TrNId
              JOIN CDN.TraNag F on D.TrR_TrNId = F.TrN_TrNId
              WHERE B.TrR_FaID = @TrNId AND B.TrR_TrNTyp =305 and E.TrN_Bufor = -1 AND D.Trr_TrNTyp = 308 AND F.TrN_Rodzaj = 308008)
*/
        -- SO usuwam zmiany z ustawianiem zwrid na nulla
        --UPDATE CDN.TraNag SET TrN_ZwrId = NULL WHERE Trn_TrNId = @TrnID --rozpinanie korekt
        --UPDATE CDN.TraNag SET TrN_FaID=NULL, TrN_RelTrNId=NULL, TrN_Bufor=-1, TrN_TS_Mod = GETDATE() WHERE Trn_TrNId = @TrnID
     END
        --      FAKI do FA, PA, FZ pierwotnej. Tworzę PW/RW. Następnie anuluję FAKI, powinna się anulować także PW/RW.
        --      1) Kasować PW/RW (możemy sobie na to pozwolić)
        --      2) Anulowć PW/RW (a raczej próbować, bo ze względu na zasoby może się nie powieść)
    IF  @TrnRodzaj IN (301101, 301102, 301103, 302101, 302102, 302103, 305101, 305102, 305103) -- anulowanie FAKI do FA pierwotnej
 BEGIN
  EXEC CDN.FaPierwotnaAnulujPwRw @TrnID
  GOTO KONIEC
 END
  -- po zanulowaniu FRR rozpinać go z FZ i podmieniać mu rodzaj (jeśli później ktoś zanuluje FZ,
  -- to standardowo zostanie rozpięty PZ)
  -- jeśli zanulujemy FZ skojarzony z FRR, to zostanie zanulowany FZ i PZ (tak jak do tej pory).
 IF  @TrnRodzaj/1000 = 350
 BEGIN --rozpinanie powiazania z FZ
  UPDATE CDN.TraNag SET TrN_FaId=null, TrN_RelTrNId=null WHERE TrN_TrNId=@TrnID;
  -- zmien rodzaj na FZ
  -- SO usuwam stad, przenioslem nizej UPDATE CDN.TraNag SET TrN_Rodzaj=CDN.fn_UstalRodzajPrzedKonwersja(TrN_TrNId, TrN_Rodzaj, TrN_TypDokumentu, @TrnID) WHERE TrN_TrNId = @TrnFaId AND TrN_TypDokumentu=301;
 END
    -- anulowanie ZD, jeżeli ZD powstało z RO
    IF  @TrnRodzaj/1000 = 309
 BEGIN --rozpinanie powiazania z RO
  UPDATE CDN.TraNag SET TrN_FaID=null,TrN_Rodzaj=CDN.UstalRodzajPrzedKonwersja(TrN_TrNId, TrN_Rodzaj, TrN_TypDokumentu, @TrnID) WHERE TrN_FaID =@TrnID AND TrN_TypDokumentu=308;
  UPDATE CDN.TraNag SET TrN_RelTrNId=null WHERE TrN_RelTrNId=@TrnID;
 END
 IF  @TrnRodzaj/1000 in (302,306,305,304,312)
 BEGIN --rozpinanie powiazania z RO
  UPDATE CDN.TraNag SET TrN_FaID=null WHERE TrN_FaID =@TrnID AND TrN_TypDokumentu=308;
 ENd
    IF  @TrnRodzaj IN (302005, 302007,302012, 302091, 302092, 305005, 301005, 301006, 301012, 301009, 301091, 301092, 301051, 301052, 301053)  --e_op_Rdz_FAWZKI, e_op_Rdz_FZPZKI, e_op_Rdz_FZPZKG,e_op_Rdz_FZPZKW
    BEGIN
            --anulowanie skojarzonych dokumentów
                UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=NULL, TrN_RelTrNId=null WHERE Trn_FaID = @TrnID AND TrN_TypDokumentu NOT IN (306,307,313,314)--anulowanie
                UPDATE CDN.TraNag SET TrN_RelTrNId=null WHERE TrN_RelTrNId=@TrnID;
  --anulowanie skojarzonych dokumentów magazynowych
        DECLARE DokumentyMag CURSOR LOCAL FAST_FORWARD FOR
               SELECT TrN_TrNId FROM cdn.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID AND TrN_TypDokumentu IN (306, 307,313,314) AND TrN_Rodzaj NOT IN (306061,306071,306072)
--             SELECT TrN_TrNId FROM cdn.TraNag WHERE TrN_FaID = @TrnID AND TrN_TypDokumentu IN (306, 307,313,314) AND TrN_Rodzaj NOT IN (306061,306071,306072)
        OPEN DokumentyMag
        WHILE 1=1
        BEGIN -- dla każdego anuluję
          FETCH NEXT FROM DokumentyMag INTO @TrNMagId
            IF @@FETCH_STATUS <> 0 BREAK
            Exec CDN.AnulowanieKorektMagazynowych @TrNMagId, 1, @WynikString OUTPUT
            if @WynikString <> ''
            BEGIN
                SET @Komunikat = @WynikString
                GOTO KOMUNIKAT
            END
        END
        CLOSE DokumentyMag
        DEALLOCATE DokumentyMag
    END
    INSERT INTO @TrN ( TrNId ) SELECT TrN_TrNId FROM CDN.TraNagRelacje JOIN CDN.TraNag ON TrR_TRNId = TrN_TrNId WHERE TrR_FaID =@TrnID and TrN_Rodzaj IN (308009, 308008, 308010, 309008, 309009)
    -- zmiana pola rodzaj dokumentu
    -- dla anulowanego dokumentu
        -- ze względu na zgłoszenie 62078 usunąlem ponizsze 4 linijek
        --IF @TrnRodzaj = 321022  --FWZ powiązana z FWS i anuluje FWZ, to zmieniam rodzaj na FWS
          -- BEGIN
            -- UPDATE CDN.TraNag SET TrN_Rodzaj=CDN.fn_UstalRodzajDokumentu(TrN_TypDokumentu,TrN_Rodzaj,TrN_Korekta ) WHERE TrN_TrNID = @TrnFaId;
          -- END
        -- zmieniam rodzaj anulowanego dokumentu
   if (@TrNRodzaj <> 302010 and  @TrNRodzaj <> 314004)
        begin
      IF @TrNRodzaj <> 302202
       BEGIN
      UPDATE CDN.TraNag SET TrN_Rodzaj=CDN.UstalRodzajDokumentu(TrN_TypDokumentu,TrN_Rodzaj,TrN_Korekta ) WHERE TrN_TrNID=@TrnID;
       END
 -- dla powiązanych dokumentów (1 poziom)
        UPDATE CDN.TraNag SET TrN_Rodzaj=CDN.UstalRodzajDokumentu(TrN_TypDokumentu,TrN_Rodzaj,TrN_Korekta ) FROM CDN.TraNag  JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId WHERE TrR_FaID =@TrnID AND TrN_Rodzaj NOT IN (309008,309009, 308009,308008,308010,321001, 321002, 321003, 302101,302102,302103,301101,301102,301103,305101,305102)
   and not (TrR_FaTyp = 302 and trr_trntyp = 301) and not (TrR_FaTyp = 301 and trr_trntyp = 302) and not (TrR_FaTyp = 306 and trr_trntyp = 307) and not (TrR_FaTyp = 307 and trr_trntyp = 306);
     -- UPDATE CDN.TraNag SET TrN_Rodzaj=CDN.fn_UstalRodzajDokumentu(TrN_TypDokumentu,TrN_Rodzaj,TrN_Korekta ) WHERE TrN_FaID =@TrnID;
     -- UPDATE CDN.TraNag SET TrN_Rodzaj=CDN.fn_UstalRodzajDokumentu(TrN_TypDokumentu,TrN_Rodzaj,TrN_Korekta ) WHERE TrN_RelTrnID =@TrnID;
     -- UPDATE CDN.TraNag SET TrN_RelTrNId=null WHERE TrN_RelTrNId=@TrnID;
    UPDATE CDN.TraElem SET TrE_Aktywny=1 FROM CDN.TraElem JOIN CDN.TraNag ON TrE_TrNId=TrN_TrNId join @TrN ON TrNId = TrN_TrNId WHERE TrE_Aktywny=1;
    IF @FaPfZal = 0 AND @PFzWZ = 0  --anulowanie FA powstałej z PF jeśli istnieją FAZAL tylko rozpina powiązanie FA z PF
    BEGIN
            -- dla powiązanych z powiąznymi (2 poziom)
         -- UPDATE CDN.TraNag SET TrN_Rodzaj=CDN.UstalRodzajDokumentu(TrN_TypDokumentu,TrN_Rodzaj,TrN_Korekta ) WHERE TrN_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag WHERE Trn_FaID = @TrnID);
            UPDATE CDN.TraNag SET TrN_Rodzaj=CDN.UstalRodzajDokumentu(TrN_TypDokumentu,TrN_Rodzaj,TrN_Korekta )
            FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrN_TrNId = @TrNId AND TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID)
            -- dla powiązanych z powiąznymi (3 poziom)
         --   UPDATE CDN.TraNag SET TrN_Rodzaj=CDN.fn_UstalRodzajDokumentu(TrN_TypDokumentu,TrN_Rodzaj,TrN_Korekta ) WHERE TrN_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag WHERE TrN_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag WHERE  Trn_FaID = @TrnID));
            UPDATE CDN.TraNag SET TrN_Rodzaj=CDN.UstalRodzajDokumentu(TrN_TypDokumentu,TrN_Rodzaj,TrN_Korekta )
            FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrN_TrNId = @TrNId AND TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID));
    END
 END
--RT 16    EXEC CDN.UstawRodzajDlaProForma @TrnID, @TrnRodzaj, @TrnFaId
        -- anulowanie i rozpinanie
    IF @TrnRodzaj in( 302009,302004)
    BEGIN
       UPDATE CDN.TraElem SET TrE_LpPow=TrE_LpPowRel,TrE_LpPowRel=NULL FROM CDN.TraElem JOIN CDN.TraNag ON TrE_TrNId=TrN_TrNId JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE Trn_Rodzaj = 306010 AND TrR_FaID =@TrnID AND Tre_LpPowRel > 0;
       UPDATE CDN.TraElem SET TrE_LpPow=TrE_LpPowRel,TrE_LpPowRel=NULL FROM CDN.TraElem JOIN CDN.TraNag ON TrE_TrNId=TrN_TrNId JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE Trn_TypDokumentu = 320 AND TrR_FaID =@TrnID AND Tre_LpPowRel > 0;
--     UPDATE CDN.TraElem SET TrE_LpPow=TrE_LpPowRel,TrE_LpPowRel=NULL FROM CDN.TraElem JOIN CDN.TraNag ON TrE_TrNId=TrN_TrNId WHERE Trn_Rodzaj = 306010 AND TrN_FaID =@TrnID AND Tre_LpPowRel > 0;
--     UPDATE CDN.TraElem SET TrE_LpPow=TrE_LpPowRel,TrE_LpPowRel=NULL FROM CDN.TraElem JOIN CDN.TraNag ON TrE_TrNId=TrN_TrNId WHERE Trn_TypDokumentu = 320 AND TrN_FaID =@TrnID AND Tre_LpPowRel > 0;
    END
    IF @FaPfZal=1 or  (@PFzWZ > 0 and @TylkoAnulowanie<>2)  --anulowanie FA powstałej z PF jeśli istnieją FAZAL tylko rozpina powiązanie FA z PF
    BEGIN
            IF  @PFzWZ=0
                BEGIN
                  UPDATE CDN.TraNag SET TrN_FaID=null,TrN_Rodzaj=CDN.UstalRodzajPrzedKonwersja(TrN_TrNId, TrN_Rodzaj, TrN_TypDokumentu, @TrnID) FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID =@TrnID;
--                UPDATE CDN.TraNag SET TrN_FaID=null,TrN_Rodzaj=CDN.fn_UstalRodzajPrzedKonwersja(TrN_TrNId, TrN_Rodzaj, TrN_TypDokumentu, @TrnID) WHERE TrN_FaID =@TrnID;
                END
             ELSE
                BEGIN
                  UPDATE CDN.TraNag SET TrN_FaID=TrN_RelTrNId,TrN_RelTrNId=NULL FROM CDN.TraNag  JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID =@TrnID;
               -- UPDATE CDN.TraNag SET TrN_FaID=TrN_RelTrNId,TrN_RelTrNId=NULL WHERE TrN_FaID =@TrnID;
                END
            -- rozpinanie
                UPDATE CDN.TraNag SET TrN_RelTrNId=null WHERE TrN_RelTrNId=@TrnID;
                UPDATE CDN.TraVat SET TrV_TrNIdFinalna=null WHERE TrV_TrNIdFinalna =@TrnID; --65109 Przy anulowaniu/kasowaniu finalnej faktury nulować to pole na powiązanych zaliczkowych.
          --usuwamy korekty jesli powstały po zmianie wartosci na FZ/FS
                   if exists(select trn_trnid from cdn.TraNagRelacje join cdn.TraNag on TrR_FaID = TrN_TrNId where TrR_TrNId = @TrNId AND Trr_TrNTyp = @TrNRodzaj / 1000 and TrN_NieOkreslonaWartoscKor = 1)
                BEGIN   -- anulowanie
           DECLARE DokumentySkoj CURSOR LOCAL FAST_FORWARD FOR
           SELECT  TrR_FaId, Trr_FaTyp FROM CDN.TraNagRelacje join cdn.TraNag on TrR_FaId = TrN_TrNID WHERE TrR_TrNId = @TrNId AND Trr_TrNTyp = @TrNRodzaj / 1000 and TrN_NieOkreslonaWartoscKor = 1
             OPEN DokumentySkoj
              WHILE 1=1
                BEGIN
                 FETCH NEXT FROM DokumentySkoj INTO @FaId, @FaTyp
                  IF @@FETCH_STATUS <> 0 BREAK
                --szukam powiązań
                 IF EXISTS (SELECT * FROM CDN.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNid = Trr_TrNid WHERE Trr_FaId = @FaId AND TrN_Bufor =-1 AND (TrR_TrNTyp=302 OR TrR_TrNTyp=301))
                  BEGIN
      select TrR_FaId into #typydok
 FROM CDN.TraNagRelacje join cdn.TraNag on TrR_FaId = TrN_TrNID WHERE TrR_TrNId = @TrNId AND Trr_TrNTyp = @TrNRodzaj / 1000 and TrN_NieOkreslonaWartoscKor = 1
 -- wykasowanie subelementów kasowanego dokumentu i skojarzonej WZKK
  DELETE cdn.TraSElem
  FROM cdn.TraSElem  S
       JOIN cdn.TraElem E on  S.TrS_TrEId = E.TrE_TrEId
       JOIN cdn.TraNag N  on  N.TrN_TrNId = E.TrE_TrNId
  WHERE N.TrN_TrNId in(select TrR_FaId from  #typydok ) OR  N.TrN_TrNId IN
                                    (SELECT WZKK.TrN_TrNID FROM CDN.TraNag WZKK
                                          WHERE WZKK.TrN_ZwrIdWZKK in(select TrR_FaId from  #typydok ) AND WZKK.TrN_Rodzaj
                                            IN (306061,306071,306072))
    -- anulowanie WZKK
  IF EXISTS ( SELECT * FROM CDN.TraNag join
  (select TrN_TrNID as TrNID, TrN_ZwrID as ZwrID from CDN.TraNag WHERE  TrN_ZwrIDWZKK in(select TrR_FaId from  #typydok ) AND TrN_Rodzaj IN (306061,306071,306072)) as A on TrN_ZwrId = A.ZwRID
  where TrN_TrNID >TrNID and TrN_Bufor <> -1 AND TrN_Rodzaj NOT IN (306061,306071,306072))
  begin
  SET @Komunikat = '##OPT34441##'--'Nie można anulować dokumentu! Anulowany dokument jest powiązany z dokumentem WZKK (korekta kosztów) do którego istnieją późniejsze korekty. Anuluj późniejsze korekty.'
  GOTO KOMUNIKAT
  end
  UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null, TrN_ZwrID = NULL, TrN_ZwrIdWZKK = NULL WHERE  TrN_ZwrIdWZKK in(select TrR_FaId from  #typydok ) AND TrN_Rodzaj IN (306061,306071,306072);
  -- kasuje powiazania WZKK
  DELETE CDN.TraNagRelacje WHERE TrR_TrNID IN
  (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrIDWZKK in(select TrR_FaId from  #typydok ) AND TrN_Rodzaj IN (306061,306071,306072))
  DELETE CDN.TraNagRelacje WHERE TrR_FaID IN
  (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrIDWZKK in(select TrR_FaId from  #typydok ) AND TrN_Rodzaj IN (306061,306071,306072))
                   UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null FROM CDN.TraNag WHERE TrN_TrNID  IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  ON TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID) AND TrN_TypDokumentu IN (306,307) and TrN_NieOkreslonaWartoscKor = 1;
       -- korekty PWP
       declare @PWPKId int
      DECLARE PWPKI CURSOR LOCAL FAST_FORWARD FOR
     SELECT TrN_TrNId from cdn.TraNag WHERE TrN_ZwridWzkk in (select trn_trnid FROM CDN.TraNag WHERE TrN_TrNID  IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  ON TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID) AND TrN_TypDokumentu IN (306,307) and TrN_NieOkreslonaWartoscKor = 1)
     OPEN PWPKI
       WHILE 1=1
       BEGIN
      FETCH NEXT FROM PWPKI INTO @PWPKId
      IF @@FETCH_STATUS <> 0 BREAK
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
      SET @Komunikat = @@ERROR
       IF @Komunikat <> 0
       BEGIN
     GOTO KOMUNIKAT
       END
       select @Komunikat = ''
       END
     CLOSE PWPKI
      DEALLOCATE PWPKI
                  -- DELETE FROM CDN.TraNagRelacje WHERE Trr_TrNid = @FaId AND (Trr_FaTyp = 306) AND TrR_FaId = @TrNId
                  -- DELETE FROM CDN.TraNagRelacje WHERE Trr_Faid = @FaId AND (Trr_TrNTyp = 306) AND TrR_TrNId = @TrNId
                  drop table #typydok
                   END
                  DELETE FROM CDN.TraNagRelacje WHERE TrR_TrNId = @FaId AND Trr_TrNTyp = @FaTyp
                  DELETE FROM CDN.TraNagRelacje WHERE TrR_FaId = @FaId AND Trr_FaTyp = @FaTyp
                  UPDATE CDN.TraNag SET TrN_Rodzaj = TrN_TypDokumentu * 1000 WHERE TrN_TrNId = @FaId
                END
              CLOSE DokumentySkoj
             DEALLOCATE DokumentySkoj
             end
    END
    ELSE
    BEGIN
               DECLARE DokumentyMagazynowe CURSOR LOCAL FAST_FORWARD FOR
               SELECT  Trr_FaId FROM CDN.TraNagRelacje  WHERE Trr_TrNId = @TrNId ORDER BY TrR_TrrId DESC  --poprawka dla SQL 2005
                OPEN DokumentyMagazynowe
                 WHILE 1=1
                     BEGIN -- dla każdego anuluję
                       FETCH NEXT FROM DokumentyMagazynowe INTO @FaId
                         IF @@FETCH_STATUS <> 0 BREAK
                        SELECT @TrNIdKonwersji = TrN_TrNId, @Typ = TrN_TypDokumentu, @Rodzaj = TrN_Rodzaj
                       FROM CDN.TraNag WHERE TrN_TrNId = @FaId
                             IF @Rodzaj IN (321001, 321002, 321003, 322001, 322002, 322003)
                           BEGIN
                           --anuluje korekty powiazane z dokumentem FWSKor
                           UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=NULL, TrN_RelTrNId=null WHERE Trn_TrNId = @TrNIdKonwersji
                           UPDATE CDN.TraNag SET  TrN_ZwrId = NULL  WHERE Trn_TrNId = @TrNIdKonwersji
                           END
                      IF @Typ = 306 AND EXISTS (SELECT * FROM CDN.TraNagRelacje WHERE TrR_TrNTyp = 302 AND TrR_TrNId = @TrNId AND TrR_FaTyp=308)
                         BEGIN  --przepinam powiazania w scenariuszu RO-> FA -> WZ w momencie anulowania FA
                         INSERT INTO CDN.TraNagRelacje(TrR_TrNTyp, TrR_TrNId, TrR_FaTyp, TrR_FaId, TrR_Flaga)
                         SELECT 308, TrR_TrNId, @Typ, @TrNIDKonwersji, 0 FROM CDN.TraNagRelacje WHERE TrR_FaId = @TrNId AND TrR_TrNTyp = 308
                         END
                      IF @Typ = 306 AND EXISTS (SELECT * FROM CDN.TraNagRelacje WHERE TrR_TrNTyp = 305 AND TrR_TrNId = @TrNId AND TrR_FaTyp=308)
                         BEGIN  --przepinam powiazania w scenariuszu RO-> PA -> WZ w momencie anulowania FA
                         INSERT INTO CDN.TraNagRelacje(TrR_TrNTyp, TrR_TrNId, TrR_FaTyp, TrR_FaId, TrR_Flaga)
                         SELECT 308, TrR_TrNId, @Typ, @TrNIDKonwersji, 0 FROM CDN.TraNagRelacje WHERE TrR_FaId = @TrNId AND TrR_TrNTyp = 308
                         END
                      IF @Typ = 306 AND EXISTS (SELECT B.TrR_FaTyp FROM CDN.TraNagRelacje A JOIN CDN.TraNagRelacje B ON A.Trr_FaId = B.Trr_TrNId WHERE A.TrR_TrNTyp = 302 AND A.TrR_TrNId = @TrNId AND A.TrR_FaTyp=305 AND B.Trr_FaTyp = 308)
                        BEGIN  --przepinam powiazania w scenariuszu RO-> PA -> WZ w momencie anulowania FA
                        INSERT INTO CDN.TraNagRelacje(TrR_TrNTyp, TrR_TrNId, TrR_FaTyp, TrR_FaId, TrR_Flaga)
                        SELECT B.TrR_FaTyp,  B.Trr_FaId,@Typ,@TrNIdKonwersji,0   FROM CDN.TraNagRelacje A JOIN CDN.TraNagRelacje B ON A.Trr_FaId = B.Trr_TrNId WHERE A.TrR_TrNTyp = 302 AND A.TrR_TrNId = @TrNId AND A.TrR_FaTyp=305 AND B.Trr_FaTyp = 308
                        END
                      IF @Typ = 307 AND EXISTS (SELECT * FROM CDN.TraNagRelacje WHERE TrR_TrNTyp = 301 AND TrR_TrNId = @TrNId AND TrR_FaTyp=309)
                         BEGIN
                         INSERT INTO CDN.TraNagRelacje(TrR_TrNTyp, TrR_TrNId, TrR_FaTyp, TrR_FaId, TrR_Flaga)
                         SELECT 309, TrR_TrNId, @Typ, @TrNIDKonwersji, 0 FROM CDN.TraNagRelacje WHERE TrR_FaId = @TrNId AND TrR_TrNTyp = 309
                         END
                      IF @TylkoAnulowanie = 2 --anuluje dokumenty PKA i WKA i RW
                        BEGIN
                        UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu IN (313,314);
                        UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null,TrN_Rodzaj = 304000 FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu IN (304);
      --FA z PA to tez RW anulujemy
                        UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null,TrN_Rodzaj = 304000 FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId
                        WHERE  TrR_FaID in( select trr_faid from cdn.TraNagRelacje where TrR_TrNId =@TrnID and TrR_TrNTyp = 302 and TrR_FaTyp = 305) AND TrN_TypDokumentu IN (304);
                         DECLARE DokumentyRW CURSOR LOCAL FAST_FORWARD FOR
                         SELECT TrN_TrNId FROM cdn.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID AND TrN_TypDokumentu IN (304)
                         UNION
                         SELECT TrN_TrNId FROM cdn.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID and TrR_TrNTyp = 305 and TrR_FaTyp = 302) AND TrN_TypDokumentu IN (304)
                         OPEN DokumentyRW
                         WHILE 1=1
                           BEGIN -- dla każdego spradzam, czy ma WZKK
                             FETCH NEXT FROM DokumentyRW INTO @WZId
                             IF @@FETCH_STATUS <> 0 BREAK
                             IF CDN.IstniejaWZKK(@WZId)<> ''
                             BEGIN
        SET @Komunikat = '##OPT34498##'--'Istnieją powiązane dokumenty WZKK!'
        BREAK
                             END
                  -- wykasowanie subelementów kasowanego dokumentu i skojarzonej WZKK
         DELETE cdn.TraSElem
         FROM cdn.TraSElem  S
           JOIN cdn.TraElem E on  S.TrS_TrEId = E.TrE_TrEId
           JOIN cdn.TraNag N  on  N.TrN_TrNId = E.TrE_TrNId
         WHERE N.TrN_TrNId = @WZId OR  N.TrN_TrNId IN
                                    (SELECT WZKK.TrN_TrNID FROM CDN.TraNag WZKK
                                          WHERE WZKK.TrN_ZwrID = @WZId AND WZKK.TrN_Rodzaj
                                            IN (306061,306071,306072))
         -- anulowanie WZKK
         IF EXISTS ( SELECT * FROM CDN.TraNag join
         (select TrN_TrNID as TrNID, TrN_ZwrID as ZwrID from CDN.TraNag WHERE  TrN_ZwrIDWZKK = @WZId AND TrN_Rodzaj IN (306061,306071,306072)) as A on TrN_ZwrId = A.ZwRID
         where TrN_TrNID >TrNID and TrN_Bufor <> -1 AND TrN_Rodzaj NOT IN (306061,306071,306072))
         begin
         SET @Komunikat = '##OPT34441##'--'Nie można anulować dokumentu! Anulowany dokument jest powiązany z dokumentem WZKK (korekta kosztów) do którego istnieją późniejsze korekty. Anuluj późniejsze korekty.'
         GOTO KOMUNIKAT
      end
       UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null, TrN_ZwrID = NULL, TrN_ZwrIdWZKK = NULL WHERE  TrN_ZwrID = @WZId AND TrN_Rodzaj IN (306061,306071,306072);
       -- kasuję powiązania WZKK
       DELETE CDN.TraNagRelacje WHERE TrR_TrNID IN
       (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrID = @WZId AND TrN_Rodzaj IN (306061,306071,306072))
       DELETE CDN.TraNagRelacje WHERE TrR_FaID IN
       (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrID = @WZId AND TrN_Rodzaj IN (306061,306071,306072))
       END
     CLOSE DokumentyRW
     DEALLOCATE DokumentyRW
     IF @Komunikat <> ''
       GOTO KOMUNIKAT
     -- i kasujemy relacje
                        delete from cdn.TraNagRelacje where TrR_TrNId in (select trr_trnid FROM  cdn.TraNagRelacje  WHERE  TrR_FaID = @TrnID AND Trr_TrNTyp IN (304))
                        or TrR_FaId in (select trr_trnid FROM  cdn.TraNagRelacje  WHERE  TrR_FaID = @TrnID AND Trr_TrNTyp IN (304))
                        delete from cdn.TraNagRelacje where TrR_TrNId in (select trr_trnid FROM cdn.TraNagRelacje
                        WHERE  TrR_FaID in( select trr_faid from cdn.TraNagRelacje where TrR_TrNId =@TrnID and TrR_TrNTyp = 302 and TrR_FaTyp = 305) AND Trr_TrNTyp IN (304))
                        or TrR_FAId in (select trr_trnid FROM cdn.TraNagRelacje
                        WHERE  TrR_FaID in( select trr_faid from cdn.TraNagRelacje where TrR_TrNId =@TrnID and TrR_TrNTyp = 302 and TrR_FaTyp = 305) AND Trr_TrNTyp IN (304))
                        END
                    else
                    begin
      UPDATE CDN.TraNag SET  TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null,TrN_Rodzaj = 304000 FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu IN (304);
      --FA z PA to tez RW anulujemy
      UPDATE CDN.TraNag SET TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null,TrN_Rodzaj = 304000 FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId
      WHERE  TrR_FaID in( select trr_faid from cdn.TraNagRelacje where TrR_TrNId =@TrnID and TrR_TrNTyp = 302 and TrR_FaTyp = 305) AND TrN_TypDokumentu IN (304);
      delete from cdn.TraNagRelacje where TrR_TrNId in (select trr_trnid FROM  cdn.TraNagRelacje  WHERE  TrR_FaID = @TrnID AND Trr_TrNTyp IN (304))
      or TrR_FaId in (select trr_trnid FROM  cdn.TraNagRelacje  WHERE  TrR_FaID = @TrnID AND Trr_TrNTyp IN (304))
      delete from cdn.TraNagRelacje where TrR_TrNId in (select trr_trnid FROM cdn.TraNagRelacje
      WHERE  TrR_FaID in( select trr_faid from cdn.TraNagRelacje where TrR_TrNId =@TrnID and TrR_TrNTyp = 302 and TrR_FaTyp = 305) AND Trr_TrNTyp IN (304))
      or TrR_FAId in (select trr_trnid FROM cdn.TraNagRelacje
      WHERE  TrR_FaID in( select trr_faid from cdn.TraNagRelacje where TrR_TrNId =@TrnID and TrR_TrNTyp = 302 and TrR_FaTyp = 305) AND Trr_TrNTyp IN (304))
                    end
                      UPDATE CDN.TraNag SET TrN_FaID=null FROM CDN.TraNag WHERE TrN_TrNId = @FaId AND TrN_TypDokumentu = 320
                -- SO ustawiam nowy rodzaj, w przypadku dokumentow korekcyjnych, rodzaj sie nie zmienia
                IF @Rodzaj NOT IN (321001, 321002, 321003, 322001, 322002, 322003)
                 BEGIN
                  SET @PowiazanyId = 0
                  SELECT @PowiazanyId = TrR_FaId FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNIdKonwersji AND TrR_FaId <> @TrNId
                   IF @TrNRodzaj / 1000 = 350 --anulowanie FRR pociaga za soba rozpiecie z FZ i zmiane rodzaju jak bedzie PZ
                    BEGIN
                    SET @PowiazanyId = 0
                    SELECT @PowiazanyId = TrR_TrNId FROM CDN.TraNagRelacje WHERE TrR_FaId = @FaId AND Trr_TrNTyp = 307
                    END
                   IF (SELECT COUNT(*)  FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNIdKonwersji AND TrR_FaId <> @TrNId)<>1
                     BEGIN
                       IF (SELECT TrN_TypDokumentu FROM CDN.TraNag WHERE TrN_TrNId = @FaId) = 306
                        BEGIN
                         SELECT @PowiazanyId = TrR_FaId FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNIdKonwersji AND TrR_FaId <> @TrNId AND Trr_FaTyp = 308
                        END
                       IF EXISTS (SELECT * FROM CDN.TraNagRelacje WHERE Trr_FaId = @FaId AND Trr_TrNTyp = 307 AND Trr_FaTyp=301) AND @TrNRodzaj = 322021
                        BEGIN
                         SELECT @PowiazanyId = TrR_FaId FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNIdKonwersji AND TrR_FaId <> @TrNId AND Trr_FaTyp = 307
                        END
                     END
                   IF @TylkoAnulowanie=8
     BEGIN
      UPDATE CDN.TraNag SET TrN_Rodzaj = CDN.UstalRodzajPrzedKonwersja(@PowiazanyId, TrN_Rodzaj, TrN_TypDokumentu, @TrNIdPoziom) WHERE TrN_TrNId = @PowiazanyId and TrN_Rodzaj not in(302200,302202)
      UPDATE CDN.TraNag SET TrN_Rodzaj = TrN_TypDokumentu *1000 WHERE TrN_TrNid = @FaId AND TrN_TypDokumentu = 305
      DELETE CDN.TraNagRelacje WHERE TrR_TrNId = @Faid AND TrR_TrNTyp = 305
      DELETE CDN.TraNagRelacje WHERE TrR_FaId = @Faid AND TrR_FATyp = 305
     END
                  --sprawdzanie na drugim poziommie powiazan np. FPF -> RO -> WZ -> FA i anulowanie FA i WZ powinno znow spiac RO z FPF
                   IF (SELECT COUNT(*)  FROM CDN.TraNagRelacje WHERE TrR_TrNId = @PowiazanyId AND TrR_FaId <> @TrNId)<>1 AND @TylkoAnulowanie = 2
                         BEGIN
                          SELECT @TrNIdPoziom = TrR_FaId FROM CDN.TraNagRelacje WHERE TrR_TrNId = @PowiazanyId AND TrR_FaId <> @TrNIdKonwersji
        if @TrNRodzaj <> 302010
                          begin
         IF (SELECT TrN_TypDokumentu FROM CDN.TraNag WHERE TrN_TrNId = @PowiazanyId) = 302 and exists( SELECT * FROM CDN.TraNagRelacje WHERE  TrR_TrNId = @PowiazanyId AND TrR_TrNTyp = 302  and TrR_FaTyp = 306)
                       SELECT @TrNIdPoziom = TrR_FaId FROM CDN.TraNagRelacje left join cdn.TraNag on TrN_TrNID = TrR_FaID WHERE TrR_TrNId = @PowiazanyId AND TrR_FaId <> @TrNIdKonwersji and TrR_FaTyp = 306 and TrN_Korekta = 0
         IF (SELECT TrN_Rodzaj FROM CDN.TraNag WHERE TrN_TrNId = @PowiazanyId) = 306010 and exists( SELECT * FROM CDN.TraNagRelacje WHERE  TrR_TrNId = @PowiazanyId AND TrR_TrNTyp = 306  and TrR_FaTyp = 320)
                       SELECT @TrNIdPoziom = TrR_FaId FROM CDN.TraNagRelacje left join cdn.TraNag on TrN_TrNID = TrR_FaID WHERE TrR_TrNId = @PowiazanyId  and TrR_FaTyp = 320
       UPDATE CDN.TraNag SET TrN_Rodzaj = CDN.UstalRodzajPrzedKonwersja(@PowiazanyId, TrN_Rodzaj, TrN_TypDokumentu, @TrNIdPoziom) WHERE TrN_TrNId = @PowiazanyId and TrN_Rodzaj not in(302200,302202)
                          end
                         END
      if @TrNRodzaj <> 302010  and  @TrNRodzaj <> 314004
                  UPDATE CDN.TraNag SET TrN_Rodzaj = CDN.UstalRodzajPrzedKonwersja(@TrNIdKonwersji, @Rodzaj, @Typ, @PowiazanyId) WHERE TrN_TrNId = @TrNIDKonwersji and TrN_Rodzaj not in(302200,302202)
                 END
                --usuwanie relacji przy RO -> PA -> FA i anulowanie FA
                 IF EXISTS (SELECT * FROM CDN.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNid = Trr_TrNid WHERE Trr_TrNId = @FaId AND TrN_Bufor =-1 AND TrR_TrNTyp=305 AND TrR_FaTyp=308)
                   BEGIN
                    UPDATE CDN.TraNag SET TrN_Rodzaj = TrN_TypDokumentu *1000 WHERE TrN_TrNid = @FaId AND TrN_TypDokumentu = 305
                    DELETE CDN.TraNagRelacje WHERE TrR_TrNId = @Faid
                    DELETE CDN.TraNagRelacje WHERE TrR_FaId = @Faid
                   END
                   --usuwamy korekty jesli powstały po zmianie wartosci na FZ/FS
                   if exists(select trn_trnid from cdn.TraNagRelacje join cdn.TraNag on TrR_FaID = TrN_TrNId where TrR_TrNId = @TrNId AND Trr_TrNTyp = @TrNRodzaj / 1000 and TrN_NieOkreslonaWartoscKor = 1)
    BEGIN   -- anulowanie
           DECLARE DokumentySkoj CURSOR LOCAL FAST_FORWARD FOR
           SELECT  TrR_FaId, Trr_FaTyp FROM CDN.TraNagRelacje join cdn.TraNag on TrR_FaId = TrN_TrNID WHERE TrR_TrNId = @TrNId AND Trr_TrNTyp = @TrNRodzaj / 1000 and TrN_NieOkreslonaWartoscKor = 1
             OPEN DokumentySkoj
              WHILE 1=1
                BEGIN
                 FETCH NEXT FROM DokumentySkoj INTO @FaId, @FaTyp
                  IF @@FETCH_STATUS <> 0 BREAK
                --szukam powiązań
                 IF EXISTS (SELECT * FROM CDN.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNid = Trr_TrNid WHERE Trr_FaId = @FaId AND TrN_Bufor =-1 AND (TrR_TrNTyp=302 OR TrR_TrNTyp=301))
                  BEGIN
                  -- wykasowanie subelementów kasowanego dokumentu i skojarzonej WZKK
       select TrR_FaId into #typydok1
     FROM CDN.TraNagRelacje join cdn.TraNag on TrR_FaId = TrN_TrNID WHERE TrR_TrNId = @TrNId AND Trr_TrNTyp = @TrNRodzaj / 1000 and TrN_NieOkreslonaWartoscKor = 1
      DELETE cdn.TraSElem
      FROM cdn.TraSElem  S
        JOIN cdn.TraElem E on  S.TrS_TrEId = E.TrE_TrEId
        JOIN cdn.TraNag N  on  N.TrN_TrNId = E.TrE_TrNId
      WHERE N.TrN_TrNId in(select TrR_FaId from  #typydok1 ) OR  N.TrN_TrNId IN
             (SELECT WZKK.TrN_TrNID FROM CDN.TraNag WZKK
                WHERE WZKK.TrN_ZwrIdWZKK in(select TrR_FaId from  #typydok1 ) AND WZKK.TrN_Rodzaj
               IN (306061,306071,306072))
     -- anulowanie WZKK
      IF EXISTS ( SELECT * FROM CDN.TraNag join
      (select TrN_TrNID as TrNID, TrN_ZwrID as ZwrID from CDN.TraNag WHERE  TrN_ZwrIDWZKK in(select TrR_FaId from  #typydok1 ) AND TrN_Rodzaj IN (306061,306071,306072)) as A on TrN_ZwrId = A.ZwRID
      where TrN_TrNID >TrNID and TrN_Bufor <> -1 AND TrN_Rodzaj NOT IN (306061,306071,306072))
      begin
      SET @Komunikat = '##OPT34441##'--'Nie można anulować dokumentu! Anulowany dokument jest powiązany z dokumentem WZKK (korekta kosztów) do którego istnieją późniejsze korekty. Anuluj późniejsze korekty.'
      GOTO KOMUNIKAT
      end
      UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null, TrN_ZwrID = NULL, TrN_ZwrIdWZKK = NULL WHERE  TrN_ZwrIdWZKK in(select TrR_FaId from  #typydok1 ) AND TrN_Rodzaj IN (306061,306071,306072);
      -- kasuje powiazania WZKK
      DELETE CDN.TraNagRelacje WHERE TrR_TrNID IN
      (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrIDWZKK in(select TrR_FaId from  #typydok1 ) AND TrN_Rodzaj IN (306061,306071,306072))
      DELETE CDN.TraNagRelacje WHERE TrR_FaID IN
      (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrIDWZKK in(select TrR_FaId from  #typydok1 ) AND TrN_Rodzaj IN (306061,306071,306072))
                   UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null FROM CDN.TraNag WHERE TrN_TrNID  IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  ON TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID) AND TrN_TypDokumentu IN (306,307) and TrN_NieOkreslonaWartoscKor = 1;
       -- korekty PWP
       declare @PWPKId1 int
      DECLARE PWPKI CURSOR LOCAL FAST_FORWARD FOR
     SELECT TrN_TrNId from cdn.TraNag WHERE TrN_ZwridWzkk in (select trn_trnid FROM CDN.TraNag WHERE TrN_TrNID  IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  ON TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID) AND TrN_TypDokumentu IN (306,307) and TrN_NieOkreslonaWartoscKor = 1)
     OPEN PWPKI
       WHILE 1=1
       BEGIN
      FETCH NEXT FROM PWPKI INTO @PWPKId1
      IF @@FETCH_STATUS <> 0 BREAK
      DELETE cdn.TraSElem
      FROM cdn.TraSElem  S
     JOIN cdn.TraElem E on  S.TrS_TrEId = E.TrE_TrEId
     JOIN cdn.TraNag N  on  N.TrN_TrNId = E.TrE_TrNId
      WHERE N.TrN_TrNId = @PWPKId1 OR  N.TrN_TrNId IN
      (SELECT WZKK.TrN_TrNID FROM CDN.TraNag WZKK
      WHERE WZKK.TrN_ZwrIDWZKK = @PWPKId1 AND WZKK.TrN_Rodzaj
        IN (306061,306071,306072))
      -- anulowanie WZKK
      IF EXISTS ( SELECT * FROM CDN.TraNag join
      (select TrN_TrNID as TrNID, TrN_ZwrID as ZwrID from CDN.TraNag WHERE  TrN_ZwrIDWZKK = @PWPKId1 AND TrN_Rodzaj IN (306061,306071,306072)) as A on TrN_ZwrId = A.ZwRID
      where TrN_TrNID >TrNID and TrN_Bufor <> -1 AND TrN_Rodzaj NOT IN (306061,306071,306072))
      begin
       SET @Komunikat = '##OPT34441##'--'Nie można anulować dokumentu! Anulowany dokument jest powiązany z dokumentem WZKK (korekta kosztów) do którego istnieją późniejsze korekty. Anuluj późniejsze korekty.'
       RAISERROR( @Komunikat, 16, 1)
       ROLLBACK TRAN
       SET NOCOUNT OFF
       RETURN
      end
      UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null, TrN_ZwrID = NULL, TrN_ZwrIdWZKK = NULL WHERE  TrN_ZwrIDWZKK = @PWPKId1 AND TrN_Rodzaj IN (306061,306071,306072);
      -- kasuję powiązania WZKK
      DELETE CDN.TraNagRelacje WHERE TrR_TrNID IN
      (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrIDWZKK = @PWPKId1 AND TrN_Rodzaj IN (306061,306071,306072))
      DELETE CDN.TraNagRelacje WHERE TrR_FaID IN
      (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrIDWZKK = @PWPKId1 AND TrN_Rodzaj IN (306061,306071,306072))
      exec CDN.AnulowaniePWP 1,@PWPKId1,1
      SET @Komunikat = @@ERROR
       IF @Komunikat <> 0
       BEGIN
     GOTO KOMUNIKAT
       END
       select @Komunikat = ''
       END
     CLOSE PWPKI
      DEALLOCATE PWPKI
                  -- DELETE FROM CDN.TraNagRelacje WHERE Trr_TrNid = @FaId AND (Trr_FaTyp = 306) AND TrR_FaId = @TrNId
                  -- DELETE FROM CDN.TraNagRelacje WHERE Trr_Faid = @FaId AND (Trr_TrNTyp = 306) AND TrR_TrNId = @TrNId
                  drop table #typydok1                   END
                  DELETE FROM CDN.TraNagRelacje WHERE TrR_TrNId = @FaId AND Trr_TrNTyp = @FaTyp
                  DELETE FROM CDN.TraNagRelacje WHERE TrR_FaId = @FaId AND Trr_FaTyp = @FaTyp
                  UPDATE CDN.TraNag SET TrN_Rodzaj = TrN_TypDokumentu * 1000 WHERE TrN_TrNId = @FaId
                END
              CLOSE DokumentySkoj
             DEALLOCATE DokumentySkoj
    END
                 --usuwanie relacji przy WZ -> PA -> FA i anulowanie FA z rozpinaniem dokumentow WZ i bez
                 IF @TylkoAnulowanie <> 2 AND EXISTS (SELECT * FROM CDN.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNid = Trr_TrNid WHERE Trr_FaId = @FaId AND TrN_Bufor =-1 AND (TrR_TrNTyp=302 OR TrR_TrNTyp=305))
                   BEGIN
                    DELETE FROM CDN.TraNagRelacje WHERE Trr_TrNid = @FaId AND (Trr_FaTyp = 302 OR Trr_FaTyp = 305) AND TrR_FaId = @TrNId
                    DELETE FROM CDN.TraNagRelacje WHERE Trr_Faid = @FaId AND (Trr_TrNTyp = 302 OR Trr_TrNTyp = 305) AND TrR_TrNId = @TrNId
                     IF EXISTS (SELECT * FROM CDN.TraNagRelacje WHERE TrR_TrNId = @FaId AND Trr_TrNTyp = 306 AND Trr_FaTyp=305)
                      BEGIN
                      DELETE FROM CDN.TraNagRelacje WHERE Trr_FaId = @FaId AND Trr_TrNTyp = 305
                      DELETE FROM CDN.TraNagRelacje WHERE Trr_TrNId = @FaId AND Trr_FaTyp = 305
                      END
                  END
                 --sprawdzam czy w przypadku anulowania WZ ktore jest skojarzone z FPF nie ma FAZAL, jesli tak ustawiam poprawny rodzaj dla FAZAL
                 IF @Typ = 320 AND EXISTS (SELECT * FROM CDN.TraNagRelacje WHERE TrR_TrNId = @FaId AND TrR_FaTyp = 302 AND TrR_Flaga=1)
                 BEGIN
                    SELECT @PowiazanyId = TrR_FaId FROM CDN.TraNagRelacje WHERE TrR_TrNId = @FaId AND TrR_FaTyp = 302 AND Trr_Flaga = 1
                    UPDATE CDN.TraNag SET TrN_Rodzaj = CDN.UstalRodzajPrzedKonwersja(@TrNIdKonwersji, @Rodzaj, @Typ, @PowiazanyId) WHERE TrN_TrNId = @TrNIDKonwersji
                 END
                  -- SO poprawka anulowania dokumentow po konwersji
                   IF @TrNRodzaj IN (302008,305008)
                   BEGIN
                         IF (select count(*) from cdn.tranagrelacje where trr_trnid = @faid) = 0
                         BEGIN
                           UPDATE CDN.TraNag SET TrN_ZwroconoCalaIlosc = 0 WHERE TrN_TrNId = @FaId AND TrN_TypDokumentu = 308 AND ISNULL(TrN_ZwroconoCalaIlosc,0) < 4
                           UPDATE CDN.TraNag SET TrN_Rodzaj = TrN_TypDokumentu * 1000 WHERE TrN_TrNId = @FaId
                           --UPDATE CDN.TraElem SET Tre_Aktywny = 1 WHERE TrE_Aktywny = 1 AND TrE_TrNid = @FaId
         UPDATE CDN.TraElem SET Tre_Aktywny = 1 from CDN.TraElem A join CDN.TraNag on TrE_TrNId = TrN_TrNID WHERE TrE_Aktywny = 1 AND TrE_TrNid = @FaId AND ISNULL(TrN_ZwroconoCalaIlosc,0) < 4
                         END
                   END
                   IF @TrNRodzaj IN (301011)
                   BEGIN
                         IF (select count(*) from cdn.tranagrelacje where trr_trnid = @faid and trr_faid <> @trnid) = 0 --trr_trntyp <> 309
                         BEGIN
                           UPDATE CDN.TraNag SET TrN_ZwroconoCalaIlosc = 0 WHERE TrN_TrNId = @FaId AND TrN_TypDokumentu = 309 AND ISNULL(TrN_ZwroconoCalaIlosc,0) < 4
                           UPDATE CDN.TraNag SET TrN_Rodzaj = TrN_TypDokumentu * 1000 WHERE TrN_TrNId = @FaId
                           --UPDATE CDN.TraElem SET Tre_Aktywny = 1 WHERE TrE_Aktywny = 1 AND TrE_TrNid = @FaId
         UPDATE CDN.TraElem SET Tre_Aktywny = 1 from CDN.TraElem A join CDN.TraNag on TrE_TrNId = TrN_TrNID WHERE TrE_Aktywny = 1 AND TrE_TrNid = @FaId AND ISNULL(TrN_ZwroconoCalaIlosc,0) < 4
                         END
                   END
                   IF @TrNRodzaj IN (306008)
                   BEGIN
                     DECLARE @RodzajROWZ INT
                    SET @RodzajROWZ = 0
                     SELECT  TOP 1 @RodzajROWZ = TrN_Rodzaj FROM CDN.TraNag WHERE TrN_TrNId = @FaId
                      IF @RodzajROWZ = 308008 OR @RodzajROWZ =308009 OR @RodzajROWZ =308010
                      BEGIN
                         IF (select count(*) from cdn.tranagrelacje where trr_trnid = @faid) = 1
                         BEGIN
                           UPDATE CDN.TraNag SET TrN_ZwroconoCalaIlosc = 0 WHERE TrN_TrNId = @FaId AND TrN_TypDokumentu = 308 AND ISNULL(TrN_ZwroconoCalaIlosc,0) < 4
                           UPDATE CDN.TraNag SET TrN_Rodzaj = TrN_TypDokumentu * 1000 WHERE TrN_TrNId = @FaId
                           --UPDATE CDN.TraElem SET Tre_Aktywny = 1 WHERE TrE_Aktywny = 1 AND TrE_TrNid = @FaId
         UPDATE CDN.TraElem SET Tre_Aktywny = 1 from CDN.TraElem A join CDN.TraNag on TrE_TrNId = TrN_TrNID WHERE TrE_Aktywny = 1 AND TrE_TrNid = @FaId AND ISNULL(TrN_ZwroconoCalaIlosc,0) < 4
                         END
                      END
                  END
                   IF @TrNRodzaj IN (307010)
                   BEGIN
                    SET @RodzajROWZ = 0
                     SELECT  TOP 1 @RodzajROWZ = TrN_Rodzaj FROM CDN.TraNag WHERE TrN_TrNId = @FaId
                      IF @RodzajROWZ = 309009 OR @RodzajROWZ = 309008
                      BEGIN
                         IF (select count(*) from cdn.tranagrelacje where trr_trnid = @faid) = 1
                         BEGIN
                           UPDATE CDN.TraNag SET TrN_ZwroconoCalaIlosc = 0 WHERE TrN_TrNId = @FaId AND TrN_TypDokumentu = 309 AND ISNULL(TrN_ZwroconoCalaIlosc,0) < 4
                           UPDATE CDN.TraNag SET TrN_Rodzaj = TrN_TypDokumentu * 1000 WHERE TrN_TrNId = @FaId
                           --UPDATE CDN.TraElem SET Tre_Aktywny = 1 WHERE TrE_Aktywny = 1 AND TrE_TrNid = @FaId
         UPDATE CDN.TraElem SET Tre_Aktywny = 1 from CDN.TraElem A join CDN.TraNag on TrE_TrNId = TrN_TrNID WHERE TrE_Aktywny = 1 AND TrE_TrNid = @FaId AND ISNULL(TrN_ZwroconoCalaIlosc,0) < 4
                         END
                      END
                  END
               END
              CLOSE DokumentyMagazynowe
             DEALLOCATE DokumentyMagazynowe
                   --kasuje relacje
                   DELETE cdn.TraNagRelacje WHERE TrR_TrNID =@TrnID AND Trr_FaTyp not in ( 306,314) AND Trr_FaTyp <> 307
                   DELETE cdn.TraNagRelacje WHERE TrR_FaID =@TrnID AND Trr_TrNTyp not in ( 306,314) AND Trr_TrNTyp <> 307
 /*
                DECLARE @FaId INT, @FaTyp INT
                DECLARE @Rodzaj INT, @Typ INT, @TrNIdKonwersji INT, @Orginalny INT
                SELECT @FaId = Trr_FaId FROM CDN.TraNagRelacje  WHERE Trr_TrNId = @TrNId
                SELECT @TrNIdKonwersji = TrN_TrNId, @Typ = TrN_TypDokumentu, @Rodzaj = TrN_Rodzaj
                FROM CDN.TraNag --JOIN CDN.TraNagRelacje ON Trr_TrNID = TrN_TrNID
                 WHERE TrN_TrNId = @FaId --AND TrR_FaId <> @TrNID
                --kasuje dokumenty powiazane, pomijajac magazynowe
                DELETE cdn.TraNagRelacje WHERE TrR_TrNID =@TrnID AND Trr_FaTyp <> 306 AND Trr_FaTyp <> 307
                DELETE cdn.TraNagRelacje WHERE TrR_FaID =@TrnID AND Trr_TrNTyp <> 306 AND Trr_TrNTyp <> 307
                -- po rozpięciu powinienem zmienić rodzaje na dokumentach powiązanych
                UPDATE CDN.TraNag SET TrN_Rodzaj = CDN.fn_UstalRodzajPrzedKonwersja(@TrNIdKonwersji, @Rodzaj, @Typ, 0)
                WHERE TrN_TrNId = @TrNIDKonwersji
*/
/*
            -- dla powiązanych z powiąznymi (3 poziom) dotyczy tylko RO, ZD, PF, FRR)
            UPDATE CDN.Tranag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null FROM CDN.TraNag  JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE  TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE  TrR_FaID = @TrnID)) AND TrN_TypDokumentu IN (320,321,322,350);
--          UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null WHERE  TrN_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag WHERE TrN_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag WHERE  Trn_FaID = @TrnID)) AND TrN_TypDokumentu IN (308,309,320,321,322,350);
            -- dla powiązanych z powiąznymi (2 poziom) dotyczy tylko RO, ZD, PF)
            UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null FROM CDN.TraNag  JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE  TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE TrR_FaID = @TrnID) AND TrN_TypDokumentu IN (320,321,322,350);
--          UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null WHERE  TrN_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag WHERE Trn_FaID = @TrnID) AND TrN_TypDokumentu IN (308,309,320,321,322,350);
            -- dla powiązanych z powiąznymi (1 poziom) dotyczy tylko RO, ZD, PF)
            UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null FROM CDN.TraNag  JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu IN (320,321,322,350);
--          UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null WHERE  TrN_FaID = @TrnID AND TrN_TypDokumentu IN (308,309,320,321,322,350);
*/
   END
--RT 16    EXEC CDN.UstawRodzajDlaProForma @TrnID, @TrnRodzaj, @TrnFaId
    IF @TylkoAnulowanie=2 -- O!O  anulowanie dokumentów handlowych pociąga anulowanie dokumentów magazynowych
    BEGIN   -- anulowanie
            -- wykluczenie WZKK
            DECLARE DokumentyWZ CURSOR LOCAL FAST_FORWARD FOR
               SELECT TrN_TrNId FROM cdn.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID) AND TrN_TypDokumentu IN (306, 314)
      AND NOT(TrR_FaTyp = 307 AND TrR_TrNTyp =306) AND NOT(TrR_FaTyp = 306 AND TrR_TrNTyp =307)
               UNION
               SELECT TrN_TrNId FROM cdn.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID AND TrN_TypDokumentu IN (306, 314)
      AND NOT(TrR_FaTyp = 307 AND TrR_TrNTyp =306) AND NOT(TrR_FaTyp = 306 AND TrR_TrNTyp =307)
            OPEN DokumentyWZ
            WHILE 1=1
              BEGIN -- dla każdego spradzam, czy ma WZKK
                FETCH NEXT FROM DokumentyWZ INTO @WZId
                IF @@FETCH_STATUS <> 0 BREAK
                IF CDN.IstniejaWZKK(@WZId)<> ''
                  BEGIN
                    SET @Komunikat = '##OPT34498##'--'Istnieją powiązane dokumenty WZKK!'
                    BREAK
                  END
                  -- wykasowanie subelementów kasowanego dokumentu i skojarzonej WZKK
                  DELETE cdn.TraSElem
                  FROM cdn.TraSElem  S
                       JOIN cdn.TraElem E on  S.TrS_TrEId = E.TrE_TrEId
                       JOIN cdn.TraNag N  on  N.TrN_TrNId = E.TrE_TrNId
                  WHERE N.TrN_TrNId = @WZId OR  N.TrN_TrNId IN
                                    (SELECT WZKK.TrN_TrNID FROM CDN.TraNag WZKK
                                          WHERE WZKK.TrN_ZwrID = @WZId AND WZKK.TrN_Rodzaj
                                            IN (306061,306071,306072))
                  -- anulowanie WZKK
                  IF EXISTS ( SELECT * FROM CDN.TraNag join
                  (select TrN_TrNID as TrNID, TrN_ZwrID as ZwrID from CDN.TraNag WHERE  TrN_ZwrIDWZKK = @WZId AND TrN_Rodzaj IN (306061,306071,306072)) as A on TrN_ZwrId = A.ZwRID
                  where TrN_TrNID >TrNID and TrN_Bufor <> -1 AND TrN_Rodzaj NOT IN (306061,306071,306072))
                  begin
                  SET @Komunikat = '##OPT34441##'--'Nie można anulować dokumentu! Anulowany dokument jest powiązany z dokumentem WZKK (korekta kosztów) do którego istnieją późniejsze korekty. Anuluj późniejsze korekty.'
                  GOTO KOMUNIKAT
                  end
                  UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null, TrN_ZwrID = NULL, TrN_ZwrIdWZKK = NULL WHERE  TrN_ZwrID = @WZId AND TrN_Rodzaj IN (306061,306071,306072);
                  -- kasuję powiązania WZKK
                  DELETE CDN.TraNagRelacje WHERE TrR_TrNID IN
                  (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrID = @WZId AND TrN_Rodzaj IN (306061,306071,306072))
                  DELETE CDN.TraNagRelacje WHERE TrR_FaID IN
                  (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrID = @WZId AND TrN_Rodzaj IN (306061,306071,306072))
              END
            CLOSE DokumentyWZ
            DEALLOCATE DokumentyWZ
            IF @Komunikat <> ''
              GOTO KOMUNIKAT
            insert into @RO(ROZDTrNId)
            SELECT distinct trn_trnid FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID  IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID)  and TrN_Typdokumentu IN (308, 309);
            -- odbudowa starych rezerwacji RO->WZ->FA
            IF @TylkoAnulowanie = 2  --poprawka zwiazana z 144369, 144358, 144310
            INSERT INTO @TrN ( TrNId ) SELECT TrN_TrNId FROM CDN.TraNagRelacje JOIN CDN.TraNag ON TrR_TRNId = TrN_TrNId WHERE TrR_FaID =@WZId and TrN_Rodzaj IN (308009, 308008, 308010, 309008, 309009)
 --RT 16           EXEC CDN.UstawRodzajDlaProForma @TrnID, @TrnRodzaj, @TrnFaId
            UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID  IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID) AND TrN_TypDokumentu IN (306,307)
   AND NOT(TrR_FaTyp = 307 AND TrR_TrNTyp =306) AND NOT(TrR_FaTyp = 306 AND TrR_TrNTyp =307);
--          UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null WHERE  TrN_FaID  IN ( SELECT TrN_TrNID FROM CDN.TraNag WHERE Trn_FaID = @TrnID) AND TrN_TypDokumentu IN (306,307);
--          UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null WHERE  TrN_RelTrnId IN ( SELECT TrN_TrNID FROM CDN.TraNag WHERE Trn_RelTrnID = @TrnID) AND TrN_TypDokumentu IN (313, 314);
            -- anulowanie dokumentów magazynowych (poziom 1) (dotyczy WZ, PZ, PKA)
            UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu IN (306,307)
   AND NOT(TrR_FaTyp = 307 AND TrR_TrNTyp =306) AND NOT(TrR_FaTyp = 306 AND TrR_TrNTyp =307);
            UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu IN (313,314);
--          UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null WHERE  TrN_FaID = @TrnID AND TrN_TypDokumentu IN (306, 307);
--          UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null WHERE  TrN_RelTrnID = @TrnID AND TrN_TypDokumentu IN (313,314);
            -- anulowanie i rozpinanie dla powiązanych  (poziom 1) dotyczy tylko PA)
            UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null  FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu =305
--          UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null WHERE  TrN_FaID = @TrnID AND TrN_TypDokumentu =305;
            -- rozpinanie dokumentów magazynowych (poziom 2) (dotyczy WKA->FA i PKA->FZ)
            UPDATE CDN.TraNag SET TrN_FaID=null  FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrN_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID) AND TrN_TypDokumentu IN (313, 314);
--          UPDATE CDN.TraNag SET TrN_FaID=null WHERE  TrN_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag WHERE Trn_FaID = @TrnID) AND TrN_TypDokumentu IN (313, 314);
            -- rozpinanie dokumentów magazynowych (poziom 1) (dotyczy WKA->FA i PKA->FZ)
            UPDATE CDN.TraNag SET TrN_FaID=null  FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu IN (313, 314);
--          UPDATE CDN.TraNag SET TrN_FaID=null WHERE  TrN_FaID = @TrnID AND TrN_TypDokumentu IN (313, 314);
            -- SO, sciezka ZD -> PZ -> FZ i anulowanie wszystkiego
           IF @TylkoAnulowanie = 2
              INSERT INTO @TrN
                 SELECT TrN_TrNId FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID  IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID)  and TrN_Rodzaj IN (308009, 308008, 308010, 309008, 309009);
            -- odbudowa starych rezerwacji RO->WZ->FA
            UPDATE CDN.TraNag SET TrN_Rodzaj = TrN_TypDokumentu * 1000 FROM CDN.TraNag join @TrN ON TrNId = TrN_TrNId WHERE TrN_Rodzaj <> 308011;
            UPDATE CDN.TraElem SET TrE_Aktywny=1 FROM CDN.TraElem JOIN CDN.TraNag ON TrE_TrNId=TrN_TrNId join @TrN ON TrNId = TrN_TrNId WHERE TrE_Aktywny=1;
   declare @ROZDTrNId int
            DECLARE dok CURSOR LOCAL FAST_FORWARD FOR
            select  distinct ROZDTrNId from @RO
            OPEN dok
            WHILE 1=1
    BEGIN
      FETCH NEXT FROM dok INTO @ROZDTrNId
      IF @@FETCH_STATUS <> 0 BREAK
       EXECUTE cdn.UstawStatusRezerwacji_New @ROZDTrNId,0
    END
            CLOSE dok
            DEALLOCATE dok
    END
    ELSE -- Optima nie oodziałowa
    BEGIN
 --RT 16 EXEC CDN.UstawRodzajDlaProForma @TrnID, @TrnRodzaj, @TrnFaId
        IF @FaPfZal=1  --anulowanie FA powstałej z PF jeśli istnieją FAZAL tylko rozpina powiązanie FA z PF
        BEGIN
              -- rozpinanie
                UPDATE CDN.TraNag SET TrN_FaID=null,TrN_Rodzaj=CDN.UstalRodzajPrzedKonwersja(TrN_TrNId, TrN_Rodzaj, TrN_TypDokumentu, @TrnID) FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID =@TrnID;
--              UPDATE CDN.TraNag SET TrN_FaID=null,TrN_Rodzaj=CDN.fn_UstalRodzajPrzedKonwersja(TrN_TrNId, TrN_Rodzaj, TrN_TypDokumentu, @TrnID) WHERE TrN_FaID =@TrnID;
--              UPDATE CDN.TraNag SET TrN_RelTrNId=null WHERE TrN_RelTrNId=@TrnID;
                UPDATE CDN.TraVat SET TrV_TrNIdFinalna=null WHERE TrV_TrNIdFinalna =@TrnID; --65109 Przy anulowaniu/kasowaniu finalnej faktury nulować to pole na powiązanych zaliczkowych.
--RT 16                EXEC CDN.UstawRodzajDlaProForma @TrnID, @TrnRodzaj, @TrnFaId
        END
        ELSE
        BEGIN
  --RT 16         EXEC CDN.UstawRodzajDlaProForma @TrnID, @TrnRodzaj, @TrnFaId
                -- rozpinanie dokumentów magazynowych (poziom 2) (dotyczy WZ, PZ)
                UPDATE CDN.TraNag SET TrN_FaID=null FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag WHERE Trn_FaID = @TrnID) AND TrN_TypDokumentu IN (306,307,313,314)
    AND NOT(TrR_FaTyp = 307 AND TrR_TrNTyp =306) AND NOT(TrR_FaTyp = 306 AND TrR_TrNTyp =307);
--              UPDATE CDN.TraNag SET TrN_FaID=null WHERE  TrN_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag WHERE Trn_FaID = @TrnID) AND TrN_TypDokumentu IN (306,307,313,314);
--              UPDATE CDN.TraNag SET TrN_RelTrnId=null WHERE  TrN_RelTrnID IN ( SELECT TrN_TrNID FROM CDN.TraNag WHERE Trn_RelTrNID = @TrnID) AND TrN_TypDokumentu IN (306,307,313,314);
                -- rozpinanie dokumentów magazynowych (poziom 1) (dotyczy WZ, PZ)
                UPDATE CDN.TraNag SET TrN_FaID=null FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu IN (306, 307, 313, 314);
--              UPDATE CDN.TraNag SET TrN_FaID=null     WHERE  TrN_FaID = @TrnID AND TrN_TypDokumentu IN (306, 307, 313, 314);
--              UPDATE CDN.TraNag SET TrN_RelTrnID=null WHERE  TrN_RelTrnID = @TrnID AND TrN_TypDokumentu IN (306, 307, 313, 314);
                -- anulowanie i rozpinanie dla powiązanych (1 poziom) dotyczy tylko PA)
                UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null  FROM CDN.TraNag JOIN CDN.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu =305;
              --UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null WHERE  TrN_FaID = @TrnID AND TrN_TypDokumentu =305;
               -- anulowanie dokumentow FWS/FWZ
                UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null  FROM CDN.TraNag WHERE  TrN_TrNID = @TrnID AND TrN_TypDokumentu IN (322,321);
        END
    END  -- Optima nie oodziałowa
    -- rozpinanie powiazania RO różnicowego do anulowanych RO zgł.http://www.cdn.com.pl/zgloszenie.asp?ID=94372
     UPDATE CDN.TraNag SET TrN_RelTrNId=null FROM CDN.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu =308 AND TrR_FaId IN (SELECT TrN_TrNID FROM CDN.TraNag WHERE TrN_TypDokumentu=308 AND TrN_Bufor=-1);
/*
 UPDATE CDN.TraNag SET TrN_RelTrNId=null
  WHERE TrN_TypDokumentu =308
  AND TrN_RelTrNId IN (SELECT TrN_TrNID FROM CDN.TraNag WHERE TrN_TypDokumentu=308 AND TrN_Bufor=-1);
*/
    IF @TrnRodzaj = 302202   -- anulowanie fa zal korekta zgł 66222
      BEGIN
        EXEC CDN.InicjalizujFAZal @TrnFaId, 1, @Wynik OUTPUT
        IF @Wynik = 1
          BEGIN
            SET @Komunikat = '##OPT34500##'--'Wartość anulowanego dokumentu jest większa niż wartość wpłaconych zaliczek!'
            GOTO KOMUNIKAT
          END
    END
    IF @KaucjeZwrId IS NOT NULL
   BEGIN
    EXEC CDN.Ustaw_ZwroconoCalaIlosc @KaucjeZwrId
   END
  -- kasujemy relacje w CDN.TraNagRelacje operacja odbywa się na samym końcu
 BEGIN
   IF  @TylkoAnulowanie=4  --O!O anulowanie FA - PA i WZ pozostają powiązane
     BEGIN
        DELETE cdn.TraNagRelacje WHERE TrR_TrNId = @TrnID AND TrR_FaTyp = 305
        DELETE cdn.TraNagRelacje WHERE TrR_FaId = @TrnID AND TrR_TrNTyp = 305
     END
  -- po zanulowaniu FRR rozpinać go z FZ i podmieniać mu rodzaj (jeśli później ktoś zanuluje FZ,
  -- to standardowo zostanie rozpięty PZ)
  -- jeśli zanulujemy FZ skojarzony z FRR, to zostanie zanulowany FZ i PZ (tak jak do tej pory).
    IF  @TrnRodzaj/1000 = 350
     BEGIN --rozpinanie powiazania z FZ
        DELETE CDN.TraNagRelacje WHERE TrR_TrNId = @TrnID
        DELETE CDN.TraNagRelacje WHERE TrR_FaId = @TrnID
     END
    IF  @TrnRodzaj IN (302005, 302007,302012, 302091, 302092, 305005, 301005, 301006,301012, 301009, 301091, 301092, 301051, 301052, 301053)  --e_op_Rdz_FAWZKI, e_op_Rdz_FZPZKI, e_op_Rdz_FZPZKG,e_op_Rdz_FZPZKW
     BEGIN --anulowanie skojarzonych dokumentów
        DELETE CDN.TraNagRelacje WHERE TrR_TrNId = @TrnID AND TrR_FaTyp NOT IN (306,307,313,314)
        DELETE CDN.TraNagRelacje WHERE TrR_FaId = @TrnID AND TrR_TrNTyp NOT IN (306,307,313,314)
     END
 IF @FaPfZal=1 or  (@PFzWZ > 0 and @TylkoAnulowanie<>2)  --anulowanie FA powstałej z PF jeśli istnieją FAZAL tylko rozpina powiązanie FA z PF
    BEGIN
            IF  @PFzWZ=0
                BEGIN
                  DELETE CDN.TraNagRelacje WHERE TrR_TrNId = @TrnID AND TrR_Flaga <> 1
                  DELETE CDN.TraNagRelacje WHERE TrR_FaId = @TrnID AND TrR_Flaga <> 1
                END
             ELSE
                BEGIN
                  DELETE cdn.TraNagRelacje WHERE TrR_TrNID =@TrnID AND TrR_FaTyp = 302
                  DELETE cdn.TraNagRelacje WHERE TrR_FaID =@TrnID AND TrR_TrNTyp = 302
                END
            -- rozpinanie
    END
/*
    ELSE
    BEGIN
           DECLARE @FaId INT, @FaTyp INT
           DECLARE DokumentySkoj CURSOR LOCAL FAST_FORWARD FOR
           SELECT  TrR_FaId, Trr_FaTyp FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId AND Trr_TrNTyp = @TrNRodzaj / 1000
             OPEN DokumentySkoj
              WHILE 1=1
                BEGIN
                 FETCH NEXT FROM DokumentySkoj INTO @FaId, @FaTyp
                  IF @@FETCH_STATUS <> 0 BREAK
                --szukam powiązań i je kasuje
                  DELETE FROM CDN.TraNagRelacje WHERE TrR_TrNId = @FaId AND Trr_TrNTyp = @FaTyp
                  DELETE FROM CDN.TraNagRelacje WHERE TrR_FaId = @FaId AND Trr_FaTyp = @FaTyp
                END
              CLOSE DokumentySkoj
             DEALLOCATE DokumentySkoj
            DELETE cdn.TraNagRelacje WHERE TrR_TrNID in (select Trn_TrNID FROM CDN.TraNag  JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE  TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE  TrR_FaID = @TrnID)) AND TrN_TypDokumentu IN (308,309,320,321,322,350))
            DELETE cdn.TraNagRelacje WHERE TrR_FaID  in (select Trr_FaId FROM CDN.TraNag  JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE  TrR_FaID  IN ( SELECT Trr_FaId FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE TrR_FaID  IN ( SELECT TrR_FaId FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE  TrR_TrNID = @TrNId)) AND Trr_FaTyp IN (308,309,320,321,322,350))
--            DELETE cdn.TraNagRelacje WHERE TrR_FaID  in (select Trn_TrNID FROM CDN.TraNag  JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE  TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE  TrR_FaID = @TrnID)) AND TrN_TypDokumentu IN (308,309,320,321,322,350))
            -- dla powiązanych z powiąznymi (2 poziom) dotyczy tylko RO, ZD, PF)
            DELETE cdn.TraNagRelacje WHERE TrR_TrNID in (select Trn_TrNID FROM CDN.TraNag  JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE  TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE TrR_FaID = @TrnID) AND TrN_TypDokumentu IN (308,309,320,321,322,350))
            DELETE cdn.TraNagRelacje WHERE TrR_FaID in (select Trn_TrNID FROM CDN.TraNag  JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE  TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE TrR_FaID = @TrnID) AND TrN_TypDokumentu IN (308,309,320,321,322,350))
            -- dla powiązanych z powiąznymi (1 poziom) dotyczy tylko RO, ZD, PF)
            DELETE cdn.TraNagRelacje WHERE TrR_TrNID in (select Trn_TrNID FROM CDN.TraNag  JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu IN (308,309,320,321,322,350))
            DELETE cdn.TraNagRelacje WHERE TrR_FaID in (select Trn_TrNID FROM CDN.TraNag  JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu IN (308,309,320,321,322,350))
    END
*/
    IF @TylkoAnulowanie=2 -- O!O  anulowanie dokumentów handlowych pociąga anulowanie dokumentów magazynowych
    BEGIN   -- anulowanie
           DECLARE DokumentySkoj CURSOR LOCAL FAST_FORWARD FOR
           SELECT  TrR_FaId, Trr_FaTyp FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrNId AND Trr_TrNTyp = @TrNRodzaj / 1000
             OPEN DokumentySkoj
              WHILE 1=1
                BEGIN
                 FETCH NEXT FROM DokumentySkoj INTO @FaId, @FaTyp
                  IF @@FETCH_STATUS <> 0 BREAK
                --szukam powiązań
                 IF EXISTS (SELECT * FROM CDN.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNid = Trr_TrNid WHERE Trr_FaId = @FaId AND TrN_Bufor =-1 AND (TrR_TrNTyp=302 OR TrR_TrNTyp=305)) AND @TylkoAnulowanie = 2
                  BEGIN
                   UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null FROM CDN.TraNag WHERE TrN_TrNID  IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  ON TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID) AND TrN_TypDokumentu IN (306,307);
                  -- DELETE FROM CDN.TraNagRelacje WHERE Trr_TrNid = @FaId AND (Trr_FaTyp = 306) AND TrR_FaId = @TrNId
                  -- DELETE FROM CDN.TraNagRelacje WHERE Trr_Faid = @FaId AND (Trr_TrNTyp = 306) AND TrR_TrNId = @TrNId
                   END
                  DELETE FROM CDN.TraNagRelacje WHERE TrR_TrNId = @FaId AND Trr_TrNTyp = @FaTyp AND TRR_FATyp != 320
                  DELETE FROM CDN.TraNagRelacje WHERE TrR_TrNId = @FaId AND Trr_TrNTyp = @FaTyp AND TRR_FATyp = 320
                  DELETE FROM CDN.TraNagRelacje WHERE TrR_FaId = @FaId AND Trr_FaTyp = @FaTyp AND TRR_TrNTyp != 320
                  DELETE FROM CDN.TraNagRelacje WHERE TrR_FaId = @FaId AND Trr_FaTyp = @FaTyp AND TRR_TrNTyp = 320
                  UPDATE CDN.TraNag SET TrN_Rodzaj = TrN_TypDokumentu * 1000 WHERE TrN_TrNId = @FaId
                END
              CLOSE DokumentySkoj
             DEALLOCATE DokumentySkoj
/*
            DELETE cdn.TraNagRelacje WHERE TrR_TrNID in (select Trn_TrNID  FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID  IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID) AND TrN_TypDokumentu IN (306,307))
            DELETE cdn.TraNagRelacje WHERE TrR_FaID in (select Trn_TrNID  FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID  IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID) AND TrN_TypDokumentu IN (306,307))
            DELETE cdn.TraNagRelacje WHERE TrR_TrNID in (select Trn_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaId IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID) AND TrN_TypDokumentu IN (313, 314) )
            DELETE cdn.TraNagRelacje WHERE TrR_FaID in (select Trn_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaId IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID) AND TrN_TypDokumentu IN (313, 314) )
            -- anulowanie dokumentów magazynowych (poziom 1) (dotyczy WZ, PZ, PKA)
            DELETE cdn.TraNagRelacje WHERE TrR_TrNID in (select Trn_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu IN (306, 307))
            DELETE cdn.TraNagRelacje WHERE TrR_FaID in (select Trn_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu IN (306, 307))
            DELETE cdn.TraNagRelacje WHERE TrR_TrNID in (select Trn_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu IN (313,314))
            DELETE cdn.TraNagRelacje WHERE TrR_FaID in (select Trn_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu IN (313,314))
            -- anulowanie i rozpinanie dla powiązanych  (poziom 1) dotyczy tylko PA)
            DELETE cdn.TraNagRelacje WHERE TrR_TrNID in (select Trn_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu =305)
            DELETE cdn.TraNagRelacje WHERE TrR_FaID in (select Trn_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu =305)
            -- rozpinanie dokumentów magazynowych (poziom 2) (dotyczy WKA->FA i PKA->FZ)
            DELETE cdn.TraNagRelacje WHERE TrR_TrNID in (select Trn_TrNID  FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrN_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID) AND TrN_TypDokumentu IN (313, 314))
            DELETE cdn.TraNagRelacje WHERE TrR_FaID in (select Trn_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrN_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID) AND TrN_TypDokumentu IN (313, 314))
            -- rozpinanie dokumentów magazynowych (poziom 1) (dotyczy WKA->FA i PKA->FZ)
            DELETE cdn.TraNagRelacje WHERE TrR_TrNID in (select Trn_TrNID  FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu IN (313, 314))
            DELETE cdn.TraNagRelacje WHERE TrR_FaID in (select Trn_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu IN (313, 314))
*/
    END
    ELSE -- Optima nie oodziałowa
    BEGIN
  IF @FaPfZal=1  --anulowanie FA powstałej z PF jeśli istnieją FAZAL tylko rozpina powiązanie FA z PF
        BEGIN
                -- rozpinanie
                DELETE cdn.TraNagRelacje WHERE TrR_TrNID =@TrnID
                DELETE cdn.TraNagRelacje WHERE TrR_FaID =@TrnID
        END
        ELSE
        BEGIN
           IF @Rodzaj NOT IN (321001, 321002, 321003, 322001, 322002, 322003)
            BEGIN
               -- przed rozpięciem muszę zmienić rodzaje dokumentu odpinanego
                SET @FaId = 0
                SET @TrNIdKonwersji = 0
                SELECT @FaId = Trr_FaId FROM CDN.TraNagRelacje  WHERE Trr_TrNId = @TrNId
                SELECT @TrNIdKonwersji = TrN_TrNId, @Typ = TrN_TypDokumentu, @Rodzaj = TrN_Rodzaj
                FROM CDN.TraNag --JOIN CDN.TraNagRelacje ON Trr_TrNID = TrN_TrNID
                 WHERE TrN_TrNId = @FaId --AND TrR_FaId <> @TrNID
                -- usuwanie powiazan w przypadku anulowania FA skojrzonego z WZ i PA
                IF EXISTS (SELECT * FROM CDN.TraNagRelacje JOIN CDN.TraNag ON Trr_FaId = TrN_TrNID WHERE Trr_TrNId = @FaId AND Trr_FaTyp=305 AND TrN_Bufor =-1)
                BEGIN
                 IF (SELECT COUNT(*) FROM CDN.TraNagRelacje Where Trr_TrNid = @FaId)=1
                   BEGIN
                    DELETE cdn.TraNagRelacje WHERE Trr_TrNid IN (SELECT Trr_FaId FROM CDN.TraNagRelacje WHERE Trr_TrNId = @FaId)
                    DELETE cdn.TraNagRelacje WHERE Trr_FaId IN (SELECT Trr_FaId FROM CDN.TraNagRelacje WHERE Trr_TrNId = @FaId)
                   END
                 ELSE
                   BEGIN
                   DELETE cdn.TraNagRelacje WHERE Trr_TrNid =  @FaId AND Trr_TrNid = @TrnID
                   DELETE cdn.TraNagRelacje WHERE Trr_FaId  =  @FaId AND Trr_FaId = @TrNid
                   END
  END
                DELETE cdn.TraNagRelacje WHERE TrR_TrNID =@TrnID
                DELETE cdn.TraNagRelacje WHERE TrR_FaID =@TrnID
                -- po rozpięciu powinienem zmienić rodzaje na dokumentach powiązanych
                IF @TrNIdKonwersji <> 0
                BEGIN
                 UPDATE CDN.TraNag SET TrN_Rodzaj = CDN.UstalRodzajPrzedKonwersja(@TrNIdKonwersji, @Rodzaj, @Typ, 0) WHERE TrN_TrNId = @TrNIDKonwersji
                END
/*
                -- rozpinanie dokumentów magazynowych (poziom 2) (dotyczy WZ, PZ)
                DELETE cdn.TraNagRelacje WHERE TrR_TrNID in (select Trn_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag WHERE Trr_FaID = @TrnID) AND TrN_TypDokumentu IN (306,307,313,314))
                DELETE cdn.TraNagRelacje WHERE TrR_FaID in (select Trn_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID IN ( SELECT TrN_TrNID FROM CDN.TraNag WHERE Trr_FaID = @TrnID) AND TrN_TypDokumentu IN (306,307,313,314))
                -- rozpinanie dokumentów magazynowych (poziom 1) (dotyczy WZ, PZ)
                DELETE cdn.TraNagRelacje WHERE TrR_TrNID in (select Trn_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu IN (306, 307, 313, 314))
                DELETE cdn.TraNagRelacje WHERE TrR_FaID in (select Trn_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId  WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu IN (306, 307, 313, 314))
                -- anulowanie i rozpinanie dla powiązanych (1 poziom) dotyczy tylko PA)
                DELETE cdn.TraNagRelacje WHERE TrR_TrNID in (select Trn_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu =305)
                DELETE cdn.TraNagRelacje WHERE TrR_FaID in (select Trn_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE  TrR_FaID = @TrnID AND TrN_TypDokumentu =305)
*/
            END
        END
    END  -- Optima nie oodziałowa
    -- rozpinanie powiazania RO różnicowego do anulowanych RO zgł.http://www.cdn.com.pl/zgloszenie.asp?ID=94372
    DELETE cdn.TraNagRelacje WHERE TrR_TrNID in (select Trn_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId
  WHERE TrN_TypDokumentu =308 AND TrR_FaId IN (SELECT TrN_TrNID FROM CDN.TraNag WHERE TrN_TypDokumentu=308 AND TrN_Bufor=-1))
    DELETE cdn.TraNagRelacje WHERE TrR_FaID in (select Trn_TrNID FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId
  WHERE TrN_TypDokumentu =308 AND TrR_FaId IN (SELECT TrN_TrNID FROM CDN.TraNag WHERE TrN_TypDokumentu=308 AND TrN_Bufor=-1))
    IF  @TrnRodzaj/1000 IN (301, 302, 305) -- anulowanie FZ, FS i PA przeniesione na serwer
     BEGIN
        DELETE CDN.TraNagRelacje WHERE TrR_TrNId = @TrnID
        DELETE CDN.TraNagRelacje WHERE TrR_FaId = @TrnID
     END
 END
   if exists(select TrN_Bufor from cdn.tranag where TrN_Bufor= -1 and TrN_TrNID = @TrnID)
   begin
 -- wykasowanie subelementów kasowanego dokumentu i skojarzonej WZKK
  DELETE cdn.TraSElem
  FROM cdn.TraSElem  S
       JOIN cdn.TraElem E on  S.TrS_TrEId = E.TrE_TrEId
       JOIN cdn.TraNag N  on  N.TrN_TrNId = E.TrE_TrNId
  WHERE N.TrN_TrNId IN
                                    (SELECT WZKK.TrN_TrNID FROM CDN.TraNag WZKK
                                          WHERE WZKK.TrN_ZwrID = @TrnID AND WZKK.TrN_Rodzaj
                                            IN (306061,306071,306072))
   -- anulowanie WZKK
  IF EXISTS ( SELECT * FROM CDN.TraNag join
  (select TrN_TrNID as TrNID, TrN_ZwrID as ZwrID from CDN.TraNag WHERE  TrN_ZwrIDWZKK = @TrnID AND TrN_Rodzaj IN (306061,306071,306072)) as A on TrN_ZwrId = A.ZwRID
  where TrN_TrNID >TrNID and TrN_Bufor <> -1 AND TrN_Rodzaj NOT IN (306061,306071,306072))
  begin
  SET @Komunikat = '##OPT34441##'--'Nie można anulować dokumentu! Anulowany dokument jest powiązany z dokumentem WZKK (korekta kosztów) do którego istnieją późniejsze korekty. Anuluj późniejsze korekty.'
  GOTO KOMUNIKAT
  end
  UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null, TrN_ZwrID = NULL, TrN_ZwrIdWZKK = NULL WHERE  TrN_ZwrID = @TrnID AND TrN_Rodzaj IN (306061,306071,306072);
  -- kasuję powiązania WZKK
  DELETE CDN.TraNagRelacje WHERE TrR_TrNID IN
  (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrID = @TrnID AND TrN_Rodzaj IN (306061,306071,306072))
  DELETE CDN.TraNagRelacje WHERE TrR_FaID IN
  (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrID = @TrnID AND TrN_Rodzaj IN (306061,306071,306072))
  end
  KOMUNIKAT:
  IF @Komunikat <> ''
    BEGIN
      RAISERROR( @Komunikat, 16, 1)
      --ROLLBACK TRAN
      --SET NOCOUNT OFF
      RETURN
    END
 KONIEC:
  --SET NOCOUNT OFF;
  --IF @@TRANCOUNT <> 0  COMMIT TRAN
  --SELECT 0   -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
  RETURN
END -- end PROCEDURE
