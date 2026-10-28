CREATE PROCEDURE [CDN].[OddajZasoby]
  @TrS_TrSId      INT,
  @TrS_TrEId      INT,
  @TrS_TrSIdDost  INT,
  @TrS_ZwrId      INT,
  @TrS_TwrId      INT,
  @TrS_MagId      INT,
  @TrS_Rodzaj     INT,
  @TrS_Typ        INT,
  @TrS_Metoda     INT,
  @TrS_DataOpe    DATETIME,
  @TrS_Ilosc      DECIMAL(15,4),
  @TrS_Wartosc    DECIMAL(15,2),
  @TrS_Cena       DECIMAL(17,4),
  @TrE_ZwrId      INT,
  @TrN_TrNId      INT,
  @TrN_MagDocId   INT,
  @TrN_Bufor_Doc  INT
AS
  SET NOCOUNT ON
  DECLARE
    -- zmienne dla kursora po tabeli @ZasobyDlaKorekt
    @Zas_Id          INT,
    @Zas_TwZTrS      INT,
    @Zas_TwZId       INT,
    @Zas_TrSId       INT,
    @Zas_TrEId       INT,
    @Zas_TrSIdDost   INT,
    @Zas_TrSZwrId    INT,
    @Zas_TwrId       INT,
    @Zas_MagId       INT,
    @Zas_Rodzaj      INT,
    @Zas_Typ         INT,
    @Zas_Metoda      INT,
    @Zas_DataOpe     DATETIME,
    @Zas_Ilosc       DECIMAL(15,4),
    @Zas_Wartosc     DECIMAL(15,2),
    @Zas_Cena        INT,
    @TrN_Bufor       INT,
    @Zas_TrSIdDost_P INT,
    @Zas_Ilosc_P     DECIMAL(15,4),
    @Zas_Wartosc_P   DECIMAL(15,2),
    @Zas_Poziom      INT,
    -- zmienna pomocnicza do bieżącego budowania ilości i wartości
    @Ilosc_Potrzebna         DECIMAL(15,4),
    @Wartosc_Potrzebna       DECIMAL(15,2),
    @Zas_Ilosc_Pozostala     DECIMAL(15,4),
    @Zas_Wartosc_Pozostala   DECIMAL(15,2),
    @TwI_Wartosc_Max         DECIMAL(15,2),
    @TwZ_Wartosc_Max         DECIMAL(15,2),
    -- zmienna pomocniczna do budowania dokumentow WZKK w przypadku sytuacji wartosc > 0 i ilosc = 0 oraz wartosc < 0 i ilosc = 0 (przypadki szczegolne)
    @Wartosc_Pozostala       DECIMAL (15,2),
    @Ilosc_Pozostala         DECIMAL (15,4),
    @WZKK_MagID              INT,
    @WZKK_Wartosc            DECIMAL (15,2),
    @WZKK_Ilosc              DECIMAL (15,4),
    @WZKK_Cena               DECIMAL (17,4),
    @Roznica     INT,
    @TrS_DataOpeKorygowanego DATETIME,
    -- zmienne do dodawanych subelementów
    @TrS_TrSId_N       INT,
    @TrS_TrEId_N       INT,
    @TrS_TrSIdDost_N   INT,
    @TrS_ZwrId_N       INT,
    @TrS_TwrId_N       INT,
    @TrS_MagId_N       INT,
    @TrS_Rodzaj_N      INT,
    @TrS_Typ_N         INT,
    @TrS_Metoda_N      INT,
    @TrS_DataOpe_N     DATETIME,
 @TrS_DataOpe_min     DATETIME,
    @TrS_Ilosc_N       DECIMAL(15,4),
    @TrS_Ilosc_NS      DECIMAL(15,4),
    @TrS_Wartosc_N     DECIMAL(15,2),
    @TrS_Cena_N        DECIMAL(17,4),
    @TrS_TrEId_WZKK    INT,
    @New_TrEId_WZKK    INT,
    @TrE_TrEId_MMWZKK  INT,
    @TrE_TrEId_MMWZKK1 INT,
    @TrS_TrSId_MMWZKK  INT,
    @ID1               INT,
    @ID2               INT,
    @TrE_TwrId         INT,
    @TrE_DataOpe       DATETIME,
    @Kom_Twr_Kod       NVARCHAR(50),
    @Kom_Twr_Nazwa     NVARCHAR(255),
    -- komunikat
    @Twr_Kod           NVARCHAR(50),
    @Twr_Jm            NVARCHAR(20),
    @Ilosc_Kom         NVARCHAR(30),
    @Wartosc_Kom       NVARCHAR(30),
    @Komunikat         NVARCHAR(350)
      -- Tabele tymczasowe
    DECLARE @AktWZKK TABLE (TrS_TrEId INT , TrS_TrEId_WZKK INT,typ tinyint)
    declare @LastID int
  IF NOT ( @TrS_Typ = 2 AND @TrS_Ilosc > 0 )
    BEGIN
      DECLARE @TraSElem          TABLE ( TrS_TrSId INT, TrS_TrEId INT, TrS_TrSIdDost INT, TrS_ZwrId INT, TrS_TwrId INT, TrS_MagId INT, TrS_Rodzaj INT, TrS_Typ INT, TrS_Metoda INT, TrS_DataOpe DATETIME, TrS_Ilosc DECIMAL(15,4), TrS_Wartosc DECIMAL(15,2), TrS_Cena DECIMAL(17,4) )
      DECLARE @ZasobyDlaKorekt   TABLE ( Zas_Id INT, Zas_TwZTrS INT, Zas_TwZId INT, Zas_TrSId INT, Zas_TrEId INT, Zas_TrSIdDost INT, Zas_TrSZwrId INT, Zas_TwrId INT, Zas_MagId INT, Zas_Rodzaj INT, Zas_Typ INT, Zas_Metoda INT, Zas_DataOpe  DATETIME, Zas_Ilosc DECIMAL(15,4), Zas_Wartosc DECIMAL(15,2), Zas_Cena DECIMAL(17,4), TrN_Bufor INT, Zas_TrSIdDost_P INT, Zas_Ilosc_P DECIMAL(15,4), Zas_Wartosc_P   DECIMAL(15,2),Zas_Poziom INT)
    END
  -- udodatniona ilość i wartość potrzebna do bieżącego uaktualniania
  SELECT
    @Ilosc_Potrzebna   = ABS(@TrS_Ilosc),
    @Wartosc_Potrzebna = ABS(@TrS_Wartosc),
    @Komunikat         = ''
  -- Zwykłe wydania (klonowanie sublementów)
  IF @TrS_Typ = 2 AND @TrS_Ilosc > 0
    BEGIN
      -- wartości wspólne
     WHILE 1=1
        BEGIN
  SELECT
         @TrS_TrEId_N     = @TrS_TrEId,
         @TrS_ZwrId_N     = NULL,
         @TrS_TwrId_N     = @TrS_TwrId,
         @TrS_MagId_N     = @TrS_MagId,
         @TrS_Rodzaj_N    = @TrS_Rodzaj,
         @TrS_Typ_N       = 2,
         @TrS_Metoda_N    = @TrS_Metoda,
         @TrS_DataOpe_N   = @TrS_DataOpe
         SET @Zas_Ilosc = NULL
          -- FIFO
          IF @TrS_Metoda = 1
            IF ISNULL(@TrS_TrSIdDost,0) > 0
               SELECT TOP 1 @Zas_TrSIdDost = TwZ_TrSIdDost, @Zas_Ilosc = TwZ_Ilosc,            @Zas_Wartosc = TwZ_Wartosc, @Zas_Cena = TwZ_Cena FROM CDN.TwrZasoby WHERE TwZ_TwrId = @TrS_TwrId AND TwZ_MagId = @TrS_MagId AND TwZ_Quan = 0 AND TwZ_TrSIdDost = @TrS_TrSIdDost
            ELSE
               SELECT TOP 1 @Zas_TrSIdDost = TwZ_TrSIdDost, @Zas_Ilosc = TwZ_Ilosc,            @Zas_Wartosc = TwZ_Wartosc, @Zas_Cena = TwZ_Cena FROM CDN.TwrZasoby
               JOIN CDN.TraSelem ON TwZ_TrSIdDost = TrS_TrSIdDost
               WHERE TwZ_TwrId = @TrS_TwrId AND TwZ_MagId = @TrS_MagId AND TwZ_Quan = 0        ORDER BY TwZ_Data,      TwZ_TrSIdDost
          -- LIFO
          ELSE IF @TrS_Metoda = 2
            IF ISNULL(@TrS_TrSIdDost,0) > 0
               SELECT TOP 1 @Zas_TrSIdDost = TwZ_TrSIdDost, @Zas_Ilosc = TwZ_Ilosc,            @Zas_Wartosc = TwZ_Wartosc, @Zas_Cena = TwZ_Cena FROM CDN.TwrZasoby WHERE TwZ_TwrId = @TrS_TwrId AND TwZ_MagId = @TrS_MagId AND TwZ_Quan = 0 AND TwZ_TrSIdDost = @TrS_TrSIdDost
            ELSE
               SELECT TOP 1 @Zas_TrSIdDost = TwZ_TrSIdDost, @Zas_Ilosc = TwZ_Ilosc,            @Zas_Wartosc = TwZ_Wartosc, @Zas_Cena = TwZ_Cena FROM CDN.TwrZasoby
               JOIN CDN.TraSelem ON TwZ_TrSIdDost = TrS_TrSIdDost
               WHERE TwZ_TwrId = @TrS_TwrId AND TwZ_MagId = @TrS_MagId AND TwZ_Quan = 0 AND TwZ_Data <= @TrS_DataOpe ORDER BY TwZ_Data DESC, TwZ_TrSIdDost DESC
          -- AVCO
          ELSE IF @TrS_Metoda = 3
              begin
               SELECT TOP 1 @Zas_TrSIdDost = TwZ_TrSIdDost, @Zas_Ilosc = TwZ_Ilosc,            @Zas_Wartosc = TwZ_Wartosc, @Zas_Cena = TwZ_Cena FROM CDN.TwrZasoby WHERE TwZ_TwrId = @TrS_TwrId AND TwZ_MagId = @TrS_MagId                                               ORDER BY TwZ_Data
               SELECT                      @TrS_ZwrId_N=TrS_TrSId FROM cdn.TraSElem WHERE TrS_TrEId = @TrE_ZwrId ORDER BY TrS_DataOpe DESC, TrS_TrSId DESC
              end            -- QUAN
          ELSE IF @TrS_Metoda = 4
            SELECT TOP 1 @Zas_TrSIdDost = TwZ_TrSIdDost, @Zas_Ilosc = TwZ_Ilosc + TwZ_QUAN, @Zas_Wartosc = 0,           @Zas_Cena = 0        FROM CDN.TwrZasoby WHERE TwZ_TwrId = @TrS_TwrId AND TwZ_MagId = @TrS_MagId                                               ORDER BY TwZ_Data
          -- nieobsługiwane metody
          ELSE
            SET @Zas_Ilosc = NULL
          -- koniec, jeśli zabrakło wierszy w TwrZasoby
          IF @Zas_Ilosc IS NULL  BREAK
          SELECT
            @TrS_Ilosc_N             = 0,
            @TrS_Wartosc_N           = 0,
            @Zas_Ilosc_Pozostala     = 0,
            @Zas_Wartosc_Pozostala   = 0
          -- ilości
          SET @TrS_Ilosc_N           = ( SELECT MIN(A) FROM ( SELECT A = @Zas_Ilosc UNION ALL SELECT A = @Ilosc_Potrzebna ) AS B )
         IF @TrS_Metoda = 4
    BEGIN
     SET @Roznica = @Ilosc_Potrzebna / @TrS_Ilosc_N
                 IF @Roznica > 100
                 SET @TrS_Ilosc_N = @TrS_Ilosc_N * (@Roznica / 2)
    END
          SET @Ilosc_Potrzebna       = @Ilosc_Potrzebna - @TrS_Ilosc_N
          SET @Zas_Ilosc_Pozostala   = @Zas_Ilosc - @TrS_Ilosc_N
          -- wartości
          IF @TrS_Ilosc_N <> 0 AND @Zas_Ilosc <> 0 AND @TrS_Ilosc_N <> @Zas_Ilosc
            SET @TrS_Wartosc_N         = ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND ( (@TrS_Ilosc_N / @Zas_Ilosc) * @Zas_Wartosc,11),10),9),8),7),6),5),4),3),2)
          ELSE
            SET @TrS_Wartosc_N  = @Zas_Wartosc
          SET @TrS_Wartosc_N         = ( SELECT MIN(A) FROM ( SELECT A = @Zas_Wartosc UNION ALL SELECT A = @TrS_Wartosc_N ) AS B )
          SET @Zas_Wartosc_Pozostala = @Zas_Wartosc - @TrS_Wartosc_N
          -- reszta wartości, jeśli ilość pozostała na zasobie jest zerowa
          IF @Zas_Ilosc_Pozostala = 0 AND @Zas_Wartosc_Pozostala > 0
            SET @TrS_Wartosc_N   = @Zas_Wartosc
          -- wielkości do tworzenia subelementów
          SELECT
            @TrS_TrSIdDost_N = @Zas_TrSIdDost,
            @TrS_Cena_N      = @Zas_Cena
          -- Subelement zwykły
          INSERT INTO CDN.TraSElem (  TrS_TrEId,    TrS_TrSIdDost,    TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena    )
            VALUES                 ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N  )
          -- Subelement komplementarny (MM-kowy)
          IF @TrN_MagDocId IS NOT NULL AND @TrN_Bufor_Doc IN ( 1, 0 ) AND @TrS_Rodzaj NOT IN ( 312100, 312010 )
            BEGIN
              SELECT
                @TrS_MagId_N   =   @TrN_MagDocId,
                @TrS_ZwrId_N   =   NULL
              -- bufor i subelement zamowieniowy
              IF @TrN_Bufor_Doc = 1
                SELECT
                  @TrS_TrSIdDost_N = NULL,
                  @TrS_Typ_N       = 4,
                  @TrS_Wartosc_N   = 0,
                  @TrS_Cena_N      = 0
              -- akceptacja i subelement dostawczy
              ELSE IF @TrN_Bufor_Doc = 0
                SELECT
                  @TrS_Ilosc_N   = - @TrS_Ilosc_N,
                  @TrS_Wartosc_N = - @TrS_Wartosc_N
              INSERT INTO CDN.TraSElem (  TrS_TrEId,    TrS_TrSIdDost,    TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena    )
                VALUES                 ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N  )
            END
          IF @Ilosc_Potrzebna = 0 BREAK
        END -- END WHILE
      -- Kontrola, czy wystarczyło ilości i wartości
      IF @Ilosc_Potrzebna <> 0
        GOTO KOMUNIKAT
    END
