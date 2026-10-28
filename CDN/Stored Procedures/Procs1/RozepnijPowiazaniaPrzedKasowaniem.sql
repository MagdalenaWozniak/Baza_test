CREATE PROCEDURE CDN.RozepnijPowiazaniaPrzedKasowaniem
@TrnID            AS INT,
@TrnRodzaj        AS INT,
@TrnFaId          AS INT
AS
BEGIN
DECLARE
@TrrId INT,
@TrrTyp INT,
@TypSkojarzonego INT,
@IdSkojarzonego INT
DECLARE @TrN TABLE ( TrNId INT)
SET @IdSkojarzonego = 0
SET @TypSkojarzonego = 0
SET @TrrId = 0
SET @TrrTyp = 0
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
    -- numer obcy na zapisie KB
        update cdn.BnkZdarzenia set BZd_NumerObcy = '' from cdn.BnkZdarzenia JOIN cdn.TraNagRelacje  on BZd_DokumentId = TrR_TrNId WHERE TrR_FaID =@TrnID AND TrR_TrNTyp=305 AND BZd_DokumentTyp = 1
END
IF  @TrnRodzaj/1000  = 308 -- anulowanie FZ, FS i PA przeniesione na serwer
     BEGIN
if  ( select TOP 1 1 from cdn.tranag where trn_trnid in (select TrR_FAId from CDN.TraNagRelacje WHERE TrR_TrNId = @TrnID and TrR_FATyp = 320 and TrR_TrNTyp = 308) and trn_zwroconocalailosc = 5) = 1
begin
update cdn.tranag set trn_zwroconocalailosc = 0 where trn_trnid in (select TrR_FAId from CDN.TraNagRelacje WHERE TrR_TrNId = @TrnID and TrR_FATyp = 320 and TrR_TrNTyp = 308)
end
END
    -- obsługa starych rezerwacji
    INSERT INTO @TrN ( TrNId ) SELECT TrN_TrNId FROM CDN.TraNagRelacje JOIN CDN.TraNag ON TrR_TRNId = TrN_TrNId WHERE TrR_FaID =@TrnID and TrN_Rodzaj IN (308009, 308008, 308010, 309008, 309009)
 -- kasowanie dokumentu w buforze i rozpinanie powiazan
 --BEGIN TRAN;
 --SET NOCOUNT ON;
  -- zmiana pola rodzaj dokumentu
        UPDATE CDN.TraNag SET TrN_TS_Mod = GETDATE(),TrN_Rodzaj=CDN.UstalRodzajDokumentu(TrN_TypDokumentu,TrN_Rodzaj,TrN_Korekta ) WHERE TrN_TrNID=@TrnID;
        -- SO wykomentowalem linijke nizej, bo statusy inaczej maja sie zmieniac
        -- UPDATE CDN.TraNag SET TrN_TS_Mod = GETDATE(),TrN_Rodzaj=CDN.fn_UstalRodzajDokumentu(TrN_TypDokumentu,TrN_Rodzaj,TrN_Korekta ) FROM CDN.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrnID;
        -- SO przygotowuje liste dokumentow ktore powinny miec zmieniony rodzaj dokumentu
           DECLARE K CURSOR LOCAL FAST_FORWARD FOR
         SELECT Trr_TrNId, Trr_TrNTyp FROM CDN.TraNagRelacje WHERE TrR_FaId = @TrNId
       OPEN K
         WHILE 1=1
          BEGIN
            FETCH NEXT FROM K INTO @TrrId, @TrrTyp
               IF @@FETCH_STATUS <> 0 BREAK
            -- nastepnie kasuje powiazania z dokumentem glownym
           --   DELETE cdn.TraNagRelacje WHERE TrR_TrNID =@TrnID
            --  DELETE cdn.TraNagRelacje WHERE TrR_FaID =@TrnID
              -- IF @TrrTyp = 307 --na razie na probe w przypadku ZD -> PZ -> FZ i kasuje FZ z bufora
                  BEGIN
                 --teraz zmieniam rodzaj dokumentu skojarzonego
                  IF @TrrTyp = 301 AND (SELECT COUNT(*)  FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrrID AND TrR_FaId <> @TrNId)<>1
                     BEGIN
                      SET @IdSkojarzonego = 0
                      SELECT  TOP 1 @IdSkojarzonego = TrR_TrNId, @TypSkojarzonego = TrR_TrNTyp FROM CDN.TraNagRelacje WHERE  Trr_FaId = @TrRId AND TrR_FaTyp = @TrrTyp AND Trr_TrNId <> @TrNId AND Trr_TrNTyp = 350
                     END
                  ELSE
      IF @TrrTyp = 306 AND
     exists( SELECT * FROM CDN.TraNagRelacje WHERE  Trr_FaId = @TrrID AND TrR_FaTyp = @TrrTyp  and TrR_TrNTyp = 308)
     and
     exists( SELECT * FROM CDN.TraNagRelacje WHERE  Trr_FaId = @TrrID AND TrR_FaTyp = @TrrTyp and TrR_TrNTyp = 320)
                     BEGIN
                      SET @IdSkojarzonego = 0
                      SELECT  TOP 1 @IdSkojarzonego = TrR_TrNId, @TypSkojarzonego = TrR_TrNTyp FROM CDN.TraNagRelacje WHERE  Trr_FaId = @TrRId AND TrR_FaTyp = @TrrTyp AND Trr_TrNId <> @TrNId AND Trr_TrNTyp = 320
                     END
                  ELSE
                   SELECT TOP 1 @IdSkojarzonego = TrR_TrNId, @TypSkojarzonego = TrR_TrNTyp FROM CDN.TraNagRelacje WHERE  Trr_FaId = @TrRId AND TrR_FaTyp = @TrrTyp AND Trr_TrNId <> @TrNId order by TrR_TrRId desc
                     IF @IdSkojarzonego <> 0 AND (@TypSkojarzonego <> @TrNRodzaj/1000)
                       UPDATE CDN.TraNag SET TrN_TS_Mod = GETDATE(),TrN_Rodzaj=CDN.UstalRodzajPrzedKonwersja(@TrrId,TrN_Rodzaj,TrN_TypDokumentu, @IdSkojarzonego) FROM  CDN.TraNag  WHERE TrN_TrNid = @TrrId
        and not((@TrNRodzaj / 1000 =301 and TrN_TypDokumentu = 302) or ( @TrNRodzaj / 1000 =302 and TrN_TypDokumentu =301) or ( @TrNRodzaj / 1000 =306 and TrN_TypDokumentu =307) or (@TrNRodzaj / 1000 =307 and TrN_TypDokumentu = 306))
                     IF @IdSkojarzonego = 0
                       UPDATE CDN.TraNag SET TrN_TS_Mod = GETDATE(),TrN_Rodzaj=CDN.UstalRodzajPrzedKonwersja(@TrrId,TrN_Rodzaj,TrN_TypDokumentu, TrN_TrNId) FROM  CDN.TraNag  WHERE TrN_TrNid = @TrrId
        and not((@TrNRodzaj / 1000 =301 and TrN_TypDokumentu = 302) or ( @TrNRodzaj / 1000 =302 and TrN_TypDokumentu =301) or ( @TrNRodzaj / 1000 =306 and TrN_TypDokumentu =307) or (@TrNRodzaj / 1000 =307 and TrN_TypDokumentu = 306))
                  END
                    IF @TrrTyp = 320 AND @TrNRodzaj / 1000 = 306 --nalezy sprawdzic czy WZ nie jest przypadkiem skojarzona z FPF a ta FPF nie ma FAZAL
                     BEGIN
                      SELECT TOP 1 @IdSkojarzonego = TrR_FaId, @TypSkojarzonego = TrR_FaTyp FROM CDN.TraNagRelacje WHERE Trr_TrNid = @TrrId AND Trr_Flaga = 1 AND Trr_FaTyp=302
                      UPDATE CDN.TraNag SET TrN_TS_Mod = GETDATE(),TrN_Rodzaj=CDN.UstalRodzajPrzedKonwersja(@TrrId,TrN_Rodzaj,TrN_TypDokumentu, @IdSkojarzonego) FROM  CDN.TraNag  WHERE TrN_TrNid = @TrrId
                     END
      END
          CLOSE k
         DEALLOCATE K
