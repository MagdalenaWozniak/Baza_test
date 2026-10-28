CREATE PROCEDURE CDN.NaliczajKWS
  @InsDel           INT,      --1 = Insert, 2 = Delete
  @Koniec           DATETIME,
  @TrN_OpeZalId     INT,
  @TrN_TS_Zal       DATETIME
  AS
  SET NOCOUNT ON
   declare @OpeZalKod varchar(20), @OpeZalNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @TrN_OpeZalId, @OpeZalKod OUT, @OpeZalNazwisko OUT
  BEGIN Transaction
  DECLARE
    -- naglowek i elementy
    @TrN_TrNId          INT,
    @TrN_Rodzaj         INT,
    @TrE_TrEId          INT,
    -- pomocnicze
    @Poczatek           DATETIME,
    @Komunikat          NVARCHAR(255),
    @Metoda             INT,
    @QUAN               INT,
    @Koniec1           DATETIME,
    -- naglowek nowy
    @TrN_TrNId_N        INT,
    @TrN_MagZrdId       INT,
    @TrN_DataDok        DATETIME,
    @TrN_NumerNr_N      INT,
    @DDfId              INT,
    @TrN_NumerString_N  NVARCHAR(100),
    @TrN_RazemNetto_N   DECIMAL(15,4),
    @TrN_Opis_N         NVARCHAR(255),
    @TrN_StaZalId       INT,
    -- baza konfiguracyjna
    @KnfSrv             SYSNAME,
    @KnfDb              SYSNAME,
    -- do wyliczenia serii dla operatora
    @SeriaOperatora     NVARCHAR(5),
    @RejestrOperatora   NVARCHAR(20),
    -- zmienna dla kasowanych subelementów
    @TrS_TrSId          INT,
    @TreTrNId   INT,
    @TrETrEId   INT,
 -- piecząta firmy
    @PCID               INT,
    @PCIDJS             INT,
 --logi
 @NumerPelny  NVarchar(30)
  -- Dzialania przy dodawaniu i kasowaniu
  IF @InsDel IN ( 1, 2 )
    BEGIN
      -- TrN_Rodzaj
      SELECT
        @TrN_Rodzaj   = 310005,
        @TrN_StaZalId = 0,
        @TrN_MagZrdId = 1,
        @TrN_DataDok  = @Koniec
      -- ustalenie metody liczenia KWS z konfiguracji i zaznaczenia QUAN-u
      SET @QUAN   = ( SELECT TOP 1 ISNULL( Fir_Wartosc,0 ) FROM cdn.Firma WHERE Fir_Numer = 1485 )
      SET @Metoda = ( SELECT TOP 1 ISNULL( Fir_Wartosc,1 ) FROM cdn.Firma WHERE Fir_Numer = 1352 )
      IF  @Metoda NOT IN ( 1, 2, 3, 4 ) OR @QUAN NOT IN ( 0, 1 )
        BEGIN
          SET @Komunikat = '##OPT34442##'
          GOTO KOMUNIKAT
        END
      -- ustalenie poczatkowej daty dla ktorej bedzie zamykany bilans
      SET @Poczatek = ( SELECT MAX( TrN_DataOpe ) FROM CDN.TraNag WHERE TrN_Rodzaj = 310005 )
        IF @Poczatek IS NULL
          SET @Poczatek = ( SELECT ISNULL( MIN( TrN_DataOpe ),0 ) FROM CDN.TraNag )
        ELSE
          SET @Poczatek = @Poczatek + 1
    END
  -- Dzialania przy kasowaniu
  IF @InsDel = 2
    BEGIN
      -- Kontrola, czy po dacie przekazanej przy kasowaniu wystepuje jakis BZM
      IF EXISTS ( SELECT * FROM CDN.TraNag WHERE TrN_Rodzaj = 310005 AND TrN_DataOpe > @Koniec )
        BEGIN
          SET @Komunikat = '##OPT34443##'
          GOTO KOMUNIKAT
        END
      -- ustalenie daty koncowej w przypadku kasowania
      SET @Koniec1 = ( SELECT MAX( TrN_DataOpe ) FROM CDN.TraNag )
      -- kontrola , czy w podanym okresie sa zaksiegowane dokumenty o typach 303, 304, 306, 307, 310, 312, 317, 318
      IF EXISTS ( SELECT * FROM CDN.TraNag WHERE TrN_DataOpe >= @Poczatek AND TrN_DataOpe <= @Koniec1
                  AND TrN_TypDokumentu IN ( 303, 304, 306, 307, 310, 312, 317, 318 )
                  AND (  ( TrN_VanId IS NOT NULL AND TrN_TypDokumentu <> 310 ) OR ( TrN_DekId IS NOT NULL AND TrN_TypDokumentu <> 310 ) ) )
                  AND @QUAN IN ( 1 )
        BEGIN
          SET @Komunikat = '##OPT34444##'
          GOTO KOMUNIKAT
        END
    END
  -- Dzialania przy dodawaniu
  IF @InsDel = 1
    BEGIN
      -- Kontrola, czy pod data koncowa wystepuje juz BZM
      IF EXISTS ( SELECT * FROM CDN.TraNag WHERE TrN_Rodzaj = 310005 AND TrN_DataOpe = @Koniec )
        BEGIN
          SET @Komunikat = '##OPT34445##'
          GOTO KOMUNIKAT
        END
      -- Kontrola, czy sa transakcje do zamkniecia
      IF NOT EXISTS ( SELECT * FROM cdn.TraSElem WHERE TrS_DataOpe >= @Poczatek AND TrS_DataOpe <= @Koniec AND TrS_Typ IN ( 1, 2 ) )
        BEGIN
          SET @Komunikat = '##OPT34446##'
          GOTO KOMUNIKAT
        END
      -- Kontrola, czy data koncowa nie jest mniejsza od daty ostatniego BZM
      IF @Koniec < @Poczatek
        BEGIN
          SET @Komunikat = '##OPT34447##'
          GOTO KOMUNIKAT
        END
      -- kontrola , czy w podanym okresie wystepuja rezerwacje,zamowienia,braki - w zaleznosci od parametru w konf
      IF ( SELECT ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1826 ) <> 1
       BEGIN
        -- kontrola , czy w podanym okresie wystepuja rezerwacje - tylko przy INSERT
        IF ( SELECT SUM(TwI_Rezerwacje) FROM cdn.TwrIlosci WHERE TwI_Data <= @Koniec AND TwI_MagId IS NULL ) > 0
          IF( select sum(trs_ilosc) from cdn.traselem where trs_typ = 3 AND Trs_DataOpe <=@Koniec) > 0
          BEGIN
            SET @Komunikat = '##OPT34448##'
            GOTO KOMUNIKAT
          END
        -- kontrola , czy w podanym okresie wystepują zamowienia - tylko przy INSERT
        IF ( SELECT SUM(TwI_Zamowienia) FROM cdn.TwrIlosci WHERE TwI_Data <= @Koniec AND TwI_MagId IS NULL ) > 0
          IF( select sum(trs_ilosc) from cdn.traselem where trs_typ = 4 AND Trs_DataOpe <=@Koniec) > 0
          BEGIN
            SET @Komunikat = '##OPT34449##'
            GOTO KOMUNIKAT
          END
        -- kontrola , czy w podanym okresie wystepuja braki
        IF ( SELECT SUM(TwI_Braki) FROM cdn.TwrIlosci WHERE TwI_Data <= @Koniec AND TwI_MagId IS NULL ) > 0
          BEGIN
            SET @Komunikat = '##OPT34450##'
            GOTO KOMUNIKAT
          END
      END
    END
  IF @InsDel IN ( 1 )  OR ( @InsDel IN ( 2 )  AND  @QUAN = 1 )
    BEGIN
      -- kontrola , czy w podanym okresie sa dokumenty w buforze za wyjątkiem pierwotnych
      IF EXISTS ( SELECT * FROM CDN.TraNag WHERE TrN_DataOpe >= @Poczatek AND TrN_DataOpe <= @Koniec AND TrN_Bufor = 1 AND TrN_Rodzaj NOT IN ( 302100, 305100, 301100, 345000  )  AND TrN_TypDokumentu NOT IN (321, 322) )
        BEGIN
          SET @Komunikat = '##OPT34451##'
          GOTO KOMUNIKAT
        END
      -- Tworzenie naglowka - tylko dla Ins.
      IF @InsDel = 1
        BEGIN
          SELECT
            @DDfId        = CDN.DomyslnaDefinicja ( @TrN_Rodzaj ),
            @TrN_Opis_N        = ' Bilans zamknięcia magazynu '
          SELECT @KnfSrv    = SYS_Wartosc FROM CDN.SystemCDN WHERE SYS_ID=1001
          SELECT @KnfDb     = SYS_Wartosc FROM CDN.SystemCDN WHERE SYS_ID=1002
          -- seria operatora
          IF ( SELECT TOP 1 DDf_SeriaOperatora FROM cdn.DokDefinicje WHERE DDF_DDFId = @DDFId ) = 1
            EXEC CDN.SeriaOperatora @KnfSrv, @KnfDb, @TrN_OpeZalId, @SeriaOperatora OUTPUT, @RejestrOperatora OUTPUT
          SET @SeriaOperatora = ISNULL(@SeriaOperatora, '')
          -- NumerString dodawanego nagłówka
          SET @TrN_NumerString_N = CDN.NumerString (
                                                         @TrN_Rodzaj      , -- Rodzaj dokumentu
                                                         @TrN_OpeZalId    , -- Operator inicjujący dokument do numeracji
                                                         @TrN_StaZalId    , -- Stanowisko, na którym zainicjowano dokument
                                                         @TrN_MagZrdId    , -- Id magazynu do numeracji
                                                         @TrN_DataDok     , -- Data dokumentu
                                                         @SeriaOperatora,    -- seria operatora
       default,
       default,
       default
                                                       )
              SET @Komunikat = CDN.SprawdzNumerString ( @DDFId, @TrN_NumerString_N )
              IF @Komunikat <> '' GOTO KOMUNIKAT
          -- obliczenie kolejnego numeru dokumentu i insert naglowka
    --pieczatka
          SELECT @PCIDJS = PCJS_PCJSID FROM CDN.PieczatkiJS WHERE @Koniec BETWEEN PCJS_DataOd AND PCJS_DataDo
          SELECT @PCID = Pc_PCID  FROM CDN.Pieczatki WHERE @Koniec BETWEEN PC_DataOd AND PC_DataDo
          SET @TrN_NumerNr_N = 1 + ( SELECT ISNULL(MAX(TrN_NumerNr),0) AS MaxNumerNr FROM CDN.TraNag WHERE TrN_NumerString = @TrN_NumerString_N )
          INSERT INTO cdn.TraNag (  TrN_DDfId,  TrN_TypDokumentu, TrN_ZwrId, TrN_FaId,  TrN_NumerNr,         TrN_NumerString,       TrN_Bufor, TrN_VaNId, TrN_DataDok, TrN_DataWys, TrN_DataOpe, TrN_NumerObcy, TrN_Korekta, TrN_Fiskalna, TrN_Detal, TrN_Rodzaj, TrN_PodmiotTyp, TrN_PodID, TrN_PodNazwa1, TrN_PodNazwa2, TrN_PodKraj, TrN_PodWojewodztwo, TrN_PodPowiat, TrN_PodGmina, TrN_PodUlica, TrN_PodNrDomu, TrN_PodNrLokalu, TrN_PodMiasto, TrN_PodKodPocztowy, TrN_PodPoczta, TrN_PodAdres2, TrN_PodNipE, TrN_Finalny, TrN_Export, TrN_NotaKorPrzed, TrN_NotaKorPo, TrN_TrSTyp,
                                    TrN_OdbiorcaTyp, TrN_OdbID, TrN_OdbNazwa1, TrN_OdbNazwa2, TrN_OdbKraj, TrN_OdbWojewodztwo, TrN_OdbPowiat, TrN_OdbGmina, TrN_OdbUlica, TrN_OdbNrDomu, TrN_OdbNrLokalu, TrN_OdbMiasto, TrN_OdbKodPocztowy, TrN_OdbPoczta, TrN_OdbAdres2, TrN_OdbNipE, TrN_KatID, TrN_Kategoria, TrN_FPlId, TrN_Termin,  TrN_RazemNetto,   TrN_RazemVAT,  TrN_RazemBrutto,   TrN_BlokadaPlatnosci,  TrN_MagZrdId,   TrN_MagDocId, TrN_TypNB, TrN_Rabat, TrN_Odebral, TrN_Opis,  TrN_OpeZalID, TrN_OpeZalKod, TrN_OpeZalNazwisko,  TrN_TS_Zal,  TrN_OpeModID, TrN_OpeModKod, TrN_OpeModNazwisko,  TrN_TS_Mod, TrN_Waluta, TrN_KursNumer, TrN_KursL, TrN_KursM, TrN_RazemNettoWal, TrN_PodNazwa3, TrN_OdbNazwa3, TrN_Centrala, TrN_PodmiotGLN, TrN_OdbiorcaGLN, TrN_NumerPelnyPrw, TrN_PlatElemWalSys, TrN_RazemBruttoWal, TrN_RazemVATWal, TrN_PodNipKraj, TrN_OdbNipKraj, TrN_KodTransakcji, TrN_KodKraju, TrN_Anulowany, TrN_PlatKaucje, TrN_TaxFreePotwierdzony
                                    ,TrN_VatDlaDokWal, TrN_DataKur,TrN_OpeZatwID,TrN_OpeZatwKod,TrN_OpeZatwNazwisko,TrN_TS_Zatw ,TrN_PCID,TrN_PCJSID)
            VALUES               (  @DDfId,               310,      NULL,     NULL, @TrN_NumerNr_N, LEFT(@TrN_NumerString_N,31),         0,      NULL,     @Koniec,     @Koniec,     @Koniec,            '',           0,            0,         0,     310005,              1,         1,            '',            '',          '',                 '',            '',           '',           '',            '',              '',            '',                 '',            '',            '',          '',           0,          0,               '',            '',          0,
                                                  1,         1,            '',            '',          '',                 '',            '',           '',           '',            '',              '',            '',                 '',            '',            '',          '',      NULL,            '',         1,    @Koniec,               0,            0,                  0,                      1, @TrN_MagZrdId,           NULL,         1,         0,          '',       '', @TrN_OpeZalID, @OpeZalKod, @OpeZalNazwisko, @TrN_TS_Zal, @TrN_OpeZalID, @OpeZalKod, @OpeZalNazwisko, @TrN_TS_Zal,        '',             0,         1,         1,                 0,            '',            '',            0,             '',              '',                '',                  0,                  0,               0,           'PL',           'PL',                '',            '',             0,              0,                       0
                                     ,              0, @Koniec, @TrN_OpeZalID, @OpeZalKod, case when @OpeZalNazwisko = '' then @OpeZalKod else @OpeZalNazwisko end , @TrN_TS_Zal,@PCID,@PCIDJS)
          SET @TrN_TrNId_N = ( SELECT MAX( TrN_TrNId ) FROM CDN.TraNag )
  --logi
  select @NumerPelny = TrN_numerPelny from cdn.tranag where trn_trnid = @TrN_TrNId_N
  exec [CDN].[RejestrOperacjiDodaj] 310,1, @TrN_TrNId_N, @NumerPelny, 1, ''
  exec [CDN].[RejestrOperacjiDodaj] 310,1, @TrN_TrNId_N, @NumerPelny, 103, ''
        END -- End dla tworzenia naglowka
      -- Naliczenie kosztu jesli w konfiguracji jest ustawiony QUAN
      IF @QUAN = 1
        BEGIN
