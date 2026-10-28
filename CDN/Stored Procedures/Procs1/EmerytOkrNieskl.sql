CREATE PROCEDURE CDN.EmerytOkrNieskl
(@pracid INT,
 @dataod DATETIME,
 @datado DATETIME
)
AS
    BEGIN
        CREATE TABLE #NieobecnosciER
        (dataOd    DATETIME,
         dataDo    DATETIME,
         TNB_PdzId INT,
         Nazwa     NVARCHAR(MAX)
        );
        --
        CREATE TABLE #tmp
        (dataOd    DATETIME,
         dataDo    DATETIME,
         TNB_PdzId INT,
         Nazwa     NVARCHAR(MAX)
        );
        --
        SELECT PRE_DataOd,
               PRE_DataDo
        INTO #datyOgr
        FROM cdn.PracEtaty
        WHERE PRE_PraId = @pracid
              AND PRE_DataOd <= @datado
              AND (PRE_DataDo IS NULL
                   OR PRE_DataDo >= @dataod)
              AND PRE_PrawoER IN(1, 2);
        --
        UPDATE #datyOgr
          SET
              PRE_DataOd = @dataod
        WHERE PRE_DataOd < @dataod;
        UPDATE #datyOgr
          SET
              PRE_DataDo = @datado
        WHERE PRE_DataDo > @datado;
        --
        --
        INSERT INTO #tmp
        (dataOd,
         dataDo,
         TNB_PdzId,
         Nazwa
        )
               SELECT PNB_OkresOd,
                      PNB_OkresDo,
                      TNB_PdzId,
                      TNB_Nazwa
               FROM cdn.PracNieobec
                    JOIN cdn.TypNieobec ON PNB_TnbId = TNB_TnbId
               WHERE PNB_PraId = @pracid
                     AND PNB_OkresOd >= @dataod
                     AND PNB_OkresDo <= @datado
                     AND TNB_PdzId NOT IN(111, 112, 151, 152, 311, 999, 319, 325, 327)
                    AND TNB_Standardowy <> 312
                    AND (PNB_Tryb = 0
                         OR PNB_Tryb = 2);
        --
        UPDATE #tmp
          SET
              dataOd = @dataod
        WHERE dataOd < @dataod;
        UPDATE #tmp
          SET
              dataDo = @datado
        WHERE dataDo > @datado;
        --
        DECLARE c CURSOR LOCAL FAST_FORWARD READ_ONLY
        FOR SELECT PRE_DataOd,
                   PRE_DataDo
            FROM #datyOgr
            ORDER BY PRE_DataOd;
        --
        DECLARE @preDataOd DATETIME, @preDataDo DATETIME, @nbDataOd DATETIME, @nbDataDo DATETIME, @nbTnbId INT;
        OPEN c;
        FETCH NEXT FROM c INTO @preDataOd, @preDataDo;
        WHILE @@FETCH_STATUS = 0
            BEGIN
                INSERT INTO #NieobecnosciER
                (dataOd,
                 dataDo,
                 TNB_PdzId,
                 Nazwa
                )
                       SELECT(CASE
                                  WHEN dataOd < @preDataOd
                                  THEN @preDataOd
                                  ELSE dataOd
                              END),
                             (CASE
                                  WHEN dataDo > @preDataDo
                                  THEN @preDataDo
                                  ELSE dataDo
                              END),
                             TNB_PdzId,
                             Nazwa
                       FROM #tmp
                       WHERE dataOd <= @preDataDo
                             AND dataDo >= @preDataOd;
                --
                FETCH NEXT FROM c INTO @preDataOd, @preDataDo;
            END;
        --
        SELECT dataOd,
               dataDo,
               TNB_PdzId,
               Nazwa
        FROM #NieobecnosciER;
        --
        DROP TABLE #NieobecnosciER;
        DROP TABLE #datyogr;
        DROP TABLE #tmp;
    END;