/*
    BEGIN
    -- dostępne zasoby dla korekt do tabeli tymczasowej
    INSERT INTO @ZasobyDlaKorekt   ( Zas_Id,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor     )
      SELECT                         Zas_Id,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor
        FROM CDN.ZasobyDlaKorekt ( @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena, @TrE_ZwrId  )
          WHERE TrN_Bufor IN ( 0, 1 )  -- tylko dokumenty nie będące w buforze
          ORDER BY Zas_Id              -- najpierw zasoby z magazynu źródłowego, potem subelemnety do zwrotu z magazynu źródłowego, potem zasoby z innych magazynów, potem subelementy do zwrotu z innych magazynów
    -- kursor po dostępnych zasobach z tabeli tymczasowej @ZasobyDlaKorekt
    DECLARE Z CURSOR LOCAL FAST_FORWARD FOR
      SELECT                          Zas_Id,  Zas_TwZTrS,  Zas_TwZId,  Zas_TrSId,  Zas_TrEId,  Zas_TrSIdDost,  Zas_TrSZwrId,  Zas_TwrId,  Zas_MagId,  Zas_Rodzaj,  Zas_Typ,  Zas_Metoda,  Zas_DataOpe,  Zas_Ilosc,  Zas_Wartosc,  Zas_Cena,  TrN_Bufor
        FROM @ZasobyDlaKorekt ORDER BY Zas_Id
        OPEN Z
          WHILE 1=1
            BEGIN
              FETCH NEXT FROM Z INTO @Zas_Id, @Zas_TwZTrS, @Zas_TwZId, @Zas_TrSId, @Zas_TrEId, @Zas_TrSIdDost, @Zas_TrSZwrId, @Zas_TwrId, @Zas_MagId, @Zas_Rodzaj, @Zas_Typ, @Zas_Metoda, @Zas_DataOpe, @Zas_Ilosc, @Zas_Wartosc, @Zas_Cena, @TrN_Bufor
              IF @@FETCH_STATUS <> 0 BREAK
              IF @Ilosc_Potrzebna = 0 BREAK
              SELECT
                @TrS_Ilosc_N             = 0,
                @TrS_Wartosc_N           = 0,
                @Zas_Ilosc_Pozostala     = 0,
                @Zas_Wartosc_Pozostala   = 0
              -- ilości
              SET @TrS_Ilosc_N           = ( SELECT MIN(A) FROM ( SELECT A = @Zas_Ilosc UNION ALL SELECT A = @Ilosc_Potrzebna ) AS B )
              SET @Ilosc_Potrzebna       = @Ilosc_Potrzebna - @TrS_Ilosc_N
              SET @Zas_Ilosc_Pozostala   = @Zas_Ilosc - @TrS_Ilosc_N
              -- wartości
              IF @TrS_Ilosc_N <> 0 AND @Zas_Ilosc <> 0 AND @TrS_Ilosc_N <> @Zas_Ilosc
                SET @TrS_Wartosc_N         = ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND ( (@TrS_Ilosc_N / @Zas_Ilosc) * @Zas_Wartosc,11),10),9),8),7),6),5),4),3),2)
              ELSE
                SET @TrS_Wartosc_N  = @Zas_Wartosc
              SET @TrS_Wartosc_N         = ( SELECT MIN(A) FROM ( SELECT A = @Zas_Wartosc UNION ALL SELECT A = @TrS_Wartosc_N ) AS B )
              SET @Zas_Wartosc_Pozostala = @Zas_Wartosc - @TrS_Wartosc_N
              -- reszta wartości, jeśli ilość pozostała na zasobie jest zerowa
              IF @Zas_Ilosc_Pozostala = 0 AND @Zas_Wartosc_Pozostala > 0
                SET @TrS_Wartosc_N   = @Zas_Wartosc
              -- wielkości do tworzenia subelementów
              SELECT
                @TrS_TrEId_N     = @TrS_TrEId,
                @TrS_TrSIdDost_N = @Zas_TrSIdDost,
                @TrS_ZwrId_N     = NULL,
                @TrS_TwrId_N     = @TrS_TwrId,
                @TrS_MagId_N     = @TrS_MagId,
                @TrS_Rodzaj_N    = @TrS_Rodzaj,
                @TrS_Typ_N       = 2,
                @TrS_Metoda_N    = @TrS_Metoda,
                @TrS_DataOpe_N   = @TrS_DataOpe,
                @TrS_Cena_N      = @Zas_Cena
              -- Subelement zwykły
              INSERT INTO CDN.TraSElem (  TrS_TrEId,    TrS_TrSIdDost,    TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena    )
                VALUES                 ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N  )
              -- Subelement komplementarny (MM-kowy)
              IF @TrN_MagDocId IS NOT NULL AND @TrN_Bufor_Doc IN ( 1, 0 ) AND @TrS_Rodzaj NOT IN ( 312100, 312010 )
                BEGIN
                  SELECT
                    @TrS_MagId_N   =   @TrN_MagDocId,
                    @TrS_ZwrId_N   =   NULL
                  -- bufor i subelement zamowieniowy
                  IF @TrN_Bufor_Doc = 1
                    SELECT
                      @TrS_TrSIdDost_N = NULL,
                      @TrS_Typ_N       = 4,
                      @TrS_Wartosc_N   = 0,
                      @TrS_Cena_N      = 0
                  -- akceptacja i subelement dostawczy
                  ELSE IF @TrN_Bufor_Doc = 0
                    SELECT
                      @TrS_Ilosc_N   = - @TrS_Ilosc_N,
                      @TrS_Wartosc_N = - @TrS_Wartosc_N
                  INSERT INTO CDN.TraSElem (  TrS_TrEId,    TrS_TrSIdDost,    TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena    )
                    VALUES                 ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N  )
                END
            END
        CLOSE Z
    DEALLOCATE Z
    -- Kontrola, czy wystarczyło ilości i wartości
    IF @Ilosc_Potrzebna <> 0
      GOTO KOMUNIKAT
    END
*/
  -- Korekta ilościowe do dostaw na minus
  IF @TrS_Typ = 1 AND @TrS_Ilosc <  0 AND @TrS_TrSId <> @TrS_TrSIdDost AND @TrS_Metoda IN ( 1, 2, 3, 4 )
    BEGIN
    -- dostępne zasoby dla korekt do tabeli tymczasowej
    INSERT INTO @ZasobyDlaKorekt   ( Zas_Id,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor , Zas_Poziom    )
      SELECT                         Zas_Id,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor , Zas_Poziom
        FROM CDN.ZasobyDlaKorekt ( @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena, @TrE_ZwrId  )
          WHERE TrN_Bufor IN ( 0, 1 )  -- tylko dokumenty nie będące w buforze
          ORDER BY Zas_Id              -- najpierw zasoby z magazynu źródłowego, potem subelemnety do zwrotu z magazynu źródłowego, potem zasoby z innych magazynów, potem subelementy do zwrotu z innych magazynów
    -- kursor po dostępnych zasobach z tabeli tymczasowej @ZasobyDlaKorekt
    DECLARE Z CURSOR LOCAL FAST_FORWARD FOR
      SELECT                          Zas_Id,  Zas_TwZTrS,  Zas_TwZId,  Zas_TrSId,  Zas_TrEId,  Zas_TrSIdDost,  Zas_TrSZwrId,  Zas_TwrId,  Zas_MagId,  Zas_Rodzaj,  Zas_Typ,  Zas_Metoda,  Zas_DataOpe,  Zas_Ilosc,  Zas_Wartosc,  Zas_Cena,  TrN_Bufor
        FROM @ZasobyDlaKorekt ORDER BY Zas_Id
        OPEN Z
          WHILE 1=1
            BEGIN
              FETCH NEXT FROM Z INTO @Zas_Id, @Zas_TwZTrS, @Zas_TwZId, @Zas_TrSId, @Zas_TrEId, @Zas_TrSIdDost, @Zas_TrSZwrId, @Zas_TwrId, @Zas_MagId, @Zas_Rodzaj, @Zas_Typ, @Zas_Metoda, @Zas_DataOpe, @Zas_Ilosc, @Zas_Wartosc, @Zas_Cena, @TrN_Bufor
              IF @@FETCH_STATUS <> 0 BREAK
              IF @Ilosc_Potrzebna = 0 AND @Wartosc_Potrzebna = 0 BREAK
              SELECT
                @TrS_Ilosc_N             = 0,
                @TrS_Wartosc_N           = 0,
                @Zas_Ilosc_Pozostala     = 0,
                @Zas_Wartosc_Pozostala   = 0
              -- ilości
              SET @TrS_Ilosc_N           = ( SELECT MIN(A) FROM ( SELECT A = @Zas_Ilosc UNION ALL SELECT A = @Ilosc_Potrzebna ) AS B )
              SET @Ilosc_Potrzebna       = @Ilosc_Potrzebna - @TrS_Ilosc_N
              SET @Zas_Ilosc_Pozostala   = @Zas_Ilosc - @TrS_Ilosc_N
              -- Wartosci dla PWP - nie liczymy wartości na podstawie współczynnika z subelementu pierwotnego
              IF CONVERT(INT, @TrS_Rodzaj/1000) = 317
                SET @TrS_Wartosc_N         = ( SELECT MIN(A) FROM ( SELECT A = @Zas_Wartosc UNION ALL SELECT A = @Wartosc_Potrzebna ) AS B )
              ELSE
                BEGIN
                  -- wartości FIFO,LIFO
                  IF @TrS_Metoda IN ( 1, 2 )
                    BEGIN
                      IF @TrS_Ilosc_N <> 0 AND @Zas_Ilosc <> 0 AND @TrS_Ilosc_N <> @Zas_Ilosc AND @Ilosc_Potrzebna <> 0
                        SET @TrS_Wartosc_N         = ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND ( (@TrS_Ilosc_N / @Zas_Ilosc) * @Zas_Wartosc,11),10),9),8),7),6),5),4),3),2)
                      ELSE
                        SET @TrS_Wartosc_N  = @Zas_Wartosc
                      SET @TrS_Wartosc_N         = ( SELECT MIN(A) FROM ( SELECT A = @Zas_Wartosc UNION ALL SELECT A = @Wartosc_Potrzebna UNION ALL SELECT A = @TrS_Wartosc_N ) AS B )
                    END
                  -- wartości AVCO, QUAN
                  IF @TrS_Metoda IN ( 3, 4 )
                    BEGIN
                      SET @TrS_Wartosc_N         = ( SELECT MIN(A) FROM ( SELECT A = @Zas_Wartosc UNION ALL SELECT A = @Wartosc_Potrzebna ) AS B )
                    END
                END
              SET @Wartosc_Potrzebna     = @Wartosc_Potrzebna - @TrS_Wartosc_N
              SET @Zas_Wartosc_Pozostala = @Zas_Wartosc - @TrS_Wartosc_N
              --rt pozbywamy się smieci
               if @Zas_Ilosc_Pozostala = 0 and  @Wartosc_Potrzebna <> 0 and @Wartosc_Potrzebna in (0.01,-0.01,0.02,-0.02)
              begin
    select  @TrS_Wartosc = @TrS_Wartosc + @Wartosc_Potrzebna,
    @Wartosc_Potrzebna = 0
     end
              -- wielkości wspólne do tworzenia subelementów
             SELECT @TrS_DataOpeKorygowanego = TrS_DataOpe FROM CDN.TrasElem WHERE TrS_TrSId = @Zas_TrSId
              SELECT
                @TrS_TrEId_N     = @TrS_TrEId,
                @TrS_DataOpe_N   = CASE WHEN @TrS_DataOpeKorygowanego > @TrS_DataOpe THEN @TrS_DataOpeKorygowanego ELSE @TrS_DataOpe END,
                @TrS_TrSIdDost_N = @TrS_TrSIdDost,
                @TrS_TwrId_N     = @TrS_TwrId,
                @TrS_MagId_N     = @Zas_MagId,
                @TrS_Typ_N       = 2,
                @TrS_Metoda_N    = @TrS_Metoda,
               -- @TrS_DataOpe_N   = @TrS_DataOpe,
                @TrS_Cena_N      = @Zas_Cena
              -- korekty na minus
              IF @TrS_Ilosc <> 0 AND @TrS_Metoda IN ( 1, 2, 3, 4 )
                SET @TrS_Rodzaj_N = 306071
              -- AVCO QUAN, korekty wartościowe
              ELSE
                SET @TrS_Rodzaj_N = 306072
              -- zasoby natywne z tego samego magazynu
              IF @Zas_TwZTrS = 0 AND @Zas_MagId = @TrS_MagId
                BEGIN
                  -- obsługa śmieci wartościowych - subelement korekcyjny, jeśli zosała jakaś wartość dodatnia bez ilości
                  IF @Zas_Ilosc_Pozostala = 0 AND @Zas_Wartosc_Pozostala > 0
                    BEGIN
                      SELECT
                        @TrS_ZwrId_N     = NULL,
                        @TrS_Ilosc_N     = 0,
                        @TrS_Wartosc_N   = @Zas_Wartosc_Pozostala
                       INSERT INTO CDN.TraSElem (  TrS_TrEId,    TrS_TrSIdDost,    TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena    )
                        VALUES                 ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N  )
                        EXECUTE CDN.AktualizujWZKK_OLD @TrS_TrEId
                    END
                END
             -- subelementy kosztowe do zwrotu z tego samego magazynu
             ELSE IF @Zas_TwZTrS = 1 AND @Zas_MagId = @TrS_MagId
               BEGIN
                 -- subelement zwrotny i aktualizacja zasobów
                 SELECT
                   @TrS_ZwrId_N     = @Zas_TrSId,
                   @TrS_Ilosc_N     = - ABS(@TrS_Ilosc_N),
                   @TrS_Wartosc_N   = - ABS(@TrS_Wartosc_N),
                   @TrS_TrEId_N     = @TrS_TrEId,
                   @TrS_TrEId_WZKK  = @Zas_TrEId
                 INSERT INTO CDN.TraSElem (  TrS_TrEId,    TrS_TrSIdDost,    TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena    )
                   VALUES                 ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N  )
                 set @LastID = SCOPE_IDENTITY()
                 EXECUTE CDN.AktualizujWZKK @TrS_TrEId_N, @TrS_TrEId_WZKK,@TrS_TrEId,@New_TrEId_WZKK  output       -- generowanie automatyczne dokumetentu WZKK dla każdego subelementu
                 if not exists(select * from @AktWZKK where TrS_TrEId =  @TrS_TrEId_N and TrS_TrEId_WZKK = @New_TrEId_WZKK)
     insert into  @AktWZKK values (@TrS_TrEId_N, @New_TrEId_WZKK,0)
    set @TrS_TrEId_N =@New_TrEId_WZKK
    update a set   a.TrS_TrEId = @New_TrEId_WZKK  from cdn.TraSElem a
    where  TrS_TrSID = @LastID
                 -- klonowanie komplementarnych subelementów dodatnich - pobieramy inne dostepne dostawy z magazynu
                 SELECT
                   @TrS_ZwrId_N     = NULL,
                   @TrS_Ilosc_N     = ABS(@TrS_Ilosc_N),
                   @TrS_Wartosc_N   = 0,
                   @TrS_TrEId_N     = (SELECT ISNULL(MAX(TrS_TrEId),1) FROM CDN.TraSelem)
                 EXECUTE CDN.KlonujTraSElem 3, NULL, @New_TrEId_WZKK, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N, @TrE_ZwrId, @TrN_TrNId, @TrN_MagDocId, @TrN_Bufor_Doc
               END
             -- zasoby natywne z innego magazynu
             ELSE IF @Zas_TwZTrS = 0 AND @Zas_MagId <> @TrS_MagId
               BEGIN
                  IF @Zas_TreID IS NULL
                   BEGIN
                    declare @zas_trsid1 int, @zas_trsid2 int, @Zas_TrEid1 int
   select @Zas_TrsId1 =  p.TrS_TrSId, @Zas_TrEid1 = MAX(p.TrS_TrEId) FROM cdn.TraSElem P
   JOIN cdn.TraElem ON TrE_TrEId = P.TrS_TrEId
   JOIN cdn.TraNag  ON TrN_TrNId = TrE_TrNId
   WHERE P.TrS_TwrId     = @TrS_TwrId
   AND P.TrS_MagId     <> @TrS_MagId
   AND P.TrS_TrSIdDost = @TrS_TrSIdDost
   AND P.TrS_Typ       = 2
   AND P.TrS_ZwrId IS NULL
   AND P.TrS_Ilosc    <= 0
   AND TrN_Rodzaj in (312000,312008)
   AND TrN_MagZrdId = @TrS_MagId AND TrN_MagDocId <> @TrS_MagId
   AND TrS_MagId = @Zas_MagId
   AND P.TrS_TrEId <> @TrS_TrEId
         group by p.trs_trsid
         if @Zas_TrsId1 is NULL
         BEGIN
   select @Zas_TrsId1 =  p.TrS_TrSId, @Zas_TrEid1 = MAX(p.TrS_TrEId) FROM cdn.TraSElem P
   JOIN cdn.TraElem ON TrE_TrEId = P.TrS_TrEId
   JOIN cdn.TraNag WZ ON WZ.TrN_TrNId = TrE_TrNId
   JOIN cdn.TraNag ORG ON ORG.TrN_TrNId =WZ.TRN_ZWRID
   WHERE P.TrS_TwrId     = @TrS_TwrId
   AND P.TrS_MagId     <> @TrS_MagId
   AND P.TrS_TrSIdDost = @TrS_TrSIdDost
   AND P.TrS_Typ       = 2
   AND P.TrS_ZwrId IS NULL
   AND P.TrS_Ilosc    <= 0
   AND WZ.TrN_Rodzaj = 306071
   AND ORG.TrN_Rodzaj in (312000,312008)
   AND WZ.TrN_MagDocId <> @TrS_MagId
   AND TrS_MagId = @Zas_MagId
   AND P.TrS_TrEId <> @TrS_TrEId
         group by p.trs_trsid
         end
         if @Zas_TrsId1 is NULL
         BEGIN
                     select @Zas_TrsId1 =  p.TrS_TrSId, @Zas_TrEid1 = MAX(p.TrS_TrEId) FROM cdn.TraSElem P
                        JOIN cdn.TraElem ON TrE_TrEId = P.TrS_TrEId
                         JOIN cdn.TraNag WZ ON WZ.TrN_TrNId = TrE_TrNId
                        -- JOIN cdn.TraNag ORG ON ORG.TrN_TrNId =WZ.TRN_ZWRID
                       WHERE P.TrS_TwrId     = @TrS_TwrId
                    AND P.TrS_MagId     <> @TrS_MagId
   AND P.TrS_TrSIdDost = @TrS_TrSIdDost
   AND P.TrS_Typ       = 2
   AND P.TrS_ZwrId IS NULL
   AND P.TrS_Ilosc    <= 0
   AND WZ.TrN_Rodzaj = 306071
  -- AND ORG.TrN_Rodzaj in (312000,312008)
   AND WZ.TrN_MagDocId <> @TrS_MagId
   AND TrS_MagId = @Zas_MagId
   AND P.TrS_TrEId <> @TrS_TrEId
         group by p.trs_trsid
         end
     if @Zas_TrsId1 is NULL
         BEGIN
                     select @Zas_TrsId1 =  p.TrS_TrSId, @Zas_TrEid1 = MAX(p.TrS_TrEId) FROM cdn.TraSElem P
                        JOIN cdn.TraElem ON TrE_TrEId = P.TrS_TrEId
                         JOIN cdn.TraNag  ON TrN_TrNId = TrE_TrNId
                       WHERE P.TrS_TwrId     = @TrS_TwrId
                    AND P.TrS_MagId     <> @TrS_MagId
   AND P.TrS_TrSIdDost = @TrS_TrSIdDost
   AND P.TrS_Typ       = 2
   AND P.TrS_ZwrId IS NULL
   AND P.TrS_Ilosc    <= 0
   AND TrN_Rodzaj in (312000,312008)
   AND TrN_MagZrdId = @TrS_MagId AND TrN_MagDocId <> @TrS_MagId
   AND P.TrS_TrEId <> @TrS_TrEId
         group by p.trs_trsid
         end
         if @Zas_TrsId1 is NULL
         BEGIN
                     select @Zas_TrsId1 =  p.TrS_TrSId, @Zas_TrEid1 = MAX(p.TrS_TrEId) FROM cdn.TraSElem P
                        JOIN cdn.TraElem ON TrE_TrEId = P.TrS_TrEId
                         JOIN cdn.TraNag WZ ON WZ.TrN_TrNId = TrE_TrNId
                         JOIN cdn.TraNag ORG ON ORG.TrN_TrNId =WZ.TRN_ZWRID
                       WHERE P.TrS_TwrId     = @TrS_TwrId
                    AND P.TrS_MagId     <> @TrS_MagId
   AND P.TrS_TrSIdDost = @TrS_TrSIdDost
   AND P.TrS_Typ       = 2
   AND P.TrS_ZwrId IS NULL
   AND P.TrS_Ilosc    <= 0
   AND WZ.TrN_Rodzaj = 306071
   AND ORG.TrN_Rodzaj in (312000,312008)
   AND WZ.TrN_MagDocId <> @TrS_MagId
   AND P.TrS_TrEId <> @TrS_TrEId
         group by p.trs_trsid
         end
         if @Zas_TrsId1 is NULL
         BEGIN
                     select @Zas_TrsId1 =  p.TrS_TrSId, @Zas_TrEid1 = MAX(p.TrS_TrEId) FROM cdn.TraSElem P
                        JOIN cdn.TraElem ON TrE_TrEId = P.TrS_TrEId
                         JOIN cdn.TraNag WZ ON WZ.TrN_TrNId = TrE_TrNId
                        -- JOIN cdn.TraNag ORG ON ORG.TrN_TrNId =WZ.TRN_ZWRID
                       WHERE P.TrS_TwrId     = @TrS_TwrId
                    AND P.TrS_MagId     <> @TrS_MagId
   AND P.TrS_TrSIdDost = @TrS_TrSIdDost
   AND P.TrS_Typ       = 2
   AND P.TrS_ZwrId IS NULL
   AND P.TrS_Ilosc    <= 0
   AND WZ.TrN_Rodzaj = 306071
  -- AND ORG.TrN_Rodzaj in (312000,312008)
   AND WZ.TrN_MagDocId <> @TrS_MagId
   AND P.TrS_TrEId <> @TrS_TrEId
         group by p.trs_trsid
         end
                    END
                 -- subelement rozchodowy z magazynu obcego
                 SELECT
                   @TrS_ZwrId_N     = CASE WHEN @Zas_TrEId IS NOT NULL THEN NULL ELSE @Zas_TrsId1 END, --NULL,
                   @TrS_MagId_N     = @Zas_MagId,
                   @TrS_Ilosc_N     = ABS(@TrS_Ilosc_N),
                   @TrS_Wartosc_N   = ABS(@TrS_Wartosc_N),
                   @TrS_TrEId_N     = (SELECT ISNULL(MAX(TrS_TrEId),1) FROM CDN.TraSelem)+1,
                   @TrS_TrEId_WZKK   =  @Zas_TrEid1
         --zapisuję @TrS_TrEId_N, by potem skojarzyć drugi subelement
       declare @wartosc int
        set @wartosc = @TrS_TrEId_N
        select @TrS_DataOpe_N = CASE WHEN @TrS_DataOpe_N > TrS_DataOpe THEN @TrS_DataOpe_N ELSE TrS_DataOpe END  from cdn.TraSElem where trs_trsid = @TrS_ZwrId_N
                 INSERT INTO CDN.TraSElem       (  TrS_TrEId,  TrS_TrSIdDost,      TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena   )
                 VALUES                         ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N )
                 SELECT @TrS_TrSId_MMWZKK =  scope_identity(),@LastID = SCOPE_IDENTITY()
                 EXECUTE CDN.AktualizujWZKK @TrS_TrEId_N, @TrS_TrEId_WZKK,@TrS_TrEId,@New_TrEId_WZKK output     -- generowanie automatyczne dokumetentu WZKK dla każdego subelementu
                 SET @TrE_TrEId_MMWZKK1 = @New_TrEId_WZKK
                 if not exists(select * from @AktWZKK where TrS_TrEId =  @TrS_TrEId_N and TrS_TrEId_WZKK = @New_TrEId_WZKK)
     insert into  @AktWZKK values (@TrS_TrEId_N, @New_TrEId_WZKK,0)
     --update CDN.TraSElem SET TrS_TrEId = @TrE_TrEId_MMWZKK1 WHERE TrS_TrSId = @TrS_TrSId_MMWZKK
     set @TrS_TrEId_N =@New_TrEId_WZKK
    update a set   a.TrS_TrEId = @New_TrEId_WZKK  from cdn.TraSElem a
    where  TrS_TrSID = @LastID
            declare @zas_trsid3 int