/*
         -- BEGIN poprawka
         -- zapamietanie wszystkich dokumentów od ostatniego BZM do końca (dla nich będą kasowane i odbudowywane subelementy
          DECLARE @TrN TABLE (TrETrEId INT, TrE_DataOpe DATETIME, TrE_Rodzaj INT, TrE_TrNId INT)
          INSERT INTO  @TrN
            SELECT TrE_TrEId, TrE_DataOpe, TrE_TypDokumentu, TrE_TrNId
              FROM cdn.TraElem
              WHERE TrE_DataOpe >= @Poczatek AND -1 <> (SELECT TOP 1 TrN_Bufor FROM CDN.TraNag WHERE TrN_TrNId = TrE_TrNId)
          -- kasowanie wszystkich subelementów o typach 1 i 2 od ostatniego BZM do końca
          DELETE cdn.TraSElem
            FROM cdn.TraSElem
            JOIN cdn.TraElem ON TrE_TrEId = TrS_TrEId
            JOIN @TrN ON TrETrEId = TrE_TrEId
          -- Kasowanie RWS-ów, bo przy odbudowie będą tworzone przez procedurę GenerujRWS
          DELETE FROM @TrN WHERE CONVERT(INT, TrE_Rodzaj) = 318
          -- kasowanie wszystkich dokumentów korekcyjnych WZKK o rodzaju 306071, 306072, 306061
          DECLARE WZKK CURSOR LOCAL FAST_FORWARD FOR
            SELECT TrN_TrNId
            FROM cdn.TraNag
            WHERE TrN_DataOpe >= @Poczatek AND TrN_Rodzaj IN (306071, 306072, 306061) AND TrN_Bufor IN ( 0, 1 )
            ORDER BY TrN_DataOpe DESC, TrN_TrNId DESC
              OPEN WZKK
                WHILE 1=1
                  BEGIN
                    FETCH NEXT FROM WZKK INTO @TrN_TrNId
                    IF @@FETCH_STATUS <> 0 BREAK
                      UPDATE cdn.TraNag SET TrN_Bufor = 1 WHERE TrN_TrNId = @TrN_TrNId
                      DELETE FROM cdn.TraNag WHERE TrN_TrNId = @TrN_TrNId
                  END
              CLOSE WZKK
          DEALLOCATE WZKK
          -- kreowanie nowych subelementow od @Poczatek do @Koniec zgodnie z metoda z konfiguracji ( Metoda_F )
          -- kreowanie nowych subelementow od @Koniec do konca bazy zgodnie z metoda z programu  ( Metoda_P )
          DECLARE N CURSOR LOCAL FAST_FORWARD FOR
            SELECT TrETrEId, TrE_Rodzaj, TrE_TrNId
            FROM @TrN
            ORDER BY TrE_DataOpe, TrETrEId
            OPEN N
              WHILE 1=1
                BEGIN
                  FETCH NEXT FROM N INTO @TrETrEId, @TrN_Rodzaj, @TreTrNId
                  IF @@FETCH_STATUS <> 0 BREAK
                  -- Jesli dokumentem jest PWP  - najpierw GenerujRWS
                  IF CONVERT (int, @TrN_Rodzaj/1000) = 317
                    BEGIN
                      EXECUTE CDN.GenerujRWS @TrETrNId
                      CONTINUE
                    END
                  -- techniczny update elementów - trigger załatwi reszte
                    UPDATE cdn.TraElem SET TrE_Aktywny = 1 WHERE TrE_TrEId = @TrETrEId
                END
              CLOSE N
            DEALLOCATE N
         -- END poprawka
      */
          -- zapamietanie wszystkich dokumentów od ostatniego BZM do końca (dla nich będą kasowane i odbudowywane subelementy
          DECLARE @TrN TABLE (TrN_TrNId INT, TrN_DataOpe DATETIME, TrN_Rodzaj INT)
          INSERT INTO  @TrN
            SELECT TrN_TrNId, TrN_DataOpe, TrN_Rodzaj
              FROM cdn.TraNag
              WHERE TrN_DataOpe >= @Poczatek AND TrN_Bufor <> -1
          -- kasowanie wszystkich subelementów o typach 1 i 2 od ostatniego BZM do końca
          DELETE cdn.TraSElem
            FROM cdn.TraSElem
            JOIN cdn.TraElem ON TrE_TrEId = TrS_TrEId
            JOIN @TrN ON TrN_TrNId = TrE_TrNId
          -- Kasowanie RWS-ów, bo przy odbudowie będą tworzone przez procedurę GenerujRWS
          DELETE FROM @TrN WHERE CONVERT(INT, TrN_Rodzaj/1000) = 318
          -- kasowanie wszystkich dokumentów korekcyjnych WZKK o rodzaju 306071, 306072, 306061
          DECLARE WZKK CURSOR LOCAL FAST_FORWARD FOR
            SELECT TrN_TrNId
            FROM cdn.TraNag
            WHERE TrN_DataOpe >= @Poczatek AND TrN_Rodzaj IN (306071, 306072, 306061) AND TrN_Bufor IN ( 0, 1 )
            ORDER BY TrN_DataOpe DESC, TrN_TrNId DESC
              OPEN WZKK
                WHILE 1=1
                  BEGIN
                    FETCH NEXT FROM WZKK INTO @TrN_TrNId
                    IF @@FETCH_STATUS <> 0 BREAK
                      UPDATE cdn.TraNag SET TrN_Bufor = 1 WHERE TrN_TrNId = @TrN_TrNId
                      DELETE FROM cdn.TraNag WHERE TrN_TrNId = @TrN_TrNId
                  END
              CLOSE WZKK
          DEALLOCATE WZKK
          -- kreowanie nowych subelementow od @Poczatek do @Koniec zgodnie z metoda z konfiguracji ( Metoda_F )
          -- kreowanie nowych subelementow od @Koniec do konca bazy zgodnie z metoda z programu  ( Metoda_P )
          DECLARE N CURSOR LOCAL FAST_FORWARD FOR
            SELECT TrN_TrNId, TrN_Rodzaj
            FROM @TrN
            ORDER BY TrN_DataOpe, TrN_TrNId
            OPEN N
              WHILE 1=1
                BEGIN
                  FETCH NEXT FROM N INTO @TrN_TrNId, @TrN_Rodzaj
                  IF @@FETCH_STATUS <> 0 BREAK
                  -- Jesli dokumentem jest PWP  - najpierw GenerujRWS
                  IF CONVERT (int, @TrN_Rodzaj/1000) = 317
                    BEGIN
                      EXECUTE CDN.GenerujRWS @TrN_TrNId,''
                      CONTINUE
                    END
                  -- techniczny update elementów - trigger załatwi reszte
                  DECLARE E CURSOR LOCAL FAST_FORWARD FOR
                    SELECT TrE_TrEId FROM cdn.TraElem WHERE TrE_TrNId = @TrN_TrNId ORDER BY TrE_TrEId
                    OPEN E
                      WHILE 1=1
                        BEGIN
                          FETCH NEXT FROM E INTO @TrE_TrEId
                          IF @@FETCH_STATUS <> 0 BREAK
                          -- update techniczny
                          UPDATE cdn.TraElem SET TrE_Aktywny = 1 WHERE TrE_TrEId = @TrE_TrEId
                       END
                    CLOSE E
                  DEALLOCATE E
                END
              CLOSE N
            DEALLOCATE N
        -- Tworzenie tabelek VAT dla dokumentów wewnętrznych i aktualizacja nagłóków
        DECLARE @TraVat Table ( TrN_TypNB SMALLINT, TrV_Stawka DECIMAL (5,2), TrV_Flaga SMALLINT, TrV_Zrodlowa DECIMAL(5,2), TrV_Netto DECIMAL(15,2), TrV_Brutto DECIMAL (15,2), TrV_VAT DECIMAL (15,2), TrV_NettoWal DECIMAL(15,2), TrV_BruttoWal DECIMAL (15,2), TrV_VATWal DECIMAL (15,2) )
        DECLARE N CURSOR LOCAL FAST_FORWARD FOR
          SELECT TrN_TrNId
            FROM cdn.TraNag
            WHERE TrN_TypDokumentu IN ( 303, 304, 312, 318, 317 ) AND TrN_DataOpe >= @Poczatek AND TrN_Bufor IN (0, 1)
          OPEN N
            WHILE 1=1
              BEGIN
                FETCH NEXT FROM N INTO @TrN_TrNId
                IF @@FETCH_STATUS <> 0 BREAK
                -- odtworzenie tabeli tymczasowej i nagłówka
                EXEC CDN.AktualizujTraVATTraNag @TrN_TrNId
              END
          CLOSE N
        DEALLOCATE N
        END  -- END dla naliczania kosztu dla Metoda_P = 4
        -- Update wartosci naglowka
        IF @InsDel = 1
          BEGIN
            -- obliczenie wartości naglowka na podstawie tabeli TwrIlosci dla kazdego towaru oddzielnie
            SET @TrN_RazemNetto_N = 0
             SELECT  @TrN_RazemNetto_N = SUM(ISNULL(B.TwI_Wartosc,0))
               FROM  CDN.Towary A
               LEFT OUTER JOIN CDN.TwrIlosci B ON  A.Twr_TwrID = B.TwI_TwrID
                                               AND B.TwI_MagId IS NULL AND
                                                   B.TwI_Data = ( SELECT TOP 1 C.TwI_Data
                                                                    FROM CDN.TwrIlosci C
                                                                    WHERE C.TwI_TwrId = A.Twr_TwrId
                                                                      AND C.TwI_MagId IS NULL
                                                                      AND C.TwI_Data <= @Koniec
                                                                    ORDER BY C.TwI_Data DESC
                                                                )
            -- nowe wartosci dla naglowka
            SET @TrN_TrNId_N = ( SELECT MAX(TrN_TrNId) FROM cdn.TraNag WHERE TrN_Rodzaj = 310005 )
            UPDATE cdn.TraNag SET
              TrN_RazemNetto     = @TrN_RazemNetto_N,
              TrN_RazemBrutto    = @TrN_RazemNetto_N,
              TrN_RazemNettoWal  = @TrN_RazemNetto_N,
              TrN_RazemBruttoWal = @TrN_RazemNetto_N
            WHERE TrN_TrNId = @TrN_TrNId_N
          END -- End dla update naglowka
      KOMUNIKAT:
      IF @Komunikat<>''
        BEGIN
          RAISERROR( @Komunikat, 16, 1)
          ROLLBACK Transaction
        END
    END -- koniec operacji dla InsDel
    IF @@Trancount <> 0 COMMIT Transaction
    SET NOCOUNT OFF
    -- dla potrzeb wywolania funkcji z poziomu programu procedura musi zwrócić cokolwiek, np. 0
    SELECT 0
