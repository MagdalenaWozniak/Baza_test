CREATE PROCEDURE CDN.AnulujMagazynowe
@TylkoAnulowanie  AS INT,
@TrnID            AS INT,
@TrnRodzaj        AS INT,
@TrnFaId          AS INT
AS
BEGIN
   IF @TrnFaId = 0
 SET @TrnFaId = CDN.TraNagRelacjeFaId (@TrNId, @TrnRodzaj/1000, 0)
   IF @TrnFaId = 0
 SET @TrnFaId = CDN.TraNagRelacjeFaId (@TrNId, @TrnRodzaj/1000, 1)
 BEGIN TRAN
 SET NOCOUNT ON
 DECLARE @idPow          INT
 DECLARE @RodzajPF       INT
 DECLARE @Wynik          INT
 DECLARE @Err         INT
        DECLARE @Id             INT
        DECLARE @TrNFPF         INT
 SET @Err = 0
 IF @TrnRodzaj = 307010 OR @TrnRodzaj = 307000 --rFaktura.get_Rodzaj()=e_op_Rdz_PZZD or rFaktura.get_Rodzaj()=e_op_Rdz_PZ
  BEGIN
--   UPDATE  CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), trn_faid=null, trn_rodzaj=309000 FROM CDN.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu=309 AND TrR_FaId = @TrnID
--   UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), trn_faid=null, trn_rodzaj=309000 WHERE TrN_TypDokumentu=309 AND TrN_faid=@TrnID
   UPDATE CDN.TraNag SET TrN_Rodzaj = 307000 WHERE TrN_TrNId = @TrnID
  END
 IF @TrnRodzaj/1000 = 308   -- rFaktura.get_TypDokumentu()= e_op_KlasaRO
  BEGIN
   declare @FPzROTable table (Id int)
   insert into @FPzROTable
    select Trr_TrNId FROM CDN.TraNagRelacje WHERE Trr_FaId = @TrNId AND TrR_TrNTyp = 320
         SELECT @TrNFPF = ISNULL(Trr_TrNId,0) FROM CDN.TraNagRelacje WHERE Trr_FaId = @TrNId AND TrR_TrNTyp = 320
--SO nie kasuje FPF     UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaId=null, TrN_Rodzaj=320000 FROM CDN.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu=320 AND TrR_FaId = @TrnID
--   update cdn.tranag set trn_bufor=-1, TrN_TS_Mod = GETDATE(), trn_faid=null, trn_rodzaj=320000 where trn_typdokumentu=320 and trn_faid=@TrnID
      UPDATE CDN.TraNag SET TrN_Rodzaj=308000 WHERE TrN_TrNId = @TrnID
  END
/* IF @TrnRodzaj/1000 = 306   -- rFaktura.get_TypDokumentu()=e_op_KlasaWZ
  BEGIN
                -- [WJ] Zgloszenie 36497
   SELECT @Id = ISNULL(TrN_TrNID,0) FROM CDN.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu=308 AND TrR_FaId = @TrnID
   IF @Id <> 0
   BEGIN
    SELECT @Id = ISNULL(TrN_TrNID,0) FROM CDN.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu = 320 AND TrR_FaId = @Id
    IF @Id <> 0
     UPDATE CDN.TraNag SET TrN_Bufor = -1, TrN_TS_Mod = GETDATE(), TrN_FaId = NULL, TrN_Rodzaj = 320000 WHERE TrN_TypDokumentu = 320 AND TrN_FaId = @Id;
                        END
  -- [WJ] koniec
                 UPDATE CDN.TraNag SET TrN_Bufor = -1, TrN_TS_Mod = GETDATE(), Trn_FaId = NULL, TrN_Rodzaj=308000 WHERE TrN_TypDokumentu = 308 AND TrN_FaId = @TrnID
                 UPDATE CDN.TraNag SET TrN_Rodzaj = 306000 WHERE TrN_TrNId = @TrnID
  END*/
 IF @TylkoAnulowanie=0 --tylko rozpinanie (kasowanie w buforze)
  BEGIN
                  EXEC CDN.RozepnijPowiazaniaPrzedKasowaniem @TrnID, @TrnRodzaj, @TrnFaId
  END -- END  @TylkoAnulowanie=0 --tylko rozpinanie (kasowanie w buforze)
 ELSE
  BEGIN   -- anulowanie
    EXEC CDN.AnulowanieDokumentu @TylkoAnulowanie, @TrnID, @TrnRodzaj, @TrnFaId
                   SET @Err = @@ERROR
      IF @Err <> 0
      GOTO KONIEC
  END
