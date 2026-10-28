CREATE  PROCEDURE CDN.jdp_Oferta_GenerujHaMag
  @OfD_OfDId        INT,            -- Id zapisywanej oferty
  @TrN_TypNB        TINYINT,        -- Typ dokumentu netto/brutto
  @TrN_Rodzaj       INT,            -- TrN_Rodzaj dokumentu wynikowego
  @TrN_PodId        INT,            -- Id podmiotu ( tylko kontrahenci, tj. TrN_PodmiotTyp = 1 )
  @TrN_Waluta       NVARCHAR(3),     -- symbol waluty dokumnetu
  @TrN_KursL        DECIMAL(15,4),  -- licznik kursu waluty
  @TrN_KursM        DECIMAL(5,0),   -- mianownik kursu waluty
  @TrN_MagZrdId     INT,            -- Id magazynu na którym ma się znaleźć dokument
  @TrN_OpeZalId     INT,            -- Id operatora dokonującego zapisu dokumentu
  @TrN_StaZalId     INT,            -- Id stanowiska, na któwym jest wykonywany zapis dokumentu
  @ServerCfgString  NVARCHAR(512),   -- np. 'Z-GAJEWSKI'
  @BazaCfgString    NVARCHAR(512),   -- np. 'CDN_Konfiguracja65'
  @TrN_Opis         NVARCHAR(512),   -- opis w nagłówku
  @TwrId            TEXT,           -- id towarów rozdzielone przecinkami
  @TwrIlosc         TEXT,           -- ilosci towarow rozdzielone przecinkami
  @TwrJm            TEXT,           -- jednostki miar towarow rozdzielone przecinkami
  @CenaWWD          TEXT            -- ceny walutowe
