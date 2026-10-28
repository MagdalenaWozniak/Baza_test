-- Płatności do nowo tworzonego dokumentu
CREATE PROCEDURE CDN.DodajBnkZdarzenia
  @TrN_TrNId_Doc    INT,
  @ServerCfgString  NVARCHAR(250), -- nazwa serwera z bazą konfiguracyjną
  @BazaCfgString    NVARCHAR(250), -- nazwa bazy konfiguracyjnej
  @Kontekst         INT
AS
SET NOCOUNT ON
  DECLARE
    @Waluta               CHAR(3),
    @OpeId                INT,
    @BRa_BRaId            INT,
    @SeriaOperatora       NVARCHAR(5),
    @RejestrOperatora     NVARCHAR(20),
    @BZd_DokumentTyp      INT,
    @BZd_DokumentId       INT,
    @TrN_BlokadaPlatnosci INT,
    -- komunikat z błędem
    @Komunikat        NVARCHAR(350)
  -- na razie tylko dla nowego 2->WKA, 70->TF
  IF @Kontekst <> 2 AND @Kontekst <> 70
    RETURN
  -- szukanie rejestru dla zdarzenia
  -- dane z dokumentu dla TraNag
  SELECT
    @Waluta                =  TrN_Waluta,
    @OpeId                 =  TrN_OpeModId,
    @TrN_BlokadaPlatnosci  =  ISNULL(TrN_BlokadaPlatnosci,1)
  FROM cdn.TraNag
  WHERE TrN_TrNId = @TrN_TrNId_Doc
  -- jeśli występuje blokada płatności, to nie robimy zdarzeń
  IF @TrN_BlokadaPlatnosci = 1 AND @Kontekst <> 70
    RETURN
  -- rejestr dla zdarzenia
  SET @BRa_BraId = NULL
  -- jeśli dokument walutowy, to pobieramy rejestr domyślny z FormyPlatnWaluty
  IF ISNULL(@Waluta,'') <> '' AND UPPER(ISNULL(@Waluta,'')) <> 'PLN'
    SELECT @BRa_BraId = FPW_BRaId
      FROM cdn.FormyPlatnWaluty
        JOIN cdn.BnkRachunki ON FPW_BRaId = BRa_BraId
      WHERE BRa_Waluta = @Waluta
  -- jeśli nie istnieje rejestr walutowy, to domyślny dla formy płatności dla waluty systemowej z FormyPlatnosci
  IF @BRa_BraId IS NULL
   SELECT @BRa_BraId = FPl_BRaId
      FROM cdn.FormyPlatnosci
        JOIN cdn.BnkRachunki ON FPl_BRaId = BRa_BraId
  -- jeśli nie istnieje, to domyślny rejestr dla operatora
  IF @BRa_BraId IS NULL
    BEGIN
      EXEC CDN.SeriaOperatora @ServerCfgString, @BazaCfgString, @OpeId, @SeriaOperatora OUTPUT, @RejestrOperatora OUTPUT
      SET @RejestrOperatora = ISNULL(@SeriaOperatora, '')
      SELECT @BRa_BraId = FPl_BRaId
        FROM cdn.FormyPlatnosci
          JOIN cdn.BnkRachunki ON FPl_BRaId = BRa_BraId
          WHERE @RejestrOperatora = Bra_Akronim
    END
  -- jeśli nie istnieje także rejestr z operatora, to komunikat z błędem i wylot
  IF @BRa_BraId IS NULL
    BEGIN
      SET @Komunikat = '##OPT34462##'--' Zapis niemożliwy ! Nie znaleziono rejestru dla płatności ! '
      GOTO KOMUNIKAT
    END
  -- zmienne do inserta
  DECLARE
    @BZd_DDfID              INT,           -- odrębne, standardowe DDFID z DokDefinicje
    @BZd_NumerPelny         NVARCHAR(30),   -- nie computed
    @BZd_NumerObcy          NVARCHAR(30),   -- obowiązkowy ?
    @BZd_PodmiotTyp         SMALLINT,
    @BZd_PodmiotID          INT,
    @BZd_KatID              INT,           -- kategoria zdarzenia - dziedziczona z podmiotu
    @BZd_FPlId              INT,           -- forma płatności
    @BZd_DataDok            DATETIME,      -- data dokumentu z faktury
    @BZd_DataKur            DATETIME,      -- data kursu z faktury
    @BZd_Termin             DATETIME,      -- termin płatności (na podstawie daty dok i formy płatności )
    @BZd_KwotaSys           DECIMAL(15,2), -- kwota PLN
    @BZd_Kwota              DECIMAL(15,2), -- kwota w walucie (dokumentu)
    @BZd_Waluta             NVARCHAR(3),    -- waluta dokumetnu
    @BZd_KursNumer          INT ,          --
    @BZd_KursL              DECIMAL(15,4),
    @BZd_KursM              DECIMAL(5,0),
    @BZd_Kierunek           SMALLINT,      -- -1 wyjście, 1 wejście
    @BZd_Stan               SMALLINT,      -- 0 (bufor)
    @BZd_Opis               NVARCHAR(254) , -- ''
    @BZd_OpeZalId           INT,
    @BZd_StaZalId           INT,
    @BZd_TS_Zal             DATETIME
  -- ustawienie płatności dla TraNag
  IF @Kontekst <> 70
  BEGIN
   SELECT
     @BZd_DokumentTyp       = 1,
     @BZd_DokumentID        = @TrN_TrNId_Doc,
     @BZd_NumerPelny        = TrN_NumerPelny,
     @BZd_NumerObcy         = TrN_NumerObcy,
     @BZd_PodmiotTyp        = TrN_PodmiotTyp,
     @BZd_PodmiotID         = TrN_PodId,
     @Bzd_DDFId             = TrN_DDfId,
     @BZd_KatID             = CASE WHEN ISNULL(TrN_KatId, 0) = 0 THEN NULL ELSE TrN_KatId END,
     @BZd_FPlId             = TrN_FplId,
     @BZd_DataDok           = TrN_DataDok,
     @BZd_DataKur           = TrN_DataKur,
     @BZd_Termin            = TrN_Termin,
     @BZd_KwotaSys          = TrN_RazemBrutto,
     @BZd_Kwota             = TrN_RazemBruttoWal,
     @BZd_Waluta            = REPLACE(@Waluta, ' ',''),
     @BZd_KursNumer         = TrN_KursNumer,
     @BZd_KursL             = TrN_KursL,
     @BZd_KursM             = TrN_KursM,
     @BZd_Kierunek          = 1,                  -- -1 wyjście, 1 wejście
     @BZd_Stan              = 0,                  -- 0 (bufor)
     @BZd_Opis              = 'Dok.: ' + TrN_NumerPelny +
                                 CASE -- BZd_Opis,
                                   WHEN TrN_TypDokumentu IN (313) THEN ' (Przyjęcie opakowań/kaucji)'
                                   WHEN TrN_TypDokumentu IN (314) THEN ' (Wydanie opakowań/kaucji)'
                                   ELSE ' '
                                 END,
     @BZd_OpeZalId           = TrN_OpeModId,
     @BZd_StaZalId           = TrN_StaModId,
     @BZd_TS_Zal             = TrN_TS_Mod
    FROM cdn.TraNag   WHERE TrN_TrNId = @TrN_TrNId_Doc
  END
  ELSE
  BEGIN
   SELECT
     @BZd_DokumentTyp       = 1,
     @BZd_DokumentID        = @TrN_TrNId_Doc,
     @BZd_NumerPelny        = TrN_NumerPelny,
     @BZd_NumerObcy         = TrN_NumerObcy,
     @BZd_PodmiotTyp        = TrN_PodmiotTyp,
     @BZd_PodmiotID         = TrN_PodId,
     @Bzd_DDFId             = TrN_DDfId,
     @BZd_KatID             = CASE WHEN ISNULL(TrN_KatId, 0) = 0 THEN NULL ELSE TrN_KatId END,
     @BZd_FPlId             = TrN_FplId,
     @BZd_DataDok           = TrN_DataDok,
     @BZd_DataKur           = TrN_DataKur,
     @BZd_Termin            = TrN_Termin,
     @BZd_KwotaSys          = (SELECT SUM(TrV_Vat) FROM Cdn.TraVat WHERE TrV_TrnId = @TrN_TrNId_Doc),
     @BZd_Kwota             = (SELECT SUM(trV_Vat) FROM Cdn.TraVat WHERE TrV_TrnId = @TrN_TrNId_Doc),
     @BZd_Waluta            = REPLACE(@Waluta, ' ',''),
     @BZd_KursNumer         = TrN_KursNumer,
     @BZd_KursL             = TrN_KursL,
     @BZd_KursM             = TrN_KursM,
     @BZd_Kierunek          = -1,                 -- -1 wyjście, 1 wejście
     @BZd_Stan              = 1,                  -- 1 (nie zatwierdzony)
     @BZd_Opis              = 'Dok.: ' + TrN_NumerPelny,
     @BZd_OpeZalId           = TrN_OpeModId,
     @BZd_StaZalId           = TrN_StaModId,
     @BZd_TS_Zal             = TrN_TS_Mod
   FROM cdn.TraNag   WHERE TrN_TrNId = @TrN_TrNId_Doc
  END
  EXEC CDN.DodajBnkZdarzenie
    @BZd_DokumentTyp,        -- SmallInt,
    @BZd_DokumentID,         -- Int,
    @BZd_NumerPelny,         -- NVARCHAR(30),
    @BZd_NumerObcy,          -- NVARCHAR(30),
    @BZd_PodmiotTyp,         -- SmallInt,
    @BZd_PodmiotID,          -- Int,
    @BZd_DDfID,              -- Int,
    @BZd_Kierunek,           -- SmallInt,
    @BZd_KatID,              -- Int,
    @BZd_FPlId,              -- Int,
    @BZd_DataDok,            -- DateTime,
    @BZd_DataKur,            -- DateTime,
    @BZd_KwotaSys,           -- Decimal(15,2),
    @BZd_Kwota,              -- Decimal(15,2),
    @BZd_Waluta,             -- NVARCHAR(3),
    @BZd_KursNumer,          -- Int,
    @BZd_KursL,              -- Decimal(15,4),
    @BZd_KursM,              -- Decimal(5,0),
    @BZd_Stan,               -- SmallInt,
    @BZd_Opis,               -- NVARCHAR(254),
    @BZd_OpeZalId,           -- Int,
    @BZd_StaZalId,           -- Int,
    @BZd_Termin              -- DateTime = Null
  -- Wyswietlenie komunikatu i rollback całej transakcji
  KOMUNIKAT:
  IF @Komunikat <> ''
    BEGIN
      RAISERROR( @Komunikat, 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