select @Zas_TrsId3 =  TrS_TrSId
   FROM cdn.TraSElem P
 JOIN cdn.TraElem ON TrE_TrEId = P.TrS_TrEId
 JOIN cdn.TraNag  ON TrN_TrNId = TrE_TrNId
 WHERE P.TrS_TwrId     = @TrS_TwrId
 AND P.TrS_MagId     = @TrS_MagId
 AND P.TrS_TrSIdDost = @TrS_TrSIdDost
 AND P.TrS_Typ       = 2
 AND P.TrS_ZwrId IS NULL
 AND P.TrS_Ilosc    >= 0
 AND TrN_Rodzaj in (312000,312008)
 AND TrN_MagZrdId = @TrS_MagId
  AND P.TrS_TrEId =  @Zas_TrEid1
group by p.trs_trsid
if @Zas_TrsId3 is null
select @Zas_TrsId3 =  TrS_TrSId
   FROM cdn.TraSElem P
 JOIN cdn.TraElem ON TrE_TrEId = P.TrS_TrEId
 JOIN cdn.TraNag WZ ON WZ.TrN_TrNId = TrE_TrNId
 JOIN cdn.TraNag ORG ON ORG.TrN_TrNId =WZ.TRN_ZWRID
 WHERE P.TrS_TwrId     = @TrS_TwrId
 AND P.TrS_MagId     = @TrS_MagId
 AND P.TrS_TrSIdDost = @TrS_TrSIdDost
 AND P.TrS_Typ       = 2
 AND P.TrS_ZwrId IS NULL
 AND P.TrS_Ilosc    >= 0
 AND WZ.TrN_Rodzaj = 306071
 AND ORG.TrN_Rodzaj in (312000,312008)
 AND WZ.TrN_MagZrdId = @TrS_MagId
 AND P.TrS_TrEId =  @Zas_TrEid1
group by p.trs_trsid
if @Zas_TrsId3 is null
select @Zas_TrsId3 =  TrS_TrSId
   FROM cdn.TraSElem P
 JOIN cdn.TraElem ON TrE_TrEId = P.TrS_TrEId
 JOIN cdn.TraNag WZ ON WZ.TrN_TrNId = TrE_TrNId
 --JOIN cdn.TraNag ORG ON ORG.TrN_TrNId =WZ.TRN_ZWRID
 WHERE P.TrS_TwrId     = @TrS_TwrId
 AND P.TrS_MagId     = @TrS_MagId
 AND P.TrS_TrSIdDost = @TrS_TrSIdDost
 AND P.TrS_Typ       = 2
 AND P.TrS_ZwrId IS NULL
 AND P.TrS_Ilosc    >= 0
 AND WZ.TrN_Rodzaj = 306071
 --AND ORG.TrN_Rodzaj in (312000,312008)
 AND WZ.TrN_MagZrdId = @TrS_MagId
  AND P.TrS_TrEId =  @Zas_TrEid1
group by p.trs_trsid
if @Zas_TrsId3 is null
select @Zas_TrsId3 =  TrS_TrSId
   FROM cdn.TraSElem P
 JOIN cdn.TraElem ON TrE_TrEId = P.TrS_TrEId
 JOIN cdn.TraNag  ON TrN_TrNId = TrE_TrNId
 WHERE P.TrS_TwrId     = @TrS_TwrId
 AND P.TrS_MagId     = @TrS_MagId
 AND P.TrS_TrSIdDost = @TrS_TrSIdDost
 AND P.TrS_Typ       = 2
 AND P.TrS_ZwrId IS NULL
 AND P.TrS_Ilosc    >= 0
 AND TrN_Rodzaj in (312000,312008)
 AND TrN_MagZrdId = @TrS_MagId
 AND P.TrS_TrEId <> @TrS_TrEId
group by p.trs_trsid
if @Zas_TrsId3 is null
select @Zas_TrsId3 =  TrS_TrSId
   FROM cdn.TraSElem P
 JOIN cdn.TraElem ON TrE_TrEId = P.TrS_TrEId
 JOIN cdn.TraNag WZ ON WZ.TrN_TrNId = TrE_TrNId
 JOIN cdn.TraNag ORG ON ORG.TrN_TrNId =WZ.TRN_ZWRID
 WHERE P.TrS_TwrId     = @TrS_TwrId
 AND P.TrS_MagId     = @TrS_MagId
 AND P.TrS_TrSIdDost = @TrS_TrSIdDost
 AND P.TrS_Typ       = 2
 AND P.TrS_ZwrId IS NULL
 AND P.TrS_Ilosc    >= 0
 AND WZ.TrN_Rodzaj = 306071
 AND ORG.TrN_Rodzaj in (312000,312008)
 AND WZ.TrN_MagZrdId = @TrS_MagId
 AND P.TrS_TrEId <> @TrS_TrEId
group by p.trs_trsid
if @Zas_TrsId3 is null
select @Zas_TrsId3 =  TrS_TrSId
   FROM cdn.TraSElem P
 JOIN cdn.TraElem ON TrE_TrEId = P.TrS_TrEId
 JOIN cdn.TraNag WZ ON WZ.TrN_TrNId = TrE_TrNId
 --JOIN cdn.TraNag ORG ON ORG.TrN_TrNId =WZ.TRN_ZWRID
 WHERE P.TrS_TwrId     = @TrS_TwrId
 AND P.TrS_MagId     = @TrS_MagId
 AND P.TrS_TrSIdDost = @TrS_TrSIdDost
 AND P.TrS_Typ       = 2
 AND P.TrS_ZwrId IS NULL
 AND P.TrS_Ilosc    >= 0
 AND WZ.TrN_Rodzaj = 306071
 --AND ORG.TrN_Rodzaj in (312000,312008)
 AND WZ.TrN_MagZrdId = @TrS_MagId
 AND P.TrS_TrEId <> @TrS_TrEId
