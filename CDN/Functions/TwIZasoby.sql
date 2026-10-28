CREATE FUNCTION CDN.TwIZasoby ( @MagId INT, @DataOdChr NVARCHAR(50), @DataDoChr NVARCHAR(50) )
RETURNS @TwIZasoby Table ( TwrId INT PRIMARY KEY, Ilosc DECIMAL(15,4), Wartosc DECIMAL(15,2), Rezerwacje DECIMAL(15,4), Braki DECIMAL(15,4), Zamowienia DECIMAL(15,4) )
AS
BEGIN
  DECLARE
    @DataOd       DATETIME,
    @DatadO       DATETIME,
    @D            DATETIME,
    @T            INT,
    @M            INT,
    @I            DECIMAL(15,4),
    @W            DECIMAL(15,2),
    @R            DECIMAL(15,4),
    @B            DECIMAL(15,4),
    @Z            DECIMAL(15,4),
    @DOld         DATETIME,
    @IOld         DECIMAL(15,4),
    @WOld         DECIMAL(15,2),
    @ROld         DECIMAL(15,4),
    @BOld         DECIMAL(15,4),
    @ZOld         DECIMAL(15,4),
    @IloscDni     INT
  -- DATA DATETIME
  SELECT
    @DataOd = CONVERT(DATETIME, @DataOdChr, 120),
    @DataDo = CONVERT(DATETIME, @DataDoChr, 120)
  -- Ilość dni w badanym okresie
  SET @IloscDni = DATEDIFF ( D, @DataOd, @DataDo ) + 1
  -- wypełnianie tabelki pomocniczej z datami
  DECLARE @DTmp TABLE ( D DATETIME )
  SET @D = @DataOd
  WHILE 1=1
    BEGIN
      IF @D > @DataDo
        BREAK
      INSERT INTO @DTmp ( D ) VALUES ( @D )
      SET @D = @D + 1
    END
  -- tabelka z magazynami, towarami i datami
  DECLARE @MTD TABLE ( M INT, T INT, D DATETIME, I DECIMAL (15,4), W DECIMAL (15,2), R DECIMAL (15,4), B DECIMAL (15,4), Z DECIMAL (15,4)
   PRIMARY KEY([M], [T], [D])  ON  [PRIMARY] )
  INSERT INTO @MTD ( M, T, D, I, W, R, B, Z )
    SELECT Mag_MagId, Twr_TwrId, D, NULL, NULL, NULL, NULL, NULL
      FROM @DTmp
        CROSS JOIN CDN.Towary
        CROSS JOIN CDN.Magazyny
      WHERE Twr_Typ = 1
  -- update ilosci/wartosci w tabeli @MTD
  UPDATE @MTD SET
    I = TwI_Ilosc,
    W = TwI_Wartosc,
    R = TwI_Rezerwacje,
    B = TwI_Braki,
    Z = TwI_Zamowienia
  FROM CDN.TwrIlosci WITH ( INDEX = TwITowar )
    JOIN @MTD ON
         TwI_TwrId = T
     AND TwI_MagId = M
     AND TwI_Data  = D
  -- update ilości/wartości dla pierwszej daty
  UPDATE @MTD SET
    I = TwI_Ilosc,
    W = TwI_Wartosc,
    R = TwI_Rezerwacje,
    B = TwI_Braki,
    Z = TwI_Zamowienia
  FROM @MTD
    LEFT OUTER JOIN CDN.TwrIlosci WITH ( INDEX = TwITowar ) ON
         TwI_TwrId = T
     AND TwI_MagId = M
     AND TwI_Data  = (
                        SELECT MAX(TwI_Data)
                          FROM CDN.TwrIlosci WITH (INDEX = TwITowar)
                          WHERE TwI_TwrId = T
                            AND TwI_MagId = M
                            AND TwI_Data <= @DataOd
                       )
  WHERE D = @DataOd AND I IS NULL
  -- update ilości/wartości dla ostatniej (tylko jeśli daty są różne)
  IF @DataOd <> @DataDo
    UPDATE @MTD SET
      I = TwI_Ilosc,
      W = TwI_Wartosc,
      R = TwI_Rezerwacje,
      B = TwI_Braki,
      Z = TwI_Zamowienia
    FROM @MTD
      LEFT OUTER JOIN CDN.TwrIlosci WITH ( INDEX = TwITowar ) ON
           TwI_TwrId = T
       AND TwI_MagId = M
       AND TwI_Data  = (
                          SELECT MAX(TwI_Data)
                            FROM CDN.TwrIlosci WITH (INDEX = TwITowar)
                            WHERE TwI_TwrId = T
                              AND TwI_MagId = M
                              AND TwI_Data <= @DataDo
                         )
    WHERE D = @DataDo AND I IS NULL
  -- jeśli dalej nulle dla daty początkowej i końcowej, to znaczy, że nie ma wpisów w tabeli TwrIlosci i trzeba ustawić zera
  UPDATE @MTD SET
    I = 0,
    W = 0,
    R = 0,
    B = 0,
    Z = 0
  WHERE ( D = @DataOd OR D = @DataDo ) AND I IS NULL
  -- pozostałe niewypełnione wylatują - pętla będzie szybsza.
  DELETE FROM @MTD WHERE I IS NULL
  -- kursor dla każdego magazynu, towaru i daty w celu obliczenia sum magazynowych
  DECLARE M CURSOR LOCAL FAST_FORWARD FOR
    SELECT Mag_MagId FROM CDN.Magazyny
      OPEN M
        WHILE 1=1
        BEGIN
          FETCH NEXT FROM M INTO @M
          IF @@FETCH_STATUS <> 0 BREAK
            DECLARE T CURSOR LOCAL FAST_FORWARD FOR
            SELECT Twr_TwrId FROM CDN.Towary
            OPEN T
              WHILE 1=1
                BEGIN
                  FETCH NEXT FROM T INTO @T
                  IF @@FETCH_STATUS <> 0 BREAK
                    -- dla pozostałych dodajemy poprzedni stan
                    DECLARE D CURSOR LOCAL FAST_FORWARD FOR
                      SELECT D, I, W, R, B, Z FROM @MTD WHERE M = @M AND T = @T ORDER BY D
                        OPEN D
                          WHILE 1=1
                            BEGIN
                              FETCH NEXT FROM D INTO @D, @I, @W, @R, @B, @Z
                              IF @@FETCH_STATUS <> 0 BREAK
                              IF @D > @DataOd
                                UPDATE @MTD SET
                                  I = @IOld * DATEDIFF(D, @DOld, @D),
                                  W = @WOld * DATEDIFF(D, @DOld, @D),
                                  R = @ROld * DATEDIFF(D, @DOld, @D),
                                  B = @BOld * DATEDIFF(D, @DOld, @D),
                                  Z = @ZOld * DATEDIFF(D, @DOld, @D)
                                WHERE M = @M
                                  AND T = @T
                                  AND D = @DOld
                              SELECT
                                @DOld = @D,
                                @IOld = @I,
                                @WOld = @W,
                                @ROld = @R,
                                @BOld = @B,
                                @ZOld = @Z
                            END
                         CLOSE D
                    DEALLOCATE D
                END
              CLOSE T
            DEALLOCATE T
      END
    CLOSE M
  DEALLOCATE M
  IF @MagId IS NULL
    INSERT INTO @TwIZasoby ( TwrId, Ilosc, Wartosc, Rezerwacje, Braki, Zamowienia )
      SELECT
        T,
        SUM(I)/@IloscDni,
        SUM(W)/@IloscDni,
        SUM(R)/@IloscDni,
        SUM(B)/@IloscDni,
        SUM(Z)/@IloscDni
      FROM @MTD
      GROUP BY T
  IF @MagId IS NOT NULL
    INSERT INTO @TwIZasoby ( TwrId, Ilosc, Wartosc, Rezerwacje, Braki, Zamowienia )
      SELECT
        T,
        SUM(I)/@IloscDni,
        SUM(W)/@IloscDni,
        SUM(R)/@IloscDni,
        SUM(B)/@IloscDni,
        SUM(Z)/@IloscDni
      FROM @MTD
      WHERE M = @MagId
      GROUP BY T
  RETURN
END
