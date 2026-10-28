CREATE FUNCTION CDN.ZasobyDlaKorekt
(
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
  @TrE_ZwrId      INT
 )
RETURNS @Zasoby TABLE
(
   Zas_Id          INT IDENTITY(1,1),
   Zas_TwZTrS      INT,               -- 0-TwrZasoby; 1-TraSElem
   Zas_TwZId       INT,
   Zas_TrSId       INT,
   Zas_TrEId       INT,
   Zas_TrSIdDost   INT,
   Zas_TrSZwrId    INT,
   Zas_TwrId       INT,
   Zas_MagId       INT,
   Zas_Rodzaj      INT,
   Zas_Typ         INT,
   Zas_Metoda      INT,
   Zas_DataOpe     DATETIME,
   Zas_Ilosc       DECIMAL(15,4),
   Zas_Wartosc     DECIMAL(15,2),
   Zas_Cena        DECIMAL(17,4),
   TrN_Bufor       INT,
   Zas_TrSIdDost_P INT,
   Zas_Ilosc_P     DECIMAL(15,4),
   Zas_Wartosc_P   DECIMAL(15,2),
   Zas_Poziom      INT
)
AS
BEGIN
             DECLARE @Poziom INT
/*
  -- zwykłe wydania (klonowanie zasobów)
  IF @TrS_Typ = 2 AND @TrS_Ilosc > 0
    BEGIN
      -- FIFO
      IF @TrS_Metoda = 1
        INSERT INTO @Zasoby ( Zas_TwZTrS, Zas_TwZId, Zas_TrSId, Zas_TrEId, Zas_TrSIdDost, Zas_TrSZwrId, Zas_TwrId, Zas_MagId, Zas_Rodzaj, Zas_Typ,  Zas_Metoda, Zas_DataOpe, Zas_Ilosc, Zas_Wartosc, Zas_Cena, TrN_Bufor )
          SELECT                       0, TwZ_TwZId,      NULL,      NULL, TwZ_TrSIdDost,         NULL, TwZ_TwrId, TwZ_MagId,       NULL,    NULL, @TrS_Metoda,        NULL, TwZ_Ilosc, TwZ_Wartosc, TwZ_Cena,         0
            FROM CDN.TwrZasoby
            WHERE TwZ_TwrId     = @TrS_TwrId
              AND TwZ_MagId     = @TrS_MagId
              AND TwZ_Quan      = 0
            ORDER BY TwZ_Data, TwZ_TrSIdDost
      -- LIFO
      IF @TrS_Metoda = 2
        INSERT INTO @Zasoby ( Zas_TwZTrS, Zas_TwZId, Zas_TrSId, Zas_TrEId, Zas_TrSIdDost, Zas_TrSZwrId, Zas_TwrId, Zas_MagId, Zas_Rodzaj, Zas_Typ,  Zas_Metoda, Zas_DataOpe, Zas_Ilosc, Zas_Wartosc, Zas_Cena, TrN_Bufor )
          SELECT                       0, TwZ_TwZId,      NULL,      NULL, TwZ_TrSIdDost,         NULL, TwZ_TwrId, TwZ_MagId,       NULL,    NULL, @TrS_Metoda,        NULL, TwZ_Ilosc, TwZ_Wartosc, TwZ_Cena,         0
            FROM CDN.TwrZasoby
            WHERE TwZ_TwrId     = @TrS_TwrId
              AND TwZ_MagId     = @TrS_MagId
              AND TwZ_Quan      = 0
              AND TwZ_Data     <= @TrS_DataOpe
            ORDER BY TwZ_Data DESC, TwZ_TrSIdDost DESC
      -- AVCO
      IF @TrS_Metoda = 3
        INSERT INTO @Zasoby ( Zas_TwZTrS, Zas_TwZId, Zas_TrSId, Zas_TrEId, Zas_TrSIdDost, Zas_TrSZwrId, Zas_TwrId, Zas_MagId, Zas_Rodzaj, Zas_Typ,  Zas_Metoda, Zas_DataOpe, Zas_Ilosc, Zas_Wartosc, Zas_Cena, TrN_Bufor )
          SELECT                       0, TwZ_TwZId,      NULL,      NULL, TwZ_TrSIdDost,         NULL, TwZ_TwrId, TwZ_MagId,       NULL,    NULL, @TrS_Metoda,        NULL, TwZ_Ilosc, TwZ_Wartosc, TwZ_Cena,         0
            FROM CDN.TwrZasoby
            WHERE TwZ_TwrId     = @TrS_TwrId
              AND TwZ_MagId     = @TrS_MagId
            ORDER BY TwZ_Data DESC, TwZ_TrSIdDost DESC
      -- QUAN
      IF @TrS_Metoda = 4
        INSERT INTO @Zasoby ( Zas_TwZTrS, Zas_TwZId, Zas_TrSId, Zas_TrEId, Zas_TrSIdDost, Zas_TrSZwrId, Zas_TwrId, Zas_MagId, Zas_Rodzaj, Zas_Typ,  Zas_Metoda, Zas_DataOpe, Zas_Ilosc,            Zas_Wartosc, Zas_Cena, TrN_Bufor )
          SELECT                       0, TwZ_TwZId,      NULL,      NULL, TwZ_TrSIdDost,         NULL, TwZ_TwrId, TwZ_MagId,       NULL,    NULL, @TrS_Metoda,        NULL, TwZ_Ilosc + TwZ_QUAN, TwZ_Wartosc, TwZ_Cena,         0
            FROM CDN.TwrZasoby
            WHERE TwZ_TwrId     = @TrS_TwrId
              AND TwZ_MagId     = @TrS_MagId
            ORDER BY TwZ_Data DESC, TwZ_TrSIdDost DESC
    END
*/
  -- korekty ilościowe do dostaw na minus dla FIFO LIFO
  IF @TrS_Typ = 1 AND @TrS_Ilosc < 0 AND @TrS_TrSId <> @TrS_TrSIdDost AND @TrS_Metoda IN ( 1, 2 )
    BEGIN
     IF EXISTS (SELECT TrS_WyborDostaw FROM CDN.TrasElem WHERE TrS_TrSIdDost = @TrS_TrSIdDost AND TrS_WyborDostaw = 1)
       INSERT INTO @Zasoby ( Zas_TwZTrS, Zas_TwZId, Zas_TrSId, Zas_TrEId, Zas_TrSIdDost, Zas_TrSZwrId, Zas_TwrId, Zas_MagId, Zas_Rodzaj, Zas_Typ, Zas_Metoda, Zas_DataOpe, Zas_Ilosc,            Zas_Wartosc, Zas_Cena,    TrN_Bufor, Zas_Poziom)
        -- zasoby z danego magazynu
        SELECT                       0, TwZ_TwZId,      NULL,      NULL,    @TrS_TrSIdDost,         NULL,    @TrS_TwrId,    TwZ_MagId,       NULL,    NULL,    @TrS_Metoda,        NULL, TwZ_Ilosc + TwZ_Quan, TwZ_Wartosc, TwZ_Cena,        0, 0
          FROM CDN.TwrZasoby
          WHERE TwZ_TwrId     = @TrS_TwrId
            AND TwZ_MagId     = @TrS_MagId
            AND TwZ_TrSIdDost = @TrS_TrSIdDost
        -- zasoby z innych magazynów
        /*UNION ALL
        SELECT                       0, TwZ_TwZId,      NULL,      NULL,    @TrS_TrSIdDost,         NULL,    @TrS_TwrId,  TwZ_MagId,       NULL,    NULL,    @TrS_Metoda,        NULL, TwZ_Ilosc + TwZ_Quan, TwZ_Wartosc, TwZ_Cena, 0
          FROM CDN.TwrZasoby
          WHERE TwZ_TwrId = @TrS_TwrId
            AND TwZ_MagId <> @TrS_MagId
            AND TwZ_TrSIdDost = @TrS_TrSIdDost  */
     ELSE
      INSERT INTO @Zasoby ( Zas_TwZTrS, Zas_TwZId, Zas_TrSId, Zas_TrEId, Zas_TrSIdDost, Zas_TrSZwrId, Zas_TwrId, Zas_MagId, Zas_Rodzaj, Zas_Typ, Zas_Metoda, Zas_DataOpe, Zas_Ilosc,            Zas_Wartosc, Zas_Cena,    TrN_Bufor, Zas_Poziom)
        -- zasoby z danego magazynu
        SELECT                       0, TwZ_TwZId,      NULL,      NULL,    @TrS_TrSIdDost,         NULL,    @TrS_TwrId,    TwZ_MagId,       NULL,    NULL,    @TrS_Metoda,        NULL, TwZ_Ilosc + TwZ_Quan, TwZ_Wartosc, TwZ_Cena,        0,0
          FROM CDN.TwrZasoby
          WHERE TwZ_TwrId     = @TrS_TwrId
            AND TwZ_MagId     = @TrS_MagId
            AND TwZ_TrSIdDost = @TrS_TrSIdDost
        -- subelementy kosztowe do zwrócenia - ilość i wartość możliwa do zwrócenia z danego magazynu
        UNION ALL
        SELECT                       1,      NULL, P.TrS_TrSId, MAX(P.TrS_TrEId),   @TrS_TrSIdDost,        NULL,      @TrS_TwrId,    MAX(P.TrS_MagId), MAX(P.TrS_Rodzaj), MAX(P.TrS_Typ),    @TrS_Metoda, MAX(P.TrS_DataOpe), MAX(P.TrS_Ilosc) + SUM(ISNULL(K.TrS_Ilosc,0)), MAX(P.TrS_Wartosc) + SUM(ISNULL(K.TrS_Wartosc,0)), MAX(P.TrS_Cena), MAX(TrN_Bufor),0
          FROM CDN.TraSElem P
            LEFT OUTER JOIN CDN.TraSElem K ON P.TrS_TrSId = K.TrS_ZwrId
            JOIN CDN.TraElem ON TrE_TrEId = P.TrS_TrEId
            JOIN CDN.TraNag  ON TrN_TrNId = TrE_TrNId
          WHERE P.TrS_TwrId     = @TrS_TwrId
            AND P.TrS_MagId     = @TrS_MagId
            AND P.TrS_TrSIdDost = @TrS_TrSIdDost
            AND P.TrS_Typ       = 2
            AND P.TrS_ZwrId IS NULL
            AND P.TrS_Ilosc    >= 0
            AND P.TrS_WyborDostaw = 0
            AND TrN_Rodzaj not in (312000,312008)
            AND ( TrN_MagDocId IS NULL  OR ( TrN_Rodzaj = 312100 AND TrN_MagDocId IS NOT NULL ) )
            AND P.TrS_TrEId <> @TrS_TrEId
          GROUP BY P.TrS_TrSId
        -- zasoby z innych magazynów
        UNION ALL
        SELECT                       0, TwZ_TwZId,      NULL,      NULL,    @TrS_TrSIdDost,         NULL,    @TrS_TwrId,  TwZ_MagId,       NULL,    NULL,    @TrS_Metoda,        NULL, TwZ_Ilosc + TwZ_Quan, TwZ_Wartosc, TwZ_Cena, 0,0
          FROM CDN.TwrZasoby
          WHERE TwZ_TwrId = @TrS_TwrId
            AND TwZ_MagId <> @TrS_MagId
            AND TwZ_TrSIdDost = @TrS_TrSIdDost
        -- subelementy kosztowe do zwrócenia - ilość i wartość możliwa do zwrócenia z innego magazynu
        UNION ALL
        SELECT                       1,      NULL, P.TrS_TrSId, MAX(P.TrS_TrEId),   @TrS_TrSIdDost,        NULL,      @TrS_TwrId,    MAX(P.TrS_MagId), MAX(P.TrS_Rodzaj), MAX(P.TrS_Typ),    @TrS_Metoda, MAX(P.TrS_DataOpe), MAX(P.TrS_Ilosc) + SUM(ISNULL(K.TrS_Ilosc,0)), MAX(P.TrS_Wartosc) + SUM(ISNULL(K.TrS_Wartosc,0)), MAX(P.TrS_Cena), MAX(TrN_Bufor),0
          FROM CDN.TraSElem P
            LEFT OUTER JOIN CDN.TraSElem K ON P.TrS_TrSId = K.TrS_ZwrId
            JOIN CDN.TraElem ON TrE_TrEId = P.TrS_TrEId
            JOIN CDN.TraNag  ON TrN_TrNId = TrE_TrNId
          WHERE P.TrS_TwrId     = @TrS_TwrId
            AND P.TrS_MagId     <> @TrS_MagId
            AND P.TrS_TrSIdDost = @TrS_TrSIdDost
            AND P.TrS_Typ       = 2
            AND P.TrS_ZwrId IS NULL
            AND P.TrS_Ilosc    >= 0
            AND P.TrS_WyborDostaw = 0
            AND TrN_Rodzaj not in (312000,312008)
            AND ( TrN_MagDocId IS NULL  OR ( TrN_Rodzaj = 312100 AND TrN_MagDocId IS NOT NULL ) )
            AND P.TrS_TrEId <> @TrS_TrEId
          GROUP BY P.TrS_TrSId
  UNION ALL
        SELECT                       1,      NULL, P.TrS_TrSId, MAX(P.TrS_TrEId),   @TrS_TrSIdDost,        NULL,      @TrS_TwrId,    MAX(P.TrS_MagId), MAX(P.TrS_Rodzaj), MAX(P.TrS_Typ),    @TrS_Metoda, MAX(P.TrS_DataOpe), MAX(P.TrS_Ilosc) + SUM(ISNULL(K.TrS_Ilosc,0)), MAX(P.TrS_Wartosc) + SUM(ISNULL(K.TrS_Wartosc,0)), MAX(P.TrS_Cena), MAX(TrN_Bufor),0
          FROM CDN.TraSElem P
            LEFT OUTER JOIN CDN.TraSElem K ON P.TrS_TrSId = K.TrS_ZwrId
            JOIN CDN.TraElem ON TrE_TrEId = P.TrS_TrEId
            JOIN CDN.TraNag  ON TrN_TrNId = TrE_TrNId
          WHERE P.TrS_TwrId     = @TrS_TwrId
            AND P.TrS_MagId     = @TrS_MagId
            AND P.TrS_TrSIdDost = @TrS_TrSIdDost
            AND P.TrS_Typ       = 2
            AND P.TrS_ZwrId IS NULL
            AND P.TrS_Ilosc    >= 0
            AND P.TrS_WyborDostaw = 0
            AND TrN_Rodzaj in (312000,312008)
            AND TrN_Bufor = 1
            AND P.TrS_TrEId <> @TrS_TrEId
          GROUP BY P.TrS_TrSId
    END
  -- korekty wartościowe do dostaw dla FIFO i LIFO
  IF @TrS_Typ = 1 AND @TrS_Ilosc = 0 AND @TrS_TrSId <> @TrS_TrSIdDost AND @TrS_Metoda IN ( 1, 2 )
    BEGIN
      INSERT INTO @Zasoby ( Zas_TwZTrS, Zas_TwZId, Zas_TrSId, Zas_TrEId, Zas_TrSIdDost, Zas_TrSZwrId, Zas_TwrId, Zas_MagId, Zas_Rodzaj, Zas_Typ, Zas_Metoda, Zas_DataOpe, Zas_Ilosc,            Zas_Wartosc, Zas_Cena,    TrN_Bufor , Zas_Poziom)
        -- subelementy kosztowe do skorygowania - wartość możliwa do zwrócenia
        SELECT                       1,      NULL, P.TrS_TrSId, MAX(P.TrS_TrEId),   @TrS_TrSIdDost,        NULL,      @TrS_TwrId,    MAX(P.TrS_MagId), MAX(P.TrS_Rodzaj), MAX(P.TrS_Typ),    @TrS_Metoda, MAX(P.TrS_DataOpe), MAX(P.TrS_Ilosc) + SUM(ISNULL(K.TrS_Ilosc,0)), MAX(P.TrS_Wartosc) + SUM(ISNULL(K.TrS_Wartosc,0)), MAX(P.TrS_Cena), MAX(TrN_Bufor),0
          FROM CDN.TraSElem P
            LEFT OUTER JOIN CDN.TraSElem K ON P.TrS_TrSId = K.TrS_ZwrId
            JOIN CDN.TraElem ON TrE_TrEId = P.TrS_TrEId
            JOIN CDN.TraNag  ON TrN_TrNId = TrE_TrNId
          WHERE P.TrS_TwrId     = @TrS_TwrId
            AND P.TrS_TrSIdDost = @TrS_TrSIdDost
            AND P.TrS_Typ       = 2
            AND P.TrS_ZwrId IS NULL
            AND P.TrS_TrEId <> @TrS_TrEId
          GROUP BY P.TrS_TrSId
      END
  -- korekty ilościowe do dostaw na minus oraz korekty wartościowe dla AVCO i QUAN
  IF @TrS_Typ = 1 AND @TrS_Ilosc <= 0 AND @TrS_Metoda IN ( 3, 4 )
     BEGIN
      INSERT INTO @Zasoby ( Zas_TwZTrS, Zas_TwZId, Zas_TrSId, Zas_TrEId, Zas_TrSIdDost, Zas_TrSZwrId, Zas_TwrId, Zas_MagId, Zas_Rodzaj, Zas_Typ, Zas_Metoda, Zas_DataOpe, Zas_Ilosc,            Zas_Wartosc, Zas_Cena, TrN_Bufor  , Zas_Poziom)
        -- zasoby z danego magazynu
        SELECT                       0, TwZ_TwZId,      NULL,      NULL,    NULL,         NULL,    @TrS_TwrId,    TwZ_MagId,       NULL,    NULL,    @TrS_Metoda,        NULL, TwZ_Ilosc + TwZ_Quan, TwZ_Wartosc, TwZ_Cena,      0,0
          FROM CDN.TwrZasoby
          WHERE TwZ_TwrId     = @TrS_TwrId
            AND TwZ_MagId     = @TrS_MagId
        -- subelementy kosztowe do zwrócenia - ilość i wartość możliwa do zwrócenia z danego magazynu
        UNION ALL
        SELECT                       1,      NULL, P.TrS_TrSId, MAX(P.TrS_TrEId),   NULL,        NULL,      @TrS_TwrId,    MAX(P.TrS_MagId), MAX(P.TrS_Rodzaj), MAX(P.TrS_Typ),    @TrS_Metoda, MAX(P.TrS_DataOpe), MAX(P.TrS_Ilosc) + SUM(ISNULL(K.TrS_Ilosc,0)), MAX(P.TrS_Wartosc) + SUM(ISNULL(K.TrS_Wartosc,0)), MAX(P.TrS_Cena), MAX(TrN_Bufor),0
          FROM CDN.TraSElem P
            LEFT OUTER JOIN CDN.TraSElem K ON P.TrS_TrSId = K.TrS_ZwrId
            JOIN CDN.TraElem ON TrE_TrEId = P.TrS_TrEId
            JOIN CDN.TraNag  ON TrN_TrNId = TrE_TrNId
          WHERE P.TrS_TwrId     = @TrS_TwrId
            AND P.TrS_MagId     = @TrS_MagId
            AND P.TrS_Typ       = 2
            AND P.TrS_ZwrId IS NULL
            AND P.TrS_Ilosc >= 0
            AND TrN_Rodzaj not in (312000,312008)
            AND ( TrN_MagDocId IS NULL  OR ( TrN_Rodzaj = 312100 AND TrN_MagDocId IS NOT NULL ) )
            AND P.TrS_TrEId <> @TrS_TrEId
          GROUP BY P.TrS_TrSId
        -- zasoby z innego magazynu
        UNION ALL
        SELECT                       0, TwZ_TwZId,      NULL,      NULL,    NULL,         NULL,    @TrS_TwrId,  TwZ_MagId,       NULL,    NULL,    @TrS_Metoda,        NULL, TwZ_Ilosc + TwZ_Quan, TwZ_Wartosc, TwZ_Cena, 0,0
          FROM CDN.TwrZasoby
          WHERE TwZ_TwrId = @TrS_TwrId
            AND TwZ_MagId <> @TrS_MagId
        -- subelementy kosztowe do zwrócenia - ilość i wartość możliwa do zwrócenia z innego magazynu
        UNION ALL
        SELECT                       1,      NULL, P.TrS_TrSId, MAX(P.TrS_TrEId),   NULL,        NULL,      @TrS_TwrId,    MAX(P.TrS_MagId), MAX(P.TrS_Rodzaj), MAX(P.TrS_Typ),    @TrS_Metoda, MAX(P.TrS_DataOpe), MAX(P.TrS_Ilosc) + SUM(ISNULL(K.TrS_Ilosc,0)), MAX(P.TrS_Wartosc) + SUM(ISNULL(K.TrS_Wartosc,0)), MAX(P.TrS_Cena), MAX(TrN_Bufor),0
          FROM CDN.TraSElem P
            LEFT OUTER JOIN CDN.TraSElem K ON P.TrS_TrSId = K.TrS_ZwrId
            JOIN CDN.TraElem ON TrE_TrEId = P.TrS_TrEId
            JOIN CDN.TraNag  ON TrN_TrNId = TrE_TrNId
          WHERE P.TrS_TwrId     = @TrS_TwrId
            AND P.TrS_MagId     <> @TrS_MagId
            AND P.TrS_Typ       = 2
            AND P.TrS_ZwrId IS NULL
            AND P.TrS_Ilosc >= 0
            AND TrN_Rodzaj not in (312000,312008)
            AND ( TrN_MagDocId IS NULL  OR ( TrN_Rodzaj = 312100 AND TrN_MagDocId IS NOT NULL ) )
            AND P.TrS_TrEId <> @TrS_TrEId
          GROUP BY P.TrS_TrSId
    END
  -- korekty ilościowe do wydań na minus dla FIFO LIFO
  IF @TrS_Typ = 2 AND @TrS_Ilosc < 0
    BEGIN
      DECLARE
        @Zas_TwZTrS           INT,               -- 0-TwrZasoby; 1-TraSElem
        @Zas_TwZId            INT,
        @Zas_TrSId            INT,
        @Zas_TrEId            INT,
        @Zas_TrSIdDost        INT,
        @Zas_TrSZwrId         INT,
        @Zas_TwrId            INT,
        @Zas_MagId            INT,
        @Zas_Rodzaj           INT,
        @Zas_Typ              INT,
        @Zas_Metoda           INT,
        @Zas_DataOpe          DATETIME,
        @Zas_Ilosc            DECIMAL(15,4),
        @Zas_Wartosc          DECIMAL(15,2),
        @Zas_Cena             DECIMAL(17,4),
        @TrN_Bufor            INT
      DECLARE @TrEId_E_TMP TABLE ( TrEId INT )
      DECLARE @TrEId_E     TABLE ( TrEId INT )
      DECLARE @TrEId_S     TABLE ( TrEId INT, Poziom INT )
      DECLARE @TrSId_E     TABLE ( TrEId INT )
      DECLARE @TrE_TrEId INT
    -- Zwracamy też do elementów z innych korekt bo mogą być "na plus"
    -- liczymy nie tylko pierwotny, ale "łańcuszek korekt" (dla RWS el. korygujące nie muszą być do elementu pierw. )
    SET @TrE_TrEId = @TrS_TrEId
    WHILE 1 = 1
      BEGIN
        IF @TrE_TrEId IS NULL
          BREAK
        -- obrabiany element
        INSERT INTO  @TrEId_E_TMP ( TrEId ) VALUES ( @TrE_TrEId )
        -- wszystkie elementy będące elementami korygującymi do danego elementu.
        INSERT INTO  @TrEId_E_TMP ( TrEId ) SELECT TrE_TrEId FROM CDN.TraElem WHERE TrE_ZwrId = @TrE_TrEId
        -- korekty do pierwotnego (na kolejnych selectach zostaną odfiltrowane tylko te "na plus")
        SELECT @TrE_TrEId = TrE_ZwrId FROM CDN.TraElem WHERE TrE_TrEId = @TrE_TrEId
      END
    DELETE FROM @TrEId_E_TMP WHERE TrEId = @TrS_TrEId
    DELETE FROM @TrEId_E
    INSERT INTO @TrEId_E ( TrEId ) SELECT TrEId FROM @TrEId_E_TMP GROUP BY TrEId
    -- Kursor po elementach z dokumentu pierwotnego
    IF @TrS_Metoda IN ( 1, 3, 4 )
    DECLARE Z CURSOR LOCAL FAST_FORWARD FOR
      SELECT                       1,      NULL, P.TrS_TrSId, MAX(P.TrS_TrEId),   MAX(P.TrS_TrSIdDost),        NULL,      @TrS_TwrId,    MAX(P.TrS_MagId), MAX(P.TrS_Rodzaj), MAX(P.TrS_Typ),    @TrS_Metoda, MAX(P.TrS_DataOpe), MAX(P.TrS_Ilosc) + SUM(ISNULL(K.TrS_Ilosc,0)), MAX(P.TrS_Wartosc) + SUM(ISNULL(K.TrS_Wartosc,0)), MAX(P.TrS_Cena), MAX(TrN_Bufor),0
        FROM CDN.TraSElem P
          LEFT OUTER JOIN CDN.TraSElem K ON P.TrS_TrSId = K.TrS_ZwrId
          JOIN CDN.TraElem ON TrE_TrEId = P.TrS_TrEId
          JOIN CDN.TraNag  ON TrN_TrNId = TrE_TrNId
          JOIN @TrEId_E    ON TrEId = P.TrS_TrEId
        WHERE P.TrS_TwrId     = @TrS_TwrId
          AND P.TrS_MagId     = @TrS_MagId
          AND P.TrS_Typ       = 2
          AND P.TrS_ZwrId IS NULL
          AND P.TrS_Ilosc    >= 0
          AND P.TrS_Rodzaj   <> 306071
          AND TrN_Rodzaj not in (312000,312008)
          AND ( TrN_MagDocId IS NULL  OR ( TrN_Rodzaj = 312100 AND TrN_MagDocId IS NOT NULL ) )
        GROUP BY P.TrS_TrSId
        ORDER BY MAX(P.TrS_DataOpe) DESC, P.TrS_TrSId DESC
    IF @TrS_Metoda = 2
    DECLARE Z CURSOR LOCAL FAST_FORWARD FOR
      SELECT                       1,      NULL, P.TrS_TrSId, MAX(P.TrS_TrEId),   MAX(P.TrS_TrSIdDost),        NULL,      @TrS_TwrId,    MAX(P.TrS_MagId), MAX(P.TrS_Rodzaj), MAX(P.TrS_Typ),    @TrS_Metoda, MAX(P.TrS_DataOpe), MAX(P.TrS_Ilosc) + SUM(ISNULL(K.TrS_Ilosc,0)), MAX(P.TrS_Wartosc) + SUM(ISNULL(K.TrS_Wartosc,0)), MAX(P.TrS_Cena), MAX(TrN_Bufor),0
        FROM CDN.TraSElem P
          LEFT OUTER JOIN CDN.TraSElem K ON P.TrS_TrSId = K.TrS_ZwrId
          JOIN CDN.TraElem ON TrE_TrEId = P.TrS_TrEId
          JOIN CDN.TraNag  ON TrN_TrNId = TrE_TrNId
          JOIN @TrEId_E    ON TrEId = P.TrS_TrEId
        WHERE P.TrS_TwrId     = @TrS_TwrId
          AND P.TrS_MagId     = @TrS_MagId
          AND P.TrS_Typ       = 2
          AND P.TrS_ZwrId IS NULL
          AND P.TrS_Ilosc    >= 0
          AND P.TrS_Rodzaj   <> 306071
          AND TrN_Rodzaj not in (312000,312008)
          AND ( TrN_MagDocId IS NULL  OR ( TrN_Rodzaj = 312100 AND TrN_MagDocId IS NOT NULL ) )
        GROUP BY P.TrS_TrSId
        ORDER BY MAX(P.TrS_DataOpe), P.TrS_TrSId
        OPEN Z
          WHILE 1=1
            BEGIN
              FETCH NEXT FROM Z INTO @Zas_TwZTrS, @Zas_TwZId, @Zas_TrSId, @Zas_TrEId, @Zas_TrSIdDost, @Zas_TrSZwrId, @Zas_TwrId, @Zas_MagId, @Zas_Rodzaj, @Zas_Typ, @Zas_Metoda, @Zas_DataOpe, @Zas_Ilosc, @Zas_Wartosc, @Zas_Cena, @TrN_Bufor,@Poziom
              IF @@FETCH_STATUS <> 0 BREAK
              INSERT INTO @Zasoby (  Zas_TwZTrS,  Zas_TwZId,  Zas_TrSId,  Zas_TrEId,  Zas_TrSIdDost,  Zas_TrSZwrId,  Zas_TwrId,  Zas_MagId,  Zas_Rodzaj,  Zas_Typ,  Zas_Metoda,  Zas_DataOpe,  Zas_Ilosc,  Zas_Wartosc,  Zas_Cena,  TrN_Bufor ,Zas_Poziom)
              VALUES              ( @Zas_TwZTrS, @Zas_TwZId, @Zas_TrSId, @Zas_TrEId, @Zas_TrSIdDost, @Zas_TrSZwrId, @Zas_TwrId, @Zas_MagId, @Zas_Rodzaj, @Zas_Typ, @Zas_Metoda, @Zas_DataOpe, @Zas_Ilosc, @Zas_Wartosc, @Zas_Cena, @TrN_Bufor ,@Poziom)
       -- Jeśli występują korekcyjne, to są dodawane ( tylko dla FIFO i LIFO )
              IF @TrS_Metoda IN ( 1, 2 )
                BEGIN
                  -- Tabela TrE_TrEId-ów elementów WZKK, do których są przypięte subelementy zwrotne 306071
                  INSERT INTO @TrEId_S ( TrEId, Poziom )
                    SELECT TrS_TrEId, 0
                      FROM CDN.TraSElem
                      WHERE TrS_ZwrId = @Zas_TrSId
                        AND TrS_Rodzaj = 306071
             --DECLARE @Poziom INT
             --SET @Poziom = 0
             WHILE 1=1
              BEGIN
                 DELETE FROM @TrSId_E
   INSERT INTO @TrSId_E (TrEId)
    SELECT   K.TrS_TrEId   FROM CDN.TraSElem P
                          LEFT OUTER JOIN CDN.TraSElem K ON P.TrS_TrSId = K.TrS_ZwrId
                          JOIN @TrEId_S ON TrEId = P.TrS_TrEId AND Poziom = @Poziom -- tylko z elementów WZKK wyliczonych wcześniej
                          JOIN CDN.TraSElem Pier ON Pier.TrS_TrSId = @Zas_TrSId
                          WHERE P.TrS_TwrId     = @TrS_TwrId
                          AND P.TrS_MagId     = @TrS_MagId
                          AND P.TrS_Typ       = 2
                          AND P.TrS_ZwrId IS NULL
                          AND P.TrS_Ilosc    >= 0
                          AND P.TrS_Rodzaj   = 306071
                 IF @@ROWCOUNT = 0 BREAK
   INSERT INTO @TrEId_S ( TrEId,Poziom)
      SELECT TrS_TrEId, @Poziom+1
                     FROM CDN.TraSElem
                     -- JOIN @TrEId_S ON TrEId = TrS_TrEId AND Poziom = @Poziom
                     WHERE TrS_TrEId IN (SELECT TrEId FROM @TrSId_E)
                     AND TrS_Rodzaj = 306071 AND TrS_ZwrID IS NULL
               SET @Poziom = @Poziom + 1
              END
                  IF NOT EXISTS ( SELECT * FROM @TrEId_S )
                    CONTINUE
                  --jesli są zagmatwane przepięcia na WZKK to czasem jest kilka dostaw przepinanych z powrotem do jednej i na jednym elemencie wzkk jest kilka przepięć tej samej dostawy i się robi podwojenie ilosci
                  DECLARE @TrEId_S_TEMP     TABLE ( TrEId INT, Poziom INT )
      delete from  @TrEId_S_TEMP
                  insert into @TrEId_S_TEMP  select distinct * from @TrEId_S
                  delete from  @TrEId_S
                  insert into @TrEId_S  select * from @TrEId_S_TEMP
                  -- dodanie sublementów korekcyjnych 306071 z ZwrId = null z WZKK
                  -- WZKK zawsze jest zapisywany na trwałe, więc TrN_Bufor może być ustawiony na 0 i nie jest potrzebny JOIN do CDN.TraNag
                  -- Na końcu jest dodawane TrS_TrSIdDost z dokumentu pierwotnego - potrzebne do łatwiejszego budowania zasobów w sp_OddajZasoby
                  IF @TrS_Metoda = 1
                    INSERT INTO @Zasoby ( Zas_TwZTrS, Zas_TwZId, Zas_TrSId, Zas_TrEId, Zas_TrSIdDost, Zas_TrSZwrId, Zas_TwrId, Zas_MagId, Zas_Rodzaj, Zas_Typ, Zas_Metoda, Zas_DataOpe, Zas_Ilosc, Zas_Wartosc, Zas_Cena, TrN_Bufor, Zas_TrSIdDost_P, Zas_Ilosc_P, Zas_Wartosc_P, Zas_Poziom )
                      SELECT                       1,        NULL, PTrS_TrSId, MAX(PTrS_TrEId),   MAX(PTrS_TrSIdDost),         NULL, @TrS_TwrId, MAX(PTrS_MagId), MAX(PTrS_Rodzaj), MAX(PTrS_Typ), @TrS_Metoda, MAX(PTrS_DataOpe), MAX(PTrS_Ilosc) + SUM(ISNULL(KTrS_Ilosc,0)), MAX(PTrS_Wartosc) + SUM(ISNULL(KTrS_Wartosc,0)), MAX(PTrS_Cena),         0, @Zas_TrSIdDost, MAX(PierTrS_Ilosc), MAX(PierTrS_Wartosc),@Poziom
       FROM
       (
       SELECT DISTINCT P.TrS_TrSId as PTrS_TrSId, P.TrS_TrEId as PTrS_TrEId,   P.TrS_TrSIdDost as PTrS_TrSIdDost,  P.TrS_MagId as PTrS_MagId, P.TrS_Rodzaj as PTrS_Rodzaj , P.TrS_Typ as PTrS_Typ,  P.TrS_DataOpe as PTrS_DataOpe , P.TrS_Ilosc as PTrS_Ilosc   , ISNULL(K.TrS_Ilosc,0) as KTrS_Ilosc, P.TrS_Wartosc as PTrS_Wartosc ,ISNULL(K.TrS_Wartosc,0) as KTrS_Wartosc, P.TrS_Cena as PTrS_Cena, Pier.TrS_Ilosc as PierTrS_Ilosc, Pier.TrS_Wartosc as PierTrS_Wartosc
                        FROM CDN.TraSElem P
                          LEFT OUTER JOIN CDN.TraSElem K ON P.TrS_TrSId = K.TrS_ZwrId
                          JOIN @TrEId_S ON TrEId = P.TrS_TrEId  -- tylko z elementów WZKK wyliczonych wcześniej
                          JOIN CDN.TraSElem Pier ON Pier.TrS_TrSId = @Zas_TrSId
                        WHERE P.TrS_TwrId     = @TrS_TwrId
                          AND P.TrS_MagId     = @TrS_MagId
                          AND P.TrS_Typ       = 2
                          AND P.TrS_ZwrId IS NULL
                          AND P.TrS_Ilosc    >= 0
                          AND P.TrS_Rodzaj   = 306071) A
                        GROUP BY PTrS_TrSId
                        ORDER BY MAX(PTrS_DataOpe) DESC, PTrS_TrSId DESC
                  IF @TrS_Metoda = 2
                    INSERT INTO @Zasoby ( Zas_TwZTrS, Zas_TwZId, Zas_TrSId, Zas_TrEId, Zas_TrSIdDost, Zas_TrSZwrId, Zas_TwrId, Zas_MagId, Zas_Rodzaj, Zas_Typ, Zas_Metoda, Zas_DataOpe, Zas_Ilosc, Zas_Wartosc, Zas_Cena, TrN_Bufor, Zas_TrSIdDost_P, Zas_Ilosc_P, Zas_Wartosc_P , Zas_Poziom)
                      SELECT                       1,        NULL, PTrS_TrSId, MAX(PTrS_TrEId),   MAX(PTrS_TrSIdDost),         NULL, @TrS_TwrId, MAX(PTrS_MagId), MAX(PTrS_Rodzaj), MAX(PTrS_Typ), @TrS_Metoda, MAX(PTrS_DataOpe), MAX(PTrS_Ilosc) + SUM(ISNULL(KTrS_Ilosc,0)), MAX(PTrS_Wartosc) + SUM(ISNULL(KTrS_Wartosc,0)), MAX(PTrS_Cena),         0, @Zas_TrSIdDost, MAX(PierTrS_Ilosc), MAX(PierTrS_Wartosc),@Poziom
       FROM
       (
       SELECT DISTINCT P.TrS_TrSId as PTrS_TrSId, P.TrS_TrEId as PTrS_TrEId,  P.TrS_TrSIdDost as PTrS_TrSIdDost,  P.TrS_MagId as PTrS_MagId, P.TrS_Rodzaj as PTrS_Rodzaj, P.TrS_Typ as PTrS_Typ,  P.TrS_DataOpe as PTrS_DataOpe, P.TrS_Ilosc as PTrS_Ilosc , ISNULL(K.TrS_Ilosc,0) as KTrS_Ilosc, P.TrS_Wartosc as PTrS_Wartosc , ISNULL(K.TrS_Wartosc,0) as KTrS_Wartosc, P.TrS_Cena as PTrS_Cena, Pier.TrS_Ilosc as PierTrS_Ilosc, Pier.TrS_Wartosc as PierTrS_Wartosc
                        FROM CDN.TraSElem P
                        LEFT OUTER JOIN CDN.TraSElem K ON P.TrS_TrSId = K.TrS_ZwrId
                        JOIN @TrEId_S ON TrEId = P.TrS_TrEId  -- tylko z elementów WZKK wyliczonych wcześniej
                        JOIN CDN.TraSElem Pier ON Pier.TrS_TrSId = @Zas_TrSId
                      WHERE P.TrS_TwrId     = @TrS_TwrId
                        AND P.TrS_MagId     = @TrS_MagId
                        AND P.TrS_Typ       = 2
                        AND P.TrS_ZwrId IS NULL
                        AND P.TrS_Ilosc    >= 0
                        AND P.TrS_Rodzaj   = 306071 ) A
                      GROUP BY PTrS_TrSId
                      ORDER BY MAX(PTrS_DataOpe), PTrS_TrSId
              END
            END
        CLOSE Z
      DEALLOCATE Z
    END
  -- wyrzucamy z zestawu subelementy bezużyteczne
  -- korekty wartościowe
  IF @TrS_Ilosc < 0 AND @TrS_Metoda IN ( 1, 2 )
    DELETE FROM @Zasoby WHERE Zas_Ilosc = 0 AND Zas_Wartosc <> 0
  IF @TrS_Ilosc = 0 AND @TrS_Wartosc <> 0 AND @TrS_Metoda IN ( 1, 2 )
    DELETE FROM @Zasoby WHERE Zas_Ilosc = 0 AND Zas_Wartosc = 0
  -- pozostałe korekty
  ELSE
    DELETE FROM @Zasoby WHERE Zas_Ilosc < 0 OR Zas_Wartosc < 0 OR ( Zas_Ilosc = 0 AND Zas_Wartosc = 0 )
  RETURN
END