group by p.trs_trsid
                 -- komplementarny subelement przychodowy (MM-kowy) na magazyn źródłowy
                 SELECT
                   @TrS_ZwrId_N     = @zas_trsid3 , --NULL,
                   @TrS_MagId_N     = @TrS_MagId,
                   @TrS_Ilosc_N     = - ABS(@TrS_Ilosc_N),
                   @TrS_Wartosc_N   = - ABS(@TrS_Wartosc_N),
                   @TrS_TrEId_N     = (SELECT ISNULL(MAX(TrS_TrEId),1) FROM CDN.TraSelem)+1,
                   @TrS_TrEId_WZKK       =  @Zas_TrEid1
                   select @TrS_DataOpe_N = CASE WHEN @TrS_DataOpe_N > TrS_DataOpe THEN @TrS_DataOpe_N ELSE TrS_DataOpe END  from cdn.TraSElem where trs_trsid = @TrS_ZwrId_N
                 INSERT INTO CDN.TraSElem       (  TrS_TrEId,  TrS_TrSIdDost,      TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena   )
                 VALUES                         ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N )
                 set @LastID = SCOPE_IDENTITY()
                 EXECUTE CDN.AktualizujWZKK @TrS_TrEId_N, @TrS_TrEId_WZKK,@TrS_TrEId,@New_TrEId_WZKK output       -- generowanie automatyczne dokumetentu WZKK dla każdego subelementu
                 set @TrE_TrEId_MMWZKK  = @New_TrEId_WZKK
                 if not exists(select * from @AktWZKK where TrS_TrEId =  @TrS_TrEId_N and TrS_TrEId_WZKK = @New_TrEId_WZKK)
     insert into  @AktWZKK values (@TrS_TrEId_N, @New_TrEId_WZKK,2)
     set @TrS_TrEId_N =@New_TrEId_WZKK
     update a set   a.TrS_TrEId = @New_TrEId_WZKK  from cdn.TraSElem a
     where  TrS_TrSID = @LastID
                 -- obsługa śmieci wartościowych - subelement korekcyjny, jeśli zosała jakaś wartość dodatnia bez ilości
                 IF @Zas_Ilosc_Pozostala = 0 AND @Zas_Wartosc_Pozostala > 0
                    BEGIN
                      SELECT
                        @TrS_ZwrId_N     = NULL,
                        @TrS_MagId_N     = @Zas_MagId,
                        @TrS_Ilosc_NS     = 0,
                        @TrS_Wartosc_N   = @Zas_Wartosc_Pozostala,
                        @TrS_TrEId_N     = (SELECT ISNULL(MAX(TrS_TrEId),1) FROM CDN.TraSelem)
                      INSERT INTO CDN.TraSElem (  TrS_TrEId,    TrS_TrSIdDost,    TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena    )
                        VALUES                 ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_NS, @TrS_Wartosc_N, @TrS_Cena_N  )
              --  EXECUTE CDN.AktualizujWZKK @TrS_TrEId_N, @TrS_TrEId_WZKK,@TrS_TrEId        -- generowanie automatyczne dokumetentu WZKK dla każdego subelementu
                    END
                 -- zestaw zasobów sklonowanych z innych dostaw z magazynu źródłowego
                 DECLARE @TrS_TrEId_MM INT
                 SET @TrS_TREId_MM = (SELECT ISNULL(MAX(TrS_TrEId),1) FROM CDN.TraSelem)
                 SELECT
                   @TrS_ZwrId_N     = NULL,
                   @TrS_MagId_N     = @TrS_MagId,
                   @TrS_Ilosc_N     = ABS(@TrS_Ilosc_N),
                   @TrS_Wartosc_N   = 0,
                   @TrS_TrSId_N     = NULL --10.0
   -- 10.0 inicjalizacja wartości TrS_TrSId_N dla potrzeb kompelementarnego sublementu
     SELECT @TrS_TrSId_N     = MAX(TrS_TrSID) FROM CDN.TraSelem
                 EXECUTE CDN.KlonujTraSelem 3, NULL, @TrS_TREId_MM, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N, @TrE_ZwrId, @TrN_TrNId, @TrN_MagDocId, @TrN_Bufor_Doc
                 -- ten sam zestaw na magazyn obcy
                 DELETE FROM @TraSElem
                 INSERT INTO @TraSElem  (  TrS_TrSId, TrS_TrEId, TrS_TrSIdDost, TrS_ZwrId, TrS_TwrId, TrS_MagId, TrS_Rodzaj, TrS_Typ, TrS_Metoda, TrS_DataOpe, TrS_Ilosc, TrS_Wartosc, TrS_Cena   )
                   SELECT                  TrS_TrSId, TrS_TrEId, TrS_TrSIdDost, TrS_ZwrId, TrS_TwrId, TrS_MagId, TrS_Rodzaj, TrS_Typ, TrS_Metoda, TrS_DataOpe, TrS_Ilosc, TrS_Wartosc, TrS_Cena
                     FROM CDN.TraSElem
                       WHERE TrS_TrEId      =  @TrS_TrEId_MM
                         AND TrS_TrSId      > @TrS_TrSId_N
                         AND TrS_TwrId      =  @TrS_TwrId
                         AND TrS_Typ        =  2
                         AND TrS_Rodzaj     =  306071
                         AND TrS_ZwrId      IS NULL
                 DECLARE S CURSOR LOCAL FAST_FORWARD FOR
                   SELECT     TrS_TrSId,    TrS_TrEId,  TrS_TrSIdDost,      TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena
                     FROM @TraSElem ORDER BY TrS_TrSId
                       OPEN S
                         WHILE 1=1
                           BEGIN
                             FETCH NEXT FROM S INTO @TrS_TrSId_N, @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N
                             IF @@FETCH_STATUS <> 0 BREAK
                               SELECT
                                 @TrS_ZwrId_N     = NULL,
                                 @TrS_MagId_N     = @Zas_MagId,
                                 @TrS_Ilosc_N     = - ABS(@TrS_Ilosc_N),
                                 @TrS_Wartosc_N   = - ABS(@TrS_Wartosc_N),
                                 @TrS_TrEId_N     = @Wartosc,
                                 @TrS_TreId_WZKK =  @Zas_TrEid1
                                 if (@TrS_TrSId_MMWZKK is not null and @TrE_TrEId_MMWZKK1 is not null)
                                   INSERT INTO CDN.TraSElem       (  TrS_TrEId,  TrS_TrSIdDost,      TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena   )
                                   VALUES                         ( @TrE_TrEId_MMWZKK1, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N )
                                 else
                                   INSERT INTO CDN.TraSElem       (  TrS_TrEId,  TrS_TrSIdDost,      TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena   )
                                   VALUES                         ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N )
               --                EXECUTE CDN.AktualizujWZKK @TrS_TrEId_N, @TrS_TrEId_WZKK,@TrS_TrEId        -- generowanie automatyczne dokumetentu WZKK dla każdego subelementu
                           END
                        CLOSE S
                  DEALLOCATE S
                END
             -- subelementy do zwrotu z innego magazynu
             ELSE IF @Zas_TwZTrS = 1 AND @Zas_MagId <> @TrS_MagId
               BEGIN
                 -- subelement zwrotny na obcym magazynie i aktualizacja zasobów
                 SELECT
                   @TrS_ZwrId_N     = @Zas_TrSId,
                   @TrS_MagId_N     = @Zas_MagId,
                   @TrS_Ilosc_N     = - ABS(@TrS_Ilosc_N),
                   @TrS_Wartosc_N   = - ABS(@TrS_Wartosc_N),
                   @TrS_TrEId_N     = (SELECT ISNULL(MAX(TrS_TrEId),1) FROM CDN.TraSelem)+2,
                   @TrS_TrEId_WZKK  = @Zas_TrEId
declare @wartosc2 int
set @wartosc2 = @trs_treid_N
                 INSERT INTO CDN.TraSElem (  TrS_TrEId,    TrS_TrSIdDost,    TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena    )
                   VALUES                 ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N  )
                 set @LastID = SCOPE_IDENTITY()
                 EXECUTE CDN.AktualizujWZKK @TrS_TrEId_N, @TrS_TrEId_WZKK,@TrS_TrEId,@New_TrEId_WZKK  output      -- generowanie automatyczne dokumetentu WZKK dla każdego subelementu
                 if not exists(select * from @AktWZKK where TrS_TrEId =  @TrS_TrEId_N and TrS_TrEId_WZKK = @New_TrEId_WZKK)
     insert into  @AktWZKK values (@TrS_TrEId_N, @New_TrEId_WZKK,0)
set @wartosc2 = @New_TrEId_WZKK
update a set  TrS_TrEId = @New_TrEId_WZKK  from cdn.TraSElem a WHERE a.TrS_TrSID = @LastID
     set @TrS_TrEId_N =@New_TrEId_WZKK
set @wartosc2 = @New_TrEId_WZKK
 BEGIN
declare @Zas_TreId3 int
select @Zas_TrsId1 =  TrS_TrSId, @Zas_TrEId1 = MAX(TrS_TrEid) FROM cdn.TraSElem P
 JOIN cdn.TraElem ON TrE_TrEId = P.TrS_TrEId
 JOIN cdn.TraNag  ON TrN_TrNId = TrE_TrNId
 WHERE P.TrS_TwrId     = @TrS_TwrId
 AND P.TrS_MagId     <> @TrS_MagId
 AND P.TrS_MagId  = @Zas_MagId
 AND P.TrS_TrSIdDost = @TrS_TrSIdDost
 AND P.TrS_Typ       = 2
 AND P.TrS_ZwrId IS NULL
 AND P.TrS_Ilosc    <= 0
 AND TrN_Rodzaj in (312000,312008)
 AND TrN_MagZrdId = @TrS_MagId AND TrN_MagDocId <> @TrS_MagId
 AND P.TrS_TrEId <> @TrS_TrEId
       group by p.trs_trsid
-- jak nie znajdziemy dla konkretnego magazynu to szukamy pozostałe
if @Zas_TrEId1 is null
select @Zas_TrsId1 =  TrS_TrSId, @Zas_TrEId1 = MAX(TrS_TrEid) FROM cdn.TraSElem P
 JOIN cdn.TraElem ON TrE_TrEId = P.TrS_TrEId
 JOIN cdn.TraNag  ON TrN_TrNId = TrE_TrNId
 WHERE P.TrS_TwrId     = @TrS_TwrId
 AND P.TrS_MagId     <> @TrS_MagId
 AND P.TrS_TrSIdDost = @TrS_TrSIdDost
 AND P.TrS_Typ       = 2
 AND P.TrS_ZwrId IS NULL
 AND P.TrS_Ilosc    <= 0
 AND TrN_Rodzaj in (312000,312008)
 AND TrN_MagZrdId = @TrS_MagId AND TrN_MagDocId <> @TrS_MagId
 AND P.TrS_TrEId <> @TrS_TrEId
       group by p.trs_trsid
        select @Zas_TrsId3 =  TrS_TrSId, @Zas_TrEId3 = MAX(TrS_TrEId)
   FROM cdn.TraSElem P
 JOIN cdn.TraElem ON TrE_TrEId = P.TrS_TrEId
 JOIN cdn.TraNag  ON TrN_TrNId = TrE_TrNId
 WHERE P.TrS_TwrId     = @TrS_TwrId
 AND P.TrS_MagId     = @TrS_MagId
 AND P.TrS_TrSIdDost = @TrS_TrSIdDost
 AND P.TrS_Typ       = 2
 AND P.TrS_ZwrId IS NULL
 AND P.TrS_Ilosc    >= 0
 AND TrN_Rodzaj in (312000,312008)
 AND TrN_MagZrdId = @TrS_MagId
 AND P.TrS_TrEId <> @TrS_TrEId
 AND P.TrS_TrEId = @Zas_TrEId1
group by p.trs_trsid
                    END
                 -- przesunięcie zasobów na magazyn źródłowy
                 -- subelement rozchodowy z magazynu obcego
                 SELECT
                   @TrS_ZwrId_N     = @Zas_TrsId1, --NULL,
                   @TrS_MagId_N     = @Zas_MagId,
                   @TrS_Ilosc_N     = ABS(@TrS_Ilosc_N),
                   @TrS_Wartosc_N   = ABS(@TrS_Wartosc_N),
                   @TrS_TrEId_N     = (SELECT ISNULL(MAX(TrS_TrEId),1) FROM CDN.TraSelem)+1,
                   @TrS_TrEId_WZKK  = @Zas_TrEId1
declare @wartosc1 int
set @wartosc1 = @TrS_TrEId_N
                 INSERT INTO CDN.TraSElem       (  TrS_TrEId,  TrS_TrSIdDost,      TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena   )
                 VALUES                         ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N )
                 set @LastID = SCOPE_IDENTITY()
                 EXECUTE CDN.AktualizujWZKK @TrS_TrEId_N, @TrS_TrEId_WZKK,@TrS_TrEId,@New_TrEId_WZKK  output      -- generowanie automatyczne dokumetentu WZKK dla każdego subelementu
                 if not exists(select * from @AktWZKK where TrS_TrEId =  @TrS_TrEId_N and TrS_TrEId_WZKK = @New_TrEId_WZKK)
     insert into  @AktWZKK values (@TrS_TrEId_N, @New_TrEId_WZKK,0)
      update a set  TrS_TrEId = @New_TrEId_WZKK  from cdn.TraSElem a WHERE a.TrS_TrSID = @LastID
   set @TrS_TrEId_N =@New_TrEId_WZKK
