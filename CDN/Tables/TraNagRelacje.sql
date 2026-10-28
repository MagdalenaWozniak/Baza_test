CREATE TABLE [CDN].[TraNagRelacje] (
    [TrR_TrRId]  INT      IDENTITY (1, 1) NOT NULL,
    [TrR_TrNTyp] SMALLINT NOT NULL,
    [TrR_TrNId]  INT      NOT NULL,
    [TrR_FaTyp]  SMALLINT NOT NULL,
    [TrR_FaId]   INT      NOT NULL,
    [TrR_Flaga]  SMALLINT NULL,
    CONSTRAINT [TrR_Primary] PRIMARY KEY CLUSTERED ([TrR_TrRId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [KeyTraNagRelId]
    ON [CDN].[TraNagRelacje]([TrR_TrNId] ASC, [TrR_FaTyp] ASC, [TrR_Flaga] ASC)
    INCLUDE([TrR_TrRId]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TraNagRelTrNId]
    ON [CDN].[TraNagRelacje]([TrR_TrNId] ASC, [TrR_TrNTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TraNagRelFaId]
    ON [CDN].[TraNagRelacje]([TrR_FaId] ASC, [TrR_FaTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.TraNagRelacje_InsertUpdate_Trigger
  ON CDN.TraNagRelacje
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
SET ARITHABORT ON
 DECLARE
   @TrR_TrRId INT,
   @TrR_FaId INT,
   @TrR_TrNId INT,
   @TrR_TrNTyp INT,
   @TrR_FaTyp INT,
   @TrR_FaIdLocal INT,
   @TrR_TrNIdLocal INT,
   @TrR_TrNTypLocal INT,
   @TrR_FaTypLocal INT,
   @TrR_Flaga INT
create table #WZ (TrR_FaIdlocal int,TrR_FaTyplocal int)
  --IF EXISTS (SELECT TrR_FaTyp FROM inserted WHERE TrR_FaTyp IS NULL OR TrR_FaTyp = 0)
   BEGIN
    DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
     SELECT Trr_TrRId,Trr_FaId,Trr_FaTyp,Trr_TrNTyp, Trr_TrNId,TrR_Flaga  FROM inserted
      OPEN Dodawane
      WHILE 1=1
       BEGIN
        FETCH NEXT FROM Dodawane INTO @TrR_TrRId, @TrR_FaId, @TrR_FaTyp, @TrR_TrNTyp, @TrR_TrNId, @TrR_Flaga
        IF @@FETCH_STATUS <> 0 BREAK
        -- szukamy typu dokukumentu skojarzonego i updatujemy
         IF ISNULL(@TrR_FaTyp,0)=0
         BEGIN
         SELECT @TrR_FaTyp = TrN_TypDokumentu FROM CDN.TraNag WHERE TrN_TrNId = @TrR_FaId
         UPDATE R SET R.TrR_FaTyp = @TrR_FaTyp FROM CDN.TraNagRelacje R WHERE R.TrR_TrRId =  @TrR_TrRId
         END
        -- flaga 3 to FA do PA po przekształceniu zmieniamy na 0
         UPDATE  CDN.TraNagRelacje  SET TrR_Flaga = 0 WHERE TrR_Flaga =  3
         update cdn.tranag set trn_statusint = CDN.TrnStatusInt(@TrR_FaId ,@TrR_FaTyp ,@TrR_TrNId ,@TrR_TrNTyp, 1) where trn_trnid = @TrR_FaId
         update cdn.tranag set trn_statusint = CDN.TrnStatusInt(@TrR_TrNId ,@TrR_TrNTyp ,@TrR_FAId ,@TrR_FATyp, 1) where trn_trnid = @TrR_TrNId
         IF EXISTS (SELECT * from inserted) AND NOT EXISTS (Select * from deleted)
         BEGIN
          IF EXISTS  (
            SELECT * FROM cdn.TraNagRelacje WHERE TrR_TrNId = @TrR_TrNId AND TrR_TrNTyp = @TrR_TrNTyp
                                            AND TrR_FaId = @TrR_FaId AND TrR_FaTyp = @TrR_FaTyp
                                            AND TrR_TrRId <> @TrR_TrRId
                     )
           BEGIN
            -- aby nie duplikowac zapisow w CDN.TraNagRelacje kasujemy jesli taki zapis już istnieje
            DELETE FROM CDN.TraNagRelacje WHERE TrR_TrRId = @TrR_TrRId
           END
        ELSE
           BEGIN
            -- jeśli rekord nieistnieje to należy zrobić relację w drugą strone
            INSERT INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
            VALUES (@TrR_FaId, @TrR_FaTyp, @TrR_TrNId, @TrR_TrNTyp, @TrR_Flaga)
           END
         END
        -- tworzymy relacje dla dokumentow w scenariuszu WZ -> WKA -> WZFA, PZ -> PKA -> PZFZ --                                                                                   --
      /*  IF (@TrR_FaTyp IN (306,307) OR @TrR_TrNTyp IN (306,307))
         BEGIN
          IF EXISTS (
             SELECT TrR_TrRId FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrR_FaId
                                                     AND TrR_FaId <> @TrR_TrNId
                                                     AND TrR_FaTyp IN (313,314)
                     )
            BEGIN
             -- najpierw relacja w jedną stronę
             INSERT INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
             SELECT @TrR_TrNId, @TrR_TrNTyp, TrR_FaId, TrR_FaTyp, 0 FROM CDN.TraNagRelacje
                          WHERE TrR_TrNId = @TrR_FaId AND TrR_FaId <> @TrR_TrNId AND TrR_FaTyp IN (313,314)
             -- teraz relacja w drugą stronę
             INSERT INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
             SELECT TrR_FaId, TrR_FaTyp, @Trr_TrNId, @Trr_TrNTyp, 0 FROM CDN.TraNagRelacje
                          WHERE TrR_TrNId = @TrR_FaId AND TrR_FaId <> @TrR_TrNId AND TrR_FaTyp IN (313,314)
            END
       SO, wykomentowalem bo tworzylo za duzo relacji i nie bardzo wiem do czego mialo słuzyc
          IF EXISTS (
             SELECT TrR_TrRId FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrR_TrNId
                                                     AND TrR_FaId <> @TrR_FaId
                                                     AND TrR_FaTyp IN (313,314)
                    )
            BEGIN
             -- najpierw relacja w jedną stronę
             INSERT INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
             SELECT @TrR_FaId, @TrR_FaTyp, TrR_FaId, TrR_FaTyp, 0 FROM CDN.TraNagRelacje
                         WHERE TrR_TrNId = @TrR_TrNId AND TrR_FaId <> @TrR_FaId AND TrR_FaTyp IN (313,314)
              -- teraz relacja w drugą stronę
             INSERT INTO cdn.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
             SELECT TrR_FaId, TrR_FaTyp, @Trr_FaId, @Trr_FaTyp, 0 FROM CDN.TraNagRelacje
                         WHERE TrR_TrNId = @TrR_TrNId AND TrR_FaId <> @TrR_FaId AND TrR_FaTyp IN (313,314)
            END
          END
        -- tworzymy relacje dla dokumentow w scenariuszu FA -> WZ/WKA , FZ -> PZ/PKA  --
        -- spinamy ze sobą te dokumenty, także spinamy kiedy dogenerowujemy WK        --
         IF  (@TrR_FaTyp IN (313,314) OR @TrR_TrNTyp IN (313,314))
         BEGIN
          IF EXISTS (
                 SELECT TrR_TrRId FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrR_TrNId
                           AND TrR_FaId <> @TrR_FaId AND TrR_FaTyp in (306,307)
                           AND TrR_Flaga <> 1 --SO
                    )
           BEGIN
            -- najpierw relacja w jedną stronę
            INSERT INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
     SELECT @TrR_FaId, @TrR_FaTyp, TrR_FaId, TrR_FaTyp, 0 FROM CDN.TraNagRelacje
                         WHERE TrR_TrNId = @TrR_TrNId AND TrR_FaId <> @TrR_FaId AND TrR_FaTyp IN (306,307)
             -- teraz relacja w drugą stronę
            INSERT INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
            SELECT TrR_FaId, TrR_FaTyp, @Trr_FaId, @Trr_FaTyp, 0 FROM CDN.TraNagRelacje
                         WHERE TrR_TrNId = @TrR_TrNId AND TrR_FaId <> @TrR_FaId AND TrR_FaTyp IN (306,307)
           END
          IF EXISTS (
                 SELECT TrR_TrRId FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrR_FaId
                           AND TrR_FaId <> @TrR_TrNId AND TrR_FaTyp in (306,307)
                           AND TrR_Flaga <> 1 --SO
                    )
           BEGIN
            -- najpierw relacja w jedną stronę
            INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
            SELECT @TrR_TrNId, @TrR_TrNTyp, TrR_FaId, TrR_FaTyp, 0 FROM CDN.TraNagRelacje
                         WHERE TrR_TrNId = @TrR_FaId AND TrR_FaId <> @TrR_TrNId AND TrR_FaTyp IN (306,307)
             -- teraz relacja w drugą stronę
            INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
            SELECT TrR_FaId, TrR_FaTyp, @TrR_TrNId, @Trr_TrNTyp, 0 FROM CDN.TraNagRelacje
                         WHERE TrR_TrNId = @TrR_FaId AND TrR_FaId <> @TrR_TrNId AND TrR_FaTyp IN (306,307)
           END
          END*/
        -- tworzymy relacje dla dokumentow w scenariuszu FPF -> WZ -> FPFFA           --
        -- spinamy ze sobą te dokumenty, także spinamy kiedy dogenerowujemy WK        --
        --SO IF (@TrR_FaTyp = 320 OR @TrR_TrNTyp = 320)
            IF ((@TrR_FaTyp = 320 AND @Trr_TrNTyp not in (309,306) AND (SELECT TOP 1 1 FROM CDN.TraNag WHERE TrN_TRNId = @TrR_TrNId AND TrN_Rodzaj<>302200) = 1)
            OR (@TrR_TrNTyp = 320 AND @Trr_FaTyp not in (309,306) AND (SELECT TOP 1 1 FROM CDN.TraNag WHERE TrN_TRNId = @TrR_FaId AND TrN_Rodzaj<>302200) = 1))
          BEGIN
           IF EXISTS (
                  SELECT TrR_TrRId FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrR_FaId
                            AND TrR_FaId <> @TrR_TrNId AND TrR_FaTyp IN (306,307)
                      )
            BEGIN
             -- najpierw relacja w jedną stronę
             INSERT INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
             SELECT @TrR_TrNId, @TrR_TrNTyp, A.TrR_FaId, A.TrR_FaTyp, 0 FROM CDN.TraNagRelacje A
                          WHERE A.TrR_TrNId = @TrR_FaId AND A.TrR_FaId <> @TrR_TrNId AND A.TrR_FaTyp IN (306,307)
             AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B WHERE B.Trr_TrNId = @Trr_FaId ANd B.Trr_FaId = A.Trr_FaId
                               AND B.TrR_FaTyp = A.Trr_FaTyp)
             -- teraz relacja w drugą stronę
            INSERT INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
             SELECT A.TrR_FaId, A.TrR_FaTyp, @TrR_TrNId, @TrR_TrNTyp, 0 FROM CDN.TraNagRelacje A
                          WHERE A.TrR_TrNId = @TrR_FaId AND A.TrR_FaId <> @TrR_TrNId AND A.TrR_FaTyp IN (306,307)
             AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B WHERE B.Trr_TrNId = @Trr_FaId ANd B.Trr_FaId = A.Trr_FaId
                               AND B.TrR_FaTyp = A.Trr_FaTyp)
            END
            IF EXISTS (
                  SELECT TrR_TrRId FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrR_TrNId
                            AND TrR_FaId <> @TrR_FaId AND TrR_FaTyp IN (306,307)
                      )
            BEGIN
             -- najpierw relacja w jedną stronę
/*
            INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
             SELECT @TrR_FaId, @TrR_FaTyp , A.TrR_FaId, A.TrR_FaTyp, 0 FROM cdn.TraNagRelacje A
                          WHERE A.TrR_TrNId = @TrR_TrNId AND A.TrR_FaId <> @TrR_FaId AND A.TrR_FaTyp IN (306,307)
               AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B WHERE B.Trr_TrNId = @Trr_FaId ANd B.Trr_FaId = A.Trr_FaId
                               AND B.TrR_FaTyp = A.Trr_FaTyp)
             -- teraz relacja w drugą stronę
            INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
             SELECT A.TrR_FaId, A.TrR_FaTyp, @TrR_FaId , @TrR_FaTyp , 0 FROM CDN.TraNagRelacje A
                          WHERE A.TrR_TrNId = @TrR_TrNId AND A.TrR_FaId <> @TrR_FaId AND A.TrR_FaTyp IN (306,307)
                    AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B WHERE B.Trr_TrNId = @Trr_FaId ANd B.TrR_TrNId = A.TrR_FaId
                               AND B.TrR_TrNTyp = A.TrR_FaTyp)
*/
            delete from #WZ
            insert into #WZ(TrR_FaIdlocal,TrR_FaTyplocal)
            SELECT A.TrR_FaId, A.TrR_FaTyp FROM cdn.TraNagRelacje A
             WHERE A.TrR_TrNId = @TrR_TrNId AND A.TrR_FaId <> @TrR_FaId AND A.TrR_FaTyp IN (306,307)
               AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B WHERE B.Trr_TrNId = @Trr_FaId ANd B.Trr_FaId = A.Trr_FaId
                               AND B.TrR_FaTyp = A.Trr_FaTyp)
               AND NOT EXISTS (SELECT C.Trr_TrRId FROM CDN.TraNagRelacje C where A.TrR_FaId = C.TrR_TrNID AND  c.Trr_FaTyp = 302)
             INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
             SELECT @TrR_FaId, @TrR_FaTyp , TrR_FaIdlocal, TrR_FaTyplocal, 0 from #WZ
             INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
             SELECT TrR_FaIdlocal, TrR_FaTyplocal, @TrR_FaId , @TrR_FaTyp , 0 from #WZ
             update cdn.tranag set trn_statusint = trn_statusint+2 where trn_trnid in (select TrR_FaIdlocal from #WZ where TrR_FaTyplocal = 306) and  trn_rodzaj = 306010
    update WZKOR set WZKOR.trn_statusint = WZKOR.trn_statusint+2 from cdn.tranag WZKOR join cdn.tranag WZ ON WZKOR.TRN_ZwrID = WZ.TRN_TrNID where  WZ.trn_trnid in (select TrR_FaIdlocal from #WZ where TrR_FaTyplocal = 306) and WZKOR.trn_trnid in (select TrR_FaIdlocal from #WZ where TrR_FaTyplocal = 306) and  WZKOR.trn_rodzaj = 306001 and  WZ.trn_rodzaj = 306010
            END
          END
    /* RT wiele Pa do FA
         IF ((@TrR_FaTyp = 302 AND @Trr_TrNTyp = 306 AND (SELECT TOP 1 1 FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrR_FaId AND TrR_FaId <> @TrR_TrNId AND TrR_FaTyp =305) = 1)
         OR (@TrR_TrNTyp = 302 AND @Trr_FaTyp = 306 AND (SELECT TOP 1 1 FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrR_TrNId AND TrR_FaId <> @TrR_FaId AND TrR_TrNTyp =305) = 1))
          BEGIN
         IF EXISTS (
                  SELECT TrR_TrRId FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrR_FaId
                            AND TrR_FaId <> @TrR_TrNId AND TrR_FaTyp =305
                      )
            BEGIN
             -- najpierw relacja w jedną stronę
             INSERT INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
             SELECT @TrR_TrNId, @TrR_TrNTyp, A.TrR_FaId, A.TrR_FaTyp, 0 FROM CDN.TraNagRelacje A
                          WHERE A.TrR_TrNId = @TrR_FaId AND A.TrR_FaId <> @TrR_TrNId AND A.TrR_FaTyp = 305
             AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B WHERE B.Trr_TrNId = @TrR_TrNId ANd B.Trr_FaId = A.Trr_FaId)
             -- teraz relacja w drugą stronę
             INSERT INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
             SELECT A.TrR_FaId, A.TrR_FaTyp, @TrR_TrNId, @TrR_TrNTyp, 0 FROM CDN.TraNagRelacje A
                          WHERE A.TrR_TrNId = @TrR_FaId AND A.TrR_FaId <> @TrR_TrNId AND A.TrR_FaTyp = 305
             AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B WHERE B.Trr_FAId = @TrR_TrNId ANd B.Trr_TrNId = A.Trr_FaId)
            END
            IF EXISTS (
                  SELECT TrR_TrRId FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrR_TrNId
                            AND TrR_FaId <> @TrR_FaId AND TrR_TrNTyp = 305
                      )
            BEGIN
             -- najpierw relacja w jedną stronę
            INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
             SELECT @TrR_FaId, @TrR_FaTyp , A.TrR_FaId, A.TrR_FaTyp, 0 FROM cdn.TraNagRelacje A
                          WHERE A.TrR_TrNId = @TrR_TrNId AND A.TrR_FaId <> @TrR_FaId AND A.TrR_FaTyp = 305
               AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B WHERE B.Trr_TrNId = @TrR_FaId ANd B.Trr_FaId = A.Trr_FaId)
             -- teraz relacja w drugą stronę
            INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
             SELECT A.TrR_FaId, A.TrR_FaTyp, @TrR_FaId , @TrR_FaTyp , 0 FROM CDN.TraNagRelacje A
                          WHERE A.TrR_TrNId = @TrR_TrNId AND A.TrR_FaId <> @TrR_FaId AND A.TrR_FaTyp = 305
                    AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B WHERE B.Trr_FAId = @TrR_FaId ANd B.Trr_TrNId = A.Trr_FaId)
            END
          END
*/
         --korekta do zaliczkowej podpinamy relacje do RO
            IF (@TrR_FaTyp = 320 AND @Trr_TrNTyp = 302 AND (SELECT TOP 1 1 FROM CDN.TraNag WHERE TrN_TRNId = @TrR_TrNId AND TrN_Rodzaj=302202) = 1)
            BEGIN
            IF EXISTS (
                  SELECT TrR_TrRId FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrR_FaId
                            AND TrR_FaTyp =308
                      )
               BEGIN
               delete from #WZ
               insert into #WZ(TrR_FaIdlocal,TrR_FaTyplocal)
               SELECT A.TrR_FaId, A.TrR_FaTyp FROM cdn.TraNagRelacje A
               WHERE A.TrR_TrNId = @TrR_FaId AND  A.TrR_FaTyp = 308
               AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B WHERE B.Trr_TrNId = @Trr_TrNId ANd B.Trr_FaId = A.Trr_FaId
                               AND B.TrR_FaTyp = A.Trr_FaTyp)
               INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
               SELECT @TrR_TrNId, @TrR_TrNTyp , TrR_FaIdlocal, TrR_FaTyplocal, 1 from #WZ
               INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
               SELECT TrR_FaIdlocal, TrR_FaTyplocal, @TrR_TrNId , @TrR_TrNTyp , 1 from #WZ
               END
             END
            --korekta do zaliczkowej podpinamy relacje do RO
            IF (@TrR_TrNTyp = 320 AND @Trr_FaTyp = 302 AND (SELECT TOP 1 1 FROM CDN.TraNag WHERE TrN_TRNId = @TrR_FaId AND TrN_Rodzaj=302202) = 1)
            BEGIN
             IF EXISTS (
                  SELECT TrR_TrRId FROM CDN.TraNagRelacje WHERE TrR_TrNId = @TrR_TrNId
                            AND TrR_FaTyp =308
                      )
              BEGIN
               delete from #WZ
               insert into #WZ(TrR_FaIdlocal,TrR_FaTyplocal)
               SELECT A.TrR_FaId, A.TrR_FaTyp FROM cdn.TraNagRelacje A
               WHERE A.TrR_TrNId = @TrR_TrNId AND  A.TrR_FaTyp = 308
               AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B WHERE B.Trr_TrNId = @Trr_FaId ANd B.Trr_FaId = A.Trr_FaId
                               AND B.TrR_FaTyp = A.Trr_FaTyp)
               INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
               SELECT @TrR_FaId, @TrR_FaTyp , TrR_FaIdlocal, TrR_FaTyplocal, 1 from #WZ
               INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
               SELECT TrR_FaIdlocal, TrR_FaTyplocal, @TrR_FaId , @TrR_FaTyp , 1 from #WZ
               END
             END
            -- PF->ZL i teraz RO trzeba podpiąć do RO ZL
            IF @TrR_TrNTyp = 320 AND @Trr_FaTyp = 308
            BEGIN
             IF EXISTS (
                  SELECT TrR_TrRId FROM CDN.TraNagRelacje
                    join cdn.tranag on trn_trnid = trr_faid WHERE TrR_TrNId = @TrR_TrNId
                            AND TrR_FaTyp =302 and TrN_Rodzaj=302200
                      )
              BEGIN
               delete from #WZ
               insert into #WZ(TrR_FaIdlocal,TrR_FaTyplocal)
               SELECT A.TrR_FaId, A.TrR_FaTyp FROM cdn.TraNagRelacje A
               join cdn.tranag on trn_trnid = A.trr_faid
               WHERE A.TrR_TrNId = @TrR_TrNId AND  A.TrR_FaTyp = 302 and TrN_Rodzaj=302200
               AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B WHERE B.Trr_TrNId = @Trr_FaId ANd B.Trr_FaId = A.Trr_FaId
                               AND B.TrR_FaTyp = A.Trr_FaTyp)
               INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
               SELECT @TrR_FaId, @TrR_FaTyp , TrR_FaIdlocal, TrR_FaTyplocal, 1 from #WZ
               INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
               SELECT TrR_FaIdlocal, TrR_FaTyplocal, @TrR_FaId , @TrR_FaTyp , 1 from #WZ
               END
             END
            IF @TrR_FaTyp = 320 AND @Trr_TrNTyp = 308
            BEGIN
            IF EXISTS (
                  SELECT TrR_TrRId FROM CDN.TraNagRelacje
                    join cdn.tranag on trn_trnid = trr_faid WHERE TrR_TrNId = @TrR_FaId
                            AND TrR_FaTyp =302 and TrN_Rodzaj=302200
                      )
               BEGIN
               delete from #WZ
               insert into #WZ(TrR_FaIdlocal,TrR_FaTyplocal)
               SELECT A.TrR_FaId, A.TrR_FaTyp FROM cdn.TraNagRelacje A
               join cdn.tranag on trn_trnid = A.trr_faid
               WHERE A.TrR_TrNId = @TrR_FaId AND  A.TrR_FaTyp = 302 and TrN_Rodzaj=302200
               AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B WHERE B.Trr_TrNId = @Trr_TrNId ANd B.Trr_FaId = A.Trr_FaId
                               AND B.TrR_FaTyp = A.Trr_FaTyp)
               INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
               SELECT @TrR_TrNId, @TrR_TrNTyp , TrR_FaIdlocal, TrR_FaTyplocal, 1 from #WZ
               INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
               SELECT TrR_FaIdlocal, TrR_FaTyplocal, @TrR_TrNId , @TrR_TrNTyp , 1 from #WZ
               END
             END
         IF @TrR_FaTyp = 302 AND @Trr_TrNTyp = 320 and (SELECT TOP 1 1 FROM CDN.TraNag WHERE TrN_TrNId = @TrR_FaId AND TrN_Rodzaj not in (302202, 302200)) = 1
            BEGIN
            IF EXISTS (
                  SELECT TrR_TrRId FROM CDN.TraNagRelacje
                    join cdn.tranag on trn_trnid = trr_faid WHERE TrR_TrNId = @TrR_trnId
                            AND TrR_FaTyp =308
                      )
               BEGIN
               delete from #WZ
               insert into #WZ(TrR_FaIdlocal,TrR_FaTyplocal)
               SELECT A.TrR_FaId, A.TrR_FaTyp FROM cdn.TraNagRelacje A
               join cdn.tranag on trn_trnid = A.trr_faid
               WHERE A.TrR_TrNId = @TrR_TrNId AND  A.TrR_FaTyp = 308
               AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B WHERE B.Trr_TrNId = @Trr_FAId ANd B.Trr_FaId = A.Trr_FaId
                               AND B.TrR_FaTyp = A.Trr_FaTyp)
               INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
               SELECT @TrR_FAId, @TrR_FATyp , TrR_FaIdlocal, TrR_FaTyplocal, 0 from #WZ
               INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
               SELECT TrR_FaIdlocal, TrR_FaTyplocal, @TrR_FAId , @TrR_FATyp , 0 from #WZ
               END
             END
          IF @TrR_FaTyp = 320 AND @Trr_TrNTyp = 302 and (SELECT TOP 1 1 FROM CDN.TraNag WHERE TrN_TrNId = @TrR_TrNId AND TrN_Rodzaj not in (302202, 302200)) = 1
            BEGIN
            IF EXISTS (
                  SELECT TrR_TrRId FROM CDN.TraNagRelacje
                    join cdn.tranag on trn_trnid = trr_faid WHERE TrR_TrNId = @TrR_FAId
                            AND TrR_FaTyp =308
                      )
               BEGIN
               delete from #WZ
               insert into #WZ(TrR_FaIdlocal,TrR_FaTyplocal)
               SELECT A.TrR_FaId, A.TrR_FaTyp FROM cdn.TraNagRelacje A
               join cdn.tranag on trn_trnid = A.trr_faid
               WHERE A.TrR_TrNId = @TrR_FAId AND  A.TrR_FaTyp = 308
               AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B WHERE B.Trr_TrNId = @Trr_TRNId ANd B.Trr_FaId = A.Trr_FaId
                               AND B.TrR_FaTyp = A.Trr_FaTyp)
               INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
               SELECT @TrR_TRNId, @TrR_TrNTyp , TrR_FaIdlocal, TrR_FaTyplocal, 0 from #WZ
               INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
               SELECT TrR_FaIdlocal, TrR_FaTyplocal, @TrR_TrNId , @TrR_TrNTyp , 0 from #WZ
               END
             END
    IF @TrR_FaTyp = 301 AND @Trr_TrNTyp = 350
            BEGIN
            IF EXISTS (
                  SELECT trn_trnid FROM CDN.TraNag
                    WHERE TrN_ZwrId = @TrR_TrNId
                        )
               BEGIN
               delete from #WZ
               insert into #WZ(TrR_FaIdlocal,TrR_FaTyplocal)
               SELECT TrN_TrNId, TrN_Typdokumentu FROM cdn.TraNag
               WHERE TrN_ZwrId = @TrR_TrNId and TrN_Bufor != -1
               AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B WHERE B.Trr_TrNId = @Trr_FAId ANd B.Trr_TrNId = TrN_TrNId
                               AND B.TrR_TrNTyp = TrN_Typdokumentu)
               INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
               SELECT @TrR_FAId, @TrR_FaTyp , TrR_FaIdlocal, TrR_FaTyplocal, 0 from #WZ
               INSERT  INTO CDN.TraNagRelacje(TrR_TrNId, TrR_TrNTyp, TrR_FaId, TrR_FaTyp, TrR_Flaga)
               SELECT TrR_FaIdlocal, TrR_FaTyplocal, @TrR_FaId , @TrR_FaTyp , 0 from #WZ
               END
             END
       END
      CLOSE Dodawane
     DEALLOCATE Dodawane
   END