--      UPDATE CDN.TraNag SET TrN_TS_Mod = GETDATE(),TrN_Rodzaj=CDN.fn_UstalRodzajDokumentu(TrN_TypDokumentu,TrN_Rodzaj,TrN_Korekta ) WHERE TrN_RelTrnID =@TrnID;
        IF @TrnRodzaj = 321022  --FWZ powiązana z FWS i kasuję FWZ, to zmieniam rodzaj na FWS
           BEGIN
             UPDATE CDN.TraNag SET TrN_TS_Mod = GETDATE(),TrN_Rodzaj=CDN.UstalRodzajDokumentu(TrN_TypDokumentu,TrN_Rodzaj,TrN_Korekta ) WHERE TrN_TrNID = @TrnFaId;
           END
--RT 16        EXEC CDN.UstawRodzajDlaProForma @TrnID, @TrnRodzaj, @TrnFaId
         -- przegenerowanie elementów
        IF  @TrnRodzaj NOT IN (301004, 301090, 302004, 302090, 305004) -- kasowanie FZ do którego jest PZ nie powinno ruszać elementów zgl. 37744
          BEGIN
           UPDATE CDN.TraElem SET TrE_Aktywny=1 FROM CDN.TraElem JOIN CDN.TraNag ON TrE_TrNId=TrN_TrNId join @TrN ON TrNId = TrN_TrNId WHERE TrE_Aktywny=1;
           UPDATE CDN.TraElem SET TrE_Aktywny=1 FROM CDN.TraElem JOIN CDN.TraNag ON TrE_TrNId=TrN_TrNId WHERE TrE_TypDokumentu not in (308,309) AND TrE_Aktywny=1 AND TrN_FaID =@TrnID ;
           --UPDATE CDN.TraElem SET TrE_Aktywny=1 FROM CDN.TraElem JOIN CDN.TraNag ON TrE_TrNId=TrN_TrNId WHERE TrE_Aktywny=1 AND TrN_FaID =@TrnID;
          END
        IF @TrnRodzaj in( 308000)
          BEGIN
            UPDATE CDN.TraElem SET TrE_LpPow=TrE_LpPowRel,TrE_LpPowRel=NULL FROM CDN.TraElem JOIN CDN.TraNag ON TrE_TrNId=TrN_TrNId JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE Trn_Rodzaj in (306010,306001) AND TrR_FaID =@TrnID AND Tre_LpPowRel > 0;
            UPDATE CDN.TraElem SET TrE_LpPow=TrE_LpPowRel,TrE_LpPowRel=NULL FROM CDN.TraElem JOIN CDN.TraNag ON TrE_TrNId=TrN_TrNId JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE Trn_TypDokumentu = 320 AND TrR_FaID =@TrnID AND Tre_LpPowRel > 0;