set @wartosc1 =@New_TrEId_WZKK
                 -- komplementarny subelement przychodowy (MM-kowy) na magazyn docelowy
                 SELECT
                   @TrS_ZwrId_N     = @Zas_TrsId3,
                   @TrS_MagId_N     = @TrS_MagId,
                   @TrS_Ilosc_N     = - ABS(@TrS_Ilosc_N),
                   @TrS_Wartosc_N   = - ABS(@TrS_Wartosc_N),
                   @TrS_TrEId_N     = (SELECT ISNULL(MAX(TrS_TrEId),1) FROM CDN.TraSelem)+1,
                   @TrS_TrEId_WZKK  = @Zas_TrEId3
                 INSERT INTO CDN.TraSElem       (  TrS_TrEId,  TrS_TrSIdDost,      TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena   )
                 VALUES                         ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N )
                 set @LastID = SCOPE_IDENTITY()
                 EXECUTE CDN.AktualizujWZKK @TrS_TrEId_N, @TrS_TrEId_WZKK,@TrS_TrEId,@New_TrEId_WZKK  output      -- generowanie automatyczne dokumetentu WZKK dla każdego subelementu
                 if not exists(select * from @AktWZKK where TrS_TrEId =  @TrS_TrEId_N and TrS_TrEId_WZKK = @New_TrEId_WZKK)
     insert into  @AktWZKK values (@TrS_TrEId_N, @New_TrEId_WZKK,2)
     update a set  TrS_TrEId = @New_TrEId_WZKK  from cdn.TraSElem a WHERE a.TrS_TrSID = @LastID
   set @TrS_TrEId_N =@New_TrEId_WZKK
                 -- zestaw zasobów sklonowanych z innych dostaw z magazynu źródłowego
                 SELECT
                   @TrS_ZwrId_N     = NULL,
                   @TrS_MagId_N     = @TrS_MagId,
                   @TrS_Ilosc_N     = ABS(@TrS_Ilosc_N),
                   @TrS_Wartosc_N   = 0,
                   @TrS_TrSId_N     = NULL --10.0,
   -- 10.0 inicjalizacja wartości TrS_TrSId_N dla potrzeb kompelementarnego sublementu
                 SELECT @TrS_TrSId_N     = MAX(TrS_TrSID) FROM CDN.TraSelem
                 EXECUTE CDN.KlonujTraSelem 3, NULL, @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N, @TrE_ZwrId, @TrN_TrNId, @TrN_MagDocId, @TrN_Bufor_Doc
                 -- ten sam zestaw na magazyn docelowy + rozchód na magazynie docelowym
                 DELETE FROM @TraSElem
                 INSERT INTO @TraSElem  (  TrS_TrSId, TrS_TrEId, TrS_TrSIdDost, TrS_ZwrId, TrS_TwrId, TrS_MagId, TrS_Rodzaj, TrS_Typ, TrS_Metoda, TrS_DataOpe, TrS_Ilosc, TrS_Wartosc, TrS_Cena   )
                   SELECT                  TrS_TrSId, TrS_TrEId, TrS_TrSIdDost, TrS_ZwrId, TrS_TwrId, TrS_MagId, TrS_Rodzaj, TrS_Typ, TrS_Metoda, TrS_DataOpe, TrS_Ilosc, TrS_Wartosc, TrS_Cena
                     FROM CDN.TraSElem
                       WHERE TrS_TrEId      =  @TrS_TrEId_N
                         AND TrS_TrSId      > @TrS_TrSId_N
                         AND TrS_ZwrId      IS NULL
                         AND TrS_TwrId      =  @TrS_TwrId
                         AND TrS_Typ        =  2
                         AND TrS_Rodzaj     =  306071
                 DECLARE S CURSOR LOCAL FAST_FORWARD FOR
                   SELECT     TrS_TrSId,    TrS_TrEId,  TrS_TrSIdDost,      TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena
                     FROM @TraSElem ORDER BY TrS_TrSId
                       OPEN S
                         WHILE 1=1
                           BEGIN
                             FETCH NEXT FROM S INTO @TrS_TrSId_N, @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N
                             IF @@FETCH_STATUS <> 0 BREAK
                               -- przyjęcie na magazyn docelowy
                               SELECT
                                 @TrS_ZwrId_N     =  @zas_trsid1, -- NULL,
                                 @TrS_MagId_N     = @Zas_MagId,
                                 @TrS_Ilosc_N     = - ABS(@TrS_Ilosc_N),
                                 @TrS_Wartosc_N   = - ABS(@TrS_Wartosc_N),
                                 @TrS_TrEId_N     = @wartosc1,
                                 @TrS_TrEId_WZKK  = @Zas_TrEId1
                               INSERT INTO CDN.TraSElem       (  TrS_TrEId,  TrS_TrSIdDost,      TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena   )
                               VALUES                         ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N )
                               set @LastID = SCOPE_IDENTITY()
                 EXECUTE CDN.AktualizujWZKK @TrS_TrEId_N, @TrS_TrEId_WZKK,@TrS_TrEId,@New_TrEId_WZKK output       -- generowanie automatyczne dokumetentu WZKK dla każdego subelementu
                 if not exists(select * from @AktWZKK where TrS_TrEId =  @TrS_TrEId_N and TrS_TrEId_WZKK = @New_TrEId_WZKK)
    insert into  @AktWZKK values (@TrS_TrEId_N, @New_TrEId_WZKK,0)
    update a set  TrS_TrEId = @New_TrEId_WZKK  from cdn.TraSElem a WHERE a.TrS_TrSID = @LastID
    set @TrS_TrEId_N =@New_TrEId_WZKK
                               -- rozchód z magazynu docelowego
                               SELECT
                                 @TrS_ZwrId_N     = @zas_trsid,
                                 @TrS_MagId_N     = @Zas_MagId,
                                 @TrS_Ilosc_N     = ABS(@TrS_Ilosc_N),
                                 @TrS_Wartosc_N   = ABS(@TrS_Wartosc_N),
                                 @TrS_TrEId_N     = @wartosc2,
                                 @TrS_TrEId_WZKK  = @Zas_TrEId
                               INSERT INTO CDN.TraSElem       (  TrS_TrEId,  TrS_TrSIdDost,      TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena   )
                               VALUES                         ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N )
                               set @LastID = SCOPE_IDENTITY()
                 EXECUTE CDN.AktualizujWZKK @TrS_TrEId_N, @TrS_TrEId_WZKK,@TrS_TrEId,@New_TrEId_WZKK  output      -- generowanie automatyczne dokumetentu WZKK dla każdego subelementu
                 if not exists(select * from @AktWZKK where TrS_TrEId =  @TrS_TrEId_N and TrS_TrEId_WZKK = @New_TrEId_WZKK)
     insert into  @AktWZKK values (@TrS_TrEId_N, @New_TrEId_WZKK,0)
 update a set  TrS_TrEId = @New_TrEId_WZKK  from cdn.TraSElem a WHERE a.TrS_TrSID = @LastID
     set @TrS_TrEId_N =@New_TrEId_WZKK
                           END
                        CLOSE S
                  DEALLOCATE S
               END -- subelementy do korekty z magazynu obcego
            END -- kursor z zasobami
        CLOSE Z
    DEALLOCATE Z
   --  update a set  TrS_TrEId = b.TrS_TrEId_WZKK  from cdn.TraSElem a join @AktWZKK b on a.TrS_TrEId = b.TrS_TrEId where b.typ = 1
   --  update a set  a.TrS_TrEId = b.TrS_TrEId_WZKK  from cdn.TraSElem a join @AktWZKK b on a.TrS_TrEId = b.TrS_TrEId
  --   left join cdn.traelem on TrE_TrEID = b.TrS_TrEId
   --  where TrE_TrEID is NULL
     update c set trs_dataope = tre_dataope
    from @AktWZKK b
    join  cdn.TraElem a on a.Tre_TrEId = b.TrS_TrEId_WZKK
    join  cdn.TrasElem c on c.TrS_TrEId = b.TrS_TrEId
    where trs_dataope <> tre_dataope