-- if (this->TypDokumentu==e_op_KlasaPZ && this->Korekta==e_op_KorektaWartosci)
--   value[L"Faid"]=cdn_util::VTnull();
 IF @TrnRodzaj/1000 = 313 OR @TrnRodzaj/1000 = 314 OR @TrnRodzaj/1000 = 303 OR @TrnRodzaj/1000 = 304 -- e_op_KlasaPKA, e_op_KlasaWKA, e_op_KlasaPW,  e_op_KlasaRW
  UPDATE CDN.TraNag SET TrN_FaId = NULL WHERE TrN_TrNId = @TrnID
 -- anulowanie
 create table #ROZD (ROZDTrNId int)
      insert into #ROZD(ROZDTrNId)
 select distinct tre_trnid from cdn.traelem
    left join  CDN.TraSElem on Trs_TrEId = tre_treid
    WHERE TRS_TrEIdWydania in (select tre_treid from cdn.traelem WHERE Tre_TrNId = @TrnID)
    UPDATE CDN.TraNag SET TrN_FaID=NULL, TrN_RelTrNId=NULL, TrN_Bufor=-1, TrN_TS_Mod = GETDATE() WHERE Trn_TrNId = @TrnID
 -- ustawiamy status na RO jak trzeba
 DECLARE @ROZDTrNId int
 DECLARE dok CURSOR LOCAL FAST_FORWARD FOR
         select  ROZDTrNId from #ROZD
          OPEN dok
          WHILE 1=1
            BEGIN
              FETCH NEXT FROM dok INTO @ROZDTrNId
              IF @@FETCH_STATUS <> 0 BREAK
      EXECUTE cdn.UstawStatusRezerwacji_New @ROZDTrNId,0
            END
    CLOSE dok
    DEALLOCATE dok
    -- kasujemy relacje z tabeli CDN.TraNagRelacje
 IF @TrnRodzaj = 307010 OR @TrnRodzaj = 307000 --rFaktura.get_Rodzaj()=e_op_Rdz_PZZD or rFaktura.get_Rodzaj()=e_op_Rdz_PZ
  BEGIN
      DELETE CDN.TraNagRelacje WHERE trr_Fatyp=309 and TrR_TrNId = @TrnID
      DELETE CDN.TraNagRelacje WHERE trr_Trntyp=309 and TrR_FaId = @TrnID
  END
 IF @TrnRodzaj/1000 = 308   -- rFaktura.get_TypDokumentu()= e_op_KlasaRO
  BEGIN
      DELETE CDN.TraNagRelacje WHERE trr_Fatyp=320 and TrR_TrNId = @TrnID
      DELETE CDN.TraNagRelacje WHERE trr_Trntyp=320 and TrR_FaId = @TrnID
  END
 IF @TrnRodzaj/1000 = 306   -- rFaktura.get_TypDokumentu()=e_op_KlasaWZ
  BEGIN
                -- [WJ] Zgloszenie 36497
   SELECT @Id = ISNULL(TrN_TrNID,0) FROM CDN.TraNag JOIN cdn.TraNagRelacje ON TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu = 308 AND TrR_FaId = @TrnID
   IF @Id <> 0
   BEGIN
    SELECT @Id = ISNULL(TrN_TrNID,0) FROM CDN.TraNag JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu = 320 AND TrR_FaId = @Id
    IF @Id<>0
                           BEGIN
      DELETE CDN.TraNagRelacje WHERE TrR_Fatyp=320 and TrR_TrNId = @id
    DELETE CDN.TraNagRelacje WHERE TrR_Trntyp=320 and TrR_FaId = @id
                           END
                        END
    -- [WJ] koniec
      DELETE CDN.TraNagRelacje WHERE TrR_Fatyp=308 and TrR_TrNId = @TrnID
      DELETE CDN.TraNagRelacje WHERE TrR_Trntyp=308 and TrR_FaId = @TrnID
  END
 IF @TrnRodzaj/1000 = 313 OR @TrnRodzaj/1000 = 314 OR @TrnRodzaj/1000 = 303 OR @TrnRodzaj/1000 = 304 -- e_op_KlasaPKA, e_op_KlasaWKA, e_op_KlasaPW,  e_op_KlasaRW
 DELETE CDN.TraNagRelacje WHERE TrR_TrNId = @TrnID
 DELETE CDN.TraNagRelacje WHERE TrR_FaId = @TrnID
        -- przy anulowaniu RO odbudowuje rezerwacje dla FPF jesli ma ona takze rezerwacje
        IF @TrnRodzaj/1000 = 308 AND (SELECT ISNULL(TrN_TrSTyp,0) FROM CDN.TraNag WHERE TrN_TrNId = @TrNFPF AND TrN_TypDokumentu = 320) = 3
         BEGIN
          UPDATE CDN.TraElem SET TrE_Aktywny = 1 WHERE TrE_Aktywny = 1 AND TrE_TrNId = @TrNFPF
         END
  IF @TrnRodzaj/1000 = 308 and exists(select ID from @FPzROTable)
         BEGIN
         if not exists (select ID from @FPzROTable join cdn.tranagrelacje on ID= trr_faid and trr_trntyp = 308)
          UPDATE CDN.TraNag SET TrN_Rodzaj=320000 WHERE TrN_TrNId in (select ID from @FPzROTable)
          UPDATE CDN.TraNag SET TrN_ZwroconoCalaIlosc = 0 WHERE TrN_TrNId in (select ID from @FPzROTable) and TrN_ZwroconoCalaIlosc = 5
         END
      -- wykasowanie subelementów kasowanego dokumentu i skojarzonej WZKK
  DELETE cdn.TraSElem
  FROM cdn.TraSElem  S
       JOIN cdn.TraElem E on  S.TrS_TrEId = E.TrE_TrEId
       JOIN cdn.TraNag N  on  N.TrN_TrNId = E.TrE_TrNId
  WHERE N.TrN_TrNId = @TrnID OR  N.TrN_TrNId IN
                                    (SELECT WZKK.TrN_TrNID FROM CDN.TraNag WZKK
                                          WHERE WZKK.TrN_ZwrID = @TrnID AND WZKK.TrN_Rodzaj
                                            IN (306061,306071,306072))
   -- anulowanie WZKK
  IF EXISTS ( SELECT * FROM CDN.TraNag join
  (select TrN_TrNID as TrNID, TrN_ZwrID as ZwrID from CDN.TraNag WHERE  TrN_ZwrIDWZKK = @TrnID AND TrN_Rodzaj IN (306061,306071,306072)) as A on TrN_ZwrId = A.ZwRID
  where TrN_TrNID >TrNID and TrN_Bufor <> -1 AND TrN_Rodzaj NOT IN (306061,306071,306072))
  begin
  SET @Err  = 'Nie można anulować dokumentu! Anulowany dokument jest powiązany z dokumentem WZKK (korekta kosztów) do którego istnieją późniejsze korekty. Anuluj późniejsze korekty.'
  GOTO KONIEC
  end
  UPDATE CDN.TraNag SET TrN_Bufor=-1, TrN_TS_Mod = GETDATE(), TrN_FaID=null, TrN_RelTrNId=null, TrN_ZwrID = NULL, TrN_ZwrIdWZKK = NULL WHERE  TrN_ZwrID = @TrnID AND TrN_Rodzaj IN (306061,306071,306072);
  -- kasuję powiązania WZKK
  DELETE CDN.TraNagRelacje WHERE TrR_TrNID IN
  (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrID = @TrnID AND TrN_Rodzaj IN (306061,306071,306072))
  DELETE CDN.TraNagRelacje WHERE TrR_FaID IN
  (SELECT TrN_TrNID FROM CDN.TraNag WHERE  TrN_ZwrID = @TrnID AND TrN_Rodzaj IN (306061,306071,306072))
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
END -- end PROCEDURE