--            UPDATE CDN.TraElem SET TrE_LpPow=TrE_LpPowRel,TrE_LpPowRel=NULL FROM CDN.TraElem JOIN CDN.TraNag ON TrE_TrNId=TrN_TrNId WHERE Trn_Rodzaj = 306010 AND TrN_FaID =@TrnID AND Tre_LpPowRel > 0;
  --          UPDATE CDN.TraElem SET TrE_LpPow=TrE_LpPowRel,TrE_LpPowRel=NULL FROM CDN.TraElem JOIN CDN.TraNag ON TrE_TrNId=TrN_TrNId WHERE Trn_TypDokumentu = 320 AND TrN_FaID =@TrnID AND Tre_LpPowRel > 0;
          END
  IF @TrnRodzaj in( 302009,302004)
   BEGIN
            UPDATE CDN.TraElem SET TrE_LpPow=TrE_LpPowRel,TrE_LpPowRel=NULL FROM CDN.TraElem JOIN CDN.TraNag ON TrE_TrNId=TrN_TrNId JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE Trn_Rodzaj in (306010,306001) AND TrR_FaID =@TrnID AND Tre_LpPowRel > 0;
            UPDATE CDN.TraElem SET TrE_LpPow=TrE_LpPowRel,TrE_LpPowRel=NULL FROM CDN.TraElem JOIN CDN.TraNag ON TrE_TrNId=TrN_TrNId JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId WHERE Trn_TypDokumentu = 320 AND TrR_FaID =@TrnID AND Tre_LpPowRel > 0;
          END
        -- rozpinanie
       -- IF EXISTS(SELECT TrN_TrNId FROM CDN.TraNag WHERE TrN_FaID =@TrnID AND TrN_RelTrNId is NOT NULL AND TrN_TypDokumentu = 306)
        IF (SELECT ISNULL(COUNT(*),0) FROM CDN.TraNagRelacje WHERE TrR_TrNID = @TrnID AND TrR_FaTyp in (302,320) AND TrR_TrNTyp = 306 ) = 2
         BEGIN
           UPDATE CDN.TraNag SET TrN_TS_Mod = GETDATE(), TrN_FaID=TrN_RelTrNId,TrN_RelTrNId=NULL WHERE TrN_FaID =@TrnID;
         -- usuwam powiązania po wykonaniu update
           DELETE cdn.TraNagRelacje WHERE TrR_TrNID =@TrnID AND TrR_FaTyp = 302
           DELETE cdn.TraNagRelacje WHERE TrR_FaID =@TrnID AND TrR_TrNTyp = 302
         END
        ELSE
        -- SO w tym miejscu usunalem update kolumny rodzaj, jest robiony wyzej
        UPDATE CDN.TraNag SET TrN_TS_Mod = GETDATE(), TrN_FaID=null WHERE TrN_FaID =@TrnID;
        UPDATE CDN.TraNag SET TrN_TS_Mod = GETDATE(), TrN_RelTrNId=null WHERE TrN_RelTrNId=@TrnID;
        UPDATE CDN.TraVat SET TrV_TrNIdFinalna=null WHERE TrV_TrNIdFinalna=@TrnID; --65109 Przy anulowaniu/kasowaniu finalnej faktury nulować to pole na powiązanych zaliczkowych.
        -- usuwam powiązania po wykonaniu update
        DELETE cdn.TraNagRelacje WHERE TrR_TrNID =@TrnID
        DELETE cdn.TraNagRelacje WHERE TrR_FaID =@TrnID
        -- rozpinanie ofert dla ProForma
        IF  @TrnRodzaj/1000 = 320
          UPDATE CDN.OfertyDok SET OfD_TrNId = NULL WHERE OfD_TrNId = @TrnID
        -- usuwanie dokumenty z listy skojarzonych na CRM
        DELETE CDN.CrmDokumenty WHERE CRD_TypDokumentu = @TrnRodzaj/1000 AND CRD_DokumentId = @TrnID
        --
   KONIEC:
  --SET NOCOUNT OFF;
  --IF @@TRANCOUNT <> 0  COMMIT TRAN
  --SELECT 0   -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
  RETURN
END -- end PROCEDURE