--return
--select * from cdn.traselem where trs_rodzaj = 306071
    -- Kontrola, czy wystarczyło ilości i wartości
    IF @Ilosc_Potrzebna <> 0 OR @Wartosc_Potrzebna <> 0
      GOTO KOMUNIKAT
    -- aktualizacja zasobów z przekazanym subelementem (właściwa korekta)
    INSERT INTO CDN.TraSElem (  TrS_TrEId,  TrS_TrSIdDost,  TrS_ZwrId,  TrS_TwrId,  TrS_MagId,  TrS_Rodzaj,  TrS_Typ,  TrS_Metoda,  TrS_DataOpe,  TrS_Ilosc,  TrS_Wartosc,  TrS_Cena  )
      VALUES                 ( @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena  )
       if @TrE_TrEId_MMWZKK is not null
          update cdn.traselem set trs_treid = @TrE_TrEId_MMWZKK
          WHERE TrS_TrEId = @TrS_TrEId AND  TrS_Rodzaj IN (306071, 306072, 306061 )
    END -- Korekta ilościowe do dostaw na minus
  -- Korekta wartościowa do dostaw na plus/minus dla AVCO
  IF @TrS_Typ = 1 AND @TrS_Ilosc = 0 AND @TrS_Wartosc <> 0 AND @TrS_Metoda IN ( 3 )
    BEGIN
        -- maksymalna możliwa wartość wg tabeli TwrIlosci
        IF @TrS_Wartosc < 0
          SET @Wartosc_Potrzebna = ABS(@TrS_Wartosc)
        ELSE
          SET @Wartosc_Potrzebna = 0
      -- dostępne zasoby dla korekt do tabeli tymczasowej
      INSERT INTO @ZasobyDlaKorekt   ( Zas_Id,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor     )
        SELECT                         Zas_Id,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor
          FROM CDN.ZasobyDlaKorekt ( @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena, @TrE_ZwrId  )
            WHERE TrN_Bufor IN ( 0, 1 )  -- tylko dokumenty nie będące w buforze
            ORDER BY Zas_Id              -- najpierw zasoby z magazynu źródłowego, potem subelemnety do zwrotu z magazynu źródłowego, potem zasoby z innych magazynów, potem subelementy do zwrotu z innych magazynów
        -- kursor po dostępnych zasobach z tabeli tymczasowej @ZasobyDlaKorekt
        DECLARE Z CURSOR LOCAL FAST_FORWARD FOR
          SELECT                          Zas_Id,  Zas_TwZTrS,  Zas_TwZId,  Zas_TrSId,  Zas_TrEId,  Zas_TrSIdDost,  Zas_TrSZwrId,  Zas_TwrId,  Zas_MagId,  Zas_Rodzaj,  Zas_Typ,  Zas_Metoda,  Zas_DataOpe,  Zas_Ilosc,  Zas_Wartosc,  Zas_Cena,  TrN_Bufor
            FROM @ZasobyDlaKorekt ORDER BY Zas_TwZTrS, Zas_Wartosc DESC
            OPEN Z
              WHILE 1=1
                BEGIN
                  FETCH NEXT FROM Z INTO @Zas_Id, @Zas_TwZTrS, @Zas_TwZId, @Zas_TrSId, @Zas_TrEId, @Zas_TrSIdDost, @Zas_TrSZwrId, @Zas_TwrId, @Zas_MagId, @Zas_Rodzaj, @Zas_Typ, @Zas_Metoda, @Zas_DataOpe, @Zas_Ilosc, @Zas_Wartosc, @Zas_Cena, @TrN_Bufor
                  IF @@FETCH_STATUS <> 0 BREAK
                  IF @Wartosc_Potrzebna = 0 BREAK
                    -- wielkości wspólne do tworzenia subelementów
                    SELECT
                      @TrS_TrEId_N     = @TrS_TrEId,
                      @TrS_TrSIdDost_N = NULL,
                      @TrS_TwrId_N     = @TrS_TwrId,
                      @TrS_Rodzaj_N    = 306072,
                      @TrS_Typ_N       = 2,
                      @TrS_Metoda_N    = @TrS_Metoda,
                      @TrS_DataOpe_N   = @TrS_DataOpe,
                      @TrS_Ilosc_N     = 0,
                      @TrS_Cena_N      = @Zas_Cena
                  -- zasoby natywne z tego samego magazynu
                  IF @Zas_TwZTrS = 0 AND @Zas_MagId = @TrS_MagId
                    BEGIN
                      SELECT
                        @TwI_Wartosc_Max = MIN(TwI_Wartosc)
                      FROM CDN.TwrIlosci WITH (INDEX = TwITowar)
                      WHERE TwI_TwrId = @Zas_TwrId
                        AND TwI_MagId = @Zas_MagId
                        AND TwI_Data  >= (
                                           SELECT MAX(TwI_Data)
                                           FROM CDN.TwrIlosci WITH (INDEX = TwITowar)
                                           WHERE TwI_TwrId = @Zas_TwrId
                                             AND TwI_MagId = @Zas_MagId
                                             AND TwI_Data <= @TrS_DataOpe
                                          )
                      SELECT @TwZ_Wartosc_Max = ISNULL(TwZ_Wartosc,0)
                        FROM CDN.TwrZasoby
                        WHERE TwZ_TwrId = @TrS_TwrId
                          AND TwZ_MagId = @Zas_MagId
                      SELECT
                        @TwI_Wartosc_Max = ISNULL(@TwI_Wartosc_Max,0),
                        @TwZ_Wartosc_Max = ISNULL(@TwZ_Wartosc_Max,0)
                      SET @TrS_Wartosc_N         = 0
                      SET @TrS_Wartosc_N         = ( SELECT MIN(A) FROM ( SELECT A = @Zas_Wartosc UNION ALL SELECT A = @Wartosc_Potrzebna UNION ALL SELECT A = @TwI_Wartosc_Max UNION ALL SELECT A = @TwZ_Wartosc_Max ) AS B )
                      SET @Wartosc_Potrzebna     = @Wartosc_Potrzebna - @TrS_Wartosc_N
                    END
                 -- subelementy kosztowe do zwrotu z tego samego magazynu
                 ELSE IF @Zas_TwZTrS = 1 AND @Zas_MagId = @TrS_MagId
                   BEGIN
                      SET @TrS_Wartosc_N         = 0
                      SET @TrS_Wartosc_N         = ( SELECT MIN(A) FROM ( SELECT A = @Zas_Wartosc UNION ALL SELECT A = @Wartosc_Potrzebna ) AS B )
                      SET @Wartosc_Potrzebna     = @Wartosc_Potrzebna - @TrS_Wartosc_N
                     -- subelement zwrotny i aktualizacja zasobów
                     SELECT
                       @TrS_MagId_N     = @Zas_MagId,
                       @TrS_ZwrId_N     = @Zas_TrSId,
                       @TrS_Wartosc_N   = - ABS(@TrS_Wartosc_N)
                     INSERT INTO CDN.TraSElem (  TrS_TrEId,    TrS_TrSIdDost,    TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena    )
                       VALUES                 ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N  )
                   END
                 -- zasoby natywne z innego magazynu
                 ELSE IF @Zas_TwZTrS = 0 AND @Zas_MagId <> @TrS_MagId
                   BEGIN
              SELECT
                       @TwI_Wartosc_Max = MIN(TwI_Wartosc)
                     FROM CDN.TwrIlosci WITH (INDEX = TwITowar)
                     WHERE TwI_TwrId = @Zas_TwrId
                       AND TwI_MagId = @Zas_MagId
                       AND TwI_Data  >= (
                                          SELECT MAX(TwI_Data)
                                          FROM CDN.TwrIlosci WITH (INDEX = TwITowar)
                                          WHERE TwI_TwrId = @Zas_TwrId
                                            AND TwI_MagId = @Zas_MagId
                                            AND TwI_Data <= @TrS_DataOpe
                                         )
                     SELECT @TwZ_Wartosc_Max = ISNULL(TwZ_Wartosc,0)
                       FROM CDN.TwrZasoby
                      WHERE TwZ_TwrId = @TrS_TwrId
                        AND TwZ_MagId = @Zas_MagId
                     SELECT
                       @TwI_Wartosc_Max = ISNULL(@TwI_Wartosc_Max,0),
                       @TwZ_Wartosc_Max = ISNULL(@TwZ_Wartosc_Max,0)
                     SET @TrS_Wartosc_N         = 0
                     SET @TrS_Wartosc_N         = ( SELECT MIN(A) FROM ( SELECT A = @Zas_Wartosc UNION ALL SELECT A = @Wartosc_Potrzebna UNION ALL SELECT A = @TwI_Wartosc_Max UNION ALL SELECT A = @TwZ_Wartosc_Max ) AS B )
                     SET @Wartosc_Potrzebna     = @Wartosc_Potrzebna - @TrS_Wartosc_N
                     -- subelement rozchodowy z magazynu obcego
                     SELECT
                       @TrS_ZwrId_N     = NULL,
                       @TrS_MagId_N     = @Zas_MagId,
                       @TrS_Wartosc_N   = ABS(@TrS_Wartosc_N)
                     INSERT INTO CDN.TraSElem       (  TrS_TrEId,  TrS_TrSIdDost,      TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena   )
                     VALUES                         ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N )
                     -- komplementarny subelement przychodowy (MM-kowy) na magazyn źródłowy
                     SELECT
                       @TrS_ZwrId_N     = NULL,
                       @TrS_MagId_N     = @TrS_MagId,
                       @TrS_Wartosc_N   = - ABS(@TrS_Wartosc_N)
                     INSERT INTO CDN.TraSElem       (  TrS_TrEId,  TrS_TrSIdDost,      TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena   )
                     VALUES                         ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N )
                   END
                 -- subelementy do zwrotu z innego magazynu
                 ELSE IF @Zas_TwZTrS = 1 AND @Zas_MagId <> @TrS_MagId
                   BEGIN
                      SET @TrS_Wartosc_N         = 0
                      SET @TrS_Wartosc_N         = ( SELECT MIN(A) FROM ( SELECT A = @Zas_Wartosc UNION ALL SELECT A = @Wartosc_Potrzebna ) AS B )
                      SET @Wartosc_Potrzebna     = @Wartosc_Potrzebna - @TrS_Wartosc_N
                     -- subelement zwrotny na obcym magazynie i aktualizacja zasobów
                     SELECT
                       @TrS_ZwrId_N     = @Zas_TrSId,
                       @TrS_MagId_N     = @Zas_MagId,
                       @TrS_Wartosc_N   = - ABS(@TrS_Wartosc_N)
                     INSERT INTO CDN.TraSElem (  TrS_TrEId,    TrS_TrSIdDost,    TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena    )
                       VALUES                 ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N  )
                     -- przesunięcie zasobów na magazyn źródłowy
                     -- subelement rozchodowy z magazynu obcego
                     SELECT
                       @TrS_ZwrId_N     = NULL,
                       @TrS_MagId_N     = @Zas_MagId,
                       @TrS_Wartosc_N   = ABS(@TrS_Wartosc_N)
                     INSERT INTO CDN.TraSElem       (  TrS_TrEId,  TrS_TrSIdDost,      TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena   )
                     VALUES                         ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N )
                     -- komplementarny subelement przychodowy (MM-kowy) na magazyn docelowy
                     SELECT
                       @TrS_ZwrId_N     = NULL,
                       @TrS_MagId_N     = @TrS_MagId,
                       @TrS_Wartosc_N   = - ABS(@TrS_Wartosc_N)
                     INSERT INTO CDN.TraSElem       (  TrS_TrEId,  TrS_TrSIdDost,      TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena   )
                     VALUES                         ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N )
                   END -- subelementy do korekty z magazynu obcego
                END -- kursor z zasobami
            CLOSE Z
        DEALLOCATE Z
    -- Kontrola, czy wystarczyło wartości
    IF @Wartosc_Potrzebna <> 0
      GOTO KOMUNIKAT
    -- aktualizacja zasobów z przekazanym subelementem (właściwa korekta)
    INSERT INTO CDN.TraSElem (  TrS_TrEId,  TrS_TrSIdDost,  TrS_ZwrId,  TrS_TwrId,  TrS_MagId,  TrS_Rodzaj,  TrS_Typ,  TrS_Metoda,  TrS_DataOpe,  TrS_Ilosc,  TrS_Wartosc,  TrS_Cena  )
      VALUES                 ( @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena  )
    -- jeśli wartość była dodatnia, to po dodaniu wartości na magazyn, automatyczne zdjęcie wartości, jeśli nie było ilości
    IF @TrS_Wartosc > 0
      BEGIN
        SELECT
          @TwI_Wartosc_Max = MIN(TwI_Wartosc)
        FROM CDN.TwrIlosci WITH (INDEX = TwITowar)
          WHERE TwI_TwrId = @TrS_TwrId
            AND TwI_MagId = @TrS_MagId
            AND TwI_Data  >= (
                               SELECT MAX(TwI_Data)
                               FROM CDN.TwrIlosci WITH (INDEX = TwITowar)
                               WHERE TwI_TwrId = @TrS_TwrId
                                 AND TwI_MagId = @TrS_MagId
                                 AND TwI_Data <= @TrS_DataOpe
                              )
            AND TwI_Ilosc = 0
            AND TwI_Wartosc > 0
        SELECT @TwZ_Wartosc_Max = ISNULL(TwZ_Wartosc,0)
          FROM CDN.TwrZasoby
         WHERE TwZ_TwrId = @TrS_TwrId
           AND TwZ_MagId = @TrS_MagId
           AND TwZ_Ilosc = 0
           AND TwZ_Wartosc > 0
        SELECT
          @TwI_Wartosc_Max = ISNULL(@TwI_Wartosc_Max,0),
          @TwZ_Wartosc_Max = ISNULL(@TwZ_Wartosc_Max,0)
        SET @TrS_Wartosc_N = ( SELECT MIN(A) FROM ( SELECT A = @TwI_Wartosc_Max UNION ALL SELECT A = @TwZ_Wartosc_Max ) AS B )
        -- tylko jeden subelement na wartość, która ma być dodana do magazynu (jeśli na magazynie nie ma ilości)
        SELECT
          @TrS_TrEId_N     = @TrS_TrEId,
          @TrS_TrSIdDost_N = NULL,
          @TrS_TwrId_N     = @TrS_TwrId,
          @TrS_Rodzaj_N    = 306072,
          @TrS_Typ_N       = 2,
          @TrS_Metoda_N    = @TrS_Metoda,
          @TrS_DataOpe_N   = @TrS_DataOpe,
          @TrS_Ilosc_N     = 0,
          @TrS_Cena_N      = @TrS_Cena,
          @TrS_MagId_N     = @TrS_MagId,
          @TrS_ZwrId_N     = NULL
        IF @TrS_Wartosc_N <> 0
          INSERT INTO CDN.TraSElem (  TrS_TrEId,    TrS_TrSIdDost,    TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena    )
            VALUES                 ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N  )
      END
    END -- Korekta wartościowa do dostaw na plus/minus dla AVCO
   IF EXISTS (SELECT * FROM CDN.TraSElem WHERE TrS_TrEId = @TrS_TrEId AND TrS_Rodzaj IN (306071, 306061,306072) and TrS_Metoda = 3 )
 begin
    EXECUTE CDN.AktualizujWZKK_OLD @TrS_TrEId
 end
  IF @TrS_Typ = 1 AND @TrS_Ilosc = 0 AND @TrS_TrSId <> @TrS_TrSIdDost AND @TrS_Metoda IN ( 1, 2 )
    BEGIN
          -- aktualizacja zasobów z przekazanym subelementem (właściwa korekta) - może być ujemna lub dodatnia
      INSERT INTO cdn.TraSElem (  TrS_TrEId,  TrS_TrSIdDost,  TrS_ZwrId,  TrS_TwrId,  TrS_MagId,  TrS_Rodzaj,  TrS_Typ,  TrS_Metoda,  TrS_DataOpe,  TrS_Ilosc,  TrS_Wartosc,  TrS_Cena    )
        VALUES                 ( @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena  )
      -- subelementy kosztowe z danej dostawy
      INSERT INTO @ZasobyDlaKorekt   ( Zas_Id,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor     )
        SELECT                         Zas_Id,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor
          FROM cdn.ZasobyDlaKorekt ( @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena, @TrE_ZwrId )
            WHERE TrN_Bufor IN ( 0, 1 )  -- tylko dokumenty nie będące w buforze
            ORDER BY Zas_Id              -- najpierw zasoby z magazynu źródłowego, potem subelemnety do zwrotu z magazynu źródłowego, potem zasoby z innych magazynów, potem subelementy do zwrotu z innych magazynów
      -- ilosc na dostawie pierwotnej
      DECLARE @Ilosc_D  DECIMAL ( 15, 4 )
      SET @Ilosc_D =   ( SELECT ISNULL(TrS_Ilosc,0)      FROM cdn.TraSElem WHERE TrS_TrSId = @TrS_TrSIdDost )
                     + ( SELECT ISNULL(SUM(TrS_Ilosc),0) FROM cdn.TraSElem WHERE TrS_ZwrId = @TrS_TrSIdDost )
      -- wielkości wspólne do tworzenia subelementów
      SELECT
        @TrS_TrSIdDost_N = @TrS_TrSIdDost,
        @TrS_TwrId_N     = @TrS_TwrId,
        @TrS_Rodzaj_N    = 306072,
        @TrS_Typ_N       = 2,
        @TrS_Metoda_N    = @TrS_Metoda,
        @TrS_Ilosc_N     = 0
      -- kursor po subelementach kosztowych
      DECLARE Z CURSOR LOCAL FAST_FORWARD FOR
        SELECT    Zas_Id,  Zas_TwZTrS,  Zas_TwZId,  Zas_TrSId,  Zas_TrEId,  Zas_TrSIdDost,  Zas_TrSZwrId,  Zas_TwrId,  Zas_MagId,  Zas_Rodzaj,  Zas_Typ,  Zas_Metoda,  Zas_DataOpe,  Zas_Ilosc,  Zas_Wartosc,  Zas_Cena,  TrN_Bufor
          FROM @ZasobyDlaKorekt ORDER BY Zas_Id
          OPEN Z
          WHILE 1=1
            BEGIN
              FETCH NEXT FROM Z INTO @Zas_Id, @Zas_TwZTrS, @Zas_TwZId, @Zas_TrSId, @Zas_TrEId, @Zas_TrSIdDost, @Zas_TrSZwrId, @Zas_TwrId, @Zas_MagId, @Zas_Rodzaj, @Zas_Typ, @Zas_Metoda, @Zas_DataOpe, @Zas_Ilosc, @Zas_Wartosc, @Zas_Cena, @TrN_Bufor
              IF @@FETCH_STATUS <> 0 BREAK
              -- wartość potrzebna do skorygowania subelementu kosztowego
              IF @Ilosc_D > 0
                SET @TrS_Wartosc_N = ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND ( (@Zas_Ilosc / @Ilosc_D) * @TrS_Wartosc,11),10),9),8),7),6),5),4),3),2)
              ELSE
                SET @TrS_Wartosc_N = 0
              -- dodajemy wiersz, gdy wartosc korekty rożna od zera
              IF @TrS_Wartosc_N <> 0
                BEGIN
                SELECT @TrS_DataOpeKorygowanego = TrS_DataOpe FROM CDN.TrasElem WHERE TrS_TrSId = @Zas_TrSId
                   SELECT
                    @TrS_DataOpe_N   = CASE WHEN @TrS_DataOpeKorygowanego > @TrS_DataOpe THEN @TrS_DataOpeKorygowanego ELSE @TrS_DataOpe END,
                    @TrS_TrEId_N     = (SELECT MAX(TrS_TrEID)+1 FROM CDN.TrasElem), --wyliczam kolejne id elementów do poszczególnych WZKK
                    @TrS_ZwrId_N     = @Zas_TrSId,
                    @TrS_MagId_N     = @Zas_MagId,
                    @TrS_Cena_N      = @Zas_Cena
                  INSERT INTO cdn.TraSElem (  TrS_TrEId,    TrS_TrSIdDost,    TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena   )
                  VALUES                   ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N )
                 EXECUTE CDN.AktualizujWZKK @TrS_TrEId_N, @TrS_TrEId,@TrS_TrEId,@New_TrEId_WZKK output       -- generowanie automatyczne dokumetentu WZKK dla każdego subelementu
                 if not exists(select * from @AktWZKK where TrS_TrEId =  @TrS_TrEId_N and TrS_TrEId_WZKK = @New_TrEId_WZKK)
     insert into  @AktWZKK values (@TrS_TrEId_N, @New_TrEId_WZKK,0)
                END
            END
          CLOSE Z
        DEALLOCATE Z
        SELECT
--          @TrS_TrEId_N       = @TrS_TrEId,
          @TrS_TrSIdDost_N   = @TrS_TrSIdDost,
          @TrS_TwrId_N       = @TrS_TwrId,
          @TrS_Rodzaj_N      = 306072,
          @TrS_Typ_N         = 2,
          @TrS_Metoda_N      = @TrS_Metoda,
--          @TrS_DataOpe_N     = @TrS_DataOpe,
          @TrS_Ilosc_N       = 0
        -- jeszcze raz kursor po TwrZasoby dla skorygowanej dostawy i sprawdzenie czy nie ma zerowej ilości przy niezerowej wartości
        DELETE FROM @ZasobyDlaKorekt
        INSERT INTO @ZasobyDlaKorekt   ( Zas_Id,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor    , Zas_Poziom     )
          SELECT                         Zas_Id,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor    , Zas_Poziom
            FROM CDN.ZasobyDlaKorekt ( @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena, @TrE_ZwrId )
              WHERE TrN_Bufor IN ( 0, 1 )  -- tylko dokumenty nie będące w buforze
              ORDER BY Zas_Id              -- najpierw zasoby z magazynu źródłowego, potem subelemnety do zwrotu z magazynu źródłowego, potem zasoby z innych magazynów, potem subelementy do zwrotu z innych magazynów
        SET @Wartosc_Potrzebna = 0
        -- kursor po zasobach
        DECLARE Z CURSOR LOCAL FAST_FORWARD FOR
          SELECT TwZ_MagId, TwZ_Wartosc FROM CDN.TwrZasoby WHERE TwZ_Ilosc = 0 AND TwZ_Wartosc <> 0 AND TwZ_TrSIdDost = @TrS_TrSIdDost
          OPEN Z
          WHILE 1=1
            BEGIN
              FETCH NEXT FROM Z INTO @ZaS_MagId, @Wartosc_Potrzebna
                IF @@FETCH_STATUS <> 0 BREAK
                DECLARE KW CURSOR LOCAL FAST_FORWARD FOR
                  SELECT Zas_TrSId, Zas_MagId, Zas_Wartosc, Zas_Cena FROM @ZasobyDlaKorekt WHERE Zas_MagId = @ZaS_MagId AND Zas_Rodzaj not in (312000,312008)
                  OPEN KW
                  WHILE 1=1
                    BEGIN
                      FETCH NEXT FROM KW INTO @Zas_TrSId, @Zas_MagId, @ZaS_Wartosc, @Zas_Cena
                        IF @@FETCH_STATUS <> 0 BREAK
                        IF @Wartosc_Potrzebna = 0 BREAK
                        -- jeśli wartść dodatnia (zwrot), to ważne jest, czy nie została przekroczona ilosć z subelementu korygowanego
                        IF @Wartosc_Potrzebna > 0
                          BEGIN
                            SET @TrS_Wartosc_N    = ( SELECT MIN(A) FROM ( SELECT A = @Wartosc_Potrzebna UNION ALL SELECT A = @Zas_Wartosc ) AS B )
                            SET @Wartosc_Potrzebna  = @Wartosc_Potrzebna - @TrS_Wartosc_N
                          END
                        -- jeśli wartość ujemna, (dodanie wartości na magazyn ), to NIE jest ważne, czy nie została przekroczona ilość z subelementu korygowanego - zawsze dodajemy całość potrzebną
                        ELSE
                          BEGIN
                            SET @TrS_Wartosc_N      = @Wartosc_Potrzebna
                            SET @Wartosc_Potrzebna  = 0
                          END
                        IF @TrS_Wartosc_N <> 0
                          BEGIN
                          SELECT @TrS_DataOpeKorygowanego = TrS_DataOpe FROM CDN.TrasElem WHERE TrS_TrSId = @Zas_TrSId
                   SELECT
                    @TrS_DataOpe_N   = CASE WHEN @TrS_DataOpeKorygowanego > @TrS_DataOpe THEN @TrS_DataOpeKorygowanego ELSE @TrS_DataOpe END,
                    @TrS_TrEId_N     = (SELECT MAX(TrS_TrEID)+1 FROM CDN.TrasElem), --wyliczam kolejne id elementów do poszczególnych WZKK
                    @TrS_ZwrId_N     = @Zas_TrSId,
                    @TrS_MagId_N     = @Zas_MagId,
                    @TrS_Cena_N      = @Zas_Cena
                  /* w związku ze zmianą zapisywania WZKK
                            SELECT
                              @TrS_ZwrId_N       = @Zas_TrSId,
                              @TrS_MagId_N       = @Zas_MagId,
                              @TrS_Cena_N        = @Zas_Cena
                   */
       IF EXISTS (SELECT * FROM CDN.TwrIlosci WHERE TwI_MagId = @TrS_MagId_N AND TwI_Data >= @TrS_DataOpe_N AND TwI_TwrId = @TrS_TwrId_N AND TwI_Wartosc = 0 )
                    BEGIN
      SELECT @TrS_DataOpe_min = max(TwI_Data) FROM CDN.TwrIlosci WHERE TwI_MagId = @TrS_MagId_N AND TwI_Data >= @TrS_DataOpe_N AND TwI_TwrId = @TrS_TwrId_N AND TwI_Wartosc = 0
      IF EXISTS (SELECT * FROM CDN.TwrIlosci WHERE TwI_MagId = @TrS_MagId_N AND TwI_Data >= @TrS_DataOpe_min AND TwI_TwrId = @TrS_TwrId_N AND TwI_Wartosc > 0 )
      BEGIN
       SELECT @TrS_DataOpe_N  = Min(TwI_Data)  FROM CDN.TwrIlosci WHERE TwI_MagId = @TrS_MagId_N AND TwI_Data > @TrS_DataOpe_min AND TwI_TwrId = @TrS_TwrId_N AND TwI_Wartosc > 0
      end
                    END
                            INSERT INTO cdn.TraSElem (  TrS_TrEId,    TrS_TrSIdDost,    TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena    )
                            VALUES                   ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N  )
                 EXECUTE CDN.AktualizujWZKK @TrS_TrEId_N, @TrS_TrEId,@TrS_TrEId,@New_TrEId_WZKK output
                 if not exists(select * from @AktWZKK where TrS_TrEId =  @TrS_TrEId_N and TrS_TrEId_WZKK = @New_TrEId_WZKK)
     insert into  @AktWZKK values (@TrS_TrEId_N, @New_TrEId_WZKK,0)
                          END
                    END
                  CLOSE KW
                DEALLOCATE KW
            END
          CLOSE Z
        DEALLOCATE Z
