-- @Typ: 1 = kalendarz, 2 = plan pracy, 3 = czas pracy lub zestawienie, 4 = czas pracy i zestawienie, 5 = podsumowanie
CREATE PROCEDURE CDN.PracCzasPracyExport @Typ        SMALLINT,
                                         @Id         INT,
                                         @DataOd     DATETIME,
                                         @DataDo     DATETIME,
                                         @TylkoWypel INT,
                                         @Umowa      INT      = 1
-- 1 = kalendarz, 2 = plan pracy, 3 = czas pracy lub zestawienie, 4 = czas pracy i zestawienie, 5 = podsumowanie
AS
     SET NOCOUNT ON;
     IF @DataOd IS NULL
         SET @DataOd = GETDATE();
     IF @DataDo IS NULL
        OR @DataDo < @DataOd
         SET @DataDo = @DataOd;
     DECLARE @Lp INT;
     DECLARE @GodzDo DATETIME;
     DECLARE @GodzOd_N DATETIME;
     DECLARE @GodzDo_N DATETIME;
     DECLARE @Data DATETIME;
     DECLARE @Zestaw TINYINT;
     DECLARE @Wymiar REAL;
     DECLARE @UndefId NVARCHAR(50);
     DECLARE @datemin DATETIME;
     SELECT @UndefId = DefinicjeStref.DST_Akronim
     FROM CDN.DefinicjeStref
     WHERE DefinicjeStref.DST_Standardowy = 99;
     SET @datemin = CONVERT(DATETIME, '1899.12.30', 102);
     CREATE TABLE #CzasPracy
     (Typ           SMALLINT DEFAULT 2,
      Data          DATETIME,
      TypDnia       INT DEFAULT 1,
   RodzajDniaWol nvarchar(2) default '',
      Nieobec       INT DEFAULT NULL,
      TypNieob      INT DEFAULT NULL,
      Lp            INT,
      GodzOd DATETIME DEFAULT CONVERT(DATETIME, '1899.12.30', 102),
      GodzDo DATETIME DEFAULT CONVERT(DATETIME, '1899.12.30', 102),
      Strefa        NVARCHAR(50),
      Dzial         NVARCHAR(50) DEFAULT 'brak',
      Dzial_wezel   NVARCHAR(512) DEFAULT '0',
      Projekt       NVARCHAR(50) DEFAULT 'brak',
      Projekt_wezel NVARCHAR(512) DEFAULT CHAR(32) + CHAR(32) + '1',
      Norma         INT DEFAULT 0,
      Praca         INT DEFAULT 0,
      Zestaw        TINYINT,
      OdbNadg       TINYINT DEFAULT 1
     );
     INSERT INTO #CzasPracy
            SELECT 3,
                   PPL_Data,
                   PPL_TypDnia,
     (
     SELECT OpisyDniWolne.ODW_Symbol
     FROM cdn.OpisyDniWolne
     WHERE OpisyDniWolne.ODW_OdwId = pracplandni.PPL_OdwId
     ),
                   NULL,
                   NULL,
                   PGL_Lp,
                   PGL_OdGodziny,
                   PGL_DoGodziny,
            (
                SELECT DefinicjeStref.Dst_Akronim
                FROM CDN.DefinicjeStref
                WHERE DefinicjeStref.Dst_DstId = pracplandnigodz.PGL_Strefa
            ),
            (
                SELECT Dzialy.Dzl_Kod
                FROM CDN.Dzialy
                WHERE Dzialy.Dzl_DzlId = pracplandnigodz.PGL_DzlId
            ),
            (
                SELECT Dzialy.Dzl_AdresWezla
                FROM CDN.Dzialy
                WHERE Dzialy.Dzl_DzlId = pracplandnigodz.PGL_DzlId
            ),
            (
                SELECT DefProjekty.Prj_Kod
                FROM CDN.DefProjekty
                WHERE DefProjekty.Prj_PrjId = pracplandnigodz.PGL_PrjId
            ),
            (
                SELECT DefProjekty.Prj_Wezel
                FROM CDN.DefProjekty
                WHERE DefProjekty.Prj_PrjId = pracplandnigodz.PGL_PrjId
            ),
                   0,
                   0,
            (
                SELECT PracEtaty.PRE_ZestCzasuPracy
                FROM CDN.PracEtaty
                WHERE PracEtaty.PRE_PraId = @Id
                      AND PracPlanDni.PPL_Data BETWEEN PracEtaty.PRE_DataOd AND PracEtaty.PRE_DataDo
            ) AS ZestCzasuPracy,
                   1
            FROM CDN.PracPlanDni
                 JOIN CDN.pracplandnigodz ON PracPlanDni.ppl_pplid = pracplandnigodz.pgl_pplid
            WHERE PracPlanDni.PPL_PraId = @Id
                  AND PracPlanDni.PPL_Data BETWEEN @DataOd AND @DataDo;
    BEGIN
        INSERT INTO #CzasPracy
               SELECT 2,
                      KAD_Data,
                      KAD_TypDnia,
       (
     SELECT OpisyDniWolne.ODW_Symbol
     FROM cdn.OpisyDniWolne
     WHERE OpisyDniWolne.ODW_OdwId = KalendDni.KAD_OdwId
     ),
                      NULL,
                      NULL,
                      KDG_Lp,
                      KDG_OdGodziny,
                      CASE
                          WHEN @Typ = 1
                               OR KDG_DoGodziny = KDG_OdGodziny
                               OR
               (
                   SELECT Kalendarze.KAL_UwzglWymiarEtatu
                   FROM CDN.Kalendarze,
                        CDN.PracEtaty
                   WHERE Kalendarze.KAL_KalId = PracEtaty.PRE_KalId
                         AND PracEtaty.PRE_PraId = @Id
                         AND KalendDni.KAD_Data BETWEEN PracEtaty.PRE_DataOd AND PracEtaty.PRE_DataDo
               ) = 0
                          THEN KDG_DoGodziny
                          ELSE DATEADD(minute, CONVERT(INT, CEILING(((CASE
                                                                          WHEN KDG_DoGodziny <= KDG_OdGodziny
                                                                          THEN 1440
                                                                          ELSE 0
                                                                      END) + DATEDIFF(minute, KDG_OdGodziny, KDG_DoGodziny)))) % 1440, KDG_OdGodziny)
                      END,
               (
                   SELECT DefinicjeStref.Dst_Akronim
                   FROM CDN.DefinicjeStref
                   WHERE DefinicjeStref.Dst_DstId = kalenddnigodz.KDG_Strefa
               ),
                      'brak',
                      '0',
                      'brak',
                      CHAR(32) + CHAR(32) + '1',
                      0,
                      0,
                      CASE @Typ
                          WHEN 1
                          THEN 0
                          ELSE
               (
                   SELECT PracEtaty.PRE_ZestCzasuPracy
                   FROM CDN.PracEtaty
                   WHERE PracEtaty.PRE_PraId = @Id
                         AND KalendDni.KAD_Data BETWEEN PracEtaty.PRE_DataOd AND PracEtaty.PRE_DataDo
               )
                      END AS Zestaw,
                      1
               FROM CDN.KalendDni
                    JOIN CDN.kalenddnigodz ON KalendDni.kad_kadid = kalenddnigodz.kdg_kadid
               WHERE KalendDni.KAD_Data BETWEEN @DataOd AND @DataDo
                     AND KalendDni.KAD_Data NOT IN
               (
                   SELECT #CzasPracy.Data
                   FROM #CzasPracy
               )
                     AND KalendDni.KAD_KalID = (CASE @Typ
                                                    WHEN 1
                                                    THEN @Id
                                                    ELSE
               (
                   SELECT PracEtaty.PRE_KalId
                   FROM CDN.PracEtaty
                   WHERE PracEtaty.PRE_PraId = @Id
                         AND KalendDni.KAD_Data BETWEEN PracEtaty.PRE_DataOd AND PracEtaty.PRE_DataDo
               )
                                                END);
    END;
    BEGIN
        BEGIN
            SET DATEFIRST 7;
            DECLARE @PRE_Data DATETIME;
            DECLARE @PodstId NVARCHAR(50);
   declare @RodzajDniaWol nvarchar(2);
            SELECT @PodstId = DefinicjeStref.DST_Akronim
            FROM CDN.DefinicjeStref
            WHERE DefinicjeStref.DST_Standardowy = 1;
            SET @PRE_Data = 0;
   set @RodzajDniaWol = '';
            SET @Zestaw = 0;
            SET @Wymiar = 1;
            SET @GodzDo = DATEADD(hour, 15, CONVERT(DATETIME, '1899.12.30', 102));
            SET @Data = @DataOd;
            WHILE @Data <= @DataDo
                BEGIN
                    IF @Typ > 1
                       AND @PRE_Data < @Data
                        BEGIN
                            SELECT @Zestaw = PRE_ZestCzasuPracy,
                                   @Wymiar = CONVERT(REAL, PRE_ETAEtatL) / (CASE PRE_ETAEtatM
                                                                                WHEN 0
                                                                                THEN 1
                                                                                ELSE PRE_ETAEtatM
                                                                            END),
                                   @PRE_Data = PRE_DataDo
                            FROM CDN.PracEtaty
                            WHERE PracEtaty.PRE_PraId = @Id
                                  AND @Data BETWEEN PracEtaty.PRE_DataOd AND PracEtaty.PRE_DataDo;
                    END;
                    IF NOT EXISTS
                    (
                        SELECT #CzasPracy.Data
                        FROM #CzasPracy
                        WHERE #CzasPracy.Data = @Data
                    )
                        BEGIN
                            IF DATEPART(weekday, @Data) BETWEEN 2 AND 6
                                INSERT INTO #CzasPracy
                                (Data,
                                 Lp,
                                 GodzOd,
                                 GodzDo,
                                 Strefa,
                                 Zestaw
                                )
                                VALUES
                                (@Data,
                                 1,
                                 DATEADD(hour, 7, CONVERT(DATETIME, '1899.12.30', 102)),
                                 @GodzDo,
                                 @PodstId,
                                 @Zestaw
                                );
                                ELSE
                                INSERT INTO #CzasPracy
                                (Data,
                                 Lp,
                                 TypDnia,
         RodzajDniaWol,
                                 Strefa,
                                 Zestaw
                                )
                                VALUES
                                (@Data,
                                 1,
                                 CASE DATEPART(weekday, @Data)
                                     WHEN 1
                                     THEN 3
                                     ELSE 2
                                 END,
         @RodzajDniaWol,
                                 @UndefId,
                                 @Zestaw
                                );
                    END;
                    SET @Data = DATEADD(day, 1, @Data);
                END;
        END;
    END;
     DECLARE @roznica INT;
     DECLARE @godzinyNb INT;
     DECLARE @strefa NVARCHAR(50);
     DECLARE @ZatrudOd DATETIME;
     DECLARE @ZatrudDo DATETIME;
     DECLARE @UwzglEtat INT;
     SET @Data = @DataOd;
     WHILE @Data <= @DataDo
         BEGIN
             IF EXISTS
             (
                 SELECT 1
                 FROM #CzasPracy
                 WHERE #CzasPracy.Data = @Data
                       AND #CzasPracy.Typ < 3
             )
                 BEGIN
                     SELECT @ZatrudOd = Pre_ZatrudnionyOd,
                            @ZatrudDo = Pre_ZatrudnionyDo,
                            @UwzglEtat = Kal_UwzglWymiarEtatu,
                            @Zestaw = PRE_ZestCzasuPracy,
                            @Wymiar = CONVERT(FLOAT, PRE_ETAEtatL) / (CASE PRE_ETAEtatM
                                                                          WHEN 0
                                                                          THEN 1
                                                                          ELSE PRE_ETAEtatM
                                                                      END),
                            @PRE_Data = PRE_DataDo
                     FROM CDN.pracetaty
                          JOIN CDN.kalendarze ON kalendarze.Kal_KalId = pracetaty.Pre_KalID
                     WHERE pracetaty.Pre_PraId = @Id
                           AND @Data BETWEEN pracetaty.Pre_DataOd AND pracetaty.Pre_DataDo;
                     IF @Umowa = 1
                         BEGIN
                             SELECT @ZatrudOd = UMW_DataOd,
                                    @ZatrudDo = UMW_DataDo
                             FROM CDN.Umowy
                             WHERE UMW_PraId = @Id
                                   AND UMW_DataOd <= @DataDo
                                   AND (UMW_DataDo IS NULL
                                        OR UMW_DataDo >= @DataOd);
                     END;
                     DECLARE c CURSOR LOCAL FORWARD_ONLY
                     FOR SELECT #CzasPracy.Lp,
                                #CzasPracy.GodzOd,
                                #CzasPracy.GodzDo,
                                #CzasPracy.Strefa
                         FROM #CzasPracy
                         WHERE #CzasPracy.Data = @Data
                         -- [JK] TFS:152077
                         ORDER BY #CzasPracy.Lp DESC;
                     OPEN c;
                     FETCH NEXT FROM c INTO @Lp, @GodzOd_N, @GodzDo_N, @Strefa;
                     WHILE @@FETCH_STATUS = 0
                         BEGIN
                             IF @UwzglEtat = 1
                                AND @Data >= @ZatrudOd
                                AND @Data <= @ZatrudDo
                                 BEGIN
                                     IF @Strefa <> 'undefined'
                                         BEGIN
                                             SET @roznica = CEILING(DATEDIFF(minute, @GodzOd_N, @GodzDo_N) * @Wymiar);
                                             SET @GodzDo_N = DATEADD(minute, @roznica, @GodzOd_N);
                                     END;
                                     UPDATE #CzasPracy
                                       SET
                                           #CzasPracy.GodzOd = @GodzOd_N,
                                           #CzasPracy.GodzDo = @GodzDo_N
                                     WHERE #CzasPracy.Data = @Data
                                           AND #CzasPracy.Lp = @Lp;
                             END;
                                 ELSE
                                 IF @UwzglEtat = 1
                                    AND @Typ = 3
                                    AND (@Data < @ZatrudOd
                                         OR @Data > @ZatrudDo
                                         OR @ZatrudOd IS NULL)
                                     BEGIN
                                         UPDATE #CzasPracy
                                           SET
                                               #CzasPracy.GodzOd = @datemin,
                                               #CzasPracy.GodzDo = @datemin
                                         WHERE #CzasPracy.Data = @Data
                                               AND #CzasPracy.Lp = @Lp;
                                 END;
                             FETCH NEXT FROM c INTO @Lp, @GodzOd_N, @GodzDo_N, @Strefa;
             END;
                     CLOSE c;
                     DEALLOCATE c;
             END;
             IF EXISTS
             (
                 SELECT 1
                 FROM #CzasPracy
                 WHERE #CzasPracy.Data = @Data
                       AND #CzasPracy.Typ < 4
                       AND @Typ = 3
             )
                 BEGIN
                     SELECT @godzinyNb = SUM(DATEDIFF(minute, @datemin, PracNieobec.PNB_Godz))
                     FROM CDN.PracNieobec
                     WHERE PracNieobec.PNB_PraId = @Id
                           AND @Data BETWEEN PracNieobec.PNB_OkresOd AND PracNieobec.PNB_OkresDo
                           AND PracNieobec.Pnb_Tryb <> 1
                           AND PracNieobec.PnB_Calodzienna = 0;
                     DECLARE c CURSOR LOCAL FORWARD_ONLY
                     FOR SELECT #CzasPracy.Lp,
                                #CzasPracy.GodzOd,
                                #CzasPracy.GodzDo,
                                #CzasPracy.Strefa
                         FROM #CzasPracy
                         WHERE #CzasPracy.Data = @Data
                         -- [JK] TFS:152077
                         ORDER BY #CzasPracy.Lp DESC;
                     OPEN c;
                     FETCH NEXT FROM c INTO @Lp, @GodzOd_N, @GodzDo_N, @Strefa;
                     WHILE @@FETCH_STATUS = 0
                         BEGIN
                             IF @strefa <> 'undefined'
                                AND @godzinyNb <> 0
                                AND EXISTS
                             (
                                 SELECT 1
                                 FROM CDN.DefinicjeStref
                                 WHERE DefinicjeStref.DST_Akronim = @strefa
                                       AND DefinicjeStref.DST_UwzglCzasPracy = 1
                             )
                                 BEGIN
                                     IF @GodzDo_N >= @GodzOd_N
                                         SET @roznica = DATEDIFF(minute, @GodzOd_N, @GodzDo_N);
                                         ELSE
                                         SET @roznica = (DATEDIFF(minute, @GodzOd_N, @GodzDo_N) + 1440) % 1440;
                                     IF @godzinyNb > @roznica
                                         BEGIN
                                             SET @GodzOd_N = @datemin;
                                             SET @GodzDo_N = @datemin;
                                             SET @godzinyNb = @godzinyNb - @roznica;
                                     END;
                                         ELSE
                                         BEGIN
                                             SET @GodzDo_N = DATEADD(minute, @roznica - @godzinyNb, @GodzOd_N);
                                             SET @GodzDo_N = DATEADD(minute, DATEPART(minute, @GodzDo_N) + 60 * DATEPART(hour, @GodzDo_N), CONVERT(DATETIME, '1899.12.30', 102));
                                             SET @godzinyNb = 0;
                                             --BREAK
                                     END;
                             END;
                             UPDATE #CzasPracy
                               SET
                                   #CzasPracy.GodzOd = @GodzOd_N,
                                   #CzasPracy.GodzDo = @GodzDo_N
                             WHERE #CzasPracy.Data = @Data
                                   AND #CzasPracy.Lp = @Lp;
                             --PK!17! Dni , w ktorych suma niebecności częsciowych jest równa normie traktujemy jak nieobecność całodzienną
                             UPDATE #CzasPracy
                               SET
                                   #CzasPracy.Typ = 5,
                                   #CzasPracy.Nieobec = PracNieobec.PNB_PnbId
                             FROM #CzasPracy
                                  JOIN CDN.PracNieobec ON PracNieobec.PNB_PraId = @Id
                                  JOIN CDN.TypNieobec ON TypNieobec.TNB_TnbId = PracNieobec.PnB_TnBId
                                                         AND #CzasPracy.Data BETWEEN PracNieobec.PNB_OkresOd AND PracNieobec.PNB_OkresDo
                                                         AND PracNieobec.Pnb_Tryb <> 1
                                                         AND PracNieobec.PnB_Calodzienna = 0
                             WHERE #CzasPracy.Data = @Data
                                   AND #CzasPracy.Lp = @Lp
                                   AND #CzasPracy.GodzOd = #CzasPracy.GodzDo
                                   AND TypNieobec.TNB_PomnCzasPracy = 1;
                             FETCH NEXT FROM c INTO @Lp, @GodzOd_N, @GodzDo_N, @Strefa;
             END;
                     CLOSE c;
                     DEALLOCATE c;
             END;
             SET @Data = DATEADD(day, 1, @Data);
         END;
     IF @Typ = 3
         BEGIN
             DELETE #CzasPracy
             WHERE EXISTS
             (
                 SELECT PracPracaDni.PPR_Data
                 FROM CDN.PracPracaDni
                 WHERE PracPracaDni.PPR_PraId = @Id
                       AND PracPracaDni.PPR_Data = #CzasPracy.Data
             );
             INSERT INTO #CzasPracy
                    SELECT 3,
                           PPR_Data,
                    (
                        SELECT CASE
                                   WHEN EXISTS
                        (
                            SELECT PracPlanDni.PPL_TypDnia
                            FROM CDN.PracPlanDni
                            WHERE PracPlanDni.PPL_PraId = @Id
                                  AND PracPlanDni.PPL_Data = PracPracaDni.PPR_Data
                        )
                                   THEN
                        (
                            SELECT PracPlanDni.PPL_TypDnia
                            FROM CDN.PracPlanDni
                            WHERE PracPlanDni.PPL_PraId = @Id
                                  AND PracPlanDni.PPL_Data = PracPracaDni.PPR_Data
                        )
                                   ELSE CASE
                                            WHEN EXISTS
                        (
                            SELECT KalendDni.KAD_TypDnia
                            FROM CDN.KalendDni
                            WHERE KalendDni.KAD_KalID = (CASE @Typ
                                                             WHEN 1
                                                             THEN @Id
                                                             ELSE
                            (
                                SELECT PracEtaty.PRE_KalId
                                FROM CDN.PracEtaty
                                WHERE PracEtaty.PRE_PraId = @Id
                                      AND KalendDni.KAD_Data BETWEEN PracEtaty.PRE_DataOd AND PracEtaty.PRE_DataDo
                            )
                                                         END)
                                  AND KalendDni.KAD_Data = PracPracaDni.PPR_Data
                        )
                                            THEN
                        (
                            SELECT KalendDni.KAD_TypDnia
                            FROM CDN.KalendDni
                            WHERE KalendDni.KAD_KalID = (CASE @Typ
                                                             WHEN 1
                                                             THEN @Id
                                                             ELSE
                            (
                                SELECT PracEtaty.PRE_KalId
                                FROM CDN.PracEtaty
                                WHERE PracEtaty.PRE_PraId = @Id
                                      AND KalendDni.KAD_Data BETWEEN PracEtaty.PRE_DataOd AND PracEtaty.PRE_DataDo
                            )
                                                         END)
                                  AND KalendDni.KAD_Data = PracPracaDni.PPR_Data
                        )
                                            ELSE 1
                                        END
                               END
                    ),
     (
                        SELECT CASE WHEN EXISTS
                        (SELECT OpisyDniWolne.ODW_Symbol FROM CDN.PracPlanDni join cdn.OpisyDniWolne on PPL_OdwId = ODW_OdwId WHERE PracPlanDni.PPL_PraId = @Id AND PracPlanDni.PPL_Data = PracPracaDni.PPR_Data)
      THEN
                        (
                            SELECT OpisyDniWolne.ODW_Symbol FROM CDN.PracPlanDni join cdn.OpisyDniWolne on PPL_OdwId = ODW_OdwId WHERE PracPlanDni.PPL_PraId = @Id AND PracPlanDni.PPL_Data = PracPracaDni.PPR_Data
                        )
      ELSE
       CASE WHEN EXISTS
       (
        SELECT OpisyDniWolne.ODW_Symbol
        FROM CDN.KalendDni join cdn.OpisyDniWolne on KAD_OdwId = ODW_OdwId
        WHERE KalendDni.KAD_KalID = (CASE @Typ WHEN 1 THEN @Id ELSE
        (SELECT PracEtaty.PRE_KalId FROM CDN.PracEtaty WHERE PracEtaty.PRE_PraId = @Id AND KalendDni.KAD_Data BETWEEN PracEtaty.PRE_DataOd AND PracEtaty.PRE_DataDo) END) AND KalendDni.KAD_Data = PracPracaDni.PPR_Data)
       THEN
       (
        SELECT OpisyDniWolne.ODW_Symbol
        FROM CDN.KalendDni join cdn.OpisyDniWolne on KAD_OdwId = ODW_OdwId
        WHERE KalendDni.KAD_KalID = (CASE @Typ WHEN 1 THEN @Id ELSE
        (SELECT PracEtaty.PRE_KalId FROM CDN.PracEtaty WHERE PracEtaty.PRE_PraId = @Id AND KalendDni.KAD_Data BETWEEN PracEtaty.PRE_DataOd AND PracEtaty.PRE_DataDo) END) AND KalendDni.KAD_Data = PracPracaDni.PPR_Data
       ) ELSE ''
                          END
                    END
                    ),
                           NULL,
                           NULL,
                           PGR_Lp,
                           PGR_OdGodziny,
                           PGR_DoGodziny,
                    (
                        SELECT DefinicjeStref.Dst_Akronim
                        FROM CDN.DefinicjeStref
                        WHERE DefinicjeStref.Dst_DstId = PracPracaDniGodz.PGR_Strefa
                    ),
                    (
                        SELECT Dzialy.Dzl_Kod
                        FROM CDN.Dzialy
                        WHERE Dzialy.Dzl_DzlId = PracPracaDniGodz.PGR_DzlId
                    ),
                    (
                        SELECT Dzialy.Dzl_AdresWezla
                        FROM CDN.Dzialy
                        WHERE Dzialy.Dzl_DzlId = PracPracaDniGodz.PGR_DzlId
                    ),
                    (
                        SELECT DefProjekty.Prj_Kod
                        FROM CDN.DefProjekty
                        WHERE DefProjekty.Prj_PrjId = PracPracaDniGodz.PGR_PrjId
                    ),
                    (
                        SELECT DefProjekty.Prj_Wezel
                        FROM CDN.DefProjekty
                        WHERE DefProjekty.Prj_PrjId = PracPracaDniGodz.PGR_PrjId
                    ),
                           0,
                           0,
                    (
                        SELECT PracEtaty.PRE_ZestCzasuPracy
                        FROM CDN.PracEtaty
                        WHERE PracEtaty.PRE_PraId = @Id
                              AND PracPracaDni.PPR_Data BETWEEN PracEtaty.PRE_DataOd AND PracEtaty.PRE_DataDo
                    ) AS ZestCzasuPracy,
                           PGR_OdbNadg
                    FROM CDN.PracPracaDni
                         JOIN CDN.PracPracaDniGodz ON PracPracaDni.PPR_PprId = PracPracaDniGodz.PGR_PprId
                    WHERE PracPracaDni.PPR_PraId = @Id
                          AND PracPracaDni.PPR_Data BETWEEN @DataOd AND @DataDo;
             UPDATE #CzasPracy
               SET
                   #CzasPracy.Typ = 5,
                   #CzasPracy.Nieobec = PracNieobec.PNB_PnbId,
                   #CzasPracy.TypNieob = PracNieobec.PNB_TnbId
             FROM #CzasPracy
                  JOIN CDN.PracNieobec ON PracNieobec.PNB_PraId = @Id
                                          AND #CzasPracy.Data BETWEEN PracNieobec.PNB_OkresOd AND PracNieobec.PNB_OkresDo
                                          AND PracNieobec.Pnb_Tryb <> 1
                                          AND PracNieobec.PnB_Calodzienna = 1;
             UPDATE #CzasPracy
               SET
                   #CzasPracy.GodzOd = @datemin,
                   #CzasPracy.GodzDo = @datemin
             FROM #CzasPracy
                  JOIN CDN.TypNieobec ON TypNieobec.TNB_TnbId = #CzasPracy.TypNieob
             WHERE TypNieobec.TNB_PomnCzasPracy = 1;
             UPDATE #CzasPracy
               SET
                   #CzasPracy.Typ = 3,
                   #CzasPracy.Nieobec = 0,
                   #CzasPracy.TypNieob = PracNieobec.PNB_TnbId
             FROM #CzasPracy
                  JOIN CDN.PracNieobec ON PracNieobec.PNB_PraId = @Id
                                          AND #CzasPracy.Data BETWEEN PracNieobec.PNB_OkresOd AND PracNieobec.PNB_OkresDo
                                          AND PracNieobec.Pnb_Tryb <> 1
                                          AND PracNieobec.PnB_Calodzienna = 0
                                          AND #CzasPracy.Typ <> 5;
             UPDATE #CzasPracy
               SET
                   #CzasPracy.Strefa = 'brak'
             WHERE #CzasPracy.Nieobec <> 0;
     END;
     UPDATE #CzasPracy
       SET
           #CzasPracy.Strefa = 'brak'
     WHERE #CzasPracy.Strefa = 'undefined';
     IF @Zestaw = 0
        AND @Typ = 3
        AND @TylkoWypel = 1
         DELETE FROM #CzasPracy
         WHERE #CzasPracy.Strefa = 'brak'
               OR #CzasPracy.Typ = 5;
     IF @Zestaw = 1
        AND @Typ = 3
        AND @TylkoWypel = 1
         BEGIN
             DELETE FROM #CzasPracy
             WHERE #CzasPracy.Typ <> 4;
     END;
         ELSE
         IF @Zestaw = 1
            AND @Typ = 3
            AND @TylkoWypel = 0
             BEGIN
                 UPDATE #CzasPracy
                   SET
                       #CzasPracy.GodzOd = @datemin,
                       #CzasPracy.GodzDo = @datemin,
                       #CzasPracy.Strefa = 'brak',
                       #CzasPracy.Dzial = 'brak',
                       #CzasPracy.Dzial_wezel = 0,
                       #CzasPracy.Projekt = 'brak',
                       #CzasPracy.projekt_wezel = CHAR(32) + CHAR(32) + '1',
                       #CzasPracy.OdbNadg = ''
                 WHERE #CzasPracy.Typ <> 3;
         END;
     SELECT Typ,
            Data,
            TypDnia,
   RodzajDniaWol,
            GodzOd,
            GodzDo,
            Strefa,
            Dzial,
            Dzial_wezel,
            Projekt,
            Projekt_wezel,
            Nieobec,
            TypNieob,
     (
         SELECT TypNieobec.TNB_PomnCzasPracy
         FROM CDN.TypNieobec
         WHERE TypNieobec.TNB_TnbId = #CzasPracy.TypNieob
     ) AS Pomniejszac,
            CASE OdbNadg
                WHEN 1
                THEN ''
                WHEN 2
                THEN 'O.BM'
                WHEN 3
                THEN 'O.NM'
                WHEN 4
                THEN 'W.PŁ'
                WHEN 5
                THEN 'W.NP'
                ELSE ''
            END AS OdbNadg
     FROM #CzasPracy
     WHERE @Typ < 3
           OR #CzasPracy.Zestaw < 2
     ORDER BY #CzasPracy.Data,
              #CzasPracy.Lp;
     DROP TABLE #CzasPracy;