SET NOCOUNT OFF

GO
CREATE TRIGGER [CDN].[TraNagRelacje_Delete_Trigger]
  ON [CDN].[TraNagRelacje]
  FOR DELETE
AS
SET NOCOUNT ON
SET ARITHABORT ON
/* DECLARE
   @TrR_TrRId INT,
   @TrR_FaId INT,
   @TrR_TrNId INT,
   @TrR_TrNTyp INT,
   @TrR_FaTyp INT,
   @TrR_Flaga INT*/
  --IF EXISTS (SELECT TrR_FaTyp FROM inserted WHERE TrR_FaTyp IS NULL OR TrR_FaTyp = 0)
   BEGIN
/*    DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
     SELECT Trr_TrRId,Trr_FaId,Trr_FaTyp,Trr_TrNTyp, Trr_TrNId,TrR_Flaga  FROM deleted
      OPEN Dodawane
      WHILE 1=1
       BEGIN
        FETCH NEXT FROM Dodawane INTO @TrR_TrRId, @TrR_FaId, @TrR_FaTyp, @TrR_TrNTyp, @TrR_TrNId, @TrR_Flaga
        IF @@FETCH_STATUS <> 0 BREAK
  */
         update t set trn_statusint = CDN.TrnStatusInt(d.TrR_FaId ,d.TrR_FaTyp ,d.TrR_TrNId ,d.TrR_TrNTyp, 0)
from cdn.tranag t
join deleted d on t.trn_trnid = d.TrR_FaId
         update cdn.tranag set trn_statusint = CDN.TrnStatusInt(d.TrR_TrNId ,d.TrR_TrNTyp ,d.TrR_FAId ,d.TrR_FATyp, 0)
from cdn.tranag t
join deleted d on t.trn_trnid = d.TrR_TrNId
 /*      END
      CLOSE Dodawane
     DEALLOCATE Dodawane*/
   END
SET NOCOUNT OFF