AS
SET NOCOUNT ON
BEGIN TRANSACTION
  DECLARE
    @DataChr             NVARCHAR(10),  -- Data do procedruy InicjujTraElem
    @TrN_PlatElemWalSys  INT,
    @TrN_TrSTyp          INT,
  -- zmiennych typu OUTPUT dla procedury jdp_DodajTraNag
    @TrN_TrNId_Doc    INT      ,
    @TrN_DataDok_Doc  DATETIME ,
    @TrN_DataWys_Doc  DATETIME ,
    @TrN_DataOpe_Doc  DATETIME
  -- parametry dla nagłówka
  SET @DataChr = CONVERT(NVARCHAR(10), GETDATE(), 120)
  SELECT
    @TrN_DataDok_Doc = CONVERT(DATETIME , @DataChr, 120),
    @TrN_DataWys_Doc = CONVERT(DATETIME , @DataChr, 120),
    @TrN_DataOpe_Doc = CONVERT(DATETIME , @DataChr, 120)
  SELECT @TrN_PlatElemWalSys = CONVERT(INT, ISNULL(SUBSTRING(MAX(Fir_Wartosc),1,1),1)) FROM cdn.Firma WHERE Fir_Numer = 1578
  IF @TrN_Rodzaj = 320000
    BEGIN
      SELECT @TrN_TrSTyp = CONVERT(INT, ISNULL(SUBSTRING(MAX(Fir_Wartosc),1,1),0)) FROM cdn.Firma WHERE Fir_Numer = 1580
      IF @TrN_TrSTyp = 2 SET @TrN_TrSTyp = 0
    END
  -- sprawdzenie, czy ma być update, czy insert Pro-Formy (istnieje lub nie)
  SELECT @TrN_TrNId_Doc = ISNULL(MAX(OfD_TrNId),0) FROM CDN.OfertyDok WHERE OfD_OfDID = @OfD_OfDId
  -- jeśli nie ma dokumentu wynikowego, to go tworzymy
  IF @TrN_TrNId_Doc = 0
    BEGIN
      -- nowe wywolanie od wersji 8.5
      EXEC CDN.DodajTraNag
        NULL,                  -- INT,           -- TrN_TrNId nagłówka do dodania lub do skopiowania (może być NULL, jeśli @TrN_Rodzaj_Doc IS NOT NULL AND @TrN_MagZrdId_Doc IS NOT NULL)
        @TrN_Rodzaj,           -- INT,           -- TrN_Rodzaj dokumentu docelowego (może być null, jeśli @TrN_TrNId_Zrd IS NOT NULL )
        @TrN_MagZrdId,         -- INT,           -- TrN_MagZrdId dokumentu docelowego (może być null, jeśli @TrN_TrNId_Zrd IS NOT NULL )
        @TrN_DataDok_Doc,      -- DATETIME,      --
        @TrN_DataWys_Doc,      -- DATETIME,      --
        @TrN_DataOpe_Doc,      -- DATETIME,      --
        @ServerCfgString,      -- NVARCHAR(250),  -- nazwa serwera z bazą konfiguracyjną
        @BazaCfgString,        -- NVARCHAR(250),  -- nazwa bazy konfiguracyjnej
        @TrN_OpeZalId,         -- INT,           -- Opertor zalogowany do programu, który wykonuje operację przekształcenia
        @TrN_StaZalId,         -- INT,           -- Sanowisko, z którego jest wykonywana operacja przekształcenia
        @DataChr,              -- NVARCHAR(100),  -- Data Today z programu (może być inna niż z serwera)
        0,                     -- INT,           -- Kontekst wywołania: 0 - WZ/PZ/WKA/PKA z formularza, 1 - WZ/PZ/WKA/PKA z listy, 2 - WKA/PKA jako nowy dokument z listy FA/PA/FZ
        '',
        @TrN_TrNId_Doc OUTPUT  -- zwracany  TrN_TrNId dokumentu docelowego
      -- rejestrujemy dokument w ofertowaniu
      UPDATE cdn.OfertyDok SET
         OfD_TrNId = @TrN_TrNId_Doc,
         OfD_KntId = @TrN_PodId
      WHERE OfD_OfDID = @OfD_OfDId
    END
  -- Update nagłowka
  UPDATE CDN.TraNag SET
    TrN_DataDok        = CONVERT(DATETIME, @DataChr, 120),
    TrN_DataWys        = CONVERT(DATETIME, @DataChr, 120),
    TrN_DataOpe        = CONVERT(DATETIME, @DataChr, 120),
    TrN_PodmiotTyp     = 1,
    TrN_PodID          = Knt_KntId,
    TrN_PodNazwa1      = Knt_Nazwa1,
    TrN_PodNazwa2      = Knt_Nazwa2,
    TrN_PodKraj        = Knt_Kraj,
    TrN_PodWojewodztwo = Knt_Wojewodztwo,
    TrN_PodPowiat      = Knt_Powiat,
    TrN_PodGmina       = Knt_Gmina,
    TrN_PodUlica       = Knt_Ulica,
    TrN_PodNrDomu      = Knt_NrDomu,
    TrN_PodNrLokalu    = Knt_NrLokalu,
    TrN_PodMiasto      = Knt_Miasto,
    TrN_PodKodPocztowy = Knt_KodPocztowy,
    TrN_PodPoczta      = Knt_Poczta,
    TrN_PodAdres2      = Knt_Adres2,
    TrN_PodNipKraj     = Knt_NipKraj,
    TrN_PodNipE        = Knt_Nip,
    TrN_Finalny        = Knt_Finalny,
    TrN_Export         = Knt_Export,
    TrN_OdbiorcaTyp    = 1,
    TrN_OdbID          = Knt_KntId,
    TrN_OdbNazwa1      = Knt_Nazwa1,
    TrN_OdbNazwa2      = Knt_Nazwa2,
    TrN_OdbKraj        = Knt_Kraj,
    TrN_OdbWojewodztwo = Knt_Wojewodztwo,
    TrN_OdbPowiat      = Knt_Powiat,
    TrN_OdbGmina       = Knt_Gmina,
    TrN_OdbUlica       = Knt_Ulica,
    TrN_OdbNrDomu      = Knt_NrDomu,
    TrN_OdbNrLokalu    = Knt_NrLokalu,
    TrN_OdbMiasto      = Knt_Miasto,
    TrN_OdbKodPocztowy = Knt_KodPocztowy,
    TrN_OdbPoczta      = Knt_Poczta,
    TrN_OdbAdres2      = Knt_Adres2,
    TrN_OdbNipKraj     = Knt_NipKraj,
    TrN_OdbNipE        = Knt_Nip,
    TrN_FplId          = Knt_FplId,
    TrN_Termin         = CASE WHEN Knt_TerminPlat = 1 THEN DATEADD(d,Knt_Termin, @TrN_DataWys_Doc ) ELSE DATEADD(d,Fpl_Termin, @TrN_DataWys_Doc ) END,
    TrN_Opis           = @TrN_Opis,
    TrN_TS_Mod         = GETDATE(),
    TrN_Waluta         = @TrN_Waluta,
    TrN_KursL          = @TrN_KursL,
    TrN_KursM          = @TrN_KursM,
    TrN_PlatElemWalSys = @TrN_PlatElemWalSys,
    TrN_TrSTyp         = @TrN_TrSTyp,
    TrN_KatId          = Knt_KatId,
    TrN_Kategoria      = ISNULL(Kat_Opis,''),
    TrN_TypNB          = @TrN_TypNB
   FROM cdn.TraNag
    JOIN cdn.Kontrahenci ON @TrN_PodId = Knt_KntId
    LEFT OUTER JOIN cdn.FormyPlatnosci ON Knt_FplId = Fpl_FplId
    LEFT OUTER JOIN cdn.Kategorie ON Knt_KatId = Kat_KatId
  WHERE TrN_TrNID = @TrN_TrNId_Doc
  INSERT INTO CDN.DokAtrybuty
        (
        [DAt_DeAId],
        [DAt_Kod],
        [DAt_WartoscTxt],
        [DAt_TrNId]
         )
      SELECT
        [KnA_DeAId],
        [DeA_Kod],
        [KnA_Wartosctxt],
        @TrN_TrNId_Doc
      FROM Cdn.KntAtrybuty
      JOIN Cdn.DefAtrybuty ON KnA_DeAID = DeA_DeAID
      WHERE KnA_CzyPrzenosic = 1 AND KnA_PodmiotID = @TrN_PodId AND KnA_PodmiotTyp = 1
      ORDER BY DeA_Kod desc
  -- kasujemy stare i tworzymy nowe elementy
  DELETE FROM cdn.TraElem WHERE TrE_TrNId = @TrN_TrNId_Doc
    EXEC CDN.InicjujTraElem
      @TwrId,               -- id towarów rozdzielone przecinkami
      @TwrIlosc,            -- ilosci towarow rozdzielone przecinkami
      @TwrJm,               -- jednostki miar towarow rozdzielone przecinkami
      @CenaWWD,             -- ceny walutowe rozdzielone przecinkami
      '0',
      1,                    -- typ podmiotu zawsze 1 (kontrahent)
      @TrN_PodId,           -- Id kontrahenta
      @TrN_Waluta,          -- waluta nagłówka
      @TrN_KursL,           -- licznik kursu waluty nagłówka
      @TrN_KursM,           -- mianownik kursu waluty nagłówka
      1,                    -- magazyn na którym ma zaistnieć dokument
      @TrN_Rodzaj,          -- rodzaj dokuemntu
      @TrN_TypNB,           -- sposób liczniea VAT-u (od netto/od brutto)
      @DataChr,             -- DataDok dla elementów
      @DataChr,             -- DataOpe dla elementów
      @DataChr,             -- DataOpe dla elementów
      null,                 -- numer ceny wybrany na liście zasobów - jesli NULL, to procedura musi go zbudowac na podstawie ceny domyślnej kontrahenta i towaru
      @ServerCfgString,     -- np. 'Z-GAJEWSKI'
      @BazaCfgString,       -- np. 'CDN_Konfiguracja65'
      0,                    -- Lp z ostatniego elementu dokumentu - inicjowane elementy będą miały kolejne Lp
      '',                   -- sortowanie towarów wg kolejności na dokumencie
      @TrN_TrNId_Doc,       -- liczenie elementów z dodawaniem do TraElem
      @TrN_PlatElemWalSys,  -- czy ma byc liczone od zl
      0,                    -- czy liczyc vat dla dok wal
      0,                    -- czy faktura VAT marża
      0,                    -- @Opakowania - 0 = zwykłe towary
      1                     -- czy elementy do bazy mają zostać dodane.
  -- update tabelki VAT w zależności od:
  --   - typu dokumentu netto/brutto
  --   - rodzaju liczenia płatności (od wartości walutowej, od wartości PLN )
  EXEC cdn.AktualizujTraVatTraNag @TrN_TrNId_Doc
COMMIT TRANSACTION
IF @@TRANCOUNT > 0
  WHILE 1=1
  BEGIN
    IF @@TRANCOUNT = 0 BREAK
    ROLLBACK TRAN
  END
SET NOCOUNT OFF
