CREATE PROCEDURE CDN.KlonujTraSElem
  @CharakterZrodla INT,  -- zrodlo, z ktorego maja byc klonowane subelementy
  @TrS_TrSId       INT,
  @TrS_TrEId  INT,
  @TrS_TrSIdDost INT,
  @TrS_ZwrId  INT,
  @TrS_TwrId  INT,
  @TrS_MagId  INT,
  @TrS_Rodzaj  INT,
  @TrS_Typ  INT,
  @TrS_Metoda  INT,
  @TrS_DataOpe  DATETIME,
  @TrS_Ilosc  DECIMAL(15,4),
  @TrS_Wartosc  DECIMAL(15,2),
  @TrS_Cena  DECIMAL(17,4),
  @TrE_ZwrId            INT,
  @TrN_TrNId            INT,
  @TrN_MagDocId         INT,
  @TrN_Bufor            INT
AS
  SET NOCOUNT ON
  DECLARE
    -- subelementy nowe
    @TrS_TrSId_N        INT,
    @TrS_TrEId_N        INT,
    @TrS_TrSIdDost_N    INT,
    @TrS_ZwrId_N        INT,
    @TrS_TwrId_N        INT,
    @TrS_MagId_N        INT,
    @TrS_Rodzaj_N       INT,
    @TrS_Typ_N          INT,
    @TrS_Metoda_N       INT,
    @TrS_DataOpe_N      DATETIME,
    @TrS_Ilosc_N        DECIMAL(15,4),
    @TrS_Wartosc_N      DECIMAL(15,2),
    @TrS_Cena_N         DECIMAL(17,4),
    -- zmienne pomocnicze
    @Ilosc_Potrzebna    DECIMAL(15,4),
    @Wartosc_Potrzebna  DECIMAL(15,2),
    @Ilosc_Mozliwa      DECIMAL(15,4),
    @Wartosc_Mozliwa    DECIMAL(15,2),
    @Ilosc_Old          DECIMAL(15,4),
    @Wartosc_Old        DECIMAL(15,2)
  -- Kreowanie tabeli tymczasowej odpowiadajacej subelemntom z danymi zrodlowymi wypelnianej w zaleznosci od typu kreowanego subelemntu
  DECLARE @DaneZrodlowe TABLE ( TrSId INT, TrEId INT, TrSIdDost INT, ZwrId INT, TwrId INT, MagId INT, Rodzaj INT, Typ INT, Metoda INT, DataOpe DATETIME, Ilosc DECIMAL(15,4), Wartosc DECIMAL(15,2), Cena DECIMAL(17,4) )
  -- odczytanie potrzebnej ilosci
  SET @Ilosc_Potrzebna = @TrS_Ilosc
  -- WZ korekta ilosciowa
  IF @CharakterZrodla = 2
    BEGIN
      -- FIFO, AVCO, QUAN
      IF @TrS_Metoda = 1 OR @TrS_Metoda = 3 OR @TrS_Metoda = 4
        INSERT INTO @DaneZrodlowe (            TrSId,       TrEId,     TrSIdDost,           ZwrId,     TwrId,    MagId,       Rodzaj,      Typ,     Metoda,       DataOpe,      Ilosc,      Wartosc,     Cena )
          SELECT                     TrSId=TrS_TrSId,  @TrS_TrEId, TrS_TrSIdDost, ZwrId=TrS_TrSId, TrS_TwrId, TrS_MagId, @TrS_Rodzaj, @TrS_Typ, TrS_Metoda, @TrS_DataOpe, -TrS_Ilosc, -TrS_Wartosc, TrS_Cena  FROM cdn.TraSElem WHERE TrS_TrEId = @TrE_ZwrId ORDER BY TrS_DataOpe DESC, TrS_TrSId DESC
        INSERT INTO @DaneZrodlowe (            TrSId,       TrEId,     TrSIdDost,           ZwrId,     TwrId,    MagId,       Rodzaj,      Typ,     Metoda,       DataOpe,      Ilosc,      Wartosc,     Cena )
          SELECT                     TrSId=TrS_TrSId,  @TrS_TrEId, TrS_TrSIdDost, ZwrId=TrS_TrSId, TrS_TwrId, TrS_MagId, @TrS_Rodzaj, @TrS_Typ, TrS_Metoda, @TrS_DataOpe, -TrS_Ilosc, -TrS_Wartosc, TrS_Cena  FROM cdn.TraSElem WHERE TrS_TrEId = @TrS_TrEId AND TrS_Rodzaj = 306061 AND TrS_ZwrId IS NULL ORDER BY TrS_DataOpe DESC, TrS_TrSId DESC
      -- LIFO
      IF @TrS_Metoda = 2
        INSERT INTO @DaneZrodlowe (            TrSId,       TrEId,     TrSIdDost,           ZwrId,    TwrId,      MagId,      Rodzaj, Typ,          Metoda,      DataOpe,       Ilosc,      Wartosc,     Cena )
          SELECT                     TrSId=TrS_TrSId,  @TrS_TrEId, TrS_TrSIdDost, ZwrId=TrS_TrSId, TrS_TwrId, TrS_MagId, @TrS_Rodzaj, @TrS_Typ, TrS_Metoda, @TrS_DataOpe, -TrS_Ilosc, -TrS_Wartosc, TrS_Cena  FROM cdn.TraSElem WHERE TrS_TrEId = @TrE_ZwrId ORDER BY TrS_DataOpe, TrS_TrSId
        INSERT INTO @DaneZrodlowe (            TrSId,       TrEId,     TrSIdDost,           ZwrId,     TwrId,    MagId,       Rodzaj,      Typ,     Metoda,      DataOpe,       Ilosc,      Wartosc,     Cena )
          SELECT                     TrSId=TrS_TrSId,  @TrS_TrEId, TrS_TrSIdDost, ZwrId=TrS_TrSId, TrS_TwrId, TrS_MagId, @TrS_Rodzaj, @TrS_Typ, TrS_Metoda, @TrS_DataOpe, -TrS_Ilosc, -TrS_Wartosc, TrS_Cena  FROM cdn.TraSElem WHERE TrS_TrEId = @TrS_TrEId AND TrS_Rodzaj = 306061 AND TrS_ZwrId IS NULL ORDER BY TrS_DataOpe, TrS_TrSId
    END
  -- WZ korekcyjna do PZ korekty ilosciowej
  -- ilosc dodatnia - kursor po zasobach tak jak dla zwyklej WZ ( ale bez obrabianej dostawy w przypadku FIFO, LIFO )
  IF @CharakterZrodla = 3
    BEGIN
      -- FIFO
      IF @TrS_Metoda = 1
        INSERT INTO @DaneZrodlowe (      TrSId,      TrEId,     TrSIdDost,  ZwrId,      TwrId,      MagId,      Rodzaj, Typ,      Metoda,      DataOpe,     Ilosc,     Wartosc,     Cena )
          SELECT                    @TrS_TrSId,  @TrS_TrEId, TwZ_TrSIdDost,  NULL, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj,   2, @TrS_Metoda, @TrS_DataOpe, TwZ_Ilosc, TwZ_Wartosc, TwZ_Cena     FROM cdn.TwrZasoby WHERE TwZ_TwrId = @TrS_TwrId AND TwZ_MagId = @TrS_MagId AND TwZ_TrSIdDost <> @TrS_TrSIdDost AND TwZ_Ilosc > 0 ORDER BY TwZ_Data,      TwZ_TrSIdDost
      -- LIFO
      IF @TrS_Metoda = 2
        INSERT INTO @DaneZrodlowe (      TrSId,      TrEId,     TrSIdDost, ZwrId,      TwrId,      MagId,      Rodzaj, Typ,      Metoda,      DataOpe,      Ilosc,     Wartosc,     Cena )
          SELECT                    @TrS_TrSId,  @TrS_TrEId, TwZ_TrSIdDost,  NULL, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj,   2, @TrS_Metoda, @TrS_DataOpe, TwZ_Ilosc, TwZ_Wartosc, TwZ_Cena     FROM cdn.TwrZasoby WHERE TwZ_TwrId = @TrS_TwrId AND TwZ_MagId = @TrS_MagId AND TwZ_TrSIdDost <> @TrS_TrSIdDost AND TwZ_Ilosc > 0 ORDER BY TwZ_Data DESC, TwZ_TrSIdDost DESC
      -- AVCO, QUAN
      IF @TrS_Metoda IN ( 3, 4 )
        INSERT INTO @DaneZrodlowe (      TrSId,      TrEId,     TrSIdDost,  ZwrId,      TwrId,      MagId,      Rodzaj, Typ,      Metoda,      DataOpe,     Ilosc,     Wartosc,     Cena )
          SELECT                    @TrS_TrSId,  @TrS_TrEId, TwZ_TrSIdDost,  NULL, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj,   2, @TrS_Metoda, @TrS_DataOpe, TwZ_Ilosc, TwZ_Wartosc, TwZ_Cena     FROM cdn.TwrZasoby WHERE TwZ_TwrId = @TrS_TwrId AND TwZ_MagId = @TrS_MagId AND TwZ_TrSIdDost IS NULL AND TwZ_Ilosc > 0
      -- kursor po calym dokumencie - na innych elementach mogl wystapic juz ten sam towar
      DECLARE TmpKursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT TrS_TrSIdDost, TrS_TwrId, TrS_MagId, TrS_Ilosc, TrS_Wartosc
        FROM cdn.TraSElem
          JOIN cdn.TraElem ON TrE_TrEId = TrS_TrEId
        WHERE TrE_TrNId = @TrN_TrNId AND TrS_Ilosc < 0
          OPEN TmpKursor
          WHILE 1=1
            BEGIN
              FETCH NEXT FROM TmpKursor INTO @TrS_TrSIdDost_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Ilosc_N, @TrS_Wartosc_N
                IF @@FETCH_STATUS <> 0 BREAK
                  IF @TrS_Metoda IN ( 1, 2 )
                    BEGIN
                      IF EXISTS ( SELECT * FROM @DaneZrodlowe WHERE TwrId = @TrS_TwrId_N AND MagId = @TrS_MagId_N AND TrSIdDost = @TrS_TrSIdDost_N )
                        BEGIN
                          SELECT @Ilosc_Old = Ilosc,   @Wartosc_Old = Wartosc  FROM @DaneZrodlowe WHERE TwrId = @TrS_TwrId_N AND MagId = @TrS_MagId_N AND TrSIdDost = @TrS_TrSIdDost_N
                          UPDATE @DaneZrodlowe SET Ilosc = @Ilosc_Old + @TrS_Ilosc_N, Wartosc = @Wartosc_Old + @TrS_Wartosc_N WHERE TwrId = @TrS_TwrId_N AND MagId = @TrS_MagId_N AND TrSIdDost = @TrS_TrSIdDost_N
                        END
                     END
                  IF @TrS_Metoda IN ( 3, 4 )
                    BEGIN
                      IF EXISTS ( SELECT * FROM @DaneZrodlowe WHERE TwrId = @TrS_TwrId_N AND MagId = @TrS_MagId_N AND TrSIdDost IS NULL )
                        BEGIN
                          SELECT @Ilosc_Old = Ilosc,   @Wartosc_Old = Wartosc  FROM @DaneZrodlowe WHERE TwrId = @TrS_TwrId_N AND MagId = @TrS_MagId_N AND TrSIdDost IS NULL
                          UPDATE @DaneZrodlowe SET Ilosc = @Ilosc_Old + @TrS_Ilosc_N, Wartosc = @Wartosc_Old + @TrS_Wartosc_N WHERE TwrId = @TrS_TwrId_N AND MagId = @TrS_MagId_N AND TrSIdDost IS NULL
                        END
                    END
            END
          CLOSE TmpKursor
      DEALLOCATE TmpKursor
      DELETE FROM @DaneZrodlowe WHERE  Ilosc = 0 AND  Wartosc = 0
    END
  -- start procesu klonowania
  DECLARE Zrodlo CURSOR LOCAL FAST_FORWARD FOR
    SELECT TrSId, TrEId, TrSIdDost, ZwrId, TwrId, MagId, Rodzaj, Typ, Metoda, DataOpe, Ilosc, Wartosc, Cena
      FROM @DaneZrodlowe
    OPEN Zrodlo
      WHILE 1=1
        BEGIN
          FETCH NEXT FROM Zrodlo INTO @TrS_TrSId_N, @TrS_TrEId_N, @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_MagId_N, @TrS_Rodzaj_N, @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N, @TrS_Cena_N
          IF @@FETCH_STATUS <> 0 BREAK
            -- ilosc mozliwa do pobrania ze zrodla z uwzglednieniem subelementów, które juz skorygowano (wazne dla zródel pochadzacych z innych subelementow)
            SELECT
              @Ilosc_Mozliwa   = @TrS_Ilosc_N   - ISNULL(SUM(TrS_Ilosc),  0),
              @Wartosc_Mozliwa = @TrS_Wartosc_N - ISNULL(SUM(TrS_Wartosc),0)
              FROM cdn.TraSElem
              WITH (INDEX = TrSZwrot)
              WHERE TrS_ZwrID = @TrS_TrSId_N
            IF @Ilosc_Mozliwa = 0 CONTINUE
            IF EXISTS (
              SELECT * FROM cdn.TraSElem
              WITH (INDEX = TrSZwrot)
              WHERE TrS_ZwrID = @TrS_TrSId_N AND TrS_Ilosc=0 AND TrS_Rodzaj = 306072
              )
              SET @TrS_Cena_N = @Wartosc_Mozliwa / @Ilosc_Mozliwa
            -- ilosc i wartosc  dla nowego subelementu
            IF ABS(@Ilosc_Potrzebna) >= ABS(@Ilosc_Mozliwa)
              SELECT
                @TrS_Ilosc_N   = @Ilosc_Mozliwa,
                @TrS_Wartosc_N = @Wartosc_Mozliwa
            ELSE
              SELECT
                @TrS_Ilosc_N   = @Ilosc_Potrzebna,
                @TrS_Wartosc_N = @TrS_Ilosc_N * ( @Wartosc_Mozliwa / @Ilosc_Mozliwa )
            -- ile jeszcze potrzeba pobrac
            SET @Ilosc_Potrzebna = @Ilosc_Potrzebna - @TrS_Ilosc_N
            -- wyliczenie kolejnego subelementu i aktualizacja zasobu dla magazynu zrodlowego
     INSERT INTO cdn.TraSElem (  TrS_TrEId,     TrS_TrSIdDost,    TrS_ZwrId,    TrS_TwrId,     TrS_MagId,     Trs_Rodzaj,     TrS_Typ,    TrS_Metoda,    TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,     TrS_Cena   )
       VALUES                 ( @TrS_TrEId_N,  @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N,  @TrS_MagId_N,  @Trs_Rodzaj_N,  @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N,  @TrS_Cena_N )
            -- wyliczenie komplementarnego zasobu dla subelementu MM i aktualizacja zasobu w magazynie docelowym
            IF @TrN_MagDocId IS NOT NULL AND @TrN_Bufor IN ( 1, 0 ) AND @TrS_Rodzaj NOT IN ( 312100, 312010 )
              BEGIN
                SELECT
                  @TrS_MagId_N   =   @TrN_MagDocId,
                  @TrS_ZwrId_N   =   NULL
                -- bufor i subelement zamowieniowy
                IF @TrN_Bufor = 1
                  SELECT
                    @TrS_Typ_N     = 4,
                    @TrS_Wartosc_N = 0,
                    @TrS_Cena_N    = 0
                -- akceptacja i subelement dostawczy
                ELSE IF @TrN_Bufor = 0
                  SELECT
                    @TrS_Ilosc_N   = - @TrS_Ilosc_N,
                    @TrS_Wartosc_N = - @TrS_Wartosc_N
         INSERT INTO cdn.TraSElem (  TrS_TrEId,     TrS_TrSIdDost,    TrS_ZwrId,    TrS_TwrId,     TrS_MagId,     Trs_Rodzaj,     TrS_Typ,      TrS_Metoda,  TrS_DataOpe,    TrS_Ilosc,    TrS_Wartosc,     TrS_Cena   )
               VALUES                 ( @TrS_TrEId_N,  @TrS_TrSIdDost_N, @TrS_ZwrId_N, @TrS_TwrId_N,  @TrS_MagId_N,  @Trs_Rodzaj_N,  @TrS_Typ_N, @TrS_Metoda_N, @TrS_DataOpe_N, @TrS_Ilosc_N, @TrS_Wartosc_N,  @TrS_Cena_N )
              END
            -- STOP Cala potrzebna ilosc zostala wykorzystana
            IF @Ilosc_Potrzebna = 0 BREAK
        END  -- WHILE
    CLOSE Zrodlo
  DEALLOCATE Zrodlo
  SET NOCOUNT OFF