/* stare
  -- Korekta wartościowa do dostaw dla FIFO LIFO
  IF @TrS_Typ = 1 AND @TrS_Ilosc = 0 AND @TrS_TrSId <> @TrS_TrSIdDost AND @TrS_Metoda IN ( 1, 2 )
    BEGIN
      -- aktualizacja zasobów z przekazanym subelementem (właściwa korekta) - może być ujemna lub dodatnia
      INSERT INTO CDN.TraSElem (  TrS_TrEId,  TrS_TrSIdDost,  TrS_ZwrId,  TrS_TwrId,  TrS_MagId,  TrS_Rodzaj,  TrS_Typ,  TrS_Metoda,  TrS_DataOpe,  TrS_Ilosc,  TrS_Wartosc,  TrS_Cena    )
        VALUES                 ( @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena  )
      -- subelementy kosztowe z danej dostawy
      INSERT INTO @ZasobyDlaKorekt   ( Zas_Id,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor     )
        SELECT                         Zas_Id,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor
          FROM CDN.ZasobyDlaKorekt ( @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena, @TrE_ZwrId )
            WHERE TrN_Bufor IN ( 0, 1 )  -- tylko dokumenty nie będące w buforze
            ORDER BY Zas_Id              -- najpierw zasoby z magazynu źródłowego, potem subelemnety do zwrotu z magazynu źródłowego, potem zasoby z innych magazynów, potem subelementy do zwrotu z innych magazynów
      -- ilosc na dostawie pierwotnej
      DECLARE @Ilosc_D  DECIMAL ( 15, 4 )
      SET @Ilosc_D =   ( SELECT ISNULL(TrS_Ilosc,0)      FROM CDN.TraSElem WHERE TrS_TrSId = @TrS_TrSIdDost )
                     + ( SELECT ISNULL(SUM(TrS_Ilosc),0) FROM CDN.TraSElem WHERE TrS_ZwrId = @TrS_TrSIdDost )
      -- wielkości wspólne do tworzenia subelementów
      SELECT
        @TrS_TrEId_N     = @TrS_TrEId,
        @TrS_TrSIdDost_N = @TrS_TrSIdDost,
        @TrS_TwrId_N     = @TrS_TwrId,
        @TrS_Rodzaj_N    = 306072,
        @TrS_Typ_N       = 2,
        @TrS_Metoda_N    = @TrS_Metoda,
        @TrS_DataOpe_N   = @TrS_DataOpe,
        @TrS_Ilosc_N     = 0
      -- kursor po subelementach kosztowych
      DECLARE Z CURSOR LOCAL FAST_FORWARD FOR
        SELECT                        Zas_Id,  Zas_TwZTrS,  Zas_TwZId,  Zas_TrSId,  Zas_TrEId,  Zas_TrSIdDost,  Zas_TrSZwrId,  Zas_TwrId,  Zas_MagId,  Zas_Rodzaj,  Zas_Typ,  Zas_Metoda,  Zas_DataOpe,  Zas_Ilosc,  Zas_Wartosc,  Zas_Cena,  TrN_Bufor
          FROM @ZasobyDlaKorekt ORDER BY Zas_Id
          OPEN Z
          WHILE 1=1
            BEGIN
              FETCH NEXT FROM Z INTO @Zas_Id, @Zas_TwZTrS, @Zas_TwZId, @Zas_TrSId, @Zas_TrEId, @Zas_TrSIdDost, @Zas_TrSZwrId, @Zas_TwrId, @Zas_MagId, @Zas_Rodzaj, @Zas_Typ, @Zas_Metoda, @Zas_DataOpe, @Zas_Ilosc, @Zas_Wartosc, @Zas_Cena, @TrN_Bufor
              IF @@FETCH_STATUS <> 0 BREAK
              -- wartość potrzebna do skorygowania subelementu kosztowego
              IF @Ilosc_D > 0
                SET @TrS_Wartosc_N = ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND ( (@Zas_Ilosc / @Ilosc_D) * @TrS_Wartosc,11),10),9),8),7),6),5),4),3),2)
              ELSE
                SET @TrS_Wartosc_N = 0
              -- dodajemy wiersz, gdy wartosc korekty rożna od zera
              IF @TrS_Wartosc_N <> 0
                BEGIN
                  SELECT
                    @TrS_ZwrId_N     = @Zas_TrSId,
                    @TrS_MagId_N     = @Zas_MagId,
                    @TrS_Cena_N      = @Zas_Cena
                  INSERT INTO CDN.TraSElem (  TrS_TrEId,    TrS_TrSIdDost,    TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena   )
                  VALUES                   ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N )
                END
            END
          CLOSE Z
        DEALLOCATE Z
        SELECT
          @TrS_TrEId_N       = @TrS_TrEId,
          @TrS_TrSIdDost_N   = @TrS_TrSIdDost,
          @TrS_TwrId_N       = @TrS_TwrId,
          @TrS_Rodzaj_N      = 306072,
          @TrS_Typ_N         = 2,
          @TrS_Metoda_N      = @TrS_Metoda,
          @TrS_DataOpe_N     = @TrS_DataOpe,
          @TrS_Ilosc_N       = 0
        -- jeszcze raz kursor po TwrZasoby dla skorygowanej dostawy i sprawdzenie czy nie ma zerowej ilości przy niezerowej wartości
        DELETE FROM @ZasobyDlaKorekt
        INSERT INTO @ZasobyDlaKorekt   ( Zas_Id,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor     )
          SELECT                         Zas_Id,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor
            FROM CDN.ZasobyDlaKorekt ( @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena, @TrE_ZwrId )
              WHERE TrN_Bufor IN ( 0, 1 )  -- tylko dokumenty nie będące w buforze
              ORDER BY Zas_Id              -- najpierw zasoby z magazynu źródłowego, potem subelemnety do zwrotu z magazynu źródłowego, potem zasoby z innych magazynów, potem subelementy do zwrotu z innych magazynów
        SET @Wartosc_Potrzebna = 0
        -- kursor po zasobach
        DECLARE Z CURSOR LOCAL FAST_FORWARD FOR
          SELECT TwZ_MagId, TwZ_Wartosc FROM CDN.TwrZasoby WHERE TwZ_Ilosc = 0 AND TwZ_Wartosc <> 0 AND TwZ_TrSIdDost = @TrS_TrSIdDost
          OPEN Z
          WHILE 1=1
            BEGIN
              FETCH NEXT FROM Z INTO @ZaS_MagId, @Wartosc_Potrzebna
                IF @@FETCH_STATUS <> 0 BREAK
                DECLARE KW CURSOR LOCAL FAST_FORWARD FOR
                  SELECT Zas_TrSId, Zas_MagId, Zas_Wartosc, Zas_Cena FROM @ZasobyDlaKorekt WHERE Zas_MagId = @ZaS_MagId AND Zas_Rodzaj not in (312000,312008)
                  OPEN KW
                  WHILE 1=1
                    BEGIN
                      FETCH NEXT FROM KW INTO @Zas_TrSId, @Zas_MagId, @ZaS_Wartosc, @Zas_Cena
                        IF @@FETCH_STATUS <> 0 BREAK
                        IF @Wartosc_Potrzebna = 0 BREAK
                        -- jeśli wartść dodatnia (zwrot), to ważne jest, czy nie została przekroczona ilosć z subelementu korygowanego
                        IF @Wartosc_Potrzebna > 0
                          BEGIN
                            SET @TrS_Wartosc_N    = ( SELECT MIN(A) FROM ( SELECT A = @Wartosc_Potrzebna UNION ALL SELECT A = @Zas_Wartosc ) AS B )
                            SET @Wartosc_Potrzebna  = @Wartosc_Potrzebna - @TrS_Wartosc_N
                          END
                        -- jeśli wartość ujemna, (dodanie wartości na magazyn ), to NIE jest ważne, czy nie została przekroczona ilość z subelementu korygowanego - zawsze dodajemy całość potrzebną
                        ELSE
                          BEGIN
                            SET @TrS_Wartosc_N      = @Wartosc_Potrzebna
                            SET @Wartosc_Potrzebna  = 0
                          END
                        IF @TrS_Wartosc_N <> 0
                          BEGIN
                            SELECT
                              @TrS_ZwrId_N       = @Zas_TrSId,
                              @TrS_MagId_N       = @Zas_MagId,
                              @TrS_Cena_N        = @Zas_Cena
                            INSERT INTO CDN.TraSElem (  TrS_TrEId,    TrS_TrSIdDost,    TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena    )
                            VALUES                   ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_TrSId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N  )
                          END
                    END
                  CLOSE KW
                DEALLOCATE KW
            END
          CLOSE Z
        DEALLOCATE Z
        */
        SELECT @Wartosc_Pozostala = ISNULL(TwZ_Wartosc,0), @Ilosc_Pozostala = ISNULL(TwZ_Ilosc,0) FROM CDN.TwrZasoby  WHERE TwZ_ILosc=0 AND TwZ_Wartosc <> 0 AND TwZ_TrSIdDost = @TrS_TrSIdDost
        IF (@Wartosc_Pozostala IN(-0.01, -0.02, -0.03, -0.04, -0.05, -0.06, -0.07, -0.08,  -0.09, -0.10) AND @Ilosc_Pozostala=0) OR (@Wartosc_Pozostala IN(0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08,  0.09, 0.10) AND @Ilosc_Pozostala = 0)
 BEGIN
 --wartości wspólne dla tworzenia subelementu
         SELECT
                @TrS_TrEId_N       = @TrS_TrEId,
                @TrS_TrSIdDost_N   = @TrS_TrSIdDost,
                @TrS_TwrId_N       = @TrS_TwrId,
                @TrS_Rodzaj_N      = 306072,
                @TrS_Typ_N         = 2,
                @TrS_Metoda_N      = @TrS_Metoda,
                @TrS_DataOpe_N     = @TrS_DataOpe,
                @TrS_Ilosc_N       = 0
          DECLARE WZKK CURSOR LOCAL FAST_FORWARD FOR
            SELECT TwZ_MagId, ISNULL(TwZ_Wartosc,0) ,ISNULL(TwZ_Ilosc,0), TwZ_Cena FROM CDN.TwrZasoby WHERE TwZ_Ilosc = 0 AND TwZ_Wartosc <> 0 AND TwZ_TrSIdDost = @TrS_TrSIdDost
             OPEN WZKK
              WHILE 1=1
                BEGIN
                  FETCH NEXT FROM WZKK INTO @WZKK_MagId, @WZKK_Wartosc, @WZKK_Ilosc, @WZKK_Cena
                   IF @@FETCH_STATUS <> 0 BREAK
      BEGIN
       SELECT
                        @TrS_ZwrId_N       = NULL,
                        @TrS_MagId_N       = @WZKK_MagId,
                        @TrS_Cena_N        = @WZKK_Cena
                      INSERT INTO CDN.TraSElem (  TrS_TrEId,    TrS_TrSIdDost,    TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena    )
                      VALUES                   ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_TrSId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N,  @WZKK_Ilosc, @WZKK_Wartosc, @WZKK_Cena  )
      END
                  IF @Wartosc_Potrzebna <> 0 and ABS(@Wartosc_Potrzebna) > ABS((@WZKK_Wartosc))
                       SET @Wartosc_Potrzebna = ABS(@Wartosc_Potrzebna) - ABS((@WZKK_Wartosc))
            ELSE
                       SET @Wartosc_Potrzebna = 0
         END
              CLOSE WZKK
           DEALLOCATE WZKK
           EXECUTE CDN.AktualizujWZKK_OLD @TrS_TrEId
         END
      -- Kontrola, czy wystarczyło wartości wśród subelementów kosztowych do skorygowania na danym magazynie
      IF ISNULL(@Wartosc_Potrzebna,0) <> 0
        GOTO KOMUNIKAT
    END -- korekta wartościowa do dostaw dla FIFO LIFO
  -- Korekta ilościowe do wydań na minus dla FIFO, LIFO
  IF @TrS_Typ = 2 AND @TrS_Ilosc < 0 AND @TrS_Metoda IN ( 1, 2 )
    BEGIN
    -- dostępne subelementy do zwrócenia wraz z wcześniej wystawionymi korektami kosztu 306071
    IF ISNULL(@TrS_TrSIdDost,0) > 0
      BEGIN
        INSERT INTO @ZasobyDlaKorekt   ( Zas_Id,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor, Zas_TrSIdDost_P, Zas_Ilosc_P, Zas_Wartosc_P , Zas_Poziom    )
          SELECT                         1,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor, Zas_TrSIdDost_P, Zas_Ilosc_P, Zas_Wartosc_P, Zas_Poziom
            FROM CDN.ZasobyDlaKorekt ( @TrS_TrSId, @TrS_TrEId,   NULL, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena, @TrE_ZwrId  )
              WHERE TrN_Bufor IN ( 0 )     -- tylko dokumenty nie będące w buforze
              AND Zas_TrSIdDost = @TrS_TrSIdDost
              ORDER BY Zas_Id              -- najpierw zasoby z magazynu źródłowego, potem subelemnety do zwrotu z magazynu źródłowego, potem zasoby z innych magazynów, potem subelementy do zwrotu z innych magazynów
         INSERT INTO @ZasobyDlaKorekt   ( Zas_Id,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor, Zas_TrSIdDost_P, Zas_Ilosc_P, Zas_Wartosc_P , Zas_Poziom    )
           SELECT                         Zas_Id+1,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor, Zas_TrSIdDost_P, Zas_Ilosc_P, Zas_Wartosc_P, Zas_Poziom
             FROM CDN.ZasobyDlaKorekt ( @TrS_TrSId, @TrS_TrEId,   NULL, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena, @TrE_ZwrId  )
               WHERE TrN_Bufor IN ( 0 )     -- tylko dokumenty nie będące w buforze
               AND Zas_TrSIdDost <> @TrS_TrSIdDost
               ORDER BY Zas_Id              -- najpierw zasoby z magazynu źródłowego, potem subelemnety do zwrotu z magazynu źródłowego, potem zasoby z innych magazynów, potem subelementy do zwrotu z innych magazynów
      END
    ELSE
      INSERT INTO @ZasobyDlaKorekt   ( Zas_Id,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor, Zas_TrSIdDost_P, Zas_Ilosc_P, Zas_Wartosc_P, Zas_Poziom     )
         SELECT                         Zas_Id,     Zas_TwZTrS,     Zas_TwZId,     Zas_TrSId,     Zas_TrEId,     Zas_TrSIdDost,     Zas_TrSZwrId,     Zas_TwrId,     Zas_MagId,     Zas_Rodzaj,     Zas_Typ,     Zas_Metoda,     Zas_DataOpe,           Zas_Ilosc,               Zas_Wartosc,                 Zas_Cena,               TrN_Bufor, Zas_TrSIdDost_P, Zas_Ilosc_P, Zas_Wartosc_P, Zas_Poziom
           FROM CDN.ZasobyDlaKorekt ( @TrS_TrSId, @TrS_TrEId,   NULL, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena, @TrE_ZwrId  )
             WHERE TrN_Bufor IN ( 0 )     -- tylko dokumenty nie będące w buforze
             ORDER BY Zas_Id              -- najpierw zasoby z magazynu źródłowego, potem subelemnety do zwrotu z magazynu źródłowego, potem zasoby z innych magazynów, potem subelementy do zwrotu z innych magazynów
    DECLARE Z CURSOR LOCAL FAST_FORWARD FOR
      SELECT                          Zas_Id,  Zas_TwZTrS,  Zas_TwZId,  Zas_TrSId,  Zas_TrEId,  Zas_TrSIdDost,  Zas_TrSZwrId,  Zas_TwrId,  Zas_MagId,  Zas_Rodzaj,  Zas_Typ,  Zas_Metoda,  Zas_DataOpe,  Zas_Ilosc,  Zas_Wartosc,  Zas_Cena,  TrN_Bufor, Zas_TrSIdDost_P, Zas_Ilosc_P, Zas_Wartosc_P
        FROM @ZasobyDlaKorekt ORDER BY Zas_Poziom ,   Zas_Id
        OPEN Z
          WHILE 1=1
            BEGIN
              FETCH NEXT FROM Z INTO @Zas_Id, @Zas_TwZTrS, @Zas_TwZId, @Zas_TrSId, @Zas_TrEId, @Zas_TrSIdDost, @Zas_TrSZwrId, @Zas_TwrId, @Zas_MagId, @Zas_Rodzaj, @Zas_Typ, @Zas_Metoda, @Zas_DataOpe, @Zas_Ilosc, @Zas_Wartosc, @Zas_Cena, @TrN_Bufor, @Zas_TrSIdDost_P, @Zas_Ilosc_P, @Zas_Wartosc_P
              IF @@FETCH_STATUS <> 0 BREAK
              IF @Ilosc_Potrzebna = 0 BREAK
              SELECT
                @TrS_Ilosc_N             = 0,
                @TrS_Wartosc_N           = 0,
                @Zas_Ilosc_Pozostala     = 0,
                @Zas_Wartosc_Pozostala   = 0
              -- ilości
              SET @TrS_Ilosc_N           = ( SELECT MIN(A) FROM ( SELECT A = @Zas_Ilosc UNION ALL SELECT A = @Ilosc_Potrzebna ) AS B )
              SET @Ilosc_Potrzebna       = @Ilosc_Potrzebna - @TrS_Ilosc_N
              SET @Zas_Ilosc_Pozostala   = @Zas_Ilosc - @TrS_Ilosc_N
              -- wartości
              IF @TrS_Ilosc_N <> 0 AND @Zas_Ilosc <> 0 AND @TrS_Ilosc_N <> @Zas_Ilosc
                SET @TrS_Wartosc_N         = ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND ( (@TrS_Ilosc_N / @Zas_Ilosc) * @Zas_Wartosc,11),10),9),8),7),6),5),4),3),2)
              ELSE
                SET @TrS_Wartosc_N  = @Zas_Wartosc
              SET @TrS_Wartosc_N         = ( SELECT MIN(A) FROM ( SELECT A = @Zas_Wartosc UNION ALL SELECT A = @TrS_Wartosc_N ) AS B )
              SET @Zas_Wartosc_Pozostala = @Zas_Wartosc - @TrS_Wartosc_N
              -- obsługa śmieci wartościowych (dokończenie zwrotu z dokumentu pierwotnego dla całkowitej zwracanej ilości)
              IF @Zas_Ilosc_Pozostala = 0 AND @Zas_Wartosc_Pozostala > 0
                BEGIN
                  SET @TrS_Wartosc_N = @TrS_Wartosc_N + @Zas_Wartosc_Pozostala
                  SET @Zas_Wartosc_Pozostala = 0
                END
              -- dane do subelementu wspólne
              SELECT
                @TrS_TrEId_N     = @TrS_TrEId,
                @TrS_TwrId_N     = @TrS_TwrId,
                @TrS_MagId_N     = @TrS_MagId,
                @TrS_Typ_N       = 2,
                @TrS_Metoda_N    = @TrS_Metoda,
                @TrS_DataOpe_N   = @TrS_DataOpe
              -- źródłowy subelement zwykły (nie 307071) - tylko jeden subelement korygujący z rodzajem przekazywanym
              IF @Zas_Rodzaj <> 306071
                BEGIN
                  -- dane do subelementu wspólne
                  SELECT
                    @TrS_ZwrId_N     = @Zas_TrSId,          -- wskaźnik na subelement elementu pierwotnego
                    @TrS_TrSIdDost_N = @Zas_TrSIdDost,      -- TrS_TrSIdDost z sublementu pierwotnego
                    @TrS_Cena_N      = @Zas_Cena,
                    @TrS_Ilosc_N     = - ABS(@TrS_Ilosc_N),
                    @TrS_Wartosc_N   = - ABS(@TrS_Wartosc_N),
                    @TrS_Rodzaj_N    = @TrS_Rodzaj          -- rodzaj zwykłej korekty (nie KK 306061)
                  -- Subelement korygujący (tylko 1 dla każdego subelementu pierwotnego)
                  INSERT INTO CDN.TraSElem       (  TrS_TrEId,  TrS_TrSIdDost,      TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena   )
                  VALUES                         ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N )
                END
              -- źródłowy subelement korekcyjny (307071) - to 3 subelementy korygujące
              IF @Zas_Rodzaj = 306071
                BEGIN
                  -- Subelement korygujący do 306071
                  SELECT
                    @TrS_ZwrId_N     = @Zas_TrSId,
                    @TrS_TrSIdDost_N = @Zas_TrSIdDost,
                    @TrS_Cena_N      = @Zas_Cena,
                    @TrS_Ilosc_N     = - ABS(@TrS_Ilosc_N),
                    @TrS_Wartosc_N   = - ABS(@TrS_Wartosc_N),
                    @TrS_Rodzaj_N    = 306061
                  INSERT INTO CDN.TraSElem       (  TrS_TrEId,  TrS_TrSIdDost,      TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena   )
                  VALUES                         ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N )
                  -- zdjęcie dostawy pierwotnej wg TrS_TrSIdDost z 306071 z ustawionym ZwrId-em (ten sam element)
                  -- wartość ( proporcjonalna do zasobu pierwotnego )
                  SET @TrS_Ilosc_N = ABS(@TrS_Ilosc_N)
                  IF @TrS_Ilosc_N <> 0 AND @Zas_Ilosc_P <> 0 AND @TrS_Ilosc_N <> @Zas_Ilosc_P
                    SET @TrS_Wartosc_N         = ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND(ROUND ( (@TrS_Ilosc_N / @Zas_Ilosc_P) * @Zas_Wartosc_P,11),10),9),8),7),6),5),4),3),2)
                  ELSE
                    SET @TrS_Wartosc_N  = @Zas_Wartosc_P
                  SET @TrS_Wartosc_N         = ( SELECT MIN(A) FROM ( SELECT A = @Zas_Wartosc_P UNION ALL SELECT A = @TrS_Wartosc_N ) AS B )
                  SELECT
                    @TrS_ZwrId_N     = NULL,
                    @TrS_TrSIdDost_N = @Zas_TrSIdDost_P,  -- TrS_TrSIdDost z sublementu pierwotnego
                    @TrS_Cena_N      = @Zas_Cena,
                    @TrS_Ilosc_N     = ABS(@TrS_Ilosc_N),
                    @TrS_Wartosc_N   = ABS(@TrS_Wartosc_N)
                  INSERT INTO CDN.TraSElem       (  TrS_TrEId,  TrS_TrSIdDost,      TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena   )
                  VALUES                         ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N )
                  -- korekta do zdjęcia, które zostało wykonane przed chwilą 1:1 z rodzajem korekty, a nie WZKK
                  SELECT
                    @TrS_ZwrId_N     = ( SELECT ISNULL(MAX(TrS_TrSId),0) FROM CDN.TraSElem),
                    @TrS_TrSIdDost_N = @Zas_TrSIdDost_P,  -- TrS_TrSIdDost z subelementu pierwotnego
                    @TrS_Cena_N      = @Zas_Cena,
                    @TrS_Ilosc_N     = -ABS(@TrS_Ilosc_N),
                    @TrS_Wartosc_N   = -ABS(@TrS_Wartosc_N),
                    @TrS_Rodzaj_N    = @TrS_Rodzaj
                  INSERT INTO CDN.TraSElem       (  TrS_TrEId,  TrS_TrSIdDost,      TrS_ZwrId,    TrS_TwrId,    TrS_MagId,    TrS_Rodzaj,    TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,    TrS_Cena   )
                  VALUES                         ( @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N )
                END
          END
      CLOSE Z
    DEALLOCATE Z
    -- Kontrola, czy wystarczyło ilości i wartości
    IF @Ilosc_Potrzebna <> 0 OR @Wartosc_Potrzebna <> 0
      GOTO KOMUNIKAT
    EXECUTE CDN.AktualizujWZKK_OLD @TrS_TrEId
    END   -- Korekta ilościowe do wydań na minus dla FIFO, LIFO
  -- WZKK
