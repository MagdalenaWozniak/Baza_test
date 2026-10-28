CREATE PROCEDURE [CDN].[AktualizujWZKK_OLD]
  @TrS_TrEId    INT
AS
SET NOCOUNT ON
  DECLARE
    -- dokument stary
    @TrN_TrNId          INT,
    @TrE_Lp             INT,
    @TrE_TwrId          INT,
    @TrE_DataOpe        DATETIME,
    -- dokument nowy
    @TrN_TrNId_N         INT,
    @TrN_ZwrId_N         INT,
    @TrN_Rodzaj_N        INT,
    @TrN_MagZrdId_N      INT,
    @TrN_NumerNr_N       INT,
    @TrN_TypDokumentu_N  INT,
    @DDfId_N             INT,
    @TrN_NumerString_N   VARCHAR(100),
    @TrN_OpeZalID_N      INT,
    @TrN_StaZalID_N      INT,
    @TrN_DataDok_N       DATETIME,
    @TrN_Opis_N          VARCHAR(255),
    @TrE_TrEId_N         INT,
    -- zmienne dla kursorow po subelementach
    @TrS_MagId_K         INT,
    @TrS_Rodzaj_K        INT,
    @TrS_TrSId_N         INT,
    @TrS_ZwrId_N         INT,
    @TrS_TwrId_N         INT,
    @TrS_Metoda_N        INT,
    -- baza konfiguracyjna
    @KnfSrv              SYSNAME,
    @KnfDb               SYSNAME,
    -- do wyliczenia serii dla operatora
    @SeriaOperatora       VARCHAR(5),
    @RejestrOperatora     VARCHAR(20),
    -- zmienne dla komunikatow
    @Kom_Twr_Kod         VARCHAR(40),
    @Kom_Twr_Nazwa       VARCHAR(255),
    @Kom_TrN_NumerPelny  VARCHAR(31),
    @Kom_Data            VARCHAR(10),
    @Komunikat           VARCHAR(250)
  -- STOP jesli element nie ma subelementow korekcyjnych
  IF NOT EXISTS ( SELECT * FROM cdn.TraSElem WHERE TrS_TrEId = @TrS_TrEId AND ( TrS_Rodzaj = 306071 OR TrS_Rodzaj = 306072 OR TrS_Rodzaj = 306061 ) )
    RETURN
  -- Jeśli OFF-Line, to nie można zapisać dokumentu, jeśli występują jakiekolwiek WZKK (XL nie obsługuje takich sytuacji)
  IF (SELECT ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1470) = 4
    IF EXISTS ( SELECT * FROM cdn.TraSElem WHERE TrS_TrEId = @TrS_TrEId AND TrS_Rodzaj IN ( 306071, 306061 ) )
      BEGIN
        SELECT @Kom_Twr_Kod = Twr_Kod,@Kom_Twr_Nazwa = Twr_Nazwa FROM cdn.Towary JOIN cdn.TraElem ON TrE_TwrId = Twr_TwrId WHERE TrE_TrEId = @TrS_TrEId
        SET @Komunikat = '##OPT34586##%%s1%%=' + REPLACE(@Kom_Twr_Kod,'%','%%')
    + '%%s2%%='+REPLACE(substring(REPLACE(@Kom_Twr_Nazwa,'%','%%'),0,30),Char(13) + Char(10),' ')
    + '##'
    --SET @Komunikat = 'Zapis niemożliwy!  Dla towaru ' + @Kom_Twr_Kod +' ['+REPLACE(substring(@Kom_Twr_Nazwa,0,30),Char(13) + Char(10),' ') + '] korygowane dostawy zostały wykorzystane !'
        GOTO KOMUNIKAT
      END
  -- TrN_TrNId pierwotnego dokumentu korygującego
  SET @TrN_TrNId  = ( SELECT TrN_TrNId  FROM cdn.TraNag JOIN cdn.TraElem ON TrN_TrNId = TrE_TrNId WHERE TrE_TrEId = @TrS_TrEId )
  SELECT
    @TrN_OpeZalID_N = TrN_OpeZalID,
    @TrN_StaZalID_N = TrN_StaZalID,
    @TrN_DataDok_N  = TrN_DataDok
  FROM cdn.TraNag WHERE TrN_TrNId = @TrN_TrNId
  -- Kursor po magazynach w ramach subelementów korekcyjnych - zakladanie naglowkow jesli nie istnieja
  DECLARE TrS_Magazyny CURSOR LOCAL FAST_FORWARD FOR
    SELECT TrS_MagId, TrS_Rodzaj FROM cdn.TraSElem WHERE TrS_TrEId = @TrS_TrEId AND ( TrS_Rodzaj = 306071 OR TrS_Rodzaj = 306072 OR TrS_Rodzaj = 306061 ) GROUP BY TrS_MagId, TrS_Rodzaj
      OPEN TrS_Magazyny
      WHILE 1=1
        BEGIN
          FETCH NEXT FROM TrS_Magazyny INTO @TrS_MagId_K, @TrS_Rodzaj_K
            IF @@FETCH_STATUS <> 0 BREAK
            -- Generowania naglowkow dla magazynów, ktore wystepuja na subelementach korekcyjnych
            -- sprawdzenie, czy istnieje juz nowy naglowek z odpowiednim TrN_Rodzaj na danym magazynie nie anulowany, połączony z zapisywaną korektą
            SET @TrN_TrNId_N  = ( SELECT MAX(TrN_TrNId) FROM cdn.TraNag WHERE TrN_MagZrdId = @TrS_MagId_K AND TrN_Rodzaj = @TrS_Rodzaj_K AND TrN_ZwrId = @TrN_TrNId AND TrN_Bufor = 0 )
            -- jeśli istnieje, to wyliczamy nowy rodzaj i ZwrId
            IF @TrN_TrNId_N IS NOT NULL
              SELECT
                @TrN_Rodzaj_N  = TrN_Rodzaj,
                @TrN_ZwrId_N   = TrN_ZwrId
              FROM cdn.TraNag
              WHERE TrN_TrNId  = @TrN_TrNId_N
            -- jeśli NIE istnieje, to zalozenie naglowka jesli nie istnieje na danym magazynie dla danego dokumentu pierwotnego
            ELSE
              BEGIN
                -- Skladniki naglowka
                SELECT
                  @DDfId_N            = CDN.DomyslnaDefinicja(@TrS_Rodzaj_K),
                  @TrN_MagZrdId_N     = @TrS_MagId_K,
                  @TrN_TypDokumentu_N = 306,
                  @TrN_Rodzaj_N       = @TrS_Rodzaj_K,
                  @TrN_Opis_N         = ' Korekta kosztu '
                SELECT @KnfSrv = SYS_Wartosc FROM CDN.SystemCDN WHERE SYS_ID=1001
                SELECT @KnfDb  = SYS_Wartosc FROM CDN.SystemCDN WHERE SYS_ID=1002
                -- seria operatora
                IF ( SELECT TOP 1 DDf_SeriaOperatora FROM cdn.DokDefinicje WHERE DDF_DDFId = @DDFId_N ) = 1
                EXEC CDN.SeriaOperatora @KnfSrv, @KnfDb, @TrN_OpeZalId_N, @SeriaOperatora OUTPUT, @RejestrOperatora OUTPUT
                SET @SeriaOperatora = ISNULL(@SeriaOperatora, '')
                -- NumerString dodawanego nagłówka
                SET @TrN_NumerString_N = CDN.NumerString (
                                                               @TrN_Rodzaj_N      , -- Rodzaj dokumentu
                                                               @TrN_OpeZalId_N    , -- Operator inicjujący dokument do numeracji
                                                               @TrN_StaZalId_N    , -- Stanowisko, na którym zainicjowano dokument
                                                               @TrN_MagZrdId_N    , -- Id magazynu do numeracji
                                                               @TrN_DataDok_N     , -- Data dokumentu
                                                               @SeriaOperatora    , -- Seria domyślna operatora
        default,
        default,
        default
                                                             )
                SET @Komunikat = CDN.SprawdzNumerString ( @DDfId_N, @TrN_NumerString_N )
                IF @Komunikat <> ''
                  GOTO KOMUNIKAT
                -- obliczenie kolejnego numeru dokumentu i insert naglowka
                SET @TrN_NumerNr_N = 1 + ( SELECT ISNULL(MAX(TrN_NumerNr),0) AS MaxNumerNr FROM CDN.TraNag WHERE TrN_NumerString = @TrN_NumerString_N )
                INSERT INTO cdn.TraNag (  TrN_DDfId,  TrN_TypDokumentu,    TrN_ZwrId,TrN_ZwrIdWZKK, TrN_FaId, TrN_NumerNr,          TrN_NumerString,       TrN_Bufor, TrN_VaNId, TrN_DataDok, TrN_DataWys, TrN_DataOpe, TrN_NumerObcy, TrN_Korekta, TrN_Fiskalna, TrN_Detal,  TrN_Rodzaj,   TrN_PodmiotTyp, TrN_PodID, TrN_PodNazwa1, TrN_PodNazwa2, TrN_PodKraj, TrN_PodWojewodztwo, TrN_PodPowiat, TrN_PodGmina, TrN_PodUlica, TrN_PodNrDomu, TrN_PodNrLokalu, TrN_PodMiasto, TrN_PodKodPocztowy, TrN_PodPoczta, TrN_PodAdres2, TrN_PodNipE, TrN_Finalny, TrN_Export, TrN_NotaKorPrzed, TrN_NotaKorPo, TrN_TrSTyp,
                                          TrN_OdbiorcaTyp, TrN_OdbID, TrN_OdbNazwa1, TrN_OdbNazwa2, TrN_OdbKraj, TrN_OdbWojewodztwo, TrN_OdbPowiat, TrN_OdbGmina, TrN_OdbUlica, TrN_OdbNrDomu, TrN_OdbNrLokalu, TrN_OdbMiasto, TrN_OdbKodPocztowy, TrN_OdbPoczta, TrN_OdbAdres2, TrN_OdbNipE, TrN_KatID, TrN_Kategoria, TrN_FPlId, TrN_Termin, TrN_RazemNetto, TrN_RazemVAT, TrN_RazemBrutto, TrN_BlokadaPlatnosci,  TrN_MagZrdId,   TrN_MagDocId, TrN_TypNB, TrN_Rabat, TrN_Odebral,   TrN_Opis,   TrN_OpeZalID, TrN_OpeZalKod, TrN_OpeZalNazwisko, TrN_TS_Zal, TrN_OpeModID, TrN_OpeModKod, TrN_OpeModNazwisko, TrN_TS_Mod, TrN_Waluta, TrN_KursNumer, TrN_KursL, TrN_KursM, TrN_RazemNettoWal, TrN_PodNazwa3, TrN_OdbNazwa3, TrN_Centrala, TrN_PodmiotGLN, TrN_OdbiorcaGLN, TrN_NumerPelnyPrw, TrN_PlatElemWalSys, TrN_RazemBruttoWal, TrN_RazemVATWal, TrN_PodNipKraj, TrN_OdbNipKraj, TrN_KodTransakcji, TrN_KodKraju, TrN_Anulowany
            , TrN_PlatKaucje, TrN_TaxFreePotwierdzony ,TrN_VatDlaDokWal, TrN_DataKur,TrN_ZakID,TrN_PCId,TrN_PCJSID)
                SELECT                  @DDfId_N, @TrN_TypDokumentu_N, @TrN_TrNId, @TrN_TrNId, TrN_FaId, @TrN_NumerNr_N, LEFT(@TrN_NumerString_N,31), TrN_Bufor, TrN_VaNId, TrN_DataDok, TrN_DataWys, TrN_DataOpe, TrN_NumerObcy, TrN_Korekta, TrN_Fiskalna, TrN_Detal, @TrN_Rodzaj_N, TrN_PodmiotTyp, TrN_PodID, TrN_PodNazwa1, TrN_PodNazwa2, TrN_PodKraj, TrN_PodWojewodztwo, TrN_PodPowiat, TrN_PodGmina, TrN_PodUlica, TrN_PodNrDomu, TrN_PodNrLokalu, TrN_PodMiasto, TrN_PodKodPocztowy, TrN_PodPoczta, TrN_PodAdres2, TrN_PodNipE, TrN_Finalny, TrN_Export,               '',            '', TrN_TrSTyp,
                                        TrN_OdbiorcaTyp, TrN_OdbID, TrN_OdbNazwa1, TrN_OdbNazwa2, TrN_OdbKraj, TrN_OdbWojewodztwo, TrN_OdbPowiat, TrN_OdbGmina, TrN_OdbUlica, TrN_OdbNrDomu, TrN_OdbNrLokalu, TrN_OdbMiasto, TrN_OdbKodPocztowy, TrN_OdbPoczta, TrN_OdbAdres2, TrN_OdbNipE, TrN_KatID, TrN_Kategoria, TrN_FPlId, TrN_Termin,              0,            0,               0, TrN_BlokadaPlatnosci, @TrN_MagZrdId_N, TrN_MagDocId, TrN_TypNB, TrN_Rabat, TrN_Odebral, @TrN_Opis_N,  TrN_OpeZalID, TrN_OpeZalKod, TrN_OpeZalNazwisko, TrN_TS_Zal, TrN_OpeModID, TrN_OpeModKod, TrN_OpeModNazwisko, TrN_TS_Mod,         '',             0,         1,         1,                 0, TrN_PodNazwa3, TrN_OdbNazwa3,            0, TrN_PodmiotGLN, TrN_OdbiorcaGLN,                '',                  0,                  0,               0, TrN_PodNipKraj, TrN_OdbNipKraj,                '',            '',            0,
          0,                       0 ,TrN_VatDlaDokWal, TrN_DataKur,TrN_ZakID ,TrN_PCId,TrN_PCJSID
          FROM cdn.TraNag WHERE TrN_TrNId = @TrN_TrNId
                SELECT @TrN_TrNId_N = ISNULL(MAX( TrN_TrNId ),1) FROM CDN.TraNag
    declare @NumerPelny  NVarchar(30)
    select @NumerPelny = TrN_numerPelny from cdn.tranag where trn_trnid = @TrN_TrNId_N
    exec [CDN].[RejestrOperacjiDodaj] @TrN_TypDokumentu_N,0, @TrN_TrNId_N, @NumerPelny, 1, ''
    exec [CDN].[RejestrOperacjiDodaj] @TrN_TypDokumentu_N,0, @TrN_TrNId_N, @NumerPelny, 103, ''
              END
            -- kopiowanie elementu
            SELECT TOP 1 @TrE_Lp = TrE_Lp, @TrE_TwrId = TrE_TwrId, @TrE_DataOpe = TrE_DataOpe FROM cdn.TraElem WHERE TrE_TrEId = @TrS_TrEId
            IF NOT EXISTS ( SELECT * FROM cdn.TraElem WHERE TrE_TrNId = @TrN_TrNId_N AND TrE_TwrId = @TrE_TwrId AND TrE_Lp = @TrE_Lp )
   OR EXISTS (select * from cdn.TraElem WHERE TrE_TrNId = @TrN_TrNId_N and tre_treid = @TrS_TrEId) -- jak wzkk robi się do tej pozycji ktorą dodajemy na tym wzkk to lepiej w oddzielnej pozycji
              BEGIN
                INSERT INTO CDN.TraElem  (  TrE_TrNId,    TrE_ZwrId,  TrE_Lp, TrE_TypDokumentu, TrE_Aktywny, TrE_DataDok, TrE_DataOpe, TrE_PodmiotTyp, TrE_PodID, TrE_KatId, TrE_TwrId, TrE_TwrNazwa, TrE_TwrOpis, TrE_TwrSWW, TrE_Stawka, TrE_Flaga, TrE_Zrodlowa, TrE_TwCNumer, TrE_TypNB, TrE_Cena0, TrE_Rabat, TrE_CenaW, TrE_Waluta, TrE_KursNumer, TrE_KursL, TrE_KursM, TrE_CenaT, TrE_Ilosc, TrE_Jm, TrE_JmCalkowite, TrE_JmPrzelicznikL, TrE_JmPrzelicznikM, TrE_IloscJM, TrE_WartoscNetto, TrE_WartoscBrutto, TrE_JmZ, TrE_TwrEAN, TrE_TwrNumerKat, TrE_TwrKod, TrE_LpPow, TrE_Cena0WD, TrE_CenaWWD, TrE_WartoscNettoWal, TrE_WartoscBruttoWal, TrE_Prog, TrE_UpustTyp, TrE_Upust, TrE_UpustKnt, TrE_UpustKntTyp, TrE_KosztUslugi, TrE_WartoscZakupuWylicz,
                                            TrE_Kaucja, TrE_IloscKW, TrE_IloscJMKW, TrE_Atr1_DeAId, TrE_Atr1_Kod, TrE_Atr1_Wartosc, TrE_Atr2_DeAId, TrE_Atr2_Kod, TrE_Atr2_Wartosc, TrE_Atr3_DeAId, TrE_Atr3_Kod, TrE_Atr3_Wartosc, TrE_Atr4_DeAId, TrE_Atr4_Kod, TrE_Atr4_Wartosc, TrE_Atr5_DeAId, TrE_Atr5_Kod, TrE_Atr5_Wartosc, TrE_WyborDostaw, TrE_MagId,TrE_TwrTyp ,TrE_TwrKodDostawcy,Tre_CenaZCzteremaMiejscami)
                  SELECT                   @TrN_TrNId_N, @TrS_TrEId, @TrE_Lp,              306, TrE_Aktywny, TrE_DataDok, TrE_DataOpe, TrE_PodmiotTyp, TrE_PodID, TrE_KatId, TrE_TwrId, TrE_TwrNazwa, TrE_TwrOpis, TrE_TwrSWW, TrE_Stawka, TrE_Flaga, TrE_Zrodlowa, TrE_TwCNumer, TrE_TypNB,         0,         0,         0, TrE_Waluta, TrE_KursNumer, TrE_KursL, TrE_KursM,         0,         0, TrE_Jm, TrE_JmCalkowite, 1, 1,           0,                0,                 0, '', Twr_EAN,    Twr_NumerKat,    Twr_Kod,    0        ,           0,           0,                   0,                    0,        0,            0,         0,            0,               0,               0,                       0,
                                                     0,           0,             0,           NULL,           '',               '',           NULL,           '',               '',           NULL,           '',               '',           NULL,           '',               '',           NULL,           '',               '',               0, TrE_MagId,Twr_Typ ,Twr_KodDostawcy,Tre_CenaZCzteremaMiejscami
                  FROM CDN.TraElem JOIN cdn.Towary ON TrE_TwrId = Twr_TwrId WHERE TrE_TrEId = @TrS_TrEId
                SELECT @TrE_TrEId_N = ISNULL(MAX( TrE_TrEId ),1) FROM cdn.TraElem
              END
            ELSE
              SELECT @TrE_TrEId_N = TrE_TrEId FROM cdn.TraElem WHERE TrE_TrNId = @TrN_TrNId_N AND TrE_TwrId = @TrE_TwrId AND TrE_Lp = @TrE_Lp
            -- kopiowanie subelementów z elementu dla obrabianego magazynu
            DECLARE TrS_Korekcyjne CURSOR LOCAL FAST_FORWARD FOR
              SELECT TrS_TrSId, TrS_ZwrId, TrS_TwrId, TrS_Metoda
              FROM cdn.TraSElem
              WHERE TrS_TrEId = @TrS_TrEId AND  TrS_Rodzaj IN (306071, 306072, 306061 )  AND TrS_MagId = @TrS_MagId_K
              OPEN TrS_Korekcyjne
                WHILE 1=1
                  BEGIN
                    FETCH NEXT FROM TrS_Korekcyjne INTO @TrS_TrSId_N, @TrS_ZwrId_N, @TrS_TwrId_N, @TrS_Metoda_N
                    IF @@FETCH_STATUS <> 0 BREAK
                      -- kontrola, czy subelement nie jest korektą do dokumentu w buforze
                      -- kod towaru dla komunikatu
                      SELECT @Kom_Twr_Kod = Twr_Kod,@Kom_Twr_Nazwa = Twr_Nazwa FROM cdn.Towary WHERE Twr_TwrId = @TrS_TwrId_N
                      -- FIFO, LIFO
                      IF @TrS_Metoda_N IN ( 1, 2 )
                        BEGIN
                          IF ( SELECT TOP 1 TrN_Bufor FROM cdn.TraNag JOIN cdn.TraElem  ON TrE_TrNId = TrN_TrNId JOIN cdn.TraSElem ON TrS_TrEId = TrE_TrEId WHERE TrS_TrSId = @TrS_ZwrId_N ) = 1
                            BEGIN
                              SELECT TOP 1 @Kom_TrN_NumerPelny = TrN_NumerPelny FROM cdn.TraNag JOIN cdn.TraElem  ON TrE_TrNId = TrN_TrNId JOIN cdn.TraSElem ON TrS_TrEId = TrE_TrEId WHERE TrS_TrSId = @TrS_ZwrId_N
                              SET @Komunikat = '##OPT34587##%%s1%%=' + @Kom_Twr_Kod
                               + '%%s2%%='+REPLACE(substring(REPLACE(@Kom_Twr_Nazwa,'%','%%'),0,30),Char(13) + Char(10),' ')
          + '%%s3%%='+@Kom_TrN_NumerPelny
                               + '##'
                               --SET @Komunikat = 'Zapis niemożliwy!  Dla towaru   ' + @Kom_Twr_Kod +' ['+REPLACE(substring(@Kom_Twr_Nazwa,0,30),Char(13) + Char(10),' ') + ']  elementy korekcyjne dotyczą dokumentu w buforze ( ' + @Kom_TrN_NumerPelny + ' ). '
                              GOTO KOMUNIKAT
                            END
                        END
                      -- AVCO ( dla QUAN nie ma elementów korekcyjnych )
                      ELSE IF @TrS_Metoda_N IN ( 3 )
                        BEGIN
                          IF EXISTS ( SELECT * FROM cdn.TraNag JOIN cdn.TraElem  ON TrE_TrNId = TrN_TrNId WHERE TrE_TwrId = @TrS_TwrId_N AND TrN_Bufor = 1 AND TrN_TypDokumentu <> 308 AND TrN_TypDokumentu <> 309 and TrN_TrSTyp <>3 AND (TrN_MagZrdId = @TrS_MagId_K or TrN_MagDocId = @TrS_MagId_K))
                            BEGIN
                              SELECT TOP 1 @Kom_TrN_NumerPelny = TrN_NumerPelny FROM cdn.TraNag JOIN cdn.TraElem  ON TrE_TrNId = TrN_TrNId WHERE TrE_TwrId = @TrS_TwrId_N AND TrN_Bufor = 1
                              SET @Komunikat = '##OPT34588##%%s1%%=' + @Kom_Twr_Kod
                               + '%%s2%%='+REPLACE(substring(REPLACE(@Kom_Twr_Nazwa,'%','%%'),0,30),Char(13) + Char(10),' ')
                               + '##'
                               --SET @Komunikat = 'Zapis niemożliwy!  Dla towaru   ' + @Kom_Twr_Kod +' ['+REPLACE(substring(@Kom_Twr_Nazwa,0,30),Char(13) + Char(10),' ') + '] występują dokumenty w buforze. '
                              GOTO KOMUNIKAT
                            END
                        END
                      -- kontrola, czy subelement nie jest korektą do subelemntu wystawionego później
                      DECLARE @TrS_TrSId_Prw INT
                      SET @TrS_TrSId_Prw = ( SELECT A.TrS_TrSId FROM cdn.TraSElem A JOIN cdn.TraSElem B ON A.TrS_TrSId = B.TrS_ZwrId AND B.TrS_TrSId = @TrS_TrSId_N )
                      IF ( SELECT TrS_DataOpe FROM cdn.TraSElem WHERE TrS_TrSId = @TrS_TrSId_Prw ) > ( SELECT TrS_DataOpe FROM cdn.TraSElem WHERE TrS_TrSId = @TrS_TrSId_N )
                        BEGIN
                          SELECT TOP 1 @Kom_TrN_NumerPelny = TrN_NumerPelny, @Kom_Data = CONVERT(VARCHAR(10), TrN_DataOpe - 1, 120) FROM cdn.TraNag JOIN cdn.TraElem  ON TrE_TrNId = TrN_TrNId JOIN cdn.TraSElem ON TrS_TrEId = TrE_TrEId WHERE TrS_TrSId = @TrS_TrSId_Prw
                          SET @Komunikat = '##OPT34589##%%s1%%=' + @Kom_Twr_Kod
                          +'%%s2%%='+REPLACE(substring(REPLACE(@Kom_Twr_Nazwa,'%','%%'),0,30),Char(13) + Char(10),' ')
        +'%%s3%%='+@Kom_TrN_NumerPelny
        +'%%s4%%='+@Kom_Data
                          + '##'
                          --SET @Komunikat = 'Zapis niemożliwy!  Dla towaru   ' + @Kom_Twr_Kod +' ['+REPLACE(substring(@Kom_Twr_Nazwa,0,30),Char(13) + Char(10),' ') + ']  subelementy korekcyjne dotyczą dokumentu wystawionego później ( ' + @Kom_TrN_NumerPelny + ' ). Wprowadź dokument z datą większą od ' + @Kom_Data + '.'
                          GOTO KOMUNIKAT
                        END
                      -- Wyswietlenie komunikatu i rollback całej transakcji - nie kontynuujemy dla magazynu NULL
                      IF @Komunikat <> ''
                        BEGIN
                          RAISERROR( @Komunikat, 16, 1)
                          ROLLBACK TRAN
                          SET NOCOUNT OFF
                          RETURN
                        END
                      -- skopiowanie subelementu jesli nie ma bledu
                      UPDATE cdn.TraSElem SET TrS_TrEId = @TrE_TrEId_N WHERE TrS_TrSId = @TrS_TrSId_N
                      -- sprawdzenie towaru ze starego elementu
                      SET @Komunikat = CDN.TwrZasobyErr ( @TrS_TrEId, @TrE_TwrId, @Kom_Twr_Kod, @Kom_Twr_Nazwa, @TrE_DataOpe )
                      IF @Komunikat <> '' GOTO KOMUNIKAT
                      -- sprawdzenie towaru z nowego elementu
                      SET @Komunikat = CDN.TwrZasobyErr ( @TrE_TrEId_N, @TrE_TwrId, @Kom_Twr_Kod, @Kom_Twr_Nazwa, @TrE_DataOpe )
                      IF @Komunikat <> '' GOTO KOMUNIKAT
                  END
              CLOSE TrS_Korekcyjne
            DEALLOCATE TrS_Korekcyjne
            -- aktualizacja tabelki VAT
            EXEC CDN.AktualizujTraVATTraNag @TrN_TrNId_N
        END
      CLOSE TrS_Magazyny
  DEALLOCATE TrS_Magazyny
  -- stop, jeśli dokument WZKK jest zaksięgowany
  IF ( SELECT TrN_DekId FROM cdn.TraNag WHERE TrN_TrNId = @TrN_TrNId_N ) IS NOT NULL
    BEGIN
      SET @Komunikat = '##OPT34590##%%NumerPelny%%=' + (SELECT TrN_NumerPelny FROM cdn.TraNag WHERE TrN_TrNId = @TrN_TrNId_N)+ '##'--SET @Komunikat = 'Zapis niemożliwy!  Modyfikowany dokuemnt WZKK ( ' + ( SELECT TrN_NumerPelny FROM cdn.TraNag WHERE TrN_TrNId = @TrN_TrNId_N  ) + ' ) jest już zaksięgowany. '
      GOTO KOMUNIKAT
    END
  -- obsluga błędu
  KOMUNIKAT:
  IF @Komunikat <> ''
  BEGIN
    RAISERROR( @Komunikat, 16, 1 )
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
SET NOCOUNT OFF