--  IF EXISTS (SELECT * FROM CDN.TraSElem WHERE TrS_kTrEId = @TrS_TrEId AND TrS_Rodzaj IN (306071, 306061,306072) )
  --  EXECUTE CDN.AktualizujWZKK @TrS_TrEId,0
   DECLARE S CURSOR LOCAL FAST_FORWARD FOR
                   SELECT    TrS_TrEId , TrS_TrEId_WZKK
                     FROM @AktWZKK
                       OPEN S
                         WHILE 1=1
                           BEGIN
                             FETCH NEXT FROM S INTO @ID1, @ID2
                             IF @@FETCH_STATUS <> 0 BREAK
            SELECT TOP 1  @TrE_TwrId = TrE_TwrId, @TrE_DataOpe = TrE_DataOpe,@Kom_Twr_Kod = TrE_TwrKod,@Kom_Twr_Nazwa = TrE_TwrNazwa FROM cdn.TraElem
                         WHERE TrE_TrEId = @ID1
                      -- sprawdzenie towaru ze starego elementu
                      SET @Komunikat = CDN.TwrZasobyErr ( @TrS_TrEId, @TrE_TwrId, @Kom_Twr_Kod, @Kom_Twr_Nazwa, @TrE_DataOpe )
                      IF @Komunikat <> ''
  BEGIN
    RAISERROR( @Komunikat, 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
                      -- sprawdzenie towaru z nowego elementu
                      SET @Komunikat = CDN.TwrZasobyErr ( @ID2, @TrE_TwrId, @Kom_Twr_Kod, @Kom_Twr_Nazwa, @TrE_DataOpe )
                      IF @Komunikat <> ''
  BEGIN
    RAISERROR( @Komunikat, 16, 1 )
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
        --EXECUTE CDN.AktualizujWZKK @ID1, @iID2,@TrS_TrEId
                           END
                        CLOSE S
                  DEALLOCATE S
  -- Wyswietlenie komunikatu i rollback całej transakcji
    KOMUNIKAT:
  IF @Ilosc_Potrzebna > 0 OR @Wartosc_Potrzebna > 0 OR ( @Ilosc_Potrzebna = 0 AND @Wartosc_Potrzebna <> 0 )
    BEGIN
      SELECT TOP 1
        @Twr_Kod = REPLACE(Twr_Kod,'%',''),
        @Twr_Jm  = Twr_Jm,
        @Ilosc_Kom    = CONVERT(NVARCHAR(30), @Ilosc_Potrzebna),
        @Wartosc_Kom  = CONVERT(NVARCHAR(30), @Wartosc_Potrzebna)
      FROM CDN.Towary
      WHERE Twr_TwrId = @TrS_TwrId
      IF @Wartosc_Potrzebna > 0
        SET @Komunikat = '##OPT34416##%%TwrKod%%=' + REPLACE(@Twr_Kod,'%','%%') + '%%WartoscKom%%=' + @Wartosc_Kom + '##'--'Dla towaru ' + @Twr_Kod + ' na dostępnych magazynach występuje brak wartości: ' + @Wartosc_Kom + '. '
      IF @Ilosc_Potrzebna = 0 AND @Wartosc_Potrzebna <> 0
        SET @Komunikat = '##OPT34417##%%TwrKod%%=' +  REPLACE(@Twr_Kod,'%','%%') + '%%WartoscKom%%=' + @Wartosc_Kom + '##'--'Dla towaru ' + @Twr_Kod + ' na dostępnych magazynach brakuje ' + @Wartosc_Kom + ' wartości. '
      IF @Ilosc_Potrzebna > 0
        SET @Komunikat = '##OPT34418##%%TwrKod%%=' +  REPLACE(@Twr_Kod,'%','%%') + '%%IloscKom%%=' + @Ilosc_Kom +'%%TwrJm%%=' + @Twr_Jm + '##'--'Dla towaru ' + @Twr_Kod + ' na dostępnych magazynach występuje brak ilości: ' + @Ilosc_Kom + ' ' + @Twr_Jm + '. '
      IF @Ilosc_Potrzebna > 0 AND ISNULL(@TrS_TrSIdDost,0) > 0
        SET @Komunikat = '##OPT34419##%%TwrKod%%=' +  REPLACE(@Twr_Kod,'%','%%') + '##' --'Zapis niemożliwy! Wskazane zasoby  towaru  ' + @Twr_Kod + '  zostały rozchodowane. Nie można pobrać dostawy. Wybierz inny zasób towaru. '
      --ELSE
      --BEGIN
      --IF @Komunikat <> ''
      --  SET @Komunikat = @Komunikat + ' Niektóre dokumenty, do których będą wygenerowane subelementy korekcyjne mogą być w buforze - skasuj lub zaakceptuj dokumenty w buforze. '
      --IF @Komunikat <> '' AND @TrS_Typ = 1 AND @TrS_Ilosc < 0
      --  SET @Komunikat = @Komunikat + ' Mogły także wystąpić korekty graniczne FZKG - anuluj korekty graniczne przed wykonaniem korekty ilościowej. '
      --END
      RAISERROR( @Komunikat, 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF
