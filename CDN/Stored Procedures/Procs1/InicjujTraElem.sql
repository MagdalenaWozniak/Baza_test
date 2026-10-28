CREATE PROCEDURE CDN.InicjujTraElem
  @TwrId                   TEXT,           -- id towarów rozdzielone przecinkami
  @TwrIlosc                TEXT,           -- ilosci towarow rozdzielone przecinkami
  @TwrJm                   TEXT,           -- jednostki miar towarow rozdzielone przecinkami
  @CenaWWD                 TEXT,           -- ceny walutowe
  @TwrMagId                TEXT,        -- id magazynow dla pozycji
  @TrN_PodmiotTyp          INT,
  @TrN_PodId               INT,
  @TrN_Waluta              NVARCHAR(3),
  @TrN_KursL               DECIMAL(15,4),
  @TrN_KursM               DECIMAL(5,0),
  @TrN_MagId               INT,
  @TrN_Rodzaj              INT,
  @TrN_TypNB               TINYINT,
  @TrN_DataDokChar         NVARCHAR(25),
  @TrN_DataOpeChar         NVARCHAR(25),
  @TrN_DataKurChar         NVARCHAR(25),
  @TwC_TwCNumer            INT,            -- numer ceny wybrany na liście zasobów - jesli NULL, to procedura musi go zbudowac na podstawie ceny domyślnej kontrahenta i towaru
  @ServerCfgString         NVARCHAR(512),   -- np. 'Z-GAJEWSKI'
  @BazaCfgString           NVARCHAR(512),   -- np. 'CDN_Konfiguracja65'
  @OstatniLp               INT,            -- Lp z ostatniego elementu dokumentu - inicjowane elementy będą miały kolejne Lp
  @OrderBy                 NVARCHAR(30),    -- sortowanie towarów wg kodu, nazwy, numru katalogowego, EAN-u,
  @TrN_TrNId               INT,            -- jeśli ustawione, to dodajemy elemnty do tego nagłowka
  @PlatElemSys             INT,            -- czy ma byc liczone od zl
  @VatDlaDokWal            INT,            -- czy ma byc liczone vat dla wal
  @TrN_FVMarza             SMALLINT,       -- czy FA jest fakturą VAT marża
  @Opakowania              SMALLINT,       -- czy elementy mają pochodzić ze schematów opakowań: 0 - zakłądka ogólne (1 element), 1 - zakładka opakowania (1 element), 2 - piorunek (zestaw kaucji dla towarów z zakł. ogólne), 3- pka dogenerowywane .
  @DodajElementyDoBazy     SMALLINT,
  @Export                  INT = -1,
  @ZestawID                INT = 0,
  @KategoriaTowarNaglowek  INT = 0,         -- kategoria naglowka czy towar
  @PominRabaty             INT = 0,          -- nie uwzględniaj rabatów
  @CenaZPliku              INT = 0,
  @IloscZPliku             INT = 0
AS
SET NOCOUNT ON
  DECLARE
    @WalSys                NVARCHAR(3),
    @WalOstrzegaj          NVARCHAR(3),
    @TypRabatu             SMALLINT,
    @RabatCena             DECIMAL(17,4),
    @CWWD                  DECIMAL(17,4),
    @Brak                  INT,
    @Komunikat             NVARCHAR(255),
    @TwC_Typ               TINYINT,
    @TwC_Waluta            NVARCHAR(3),
    @TwC_Wartosc           DECIMAL(17,4),
    @TrN_DataDok           DATETIME,
    @TrN_DataOpe           DATETIME,
    @TrN_DataKur           DATETIME,
    @Twr_Typ               TINYINT,
    @Tre_JmPrzelicznikL    DECIMAL(15,2),
    @Tre_JmPrzelicznikM    DECIMAL(7,0),
    @Twr_KosztUslugiTyp    TINYINT,
    @Twr_KosztUslugi       DECIMAL(17,4),
 --   @ServerCfgString         NVARCHAR(512),   -- np. 'Z-GAJEWSKI'
 --   @BazaCfgString           NVARCHAR(512),   -- np. 'CDN_Konfiguracja65'
    -- elementy
--    @TrE_TrEId              INT,
--    @TrE_TrNId              INT,
--    @TrE_ZwrId              INT,
--    @TrE_IdProd             INT,
--    @TrE_PdRId              INT,
      @TrE_Lp                 INT,
--    @TrE_LpPow              INT,
    @TrE_TypDokumentu       INT,
    @TrN_TypDokumentu       INT,
--    @TrE_Aktywny            TINYINT,
--    @TrE_DataDok            DATETIME,
--    @TrE_DataOpe            DATETIME,
--    @TrE_PodmiotTyp         SMALLINT,
--    @TrE_PodID              INT,
--    @TrE_KatID              INT,
    @TrE_TwrId              INT,
--    @TrE_TwrNazwa           NVARCHAR(255),
--    @TrE_TwrEAN             NVARCHAR(20),
--    @TrE_TwrNumerKat        NVARCHAR(40),
--    @TrE_TwrKod             NVARCHAR(50),
--    @TrE_TwrOpis            NVARCHAR(1024),
--    @TrE_TwrSWW             NVARCHAR(20),
    @TrE_Stawka             DECIMAL(5,2),
    @Twr_Stawka             DECIMAL(5,2),
--    @TrE_Flaga              SMALLINT,
--    @TrE_Zrodlowa           DECIMAL(5,2),
    @TrE_TwCNumer           INT,
    @TrE_TypNB              TINYINT,
    @TrE_Cena0              DECIMAL(17,4),
    @TrE_Cena0Podst         DECIMAL(19,6),
    @TrE_Rabat              DECIMAL(5,2),
    @TrE_CenaW              DECIMAL(17,4),
--    @TrE_Waluta             NVARCHAR(3),
    @TrE_KursNumer          INT,
    @TrE_KursL              DECIMAL(15,4),
    @TrE_KursM              DECIMAL(5,0),
    @TrE_CenaT              DECIMAL(17,4),
    @TrE_Ilosc              DECIMAL(15,4),
    @KCN_Kod                varchar(8),
--    @TrE_Jm                 NVARCHAR(20),
--    @TrE_JmZ                NVARCHAR(20),
--    @TrE_JmCalkowite        TINYINT,
--    @TrE_JMPrzelicznikL     DECIMAL(15,2),
--    @TrE_JMPrzelicznikM     DECIMAL(7,0),
    @TrE_IloscJM            DECIMAL(15,4),
    @TrE_WartoscNetto       DECIMAL(15,2),
    @TrE_WartoscBrutto      DECIMAL(15,2),
--    @TrE_WartoscZakupu      DECIMAL(15,2),
    @TrE_KosztUslugi        DECIMAL(15,2),
    @TrE_Cena0WD            DECIMAL(17,4),
    @TrE_CenaWWD            DECIMAL(17,4),
    @TrE_WartoscNettoWal    DECIMAL(15,2),
    @TrE_WartoscBruttoWal   DECIMAL(15,2),
    @TrE_WartoscNettoWal6   DECIMAL(22,6),
    @TrE_WartoscBruttoWal6  DECIMAL(22,6),
    @Knt_Export             TINYINT,
 @Knt_PodatekVat         TINYINT,
    @KGO                    TINYINT,
    @TrE_TwrKaucja          TINYINT,
    @TrE_WartoscKGO         DECIMAL(15,2),
--    @TrE_Prog               DECIMAL(15,2),
--    @TrE_UpustTyp           TINYINT,
--    @TrE_Upust              DECIMAL(15,2),
--    @TrE_UpustKnt           DECIMAL(15,2),
--    @TrE_UpustKntTyp        TINYINT,
--    @TrE_IloscMax           DECIMAL(15,4)
   @ZTwID    INT,
      @ZTwGlowny   TINYINT,
      @IDSkladnika   INT,
      @TypRabatuZestaw  INT,
      @WartoscZestaw  DECIMAL(17,4),
      @WalutaZestaw   NVARCHAR(3),
      @WartoscTowaruGl  DECIMAL(15,4),
      @TypNBTowaruGl  INT,
      @WalutaTowaruGl   NVARCHAR(3),
      @IloscZestaw DECIMAL(15,4),
      @JMZestaw  varchar(20),
      @OdwrotneObciazenie int,
   @ZaokraglajDo            SMALLINT
  DECLARE @TraElem TABLE
    (
      TrE_TrEId              INT,
      TrE_TrNId              INT,
      TrE_ZwrId              INT,
      TrE_IdProd             INT,
      TrE_PdRId              INT,
      TrE_Lp                 INT,
      TrE_LpPow              INT,
      TrE_TypDokumentu       INT,
      TrE_Aktywny            TINYINT,
      TrE_DataDok            DATETIME,
      TrE_DataOpe            DATETIME,
      TrE_PodmiotTyp         SMALLINT,
      TrE_PodID              INT,
      TrE_KatID              INT,
      TrE_TwrId              INT,
      TrE_TwrNazwa           NVARCHAR(255),
      TrE_TwrEAN             NVARCHAR(40),
      TrE_TwrNumerKat        NVARCHAR(40),
      TrE_TwrKod             NVARCHAR(50),
      TrE_TwrOpis            NVARCHAR(1024),
      TrE_TwrSWW             NVARCHAR(20),
      TrE_Stawka             DECIMAL(5,2),
      TrE_Flaga              SMALLINT,
      TrE_Zrodlowa           DECIMAL(5,2),
      TrE_TwCNumer           INT,
      TrE_TypNB              TINYINT,
      TrE_Cena0              DECIMAL(17,4),
      TrE_Rabat              DECIMAL(5,2),
      TrE_CenaW              DECIMAL(17,4),
      TrE_Waluta             NVARCHAR(3),
      TrE_KursNumer          INT,
      TrE_KursL              DECIMAL(15,4),
      TrE_KursM              DECIMAL(5,0),
      TrE_CenaT              DECIMAL(17,4),
      TrE_Ilosc              DECIMAL(15,4),
      TrE_Jm                 NVARCHAR(20),
      TrE_JmZ                NVARCHAR(20),
      TrE_JmCalkowite        TINYINT,
      TrE_JMPrzelicznikL     DECIMAL(15,2),
      TrE_JMPrzelicznikM     DECIMAL(7,0),
      TrE_IloscJM            DECIMAL(15,4),
      TrE_WartoscNetto       DECIMAL(15,2),
      TrE_WartoscBrutto      DECIMAL(15,2),
      TrE_WartoscZakupu      DECIMAL(15,2),
      TrE_KosztUslugi        DECIMAL(15,2),
      TrE_Cena0WD            DECIMAL(17,4),
      TrE_CenaWWD            DECIMAL(17,4),
      TrE_WartoscNettoWal    DECIMAL(15,2),
      TrE_WartoscBruttoWal   DECIMAL(15,2),
      TrE_Prog               DECIMAL(15,2),
      TrE_UpustTyp           TINYINT,
      TrE_Upust              DECIMAL(15,2),
      TrE_UpustKnt           DECIMAL(15,2),
      TrE_UpustKntTyp        TINYINT,
      TrE_WartoscOrg         NUMERIC(15,2),
      TrE_WartoscWalOrg      NUMERIC(15,2),
      TrE_WartoscZakOrg      NUMERIC(15,2),
      TrE_IloscOrg           NUMERIC(15,4),
      TrE_IloscJmOrg         NUMERIC(15,4),
      TrE_CenaTOrg           NUMERIC(17,4),
      TrE_CenaWOrg           NUMERIC(17,4),
      TrE_CenaWWDOrg         NUMERIC(17,4),
      TrE_Cena0WDOrg         NUMERIC(17,4),
      TrE_StawkaVatOrg       NUMERIC(5,2),
      TrE_FlagaVatOrg        SMALLINT,
      TrE_ZrodlowaOrg        NUMERIC(5,2),
      TrE_IloscMax           DECIMAL(15,4),
      TrE_TwrTyp             TINYINT,
   TrE_TwrKodDostawcy     NVARCHAR(50),
      TrE_TwrEdycjaNazwy     TINYINT,
      TrE_TwrEdycjaOpisu     TINYINT,
      TrE_TwrTwcNumer        INT,
      TrE_TwrProdukt         TINYINT,
      TrE_TwrIloscZamJM      NVARCHAR(20),
      TrE_TwrNieAktywny      TINYINT,
      TrE_TwrJMPrzelicznikL     DECIMAL(15,2),
      TrE_TwrJMPrzelicznikM     DECIMAL(7,0),
      TrE_TwrJm                 NVARCHAR(20),
      TrE_TwrJmZ                NVARCHAR(20),
      TrE_TwrKosztUslugi        DECIMAL(17,4),
      TrE_TwrKosztUslugiTyp     INT,
      TrE_TwrStawka             DECIMAL(5,2),
      TrE_TwrFlaga              SMALLINT,
      TrE_TwrZrodlowa           DECIMAL(5,2),
      --TrE_TwrStawkaZak          DECIMAL(5,2),
      --TrE_TwrFlagaZak           SMALLINT,
      --TrE_TwrZrodlowaZak        DECIMAL(5,2),
      TrE_TwrGidNumer           INT,
      TrE_TwrTypMinimum         TINYINT,
      TrE_Twrmincenamarza       DECIMAL(15,2),
      TrE_TwrKaucja             TINYINT,
      TrE_Kaucja                TINYINT,
      TrE_IloscJMKW             DECIMAL(15,4),
      TrE_IloscKW               DECIMAL(15,4),
      TrE_TwrKosztKGO           DECIMAL(15,2),
      TrE_Atr1_DeAID            INT,
      TrE_Atr1_Kod              NVARCHAR(20),
      TrE_Atr1_Wartosc          NVARCHAR(100),
      TrE_Atr2_DeAID            INT,
      TrE_Atr2_Kod              NVARCHAR(20),
      TrE_Atr2_Wartosc          NVARCHAR(100),
      TrE_Atr3_DeAID            INT,
      TrE_Atr3_Kod              NVARCHAR(20),
      TrE_Atr3_Wartosc          NVARCHAR(100),
      TrE_Atr4_DeAID            INT,
      TrE_Atr4_Kod              NVARCHAR(20),
      TrE_Atr4_Wartosc          NVARCHAR(100),
      TrE_Atr5_DeAID            INT,
      TrE_Atr5_Kod              NVARCHAR(20),
      TrE_Atr5_Wartosc          NVARCHAR(100),
      TrE_Komunikat             NVARCHAR(50),
      TrE_MagId                 INT,
      TrE_IloscAkcyza           DECIMAL(15,4),
      TrE_AkcyzaOpal            DECIMAL(15,2),
      TrE_AkcyzaStawka          DECIMAL(15,2),
      TrE_KodCN                 VARCHAR(8),
      TrE_AkcyzaJMPomPrzelicznikL DECIMAL(15,2),
      TrE_AkcyzaJMPomPrzelicznikM INT,
   TrE_SJRodzajPaliwa NVARCHAR(500),
   TrE_SJSystemCertyfikacji NVARCHAR(500),
   TrE_SJPopiol NVARCHAR(15),
   TrE_SJCzesciLotne NVARCHAR(15),
   TrE_SJWartoscOpalowa NVARCHAR(15),
   TrE_SJZdolnoscSpiekania NVARCHAR(15),
   TrE_SJWymiarZiarna NVARCHAR(15),
   TrE_SJZawartoscPodziarna NVARCHAR(15),
   TrE_SJZawartoscNadziarna NVARCHAR(15),
   TrE_SJZawartoscWilgoci NVARCHAR(15),
   TrE_OdwrotneObciazenie TINYINT,
   TrE_SplitPay TINYINT,
   TrE_KV7ID  INT,
   TrE_CzySaCechyWymagane INT,
      TrE_ZTwID     INT,
      TrE_ZTwGlowny    TINYINT,
   TrE_ZTwKod    VARCHAR(20),
      IDSkladnika    INT,
      TypRabatu     INT,
      Wartosc     DECIMAL(17,4),
      Waluta     NVARCHAR(3),
      Ilosc      DECIMAL(15,4),
      Jm      NVARCHAR(20),
      TrE_TwrPobieranieSkladnikowFSUslugaZlozona INT ,
   TrE_CenaZCzteremaMiejscami TINYINT,
      TrE_WartoscNettoWal6    DECIMAL(22,6),
      TrE_WartoscBruttoWal6   DECIMAL(22,6)
    )
  -- dwa parametry w jednym 10 - kgo
  IF @DodajElementyDoBazy = 10
     SELECT  @KGO = 1,@DodajElementyDoBazy = 0
  -- tabela tymczasowa z towarwmi tj. Lp liczone do 1, id towarów, ilości (dla łatwej sprzedaży) i JM;
  -- wszystko posortowane wg parametru @OrderBy
  DECLARE @Twr  TABLE ( Lp INT,      TwrId INT,              TwrIlosc DECIMAL(15,4),         TwrJm NVARCHAR(20), CenaWWD DECIMAL(17,4), TwCNumer INT, MagId INT, Lptech INT IDENTITY (1,1) )
  DECLARE @Zestawy  TABLE ( Lp INT, TwrId INT, TwrIlosc DECIMAL(15,4), TwrJm NVARCHAR(20), TypRabatu INT, Wartosc DECIMAL(17,4),Waluta NVARCHAR(3), Glowny INT,IDSkladnik INT,TwCNumer INT, MagId INT, Lptech INT IDENTITY (1,1) )
  IF @Opakowania IN (0,1)
    BEGIN
     IF @OrderBy = ''
      INSERT INTO @Twr    (       TwrId,                  TwrIlosc,                       TwrJm            , CenaWWD,       TwCNumer,    MagId     )
        SELECT              a.NextIdInt, ISNULL(b.NextIdDecimal,1),     CASE WHEN ISNULL(c.NextIdVarchar,'') = '' THEN d.Twr_JM ELSE ISNULL(c.NextIdVarchar,'') END, ISNULL(e.NextIdDecimal, -1 ), d.Twr_TwCNumer,ISNULL(f.NextIdInt,0)
        FROM CDN.Text2TableInt ( @TwrId ) a
          JOIN cdn.Towary d ON a.NextIdInt = d.Twr_TwrId
          JOIN CDN.Text2TableDecimal ( @TwrIlosc ) b ON a.IdIdentity = b.IdIdentity
          JOIN CDN.Text2TableVarchar ( @TwrJm )    c ON a.IdIdentity = c.IdIdentity
          JOIN CDN.Text2TableDecimal ( @CenaWWD )  e ON a.IdIdentity = e.IdIdentity
          LEFT OUTER JOIN CDN.Text2TableInt     ( @TwrMagId ) f ON a.IdIdentity = f.IdIdentity
     ELSE
      INSERT INTO @Twr    (       TwrId,                  TwrIlosc,                       TwrJm            , CenaWWD,       TwCNumer,    MagId     )
        SELECT              a.NextIdInt, ISNULL(b.NextIdDecimal,1),     CASE WHEN ISNULL(c.NextIdVarchar,'') = '' THEN d.Twr_JM ELSE ISNULL(c.NextIdVarchar,'') END, ISNULL(e.NextIdDecimal, -1 ), d.Twr_TwCNumer,ISNULL(f.NextIdInt,0)
        FROM CDN.Text2TableInt ( @TwrId ) a
          JOIN cdn.Towary d ON a.NextIdInt = d.Twr_TwrId
          JOIN CDN.Text2TableDecimal ( @TwrIlosc ) b ON a.IdIdentity = b.IdIdentity
          JOIN CDN.Text2TableVarchar ( @TwrJm )    c ON a.IdIdentity = c.IdIdentity
          JOIN CDN.Text2TableDecimal ( @CenaWWD )  e ON a.IdIdentity = e.IdIdentity
          LEFT OUTER JOIN CDN.Text2TableInt     ( @TwrMagId ) f ON a.IdIdentity = f.IdIdentity
        ORDER BY
          CASE
            WHEN @OrderBy = 'Twr_Kod'       THEN Twr_Kod
            WHEN @OrderBy = 'Twr_Nazwa'     THEN Twr_Nazwa
            WHEN @OrderBy = 'Twr_NumerKat'  THEN Twr_NumerKat
            WHEN @OrderBy = 'Twr_EAN'       THEN Twr_EAN
            WHEN @OrderBy = 'Twr_SWW'       THEN Twr_SWW
   WHEN @OrderBy = ''              THEN ''
            ELSE                                 Twr_Kod
          END
     END
  -- opakowania tworzone na podstawie istniejącej FA/PA/FZ/PZ/WZ
  IF @Opakowania IN ( 2,3 )
    BEGIN
      DECLARE @TwrIdTwrIlosc TABLE ( TwrId INT, TwrIlosc DECIMAL (15,4), TwrSONId INT ,MagId INT)
      -- jeśli jest ustawione @TrN_TrNId, to liczymy towary źródłowe na podstawie elemntów dokumentu źródłowego
     IF ISNULl(@TrN_TrNId,'') <> ''
       BEGIN
           IF @Opakowania  = 3
           INSERT INTO @TwrIdTwrIlosc ( TwrId, TwrIlosc, TwrSONId,  MagId)
           SELECT TrE_TwrId, SUM(TrE_Ilosc), MAX(Twr_SONId),TrE_MagId
             FROM cdn.TraElem
               JOIN cdn.Towary ON TrE_TwrId = Twr_TwrId AND Twr_SONId IS NOT NULL
               JOIN cdn.TraNag ON TrE_TrNId = TrN_TrNId
             WHERE TrE_TrNId = @TrN_TrNId AND TrE_Kaucja = 0 AND TrN_Bufor <> -1 AND TrE_MagId = convert(int,cast(@TwrMagId as NVARCHAR(10)))
             GROUP BY TrE_TwrId, TrE_MagId
         ELSE
           INSERT INTO @TwrIdTwrIlosc ( TwrId, TwrIlosc, TwrSONId,  MagId)
           SELECT TrE_TwrId, SUM(TrE_Ilosc), MAX(Twr_SONId),TrE_MagId
             FROM cdn.TraElem
               JOIN cdn.Towary ON TrE_TwrId = Twr_TwrId AND Twr_SONId IS NOT NULL
               JOIN cdn.TraNag ON TrE_TrNId = TrN_TrNId
             WHERE TrE_TrNId = @TrN_TrNId AND TrE_Kaucja = 0 AND TrN_Bufor <> -1
             GROUP BY TrE_TwrId, TrE_MagId
         -- jeśli nie ma towarów ze schematami opakowań, to komunikat i return
         IF NOT EXISTS ( SELECT * FROM @TwrIdTwrIlosc WHERE TwrSONId IS NOT NULL )
           BEGIN
             SET @Komunikat = '##OPT34421##'--'Przekształcenie niemożliwe! Na dokumencie źródłowym nie ma towarów ze schematami opakowań.'
             GOTO KOMUNIKAT
           END
         -- odejmujemy towary z korekt
         DECLARE @TwrIdTwrIloscK TABLE ( TwrId INT, TwrIlosc DECIMAL (15,4), TwrSONId INT, MagId INT)
         INSERT INTO @TwrIdTwrIloscK ( TwrId, TwrIlosc, TwrSONId, MagId  )
           SELECT TrE_TwrId, SUM(TrE_Ilosc), MAX(Twr_SONId), TrE_MagId
             FROM cdn.TraElem
               JOIN cdn.Towary ON TrE_TwrId = Twr_TwrId AND Twr_SONId IS NOT NULL
               JOIN CDN.TraNag ON TrE_TrNId = TrN_TrNId
             WHERE TrN_ZwrId = @TrN_TrNId AND TrE_Kaucja = 0 AND TrE_Aktywny = 1
             GROUP BY TrE_TwrId,TrE_MagId
          UPDATE P SET P.TwrIlosc = P.TwrIlosc + ISNULL( K.TwrIlosc, 0 )
            FROM @TwrIdTwrIlosc P LEFT OUTER JOIN @TwrIdTwrIloscK K ON P.TwrId = K.TwrId AND P.MagId = K.MagId
       END
  -- jeśli nie ma @TrN_TrNId, to liczymy towary na podstawie przekazanych parametrów
  ELSE
    INSERT INTO @TwrIdTwrIlosc ( TwrId, TwrIlosc, TwrSONId,  MagId )
      SELECT a.NextIdInt, SUM(ISNULL(b.NextIdDecimal,1)), MAX(Twr_SONId),ISNULL(f.NextIdInt,0)
        FROM CDN.Text2TableInt ( @TwrId ) a
          LEFT OUTER JOIN CDN.Text2TableDecimal ( @TwrIlosc ) b ON a.IdIdentity = b.IdIdentity
          LEFT OUTER JOIN CDN.Text2TableInt     ( @TwrMagId ) f ON a.IdIdentity = f.IdIdentity
          JOIN cdn.Towary ON Twr_TwrId = a.NextIdInt AND Twr_SONId IS NOT NULL
          GROUP BY a.NextIdInt,ISNULL(f.NextIdInt,0)
  INSERT INTO @Twr (     TwrId,                               TwrIlosc,         TwrJm,  CenaWWD,          TwCNumer , MagId)
    SELECT           SOE_TwrId, SUM( CONVERT(INT, TwrIlosc/SOE_Ilosc)),   MAX(Twr_JM),       -1,  MAX(Twr_TwCNumer ), MagId
      FROM @TwrIdTwrIlosc
        JOIN cdn.SchematyOpakElem ON TwrSONId = SOE_SONId
        JOIN cdn.Towary ON Twr_TwrId = SOE_TwrId
      GROUP BY SOE_TwrId,MagId
      HAVING SUM( CONVERT(INT, TwrIlosc/SOE_Ilosc)) <> 0
    ORDER BY
      CASE
        WHEN @OrderBy = 'Twr_Kod'       THEN MAX(Twr_Kod)
        WHEN @OrderBy = 'Twr_Nazwa'     THEN MAX(Twr_Nazwa)
        WHEN @OrderBy = 'Twr_NumerKat'  THEN MAX(Twr_NumerKat)
        WHEN @OrderBy = 'Twr_EAN'       THEN MAX(Twr_EAN)
        WHEN @OrderBy = 'Twr_SWW'       THEN MAX(Twr_SWW)
        WHEN @OrderBy = ''              THEN ''
        ELSE                                 MAX(Twr_Kod)
      END
   END
  -- ilości kaucji na ze skojarzonych WKA do danego dokumentu lub do dokumentów pośrednich WZ/PZ
  IF @Opakowania IN ( 2,3 ) AND ISNULL(@TrN_TrNId,0) > 0
    BEGIN
      DECLARE @TwrIdTwrIlosc1 TABLE ( TwrId1 INT, TwrIlosc1 DECIMAL (15,4) )
      DECLARE @TrNIdKaucji TABLE ( TrNId INT )
      INSERT INTO @TrNIdKaucji ( TrNId )
      -- WKA/PKA skojarzone poprzez WZ/PZ
      SELECT TrN_TrNId FROM cdn.TraNag JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu IN ( 313, 314 ) AND TrR_Flaga = 1 AND TrR_FAId IN (
   SELECT TrN_TrNId FROM cdn.TraNag JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId WHERE TrR_FaId = @TrN_TrNId  AND TrN_TypDokumentu IN (306,307)
   AND TrN_TypDokumentu IN (306,307) AND NOT(TrR_FaTyp = 307 AND TrR_TrNTyp =306) AND NOT(TrR_FaTyp = 306 AND TrR_TrNTyp =307)
   ) AND TrN_Bufor <> -1
  --SELECT TrN_TrNId FROM cdn.TraNag WHERE TrN_TypDokumentu IN ( 313, 314 ) AND TrN_RelTrNId IN ( SELECT TrN_TrNId FROM cdn.TraNag WHERE TrN_FaId = @TrN_TrNId  AND TrN_TypDokumentu IN (306,307) ) AND TrN_Bufor <> -1
      -- bezpośrednie WKA
      UNION ALL
      SELECT TrN_TrNId FROM cdn.TraNag JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu IN ( 313, 314 ) AND TrR_Flaga = 1 AND TrR_FaId = @TrN_TrNId  AND TrN_Bufor <> -1
      -- WKA skojarzone z FA, która powstała z PA
      UNION ALL
      SELECT TrN_TrNId FROM cdn.TraNag JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu IN ( 313, 314 ) AND TrR_Flaga = 1 AND TrR_FaId IN (SELECT REL.TrR_FAId FROM cdn.TraNag FA JOIN cdn.TraNagRelacje REL on FA.TrN_TrNId = REL.TrR_TrNId WHERE FA.TrN_TrNId = @TrN_TrNId AND  REL.TrR_TrNTyp = 302 AND REL.TrR_FaTyp = 305) AND TrN_Bufor <> -1
      -- sumujemy wszystkie towary z dotychczasowych WKA
      INSERT INTO @TwrIdTwrIlosc1 ( TwrId1, TwrIlosc1 )
        SELECT TrE_TwrId, SUM(TrE_Ilosc) FROM cdn.TraElem WHERE TrE_TrNId IN ( SELECT TrNId FROM @TrNIdKaucji ) AND TrE_Aktywny = 1  GROUP BY TrE_TwrId
        --SELECT TrE_TwrId, SUM(TrE_Ilosc) FROM cdn.TraElem WHERE TrE_TrNId IN ( SELECT TrNId FROM @TrNIdKaucji ) AND TrE_Aktywny = 1 AND TrE_MagId = convert(int,cast(@TwrMagId as NVARCHAR(10))) GROUP BY TrE_TwrId Zgł 150306 wycięto TrE_MagId = convert(int,cast(@TwrMagId as NVARCHAR(10)))
      -- poprawa ilości na wynikowym recordsecie (odjęcie opakowań wystawionych wcześniej)
      UPDATE @Twr SET TwrIlosc = CASE WHEN TwrIlosc - ISNULL(TwrIlosc1,0) <= 0 THEN 0 ELSE TwrIlosc - ISNULL(TwrIlosc1,0) END
        FROM @Twr LEFT OUTER JOIN @TwrIdTwrIlosc1 ON TwrId = TwrId1
      -- skasowanie opakowań z ilościami zerowymi
      DELETE FROM @Twr WHERE TwrIlosc = 0
    END
 -- kontrola czy nie jest ilosc całkowita
 update @Twr SET TwrIlosc = case when round(TwrIlosc,0) = 0 and TwrIlosc != 0 then 1 else round(TwrIlosc,0) end  FROM @Twr
   left join cdn.towary on TwrId = Twr_Twrid
   where Twr_JMCalkowite = 1
  -- nadawanie Lp
  DECLARE @Identity TABLE ( LpIdent INT IDENTITY (1,1), LpTech INT )
  INSERT INTO @Identity ( LpTech ) SELECT LpTech FROM @Twr
  UPDATE a SET a.Lp = b.LpIdent FROM @Twr a JOIN @Identity b ON a.LpTech=b.LpTech
  -- Daty i typ dokuemntu
  SELECT
    @TrN_DataDok = CONVERT(DATETIME, @TrN_DataDokChar, 120),
    @TrN_DataOpe = CONVERT(DATETIME, @TrN_DataOpeChar, 120),
    @TrN_DataKur = CONVERT(DATETIME, @TrN_DataKurChar, 120),
    @TrE_TypDokumentu = CONVERT(INT, @TrN_Rodzaj / 1000),
    @TrN_TypDokumentu = CONVERT(INT, @TrN_Rodzaj / 1000)
  IF @Opakowania = 1 or @Opakowania = 2 or @Opakowania = 3
    BEGIN
      IF @TrE_TypDokumentu IN ( 302, 305 )
        SET @TrE_TypDokumentu = 314
      IF @TrE_TypDokumentu IN ( 301 )
        SET @TrE_TypDokumentu = 313
    END
  -- 1 = "Pobieraj ostatnio ustalony kurs waluty (nie ostrzegaj o zmianie kursu)"
  IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540 )
    SELECT @WalOstrzegaj=Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540
  ELSE
    SELECT @WalOstrzegaj=1
  IF @TrN_Rodzaj in(304000,312000,303000,311000,304004,304006,304008,312008) -- dla MM/RW żeby zawsze przeszlo i tak pobiera ostatnia cene zakupu
 SELECT @WalOstrzegaj=1
  -- 1 = "odwrotne obciazenie na karcie towarowej"
 IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=2197 )
    SELECT @OdwrotneObciazenie=Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=2197
  ELSE
    SELECT @OdwrotneObciazenie=0
  -- skeszowanie notowań wszystkich walut z konfiguracji
  DECLARE @sqltxt NVARCHAR (1000),@TmpSrvName SYSNAME
  SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
  IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
    SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
  SET @sqltxt = 'EXEC ['
  IF @ServerCfgString <> @TmpSrvName
    SET @sqltxt = @sqltxt + @ServerCfgString +'].['
  SET @sqltxt = @sqltxt + @BazaCfgString+'].CDN.PobierzNotowania '''', 2,'''+ @TrN_DataKurChar+''','+ @WalOstrzegaj+''
  CREATE TABLE #Notowania  ( Systemowa TINYINT, Waluta NVARCHAR(3), KursNumer INT, KursL DECIMAL(15,4), KursM DECIMAL(5,0), Brak TINYINT )
  INSERT INTO  #Notowania  ( Systemowa,         Waluta ,           KursNumer,     KursL,               KursM             , Brak         )
  EXEC sp_executesql @sqltxt
  -- jaka waluta jest taka sama jak w naglowku to podmieniamy kursy
  UPDATE #Notowania SET KursL = @TrN_KursL,KursM = @TrN_KursM, Brak = 0 WHERE Waluta = @TrN_Waluta
  -- jaka waluta systemowa
  SELECT @WalSys = Waluta from #Notowania where Systemowa=1
  -- określenie numeru ceny
  -- dla dokumentów przychodowych zawsze cena zakupu
  IF @TrE_TypDokumentu IN (301, 303, 307, 309, 310, 301, 311,350, 313, 304, 312)  SET @TwC_TwCNumer = 1
  -- jeśli nie przekazano numeru ceny, to cena domyślna z karty kontrahenta lub magazynu
  -- dla pozostałych dokumentów cena domyślna z karty kontrahenta . magaztnu, jeśli nie przekazano numeru ceny
  IF (@TwC_TwCNumer IS NULL OR @TwC_TwCNumer=0)
    begin
    SELECT @TwC_TwCNumer = Mag_TwcNumer FROM Cdn.Magazyny WHERE Mag_MagId = @TrN_MagId and @ZestawID = 0
    IF (@TwC_TwCNumer IS NULL OR @TwC_TwCNumer=0)
  SELECT @TwC_TwCNumer = Knt_Ceny FROM Cdn.Kontrahenci WHERE Knt_KntId = @TrN_PodId and @ZestawID = 0
  end
/*
  -- sprawdzamy, czy cena domyślna kontrahenta jest obecna w tabeli z cenami
  -- jeśli tak, to podmieniamy ją na wszystkich dodawanych towarach
  -- jeśli nie, to zostaje cena domyślna z towaru
  -- zakładamy, że każdy towar ma ten sam zestaw domyślnych numerów cen.
  IF EXISTS ( SELECT * FROM CDN.TwrCeny JOIN @Twr ON TwrId = TwC_TwrId AND TwC_TwCNumer = @TwC_TwCNumer )
    UPDATE @Twr SET TwCNumer = @TwC_TwCNumer
*/
  -- kursor po towarach z tabeli pomocnicznej
  -- podmieniamy numer ceny tylko wtedy, gdy istnieje w kolekcji cen każdego dodawanego towaru
  -- w przeciwnym wypadku brana jest domyślna cena z karty towaru ( zawsze występuje, nawet w O!O )
  DECLARE @Twr_Id INT
  DECLARE T CURSOR LOCAL FAST_FORWARD FOR
    SELECT TwrId FROM @Twr ORDER BY TwrId
    OPEN T
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM T INTO @Twr_Id
        IF @@FETCH_STATUS <> 0 BREAK
        IF EXISTS ( SELECT * FROM cdn.TwrCeny WHERE TwC_TwrId = @Twr_Id AND TwC_TwCNumer = @TwC_TwCNumer )
          UPDATE @Twr SET TwCNumer = @TwC_TwCNumer WHERE TwrId = @Twr_Id
      END
    CLOSE T
  DEALLOCATE T
  -- określenie czy kontrahent exportowy
  if @Export = -1
  SELECT @Knt_Export = Knt_Export
    FROM CDN.Kontrahenci
    WHERE Knt_KntId =  @TrN_PodId
  else
    select @Knt_Export = @Export
  -- Przygotowanie elementów z danymi z towarów
  INSERT INTO @TraElem
    SELECT
      -- TrE_TrEId
      NULL,
      -- TrE_TrNId
      NULL,
      -- TrE_ZwrId
      NULL,
      -- TrE_IdProd
      NULL,
      -- TrE_PdRId
      NULL,
      -- TrE_Lp
      @OstatniLp + Lp,
      -- TrE_LpPow
      @OstatniLp + Lp,
      --TrE_TypDokumentu
      @TrE_TypDokumentu,
      -- TrE_Aktywny
      1,
      -- TrE_DataDok
      @TrN_DataDok,
      -- TrE_DataOpe
      @TrN_DataOpe,
      -- TrE_PodmiotTyp
      @TrN_PodmiotTyp,
      -- TrE_PodID
      @TrN_PodId,
      -- TrE_KatID
      CASE
        WHEN @TrE_TypDokumentu IN ( 310, 301, 303, 307, 309, 350, 310, 317, 313, 321, 312 ) THEN Twr_KatZakId
        ELSE Twr_KatId
      END,
      -- TrE_TwrId
      Twr_TwrId,
      -- TrE_TwrNazwa
      Twr_Nazwa,
      -- TrE_TwrEAN
      Twr_EAN,
      -- TrE_TwrNumerKat
      Twr_NumerKat,
      -- TrE_TwrKod
      Twr_Kod,
      -- TrE_TwrOpis
      SUBSTRING(CDN.PobierzAtrybut( @TrN_PodmiotTyp, @Trn_PodId, TwrId ),1,1024),
      -- TrE_TwrSWW
      Twr_SWW,
      -- TrE_Stawka
     CASE
     WHEN @TrN_FVMarza=1 Then 0
     WHEN  @Knt_Export IN(8,9) and @TrE_TypDokumentu IN ( 301,307,309,321,322 ) THEN 0
        WHEN ( @TrN_Waluta IN (@WalSys,'')  and ISNULL (@Knt_Export,0) = 0 ) or @TrN_TypDokumentu = 305 or @TrE_TypDokumentu = 350 or @VatDlaDokWal=1
                THEN
                  CASE
        WHEN @Knt_Export=5 and @TrN_Waluta NOT IN (@WalSys,'') and @VatDlaDokWal=1 and  twr_odwrotneobciazenie = 1 and @OdwrotneObciazenie = 1 THEN 0
                    WHEN @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and @TrN_Rodzaj <> 322000 THEN Twr_StawkaZak
                    WHEN @TrN_FVMarza=1 Then 0
                    ELSE Twr_Stawka
                  END
        ELSE
        CASE
               WHEN  @Knt_Export=5 and twr_odwrotneobciazenie = 1 and @OdwrotneObciazenie = 1 THEN 0
               WHEN  @Knt_Export=5 and twr_odwrotneobciazenie != 1 and @OdwrotneObciazenie = 1 and (@VatDlaDokWal=1 OR @TrN_Waluta IN (@WalSys,'')) THEN
               CASE
                    WHEN @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and @TrN_Rodzaj <> 322000 THEN Twr_StawkaZak
                    WHEN @TrN_FVMarza=1 Then 0
                    ELSE Twr_Stawka
                  END
               WHEN  @Knt_Export=5 and @OdwrotneObciazenie = 0  THEN 0  -- dla exportowych stawka 0 i flaga 4 dla uslugi
               ELSE    0  -- dla exportowych stawka 0
        END
      END,
      -- TrE_Flaga
      CASE
     WHEN @TrN_FVMarza=1 Then 4
     WHEN  @Knt_Export IN(8,9) and @TrE_TypDokumentu IN ( 301,307,309,321,322 ) THEN 4
        WHEN ( @TrN_Waluta IN (@WalSys,'') and ISNULL (@Knt_Export,0)=0 ) or @TrN_TypDokumentu = 305 or @TrE_TypDokumentu = 350 or @VatDlaDokWal=1
               THEN
                 CASE
        WHEN @Knt_Export=5 and @TrN_Waluta NOT IN (@WalSys,'') and @VatDlaDokWal=1 and  twr_odwrotneobciazenie = 1 and @OdwrotneObciazenie = 1 THEN 4
                    WHEN @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and @TrN_Rodzaj <> 322000 THEN Twr_FlagaZak
                    WHEN @TrN_FVMarza=1 Then 4
                    ELSE Twr_Flaga
                  END
       ELSE
        CASE
          WHEN Twr_Typ = 0 and @Knt_Export<>0 and @Knt_Export<>5 and  @TrE_TypDokumentu NOT IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and  ISNULL(KAT.Kat_RodzajZakupu,0) = 1   THEN 2 -- dla exportowych stawka 0 i flaga 4 dla uslugi
          WHEN Twr_Typ = 0 and @Knt_Export<>0 and @Knt_Export<>5 and  @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and  ISNULL(KatZak.Kat_RodzajZakupu,0) = 1   THEN 2 -- dla exportowych stawka 0 i flaga 4 dla uslugi
          WHEN Twr_Typ = 0 and @Knt_Export<>0 and @Knt_Export<>5 and  @TrE_TypDokumentu NOT IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and  ISNULL(KAT.Kat_RodzajZakupu,0) != 4  and  @KategoriaTowarNaglowek = 1  THEN 2 -- dla exportowych stawka 0 i flaga 4 dla uslugi
          WHEN Twr_Typ = 0 and @Knt_Export<>0 and @Knt_Export<>5 and  @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and  ISNULL(KatZak.Kat_RodzajZakupu,0) != 4  and  @KategoriaTowarNaglowek = 1   THEN 2 -- dla exportowych stawka 0 i flaga 4 dla uslugi
          WHEN Twr_Typ = 0 and @Knt_Export<>0 and @Knt_Export<>5  THEN 4
          ELSE
           CASE
               WHEN  @Knt_Export=5 and twr_odwrotneobciazenie = 1 and @OdwrotneObciazenie = 1 THEN 4
               WHEN  @Knt_Export=5 and twr_odwrotneobciazenie != 1 and @OdwrotneObciazenie = 1 and (@VatDlaDokWal=1 OR @TrN_Waluta IN (@WalSys,'')) THEN Twr_Flaga
               WHEN  @Knt_Export=5 and @OdwrotneObciazenie = 0  THEN 4  -- dla exportowych stawka 0 i flaga 4 dla uslugi
               ELSE    2 --dla towaru flaga 2
     END
        END
      END,
      -- TrE_Zrodlowa
      CASE
          WHEN @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and @TrN_Rodzaj <> 322000 THEN Twr_ZrodlowaZak
          ELSE Twr_Zrodlowa
      END,
      -- TrE_TwCNumer
      b.TwCNumer,
      -- TrE_TypNB
      CASE @Opakowania
        WHEN 0 then @TrN_TypNB -- zakładka "ogólne" z towarami
        WHEN 1 then 2 -- zakładka "kaucje" z kaucjami
        WHEN 2 then 2 -- zakładka "kaucje" - piorunek
        WHEN 3 then 2 -- zakładka "kaucje" - piorunek
       END,
      -- TrE_Cena0
      0,
      -- TrE_Rabat,
      0,
      -- TrE_CenaW,
      0,
      -- TrE_Waluta,
      '',
      -- TrE_KursNumer,
      2,
      -- TrE_KursL,
      1,
      -- TrE_KursM,
      1,
      -- TrE_CenaT,
      0,
      -- TrE_Ilosc,
      CASE
        WHEN @TrE_TypDokumentu = 309  AND Twr_IloscZamJM = Twr_JM AND  Twr_IloscZam>0 AND b.TwrIlosc = 1 AND @IloscZPliku = 0 THEN Twr_IloscZam
        WHEN @TrE_TypDokumentu = 309  AND  Twr_IloscZamJM != Twr_JM AND  Twr_IloscZam>0 AND b.TwrIlosc = 1 AND @IloscZPliku = 0 THEN Twr_IloscZam* C.TwJZ_JmPrzelicznikL / C.TwJZ_JmPrzelicznikM
        WHEN  b.TwrJm  = Twr_Jm THEN b.TwrIlosc
        WHEN  b.TwrJm <> Twr_Jm THEN b.TwrIlosc * A.TwJZ_JmPrzelicznikL / A.TwJZ_JmPrzelicznikM
        ELSE 0
      END,
      -- TrE_Jm
      CASE
        WHEN b.TwrJm =  Twr_Jm THEN Twr_Jm
        ELSE                        b.TwrJm
      END,
      -- TrE_JmZ
      CASE
        WHEN b.TwrJm = Twr_Jm THEN b.TwrJm
        ELSE                        Twr_Jm
      END,
      -- TrE_JmCalkowite
      Twr_JMCalkowite,
      -- TrE_JmPrzelicznikL
      CASE
        WHEN b.TwrJm =  Twr_Jm THEN 1
        ELSE A.TwJZ_JMPrzelicznikL
      END,
      -- TrE_JmPrzelicznikM
      CASE
        WHEN b.TwrJm =  Twr_Jm THEN 1
        ELSE A.TwJZ_JMPrzelicznikM
      END,
      -- TrE_IloscJM
       CASE
        WHEN @TrE_TypDokumentu = 309  AND b.TwrJm = Twr_IloscZamJM AND  Twr_IloscZam>0 AND b.TwrIlosc = 1 AND @IloscZPliku = 0  THEN Twr_IloscZam
        WHEN @TrE_TypDokumentu = 309  AND b.TwrJm <> Twr_IloscZamJM AND Twr_IloscZamJM = Twr_JM AND  Twr_IloscZam>0 AND b.TwrIlosc = 1 AND @IloscZPliku = 0  THEN Twr_IloscZam * A.TwJZ_JmPrzelicznikM / A.TwJZ_JmPrzelicznikL
        WHEN @TrE_TypDokumentu = 309  AND b.TwrJm <> Twr_IloscZamJM AND Twr_IloscZamJM <> Twr_JM AND b.TwrJm  = Twr_JM AND  Twr_IloscZam>0 AND b.TwrIlosc = 1 AND @IloscZPliku = 0  THEN Twr_IloscZam * C.TwJZ_JmPrzelicznikL / C.TwJZ_JmPrzelicznikM
        WHEN @TrE_TypDokumentu = 309  AND b.TwrJm <> Twr_IloscZamJM AND Twr_IloscZamJM <> Twr_JM AND b.TwrJm  != Twr_JM AND  Twr_IloscZam>0 AND b.TwrIlosc = 1 AND @IloscZPliku = 0 THEN Twr_IloscZam * C.TwJZ_JmPrzelicznikL / C.TwJZ_JmPrzelicznikM* A.TwJZ_JmPrzelicznikM / A.TwJZ_JmPrzelicznikL
        ELSE b.TwrIlosc
      END,
      -- TrE_WartoscNetto,
      0,
      -- TrE_WartoscBrutto,
      0,
      -- TrE_WartoscZakupu,
      0,
      -- TrE_KosztUslugi,
      0,
      -- TrE_Cena0WD,
      0,
      -- TrE_CenaWWD,
      round(b.CenaWWD,case when Twr_CenaZCzteremaMiejscami = 1 and @TrN_TypDokumentu != 305 then 4 else 2 end),
      -- TrE_WartoscNettoWal,
      0,
      -- TrE_WartoscBruttoWal,
      0,
      -- TrE_Prog,
      0,
      -- TrE_UpustTyp,
      0,
      -- TrE_Upust,
      0,
      -- TrE_UpustKnt,
      0,
      -- TrE_UpustKntTyp,
      0,
      -- TrE_WartoscOrg,
      NULL,
      -- TrE_WartoscWalOrg,
      NULL,
      -- TrE_WartoscZakOrg,
      NULL,
      -- TrE_IloscOrg,
      NULL,
      -- TrE_IloscJmOrg,
      NULL,
      -- TrE_CenaTOrg,
      NULL,
      -- TrE_CenaWOrg,
      NULL,
      -- TrE_CenaWWDOrg,
      NULL,
      -- TrE_Cena0WDOrg,
      NULL,
      -- TrE_StawkaVatOrg,
      NULL,
      -- TrE_FlagaVatOrg,
      NULL,
      -- TrE_ZrodlowaOrg,
      NULL,
      -- TrE_IloscMax
      0, --CDN.fn_TwrIloscMax ( Twr_TwrId, @TrN_MagId, @TrN_DataOpe ),
      -- TrE_TwrTyp
      Twr_Typ,
   --TrE_TwrKodDostawcy
      Twr_KodDostawcy,
      -- TrE_TwrEdycjaNazwy,
      Twr_EdycjaNazwy,
      -- TrE_TwrEdycjaOpisu,
      Twr_EdycjaOpisu,
      -- TrE_TwrTwcNumer,
      Twr_TwcNumer,
      --TrE_TwrProdukt
      Twr_Produkt,
      --TrE_TwrIloscZamJM
      Twr_IloscZamJM,
      --TrE_TwrNieaktywny
      Twr_NieAktywny,
      --TrE_TwrJMPrzelicznikL
      1,
      --TrE_TwrJMPrzelicznikM
      1,
      -- TrE_TwrJm
      Twr_Jm,
      -- TrE_TwrJmZ
      '',
      --TrE_TwrKosztUslugi
      Twr_KosztUslugi,
      --TrE_TwrKosztUslugiTyp
      Twr_KosztUslugiTyp,
     --TrE_TwrStawka
      CASE
         WHEN @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and @TrN_Rodzaj <> 322000 THEN Twr_StawkaZak
         WHEN @TrN_FVMarza=1 Then 0
         ELSE Twr_Stawka
      END,
      --TrE_TwrFlaga
      CASE
         WHEN @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and @TrN_Rodzaj <> 322000 THEN Twr_FlagaZak
         WHEN @TrN_FVMarza=1 Then 4
         ELSE Twr_Flaga
      END,
      --TrE_TwrZrodlowa
      CASE
          WHEN @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and @TrN_Rodzaj <> 322000 THEN Twr_ZrodlowaZak
          ELSE Twr_Zrodlowa
      END,
      --TrE_TwrStawkaZak
      --Twr_StawkaZak,
      --TrE_TwrFlagaZak
      --Twr_FlagaZak,
      --TrE_TwrZrodlowaZak
      --Twr_ZrodlowaZak,
      --TrE_TwrGidNumer
      Twr_GidNumer,
      --TrE_TwrTypMinimum
      Twr_TypMinimum,
      --TrE_Twrmincenamarza
      Twr_MinCenaMarza,
      --TrE_TwrKaucja
      Twr_Kaucja,
      --TrE_Kaucja
      CASE @Opakowania
        WHEN 0 then 0 -- zakładka "ogólne" z towarami
        WHEN 1 then 1 -- zakładka "kaucje" z kaucjami
        WHEN 2 then 1 -- zakładka "kaucje" - piorunek
        WHEN 3 then 1 -- zakładka "kaucje" - piorunek
      END,
      --TrE_IloscJMKW
      0,
      --TrE_IloscKW
      0,
      --TrE_TwrKosztKGO
      Twr_KosztKGO,
      --TrE_Atr1_DeAID
      NULL,
      --TrE_Atr1_Kod
      '',
      --TrE_Atr1_Wartosc
      '',
      --TrE_Atr2_DeAID
      NULL,
      --TrE_Atr2_Kod
      '',
      --TrE_Atr2_Wartosc
      '',
      --TrE_Atr3_DeAID
      NULL,
      --TrE_Atr3_Kod
      '',
      --TrE_Atr3_Wartosc
      '',
      --TrE_Atr4_DeAID
      NULL,
      --TrE_Atr4_Kod
      '',
      --TrE_Atr4_Wartosc
      '',
      --TrE_Atr5_DeAID
      NULL,
      --TrE_Atr5_Kod
      '',
      --TrE_Atr5_Wartosc
      '',
      -- Tre_Komunikat
      '',
      -- TrE_MagId
      b.MagId,
      --TrE_IloscAkcyza
      0,
      --TrE_AkcyzaOpal
      case when Twr_Akcyza = 0 then 0 else  Twr_AkcyzaOpal end,
      --TrE_AkcyzaStawka
      case when Twr_Akcyza = 0 then 0 else  Twr_AkcyzaStawka end,
      -- TrE_KodCN
      isnull(KCN_Kod,''),
      -- TrE_AkcyzaJMPomPrzelicznikL
      case when Twr_Akcyza = 0 then 1 else  Twr_AkcyzaJMPomPrzelicznikL end,
      -- TrE_AkcyzaJMPomPrzelicznikM
      case when Twr_Akcyza = 0 then 1 else  Twr_AkcyzaJMPomPrzelicznikM end,
   -- Tre_SJRodzajPaliwa
   Twr_SJRodzajPaliwa,
   -- Tre_SJSystemCertyfikacji
   Twr_SJSystemCertyfikacji,
   -- Tre_SJPopiol
   Twr_SJPopiol,
   -- Tre_SJCzesciLotne
   Twr_SJCzesciLotne,
   -- Tre_SJWartoscOpalowa
   Twr_SJWartoscOpalowa,
   -- Tre_SJZdolnoscSpiekania
   Twr_SJZdolnoscSpiekania,
   -- Tre_SJWymiarZiarna
   Twr_SJWymiarZiarna,
   -- Tre_SJZawartoscPodziarna
   Twr_SJZawartoscPodziarna,
   -- Tre_SJZawartoscNadziarna
   Twr_SJZawartoscNadziarna,
   -- Tre_SJZawartoscWilgoci
   Twr_SJZawartoscWilgoci,
   -- TrE_OdwrotneObciazenie
      Twr_OdwrotneObciazenie,
   -- TrE_SplitPay
      Twr_SplitPay,
   -- Tre_KV7ID
   Twr_KV7ID,
   --Tre_CzySaCechyWymagane
   -1,
      --TrE_ZTwID INT,
      0,
      --TrE_ZTwGlowny TINYINT,
      0,
   --TrE_ZTwKod VARCHAR(20),
      '',
      --IDSkladnika INT,
      0,
      --TypRabatu INT,
      0,
      --Wartosc DECIMAL(15,4),
      0,
      --Waluta NVARCHAR(3)
      '',
      --Ilosc      DECIMAL(15,4),
      0,
      --Jm         NVARCHAR(20)
      '',
      Twr_PobieranieSkladnikowFSUslugaZlozona,
   CASE  WHEN @TrN_TypDokumentu = 305 then 0  else Twr_CenaZCzteremaMiejscami end,
      -- TrE_WartoscNettoWal6,
      0,
      -- TrE_WartoscBruttoWal6,
      0
    FROM cdn.Towary JOIN @Twr b ON b.TwrId = Twr_TwrId
 LEFT OUTER join cdn.TwrJMZ A on A.TwJZ_TwrId = Twr_TwrId AND A.TwJZ_JM = b.TwrJm AND A.TwJZ_eSklepID = 0
 LEFT OUTER join cdn.TwrJMZ C on C.TwJZ_TwrId = Twr_TwrId AND C.TwJZ_JM = Twr_IloscZamJM AND C.TwJZ_eSklepID = 0
    LEFT OUTER join cdn.KodyCN on Twr_KCNId = KCN_KCNId
 LEFT OUTER join cdn.Kategorie Kat on Twr_KatId = Kat.Kat_KatId
    LEFT OUTER join cdn.Kategorie KatZak on Twr_KatZakId = KatZak.Kat_KatId
    ORDER BY b.Lp
 -- jesli to zestaw
  insert into  @Zestawy ( TwrId , TwrIlosc , TwrJm , TypRabatu , Wartosc ,Waluta , Glowny , IDSkladnik ,TwCNumer, MagId  )
 select ZTw_TwrId,1 as ilosc,twr_jm,ZTw_TypRabatu,ZTw_Wartosc,ZTw_Waluta, 1 as glowny, 0 as IDSkladnik,Twr_TwCNumer,@TrN_MagId from CDN.ZestawyTwr  join CDN.Towary on Twr_TwrId = ZTw_TwrId  where ZTw_ZTwId = @ZestawID
 union all
 select ZTS_TwrId, ZTS_Ilosc,ZTS_Jm, ZTS_TypRabatu,ZTS_Wartosc,ZTS_Waluta,0,ZTS_ZTSId,Twr_TwCNumer,@TrN_MagId  from CDN.ZestawyTwrSkladniki  join CDN.Towary on Twr_TwrId = ZTS_TwrId where ZTS_ZTwId = @ZestawID
 -- nadawanie Lp
  delete from @Identity
  INSERT INTO @Identity ( LpTech ) SELECT LpTech FROM @Zestawy
  UPDATE a SET a.Lp = b.LpIdent FROM @Zestawy a JOIN @Identity b ON a.LpTech=b.LpTech
  DECLARE T CURSOR LOCAL FAST_FORWARD FOR
    SELECT TwrId FROM @Zestawy
    OPEN T
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM T INTO @Twr_Id
        IF @@FETCH_STATUS <> 0 BREAK
        IF EXISTS ( SELECT * FROM cdn.TwrCeny WHERE TwC_TwrId = @Twr_Id AND TwC_TwCNumer = @TwC_TwCNumer )
          UPDATE @Zestawy SET TwCNumer = @TwC_TwCNumer WHERE TwrId = @Twr_Id
      END
    CLOSE T
  DEALLOCATE T
    INSERT INTO @TraElem
    SELECT
      -- TrE_TrEId
      NULL,
      -- TrE_TrNId
      NULL,
      -- TrE_ZwrId
      NULL,
      -- TrE_IdProd
      NULL,
      -- TrE_PdRId
      NULL,
      -- TrE_Lp
      @OstatniLp + Lp,
      -- TrE_LpPow
      @OstatniLp + Lp,
      --TrE_TypDokumentu
      @TrE_TypDokumentu,
      -- TrE_Aktywny
      1,
      -- TrE_DataDok
      @TrN_DataDok,
      -- TrE_DataOpe
      @TrN_DataOpe,
      -- TrE_PodmiotTyp
      @TrN_PodmiotTyp,
      -- TrE_PodID
      @TrN_PodId,
      -- TrE_KatID
      CASE
        WHEN @TrE_TypDokumentu IN ( 310, 301, 303, 307, 309, 350, 310, 317, 313, 321, 312 ) THEN Twr_KatZakId
        ELSE Twr_KatId
      END,
      -- TrE_TwrId
      Twr_TwrId,
      -- TrE_TwrNazwa
      Twr_Nazwa,
      -- TrE_TwrEAN
      Twr_EAN,
      -- TrE_TwrNumerKat
      Twr_NumerKat,
      -- TrE_TwrKod
      Twr_Kod,
      -- TrE_TwrOpis
      SUBSTRING(CDN.PobierzAtrybut( @TrN_PodmiotTyp, @Trn_PodId, TwrId ),1,1024),
      -- TrE_TwrSWW
      Twr_SWW,
           -- TrE_Stawka
     CASE
     WHEN @TrN_FVMarza=1 Then 0
     WHEN  @Knt_Export IN(8,9) and @TrE_TypDokumentu IN ( 301,307,309,321,322 ) THEN 0
        WHEN ( @TrN_Waluta IN (@WalSys,'')  and ISNULL (@Knt_Export,0) = 0 ) or @TrN_TypDokumentu = 305 or @TrE_TypDokumentu = 350 or @VatDlaDokWal=1
                THEN
                  CASE
        WHEN @Knt_Export=5 and @TrN_Waluta NOT IN (@WalSys,'') and @VatDlaDokWal=1 and  twr_odwrotneobciazenie = 1 and @OdwrotneObciazenie = 1 THEN 0
                    WHEN @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and @TrN_Rodzaj <> 322000 THEN Twr_StawkaZak
                    WHEN @TrN_FVMarza=1 Then 0
                    ELSE Twr_Stawka
                  END
        ELSE
        CASE
               WHEN  @Knt_Export=5 and twr_odwrotneobciazenie = 1 and @OdwrotneObciazenie = 1 THEN 0
               WHEN  @Knt_Export=5 and twr_odwrotneobciazenie != 1 and @OdwrotneObciazenie = 1 and (@VatDlaDokWal=1 OR @TrN_Waluta IN (@WalSys,'')) THEN
               CASE
                    WHEN @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and @TrN_Rodzaj <> 322000 THEN Twr_StawkaZak
                    WHEN @TrN_FVMarza=1 Then 0
                    ELSE Twr_Stawka
                  END
               WHEN  @Knt_Export=5 and @OdwrotneObciazenie = 0  THEN 0  -- dla exportowych stawka 0 i flaga 4 dla uslugi
               ELSE    0  -- dla exportowych stawka 0
        END
      END,
      -- TrE_Flaga
      CASE
     WHEN @TrN_FVMarza=1 Then 4
     WHEN  @Knt_Export IN(8,9) and @TrE_TypDokumentu IN ( 301,307,309,321,322 ) THEN 4
        WHEN ( @TrN_Waluta IN (@WalSys,'') and ISNULL (@Knt_Export,0)=0 ) or @TrN_TypDokumentu = 305 or @TrE_TypDokumentu = 350 or @VatDlaDokWal=1
               THEN
                 CASE
        WHEN @Knt_Export=5 and @TrN_Waluta NOT IN (@WalSys,'') and @VatDlaDokWal=1 and  twr_odwrotneobciazenie = 1 and @OdwrotneObciazenie = 1 THEN 4
                    WHEN @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and @TrN_Rodzaj <> 322000 THEN Twr_FlagaZak
                    WHEN @TrN_FVMarza=1 Then 4
                    ELSE Twr_Flaga
                  END
       ELSE
        CASE
          WHEN Twr_Typ = 0 and @Knt_Export<>0 and @Knt_Export<>5 and  @TrE_TypDokumentu NOT IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and  ISNULL(KAT.Kat_RodzajZakupu,0) = 1   THEN 2 -- dla exportowych stawka 0 i flaga 4 dla uslugi
          WHEN Twr_Typ = 0 and @Knt_Export<>0 and @Knt_Export<>5 and  @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and  ISNULL(KatZak.Kat_RodzajZakupu,0) = 1   THEN 2 -- dla exportowych stawka 0 i flaga 4 dla uslugi
          WHEN Twr_Typ = 0 and @Knt_Export<>0 and @Knt_Export<>5 and  @TrE_TypDokumentu NOT IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and  ISNULL(KAT.Kat_RodzajZakupu,0) != 4  and  @KategoriaTowarNaglowek = 1  THEN 2 -- dla exportowych stawka 0 i flaga 4 dla uslugi
          WHEN Twr_Typ = 0 and @Knt_Export<>0 and @Knt_Export<>5 and  @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and  ISNULL(KatZak.Kat_RodzajZakupu,0) != 4  and  @KategoriaTowarNaglowek = 1   THEN 2 -- dla exportowych stawka 0 i flaga 4 dla uslugi
          WHEN Twr_Typ = 0 and @Knt_Export<>0 and @Knt_Export<>5  THEN 4
          ELSE
           CASE
               WHEN  @Knt_Export=5 and twr_odwrotneobciazenie = 1 and @OdwrotneObciazenie = 1 THEN 4
               WHEN  @Knt_Export=5 and twr_odwrotneobciazenie != 1 and @OdwrotneObciazenie = 1 and (@VatDlaDokWal=1 OR @TrN_Waluta IN (@WalSys,'')) THEN Twr_Flaga
               WHEN  @Knt_Export=5 and @OdwrotneObciazenie = 0  THEN 4  -- dla exportowych stawka 0 i flaga 4 dla uslugi
               ELSE    2 --dla towaru flaga 2
     END
        END
      END,
      -- TrE_Zrodlowa
      CASE
          WHEN @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and @TrN_Rodzaj <> 322000 THEN Twr_ZrodlowaZak
          ELSE Twr_Zrodlowa
      END,
      -- TrE_TwCNumer
      TwCNumer,
      -- TrE_TypNB
      CASE @Opakowania
        WHEN 0 then @TrN_TypNB -- zakładka "ogólne" z towarami
        WHEN 1 then 2 -- zakładka "kaucje" z kaucjami
        WHEN 2 then 2 -- zakładka "kaucje" - piorunek
        WHEN 3 then 2 -- zakładka "kaucje" - piorunek
       END,
      -- TrE_Cena0
      0,
      -- TrE_Rabat,
      0,
      -- TrE_CenaW,
      0,
      -- TrE_Waluta,
      '',
      -- TrE_KursNumer,
      2,
      -- TrE_KursL,
      1,
      -- TrE_KursM,
      1,
      -- TrE_CenaT,
      0,
      -- TrE_Ilosc,
      CASE
        WHEN @TrE_TypDokumentu = 309  AND b.TwrJm = Twr_IloscZamJM AND  Twr_IloscZam>0 AND b.TwrIlosc = 1 AND @IloscZPliku = 0 THEN Twr_IloscZam
        WHEN @TrE_TypDokumentu = 309  AND b.TwrJm <> Twr_IloscZamJM AND  Twr_IloscZam>0 AND b.TwrIlosc = 1 AND @IloscZPliku = 0 THEN Twr_IloscZam * TwJZ_JmPrzelicznikL / TwJZ_JmPrzelicznikM
        WHEN  b.TwrJm  = Twr_Jm THEN b.TwrIlosc
        WHEN  b.TwrJm <> Twr_Jm THEN b.TwrIlosc * TwJZ_JmPrzelicznikL / TwJZ_JmPrzelicznikM
        ELSE 0
      END,
      -- TrE_Jm
      CASE
        WHEN b.TwrJm =  Twr_Jm THEN Twr_Jm
        ELSE                        b.TwrJm
      END,
      -- TrE_JmZ
      CASE
        WHEN b.TwrJm = Twr_Jm THEN b.TwrJm
        ELSE                        Twr_Jm
      END,
      -- TrE_JmCalkowite
      Twr_JMCalkowite,
      -- TrE_JmPrzelicznikL
      CASE
        WHEN b.TwrJm =  Twr_Jm THEN 1
        ELSE TwJZ_JMPrzelicznikL
      END,
      -- TrE_JmPrzelicznikM
      CASE
        WHEN b.TwrJm =  Twr_Jm THEN 1
        ELSE TwJZ_JMPrzelicznikM
      END,
      -- TrE_IloscJM
      CASE
        WHEN @TrE_TypDokumentu = 309  AND b.TwrJm = Twr_IloscZamJM AND  Twr_IloscZam>0 AND b.TwrIlosc = 1 AND @IloscZPliku = 0 THEN Twr_IloscZam
        WHEN @TrE_TypDokumentu = 309  AND b.TwrJm <> Twr_IloscZamJM AND  Twr_IloscZam>0 AND b.TwrIlosc = 1 AND @IloscZPliku = 0 THEN Twr_IloscZam * TwJZ_JmPrzelicznikL / TwJZ_JmPrzelicznikM
        ELSE b.TwrIlosc
      END,
      -- TrE_WartoscNetto,
      0,
      -- TrE_WartoscBrutto,
      0,
      -- TrE_WartoscZakupu,
      0,
      -- TrE_KosztUslugi,
      0,
      -- TrE_Cena0WD,
      0,
      -- TrE_CenaWWD,
      0,
      -- TrE_WartoscNettoWal,
      0,
      -- TrE_WartoscBruttoWal,
      0,
      -- TrE_Prog,
      0,
      -- TrE_UpustTyp,
      0,
      -- TrE_Upust,
      0,
      -- TrE_UpustKnt,
      0,
      -- TrE_UpustKntTyp,
      0,
      -- TrE_WartoscOrg,
      NULL,
      -- TrE_WartoscWalOrg,
      NULL,
      -- TrE_WartoscZakOrg,
      NULL,
      -- TrE_IloscOrg,
      NULL,
      -- TrE_IloscJmOrg,
      NULL,
      -- TrE_CenaTOrg,
      NULL,
      -- TrE_CenaWOrg,
      NULL,
      -- TrE_CenaWWDOrg,
      NULL,
      -- TrE_Cena0WDOrg,
      NULL,
      -- TrE_StawkaVatOrg,
      NULL,
      -- TrE_FlagaVatOrg,
      NULL,
      -- TrE_ZrodlowaOrg,
      NULL,
      -- TrE_IloscMax
      0, --CDN.fn_TwrIloscMax ( Twr_TwrId, @TrN_MagId, @TrN_DataOpe ),
      -- TrE_TwrTyp
      Twr_Typ,
   --TrE_TwrKodDostawcy
      Twr_KodDostawcy,
      -- TrE_TwrEdycjaNazwy,
      Twr_EdycjaNazwy,
      -- TrE_TwrEdycjaOpisu,
      Twr_EdycjaOpisu,
      -- TrE_TwrTwcNumer,
      Twr_TwcNumer,
      --TrE_TwrProdukt
      Twr_Produkt,
      --TrE_TwrIloscZamJM
      Twr_IloscZamJM,
      --TrE_TwrNieaktywny
      Twr_NieAktywny,
      --TrE_TwrJMPrzelicznikL
      1,
      --TrE_TwrJMPrzelicznikM
      1,
      -- TrE_TwrJm
      Twr_Jm,
      -- TrE_TwrJmZ
      '',
      --TrE_TwrKosztUslugi
      Twr_KosztUslugi,
      --TrE_TwrKosztUslugiTyp
      Twr_KosztUslugiTyp,
     --TrE_TwrStawka
      CASE
         WHEN @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and @TrN_Rodzaj <> 322000 THEN Twr_StawkaZak
         WHEN @TrN_FVMarza=1 Then 0
         ELSE Twr_Stawka
      END,
      --TrE_TwrFlaga
      CASE
         WHEN @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and @TrN_Rodzaj <> 322000 THEN Twr_FlagaZak
         WHEN @TrN_FVMarza=1 Then 4
         ELSE Twr_Flaga
      END,
      --TrE_TwrZrodlowa
      CASE
          WHEN @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and @TrN_Rodzaj <> 322000 THEN Twr_ZrodlowaZak
          ELSE Twr_Zrodlowa
      END,
      --TrE_TwrStawkaZak
      --Twr_StawkaZak,
      --TrE_TwrFlagaZak
      --Twr_FlagaZak,
      --TrE_TwrZrodlowaZak
      --Twr_ZrodlowaZak,
      --TrE_TwrGidNumer
      Twr_GidNumer,
      --TrE_TwrTypMinimum
      Twr_TypMinimum,
      --TrE_Twrmincenamarza
      Twr_MinCenaMarza,
      --TrE_TwrKaucja
      Twr_Kaucja,
      --TrE_Kaucja
      CASE @Opakowania
        WHEN 0 then 0 -- zakładka "ogólne" z towarami
        WHEN 1 then 1 -- zakładka "kaucje" z kaucjami
        WHEN 2 then 1 -- zakładka "kaucje" - piorunek
        WHEN 3 then 1 -- zakładka "kaucje" - piorunek
      END,
      --TrE_IloscJMKW
      0,
      --TrE_IloscKW
      0,
      --TrE_TwrKosztKGO
      Twr_KosztKGO,
      --TrE_Atr1_DeAID
      NULL,
      --TrE_Atr1_Kod
      '',
      --TrE_Atr1_Wartosc
      '',
      --TrE_Atr2_DeAID
      NULL,
      --TrE_Atr2_Kod
      '',
      --TrE_Atr2_Wartosc
      '',
      --TrE_Atr3_DeAID
      NULL,
      --TrE_Atr3_Kod
      '',
      --TrE_Atr3_Wartosc
      '',
      --TrE_Atr4_DeAID
      NULL,
      --TrE_Atr4_Kod
      '',
      --TrE_Atr4_Wartosc
      '',
      --TrE_Atr5_DeAID
      NULL,
      --TrE_Atr5_Kod
      '',
      --TrE_Atr5_Wartosc
      '',
      -- Tre_Komunikat
      '',
      -- TrE_MagId
      b.MagId,
      --TrE_IloscAkcyza
      0,
      --TrE_AkcyzaOpal
      case when Twr_Akcyza = 0 then 0 else  Twr_AkcyzaOpal end,
      --TrE_AkcyzaStawka
      case when Twr_Akcyza = 0 then 0 else  Twr_AkcyzaStawka end,
      -- TrE_KodCN
      isnull(KCN_Kod,''),
      -- TrE_AkcyzaJMPomPrzelicznikL
      case when Twr_Akcyza = 0 then 1 else  Twr_AkcyzaJMPomPrzelicznikL end,
      -- TrE_AkcyzaJMPomPrzelicznikM
      case when Twr_Akcyza = 0 then 1 else  Twr_AkcyzaJMPomPrzelicznikM end,
   -- Tre_SJRodzajPaliwa
   Twr_SJRodzajPaliwa,
   -- Tre_SJSystemCertyfikacji
   Twr_SJSystemCertyfikacji,
   -- Tre_SJPopiol
   Twr_SJPopiol,
   -- Tre_SJCzesciLotne
   Twr_SJCzesciLotne,
   -- Tre_SJWartoscOpalowa
   Twr_SJWartoscOpalowa,
   -- Tre_SJZdolnoscSpiekania
   Twr_SJZdolnoscSpiekania,
   -- Tre_SJWymiarZiarna
   Twr_SJWymiarZiarna,
   -- Tre_SJZawartoscPodziarna
   Twr_SJZawartoscPodziarna,
   -- Tre_SJZawartoscNadziarna
   Twr_SJZawartoscNadziarna,
   -- TrE_SJZawartoscWilgoci,
   Twr_SJZawartoscWilgoci,
   -- TrE_OdwrotneObciazenie
      Twr_OdwrotneObciazenie,
   -- TrE_SplitPay
      Twr_SplitPay,
   -- Tre_KV7ID
   Twr_KV7ID,
   --Tre_CzySaCechyWymagane
   -1,
      --TrE_ZTwID INT,
      @ZestawID,
      --TrE_ZTwGlowny TINYINT,
      b.Glowny,
   --TrE_ZTwKod VARCHAR(20),
      ZTw_Kod,
      --IDSkladnika INT,
      b.IDSkladnik,
      --TypRabatu INT,
      b.TypRabatu,
      --Wartosc DECIMAL(15,4),
      b.Wartosc,
      --Waluta NVARCHAR(3)
      b.Waluta,
      --Ilosc      DECIMAL(15,4),
      b.twrilosc,
      --Jm         NVARCHAR(20)
      b.twrjm,
      Twr_PobieranieSkladnikowFSUslugaZlozona,
   CASE  WHEN @TrN_TypDokumentu = 305 then 0  else Twr_CenaZCzteremaMiejscami end,
      -- TrE_WartoscNettoWal6,
      0,
      -- TrE_WartoscBruttoWal6,
      0
    FROM cdn.Towary JOIN @Zestawy b ON b.TwrId = Twr_TwrId
    LEFT OUTER join cdn.TwrJMZ on TwJZ_TwrId = Twr_TwrId AND TwJZ_JM = b.TwrJm AND TwJZ_eSklepID = 0
    LEFT OUTER join cdn.KodyCN on Twr_KCNId = KCN_KCNId
 LEFT OUTER join cdn.ZestawyTwr on @ZestawID = ZTw_ZTwId
 LEFT OUTER join cdn.Kategorie Kat on Twr_KatId = Kat.Kat_KatId
    LEFT OUTER join cdn.Kategorie KatZak on Twr_KatZakId = KatZak.Kat_KatId
    order by IDSkladnik
  -- Tworzenie elementów dla zestawu towarów
 DECLARE E CURSOR LOCAL FAST_FORWARD FOR
    SELECT TrE_Lp, TrE_TwrId, TrE_Stawka, TrE_IloscJM, TrE_Ilosc, Twr_Typ, Twr_KosztUslugiTyp, Twr_KosztUslugi, TrE_TwcNumer, TrE_TwrTyp, TrE_JMPrzelicznikL, TrE_JMPrzelicznikM, TrE_CenaWWD, TrE_TypNB, TrE_TwrStawka,TrE_TwrKaucja,TrE_TwrKosztKGO,
     TrE_ZTwID ,      TrE_ZTwGlowny,      IDSkladnika ,      TypRabatu ,       Wartosc ,      Waluta, Ilosc,Jm, case when Twr_CenaZCzteremaMiejscami = 1 and @TrN_TypDokumentu != 305 then 4 else 2 end
      FROM @TraElem
        JOIN cdn.Towary ON Twr_TwrId = TrE_TwrId
    ORDER BY TrE_Lp
    OPEN E
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM E INTO @TrE_Lp, @TrE_TwrId, @TrE_Stawka, @TrE_IloscJM, @TrE_Ilosc, @Twr_Typ, @Twr_KosztUslugiTyp, @Twr_KosztUslugi,@TwC_TwCNumer ,@Twr_Typ, @Tre_JMPrzelicznikL, @Tre_JMPrzelicznikM, @CWWD, @TrE_TypNB, @Twr_Stawka,@TrE_TwrKaucja,@TrE_WartoscKGO,
         @ZTwID, @ZTwGlowny,      @IDSkladnika,      @TypRabatuZestaw,       @WartoscZestaw ,      @WalutaZestaw,  @IloscZestaw ,      @JMZestaw ,@ZaokraglajDo
        IF @@FETCH_STATUS <> 0 BREAK
          -- parametry ceny
          SELECT TOP 1
            @Brak        = Brak,
            @TwC_Typ     = TwC_Typ,
            @TwC_Wartosc = TwC_Wartosc,
            @TwC_Waluta  = TwC_Waluta,
            @TrE_KursNumer = KursNumer,
            @TrE_KursL   = CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END,
            @TrE_KursM   = CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END
          FROM cdn.TwrCeny
            JOIN cdn.Towary ON Twr_TwrId = TwC_TwrId
              AND TwC_TwrId = @TrE_TwrId
              AND TwC_TwCNumer = @TwC_TwCNumer
            LEFT OUTER JOIN #Notowania ON Waluta = TwC_Waluta
          SET @Komunikat=''
          IF @Brak = 1
            BEGIN
              IF @Opakowania = 3
                SET @Komunikat = '##OPT25003##%%Opis%%=' + @TwC_Waluta+ '##' --'Błąd ustalania kursu waluty ' + @TwC_Waluta +' dla ceny towaru.'
              ELSE
               SET @Komunikat = @TwC_Waluta
            END
          -- określenie rabatu (nie dla wewnetrznych i zakupu)
          IF @PominRabaty = 0 AND @TrE_TypDokumentu NOT IN (310, 303, 304, 312, 301, 307, 309, 311, 313) and @ZestawID = 0
            BEGIN
              SELECT TOP 1
                @TypRabatu  = TypRabatu,
                @RabatCena  = RabatCena,
                @TwC_Typ    = CASE WHEN TypRabatu = 1 THEN TypCenyNB ELSE @TwC_Typ END,
                @TwC_Waluta = CASE WHEN TypRabatu = 1 THEN Waluta ELSE @TwC_Waluta END
              FROM CDN.fnObliczRabat ( @TrN_PodmiotTyp, @TrN_PodId, @TrE_TwrId )
              IF @TypRabatu = 0
                -- rabat procentowy
                SELECT
                  @TrE_Cena0Podst = @TwC_Wartosc,
                  @TrE_Rabat = @RabatCena,
                  @TrE_TwCNumer = @TwC_TwCNumer
               ELSE
                 BEGIN
                    -- rabat "stała cena"
                    SELECT
                      @TrE_Cena0Podst = @RabatCena,
                      @TrE_Rabat = 0,
                      @TrE_TwCNumer = -1
                    -- jeśli waluta inna niż systemowa, to pobierz kurs
                    IF @TwC_Waluta <> @WalSys AND ISNULL(@TwC_Waluta,'') <> ''
                      SELECT
                        @TrE_KursL = KursL,
                        @TrE_KursM = KursM,
                        @TrE_KursNumer = KursNumer
                      FROM #Notowania  WHERE Waluta = @TwC_Waluta
                    -- jeśli jest systemowa, to wpisz symbol waluty systemowej i kurs 1:1
                    ELSE
                      SELECT
                        @TwC_Waluta = @WalSys,
                        @TrE_KursL  = 1,
                        @TrE_KursM  = 1
                 END
            END
          ELSE
            SELECT
              @TrE_Cena0Podst    = @TwC_Wartosc,
              @TrE_Rabat    = 0,
              @TrE_TwCNumer = @TwC_TwCNumer
              SET @TrE_Cena0 = @TrE_Cena0Podst
              SET @TrE_Cena0WD = CASE
                               WHEN @TwC_Waluta = @TrN_Waluta THEN @TrE_Cena0
                               ELSE round(@TrE_Cena0 * ( @TrE_KursL / @TrE_KursM ) / ( @TrN_KursL / @TrN_KursM ),@ZaokraglajDo)
                          END
        if @ZestawID > 0
          Begin
          if @ZTwGlowny = 1
      BEGIN
      if @TypRabatuZestaw = 0
     SELECT
                  @TrE_Cena0Podst = round(@TwC_Wartosc * ( 100 - @WartoscZestaw ) / 100,@ZaokraglajDo)
               ELSE
                    -- rabat "stała cena"
                 SELECT
                  @TrE_Cena0Podst = @WartoscZestaw,@TwC_Typ = 1,@TwC_Waluta = @WalutaZestaw
               -- jeśli waluta inna niż systemowa, to pobierz kurs
               IF @TwC_Waluta <> @WalSys AND ISNULL(@TwC_Waluta,'') <> ''
               BEGIN
             SELECT
         @Brak      = Brak,
                        @TrE_KursL = KursL,
                        @TrE_KursM = KursM,
                        @TrE_KursNumer = KursNumer
                      FROM #Notowania  WHERE Waluta = @TwC_Waluta
       IF @Brak = 1
                      begin
       SET @Komunikat = '##OPT25003##%%Opis%%=' + @TwC_Waluta+ '##'--'Błąd ustalania kursu waluty ' + @TwC_Waluta +' dla ceny towaru.'
       GOTO KOMUNIKAT
       end
               END
                    -- jeśli jest systemowa, to wpisz symbol waluty systemowej i kurs 1:1
                ELSE
                      SELECT
                        @TwC_Waluta = @WalSys,
                        @TrE_KursL  = 1,
                        @TrE_KursM  = 1
               SET @TrE_Cena0 = @TrE_Cena0Podst
               SET @TrE_Cena0WD = round(CASE
                                  WHEN @TwC_Waluta = @TrN_Waluta THEN @TrE_Cena0
                                  ELSE @TrE_Cena0 * ( @TrE_KursL / @TrE_KursM ) / ( @TrN_KursL / @TrN_KursM )
                                  END,@ZaokraglajDo)
               SET @WartoscTowaruGl =    @TrE_Cena0Podst;
               SET @WalutaTowaruGl = @TwC_Waluta
               SET @TypNBTowaruGl =   @TwC_Typ
      END
      ELSE
      BEGIN
    if @TypRabatuZestaw = 0
     SELECT
                  @TrE_Cena0Podst = round(@TwC_Wartosc * ( 100 - @WartoscZestaw ) / 100 ,@ZaokraglajDo)
                if @TypRabatuZestaw = 1 or @TypRabatuZestaw = 2
                    -- rabat "stała cena"
                 SELECT
                  @TrE_Cena0Podst = round(@WartoscZestaw* ( @Tre_JmPrzelicznikM / @Tre_JmPrzelicznikL ),@ZaokraglajDo),
      @TwC_Typ = 1,
      @TwC_Waluta = @WalutaZestaw
                if @TypRabatuZestaw = 3
                begin
                   select @TrE_Cena0Podst = round((@WartoscTowaruGl * ( @WartoscZestaw ) / 100)* ( @Tre_JmPrzelicznikM / @Tre_JmPrzelicznikL ),@ZaokraglajDo)
                   set @TwC_Typ = @TypNBTowaruGl
                end
               -- jeśli waluta inna niż systemowa, to pobierz kurs
      IF @TypRabatuZestaw = 3 and @WalutaTowaruGl <> @WalSys AND ISNULL(@WalutaTowaruGl,'') <> ''
               begin
               select @TwC_Waluta = @WalutaTowaruGl
                      SELECT
                        @TrE_KursL = KursL,
                        @TrE_KursM = KursM,
                        @TrE_KursNumer = KursNumer
                      FROM #Notowania  WHERE Waluta = @TwC_Waluta
                      IF @Brak = 1
                      begin
       SET @Komunikat = '##OPT25003##%%Opis%%=' + @TwC_Waluta+ '##'--'Błąd ustalania kursu waluty ' + @TwC_Waluta +' dla ceny towaru.'
       GOTO KOMUNIKAT
       end
                end
                else
               IF @TwC_Waluta <> @WalSys AND ISNULL(@TwC_Waluta,'') <> ''
               BEGIN
             SELECT
         @Brak      = Brak,
                        @TrE_KursL = KursL,
                        @TrE_KursM = KursM,
                        @TrE_KursNumer = KursNumer
                      FROM #Notowania  WHERE Waluta = @TwC_Waluta
       IF @Brak = 1
                      begin
       SET @Komunikat = '##OPT25003##%%Opis%%=' + @TwC_Waluta+ '##'--'Błąd ustalania kursu waluty ' + @TwC_Waluta +' dla ceny towaru.'
       GOTO KOMUNIKAT
       end
               END
                    -- jeśli jest systemowa, to wpisz symbol waluty systemowej i kurs 1:1
               ELSE
                      SELECT
                        @TwC_Waluta = @WalSys,
                        @TrE_KursL  = 1,
                        @TrE_KursM  = 1
                SET @TrE_Cena0 = @TrE_Cena0Podst
              SET @TrE_Cena0WD = CASE
                               WHEN @TwC_Waluta = @TrN_Waluta THEN @TrE_Cena0
                               ELSE round(@TrE_Cena0 * ( @TrE_KursL / @TrE_KursM ) / ( @TrN_KursL / @TrN_KursM ),@ZaokraglajDo)
                          END
   END
          End
         -- typ dokumentu i ceny
         IF @TrE_TypNB <> @TwC_Typ
            -- typ dokumentu netto, typ ceny brutto - trzeba zamienić bazową cenę brutto na netto
            IF @TrE_TypNB = 1
         BEGIN
                SET @TrE_Cena0WD = round(CASE
                               WHEN @TwC_Waluta = @TrN_Waluta THEN @TrE_Cena0Podst -  ( @TrE_Cena0Podst * ( @Twr_Stawka / ( 100 + @Twr_Stawka ) ) )
                               ELSE (@TrE_Cena0Podst  -  ( @TrE_Cena0Podst * ( @Twr_Stawka / ( 100 + @Twr_Stawka ))))   * ( @TrE_KursL / @TrE_KursM ) / ( @TrN_KursL / @TrN_KursM )
                             END,@ZaokraglajDo)
                    SET @TrE_Cena0Podst = round(@TrE_Cena0Podst -  ( @TrE_Cena0Podst * ( @Twr_Stawka / ( 100 + @Twr_Stawka ) ) ),@ZaokraglajDo)
                    SET @TrE_Cena0 = @TrE_Cena0Podst
                END
            -- typ dokumentu brutto, typ ceny netto - trzeba zamienić bazową cenę netto na brutto
            ELSE
              BEGIN
              SET @TrE_Cena0WD = round(CASE
                               WHEN @TwC_Waluta = @TrN_Waluta THEN @TrE_Cena0Podst  +  ( @TrE_Cena0Podst * ( @Twr_Stawka / 100 ) )
                              ELSE (@TrE_Cena0Podst  +  ( @TrE_Cena0Podst * ( @Twr_Stawka / 100 )))   * ( @TrE_KursL / @TrE_KursM ) / ( @TrN_KursL / @TrN_KursM )
                             END,@ZaokraglajDo)
                 SET @TrE_Cena0Podst = round(@TrE_Cena0Podst  +  ( @TrE_Cena0Podst * ( @Twr_Stawka / 100 ) ),@ZaokraglajDo)
                 SET @TrE_Cena0 = @TrE_Cena0Podst
              END
          IF @TrE_Cena0 = 0 SET @TrE_Rabat = 0
          -- ceny
          SET @TrE_CenaWWD = round(CASE
                               WHEN @TrE_Rabat = 0 THEN @TrE_Cena0WD * ( @Tre_JmPrzelicznikL / @Tre_JmPrzelicznikM )
                               ELSE ( @TrE_Cena0WD * ( 100 - @TrE_Rabat ) / 100 ) * ( @Tre_JmPrzelicznikL / @Tre_JmPrzelicznikM ) --rtrab
                              END,@ZaokraglajDo)
          if @KGO = 1 and   @Twr_Typ = 1 and @TrE_TwrKaucja = 0 and @TrE_WartoscKGO > 0 and @TrE_Cena0WD > @TrE_WartoscKGO
          BEGIN
            if @TrE_TypNB = 1
        SET @TrE_CenaWWD = round(CASE
                                 WHEN @TrE_Rabat = 0 THEN @TrE_Cena0WD * ( @Tre_JmPrzelicznikL / @Tre_JmPrzelicznikM )
                                 ELSE ( (@TrE_Cena0WD-@TrE_WartoscKGO)  * ( 100 - @TrE_Rabat ) / 100 ) * ( @Tre_JmPrzelicznikL / @Tre_JmPrzelicznikM ) +@TrE_WartoscKGO--rtrab
                                END,@ZaokraglajDo)
            else
              SET @TrE_CenaWWD = round(CASE
                                 WHEN @TrE_Rabat = 0 THEN @TrE_Cena0WD * ( @Tre_JmPrzelicznikL / @Tre_JmPrzelicznikM )
                                 ELSE ( (@TrE_Cena0WD-(@TrE_WartoscKGO  +  ( @TrE_WartoscKGO * ( @Twr_Stawka / 100 ))))  * ( 100 - @TrE_Rabat ) / 100 ) * ( @Tre_JmPrzelicznikL / @Tre_JmPrzelicznikM ) +(@TrE_WartoscKGO  +  ( @TrE_WartoscKGO * ( @Twr_Stawka / 100 )))--rtrab
                                END,@ZaokraglajDo)
          END
          SET @TrE_CenaW   = round(CASE
                               WHEN @TrE_Rabat = 0 THEN
                                 CASE
                                   WHEN @TwC_Waluta = @TrN_Waluta THEN   @TrE_Cena0Podst   * ( @Tre_JmPrzelicznikL / @Tre_JmPrzelicznikM )
                                   ELSE @TrE_CenaWWD * ( @TrN_KursL / @TrN_KursM ) / ( @TrE_KursL / @TrE_KursM )
                                 END
                               ELSE
                                 CASE
                                   WHEN @TwC_Waluta = @TrN_Waluta THEN   @TrE_CenaWWD
                                   ELSE @TrE_CenaWWD * ( @TrN_KursL / @TrN_KursM ) / ( @TrE_KursL / @TrE_KursM )
                                 END
                              END,@ZaokraglajDo)
          SET @TrE_CenaT   = round(CASE
                               WHEN @TrN_KursL = @TrN_KursM  THEN @TrE_CenaWWD
                               ELSE @TrE_CenaWWD * ( @TrN_KursL / @TrN_KursM )
                             END,@ZaokraglajDo)
         IF @TrN_KursL = @TrN_KursM
           SET @TrE_CenaT =
                   ROUND((
                           CASE
                             WHEN @TrE_Rabat = 0 THEN  @TrE_Cena0Podst   * ( @Tre_JmPrzelicznikL / @Tre_JmPrzelicznikM )
                             ELSE
                               CASE
                                 WHEN @TwC_Waluta = @TrN_Waluta THEN   @TrE_CenaWWD
                                 ELSE @TrE_CenaWWD * ( @TrN_KursL / @TrN_KursM ) / ( @TrE_KursL / @TrE_KursM ) * ( @Tre_JmPrzelicznikL / @Tre_JmPrzelicznikM )
                               END
                             END
                          ) * ( @TrE_KursL / @TrE_KursM ),@ZaokraglajDo)
         -- przekazano CenaWWD - tylko w ofertowaniu
         IF @CWWD > 0 OR @CenaZPliku = 1
           BEGIN
             SET @TrE_CenaWWD = @CWWD
             SET @TrE_Rabat   = 0
             SET @TrE_Cena0WD = ROUND ( @TrE_CenaWWD * @TrE_JmPrzelicznikM / @TrE_JmPrzelicznikL, @ZaokraglajDo )
             SET @TrE_CenaW   = ROUND ( @TrE_CenaWWD * ( @TrN_KursL / @TrN_KursM ) / ( @TrE_KursL / @TrE_KursM ) , @ZaokraglajDo )
             SET @TrE_Cena0   = ROUND ( @TrE_CenaW * @TrE_JmPrzelicznikM / @TrE_JmPrzelicznikL , @ZaokraglajDo )
             SET @TrE_CenaT   = ROUND ( @TrE_CenaWWD * @TrN_KursL / @TrN_KursM,@ZaokraglajDo)
           END
          -- wartości
          -- od netto
          IF @TrE_TypNB = 1
            SELECT
              @TrE_WartoscNettoWal  = @TrE_IloscJM * @TrE_CenaWWD,
              @TrE_WartoscBruttoWal = ROUND(@TrE_WartoscNettoWal * (100 + @TrE_Stawka )/100, 2),
              @TrE_WartoscNettoWal6  = @TrE_IloscJM * @TrE_CenaWWD,
              @TrE_WartoscBruttoWal6 = ROUND(@TrE_WartoscNettoWal6 * (100 + @TrE_Stawka )/100, 6),
              @TrE_WartoscNetto  =
              case
          when @PlatElemSys = 1 then  @TrE_IloscJM * @TrE_CenaT
          else  ROUND(@TrE_WartoscNettoWal * @TrN_KursL / @TrN_KursM , 2)
           end ,
              @TrE_WartoscBrutto    = ROUND(@TrE_WartoscNetto  + round(@TrE_WartoscNettoWal *@TrE_Stawka /100,2)* @TrN_KursL / @TrN_KursM, 2)--ROUND(@TrE_WartoscNetto * (100 + @TrE_Stawka )/100, 2)
          -- od brutto
          IF @TrE_TypNB = 2
            SELECT
              @TrE_WartoscBruttoWal = @TrE_IloscJM * @TrE_CenaWWD,
              @TrE_WartoscNettoWal  = @TrE_WartoscBruttoWal - ROUND ( @TrE_WartoscBruttoWal *  @TrE_Stawka / (100 + @TrE_Stawka) , 2 ),
              @TrE_WartoscBruttoWal6 = @TrE_IloscJM * @TrE_CenaWWD,
              @TrE_WartoscNettoWal6  = @TrE_WartoscBruttoWal6 - ROUND ( @TrE_WartoscBruttoWal6 *  @TrE_Stawka / (100 + @TrE_Stawka) , 6 ),
              @TrE_WartoscBrutto =
              case
          when @PlatElemSys = 1 then @TrE_IloscJM * @TrE_CenaT
          else  ROUND(@TrE_WartoscNettoWal * @TrN_KursL / @TrN_KursM , 2) + ROUND((@TrE_WartoscBruttoWal-@TrE_WartoscNettoWal)* @TrN_KursL / @TrN_KursM , 2)--ROUND(@TrE_WartoscBruttoWal * @TrN_KursL / @TrN_KursM , 2)
           end,
              @TrE_WartoscNetto     = @TrE_WartoscBrutto - ROUND ( @TrE_WartoscBrutto *  @TrE_Stawka / (100 + @TrE_Stawka) , 2 )
          -- koszt usługi
          IF @Twr_Typ = 0
            BEGIN
              -- kwotowy
              IF @Twr_KosztUslugiTyp = 1
                SET @TrE_KosztUslugi = @Twr_KosztUslugi * @TrE_Ilosc
              -- procentowy
              ELSE
                SET @TrE_KosztUslugi = ROUND( ( (@Twr_KosztUslugi/100) * @TrE_WartoscNetto), 2 )
             END
           ELSE
            SET @TrE_KosztUslugi = 0
          UPDATE @TraElem SET
           TrE_TwCNumer          = @TrE_TwCNumer,
            TrE_Cena0            = ISNULL(@TrE_Cena0,0),
            TrE_Rabat            = ISNULL(@TrE_Rabat,0),
            TrE_CenaW            = ISNULL(@TrE_CenaW,0),
            TrE_Waluta           = ISNULL(@TwC_Waluta,@WalSys),
            TrE_KursL            = ISNULL(@TrE_KursL,1),
            TrE_KursM            = ISNULL(@TrE_KursM,1),
            TrE_KursNumer        = ISNULL(@TrE_KursNumer,2),
            TrE_CenaT            = ISNULL(@TrE_CenaT,0),
            TrE_WartoscNetto     = ISNULL(@TrE_WartoscNetto,0),
            TrE_WartoscBrutto    = ISNULL(@TrE_WartoscBrutto,0),
            TrE_KosztUslugi      = ISNULL(@TrE_KosztUslugi,0),
            TrE_Cena0WD          = ISNULL(@TrE_Cena0WD,0),
            TrE_CenaWWD          = ISNULL(@TrE_CenaWWD,0),
            TrE_WartoscNettoWal  = ISNULL(@TrE_WartoscNettoWal,0),
            TrE_WartoscBruttoWal = ISNULL(@TrE_WartoscBruttoWal,0),
            TrE_WartoscNettoWal6  = ISNULL(@TrE_WartoscNettoWal6,0),
            TrE_WartoscBruttoWal6 = ISNULL(@TrE_WartoscBruttoWal6,0),
            TrE_IloscAkcyza      = TrE_Ilosc * Tre_AkcyzaJMPomPrzelicznikM/Tre_AkcyzaJMPomPrzelicznikL,
            TrE_Komunikat        = @Komunikat
          WHERE TrE_Lp = @TrE_Lp
  -- ustawienie atrybutow
          /*IF @TrE_TypDokumentu NOT IN (318)
          BEGIN
            CREATE TABLE #AtrybutyElem (TwrID INT  ,TwA_DeAID1 INT,DeA_Kod1 NVARCHAR(20), TwA_Wartosctxt1 NVARCHAR(100),TwA_DeAID2 INT,DeA_Kod2 NVARCHAR(20), TwA_Wartosctxt2 NVARCHAR(100),TwA_DeAID3 INT,DeA_Kod3 NVARCHAR(20), TwA_Wartosctxt3 NVARCHAR(100),TwA_DeAID4 INT,DeA_Kod4 NVARCHAR(20), TwA_Wartosctxt4 NVARCHAR(100),TwA_DeAID5 INT,DeA_Kod5 NVARCHAR(20), TwA_Wartosctxt5 NVARCHAR(100))
            INSERT INTO  #AtrybutyElem exec CDN.PobierzAtrybuty @TrN_PodmiotTyp, @Trn_PodId, @TrE_TwrId
            UPDATE @TraElem SET
              TrE_Atr1_DeAID =  TwA_DeAID1         ,
              TrE_Atr1_Kod =    ISNULL(DeA_Kod1,'')         ,
              TrE_Atr1_Wartosc = ISNULL(TwA_Wartosctxt1,'')     ,
              TrE_Atr2_DeAID =  TwA_DeAID2         ,
              TrE_Atr2_Kod =    ISNULL(DeA_Kod2,'')         ,
              TrE_Atr2_Wartosc = ISNULL(TwA_Wartosctxt2,'')        ,
              TrE_Atr3_DeAID =  TwA_DeAID3         ,
              TrE_Atr3_Kod =    ISNULL(DeA_Kod3,'')         ,
              TrE_Atr3_Wartosc = ISNULL(TwA_Wartosctxt3,'')        ,
              TrE_Atr4_DeAID =  TwA_DeAID4         ,
              TrE_Atr4_Kod =    ISNULL(DeA_Kod4,'')         ,
              TrE_Atr4_Wartosc = ISNULL(TwA_Wartosctxt4,'')        ,
              TrE_Atr5_DeAID =  TwA_DeAID5         ,
              TrE_Atr5_Kod =    ISNULL(DeA_Kod5,'')         ,
              TrE_Atr5_Wartosc = ISNULL(TwA_Wartosctxt5,'')
            FROM  @TraElem
            JOIN #AtrybutyElem on TrE_TwrID=TwrID
            drop table #AtrybutyElem
          END*/
          IF @TrE_TypDokumentu =311
           BEGIN
            UPDATE @TraElem SET Tre_IloscKW = ISNULL(I.TwI_Ilosc,0),Tre_IloscJMKW = ISNULL(I.TwI_Ilosc*TrE_JMPrzelicznikM/TrE_JMPrzelicznikL,0)
             FROM @TraElem
               LEFT OUTER JOIN cdn.TwrIlosci I ON TrE_TwrId = I.TwI_TwrId AND I.TwI_MagId = @TrN_MagId
               AND I.TwI_Data = (SELECT TOP 1 H.TwI_Data FROM CDN.TwrIlosci H WHERE H.TwI_TwrId = Tre_TwrId AND H.TwI_MagId = @TrN_MagId
               AND H.TwI_Data <=@TrN_DataDok ORDER BY H.TwI_Data DESC )
           END
      END
    CLOSE E
  DEALLOCATE E
  -- kill kesza z notowaniami
  DROP TABLE #Notowania
  -- finalny select lub dodanie elementów do bazy
  IF ISNULL(@TrN_TrNId,0) > 0 AND @DodajElementyDoBazy = 1
    INSERT INTO cdn.TraElem ( TrE_TrNId, TrE_Lp, TrE_LpPow, TrE_TypDokumentu, TrE_Aktywny, TrE_DataDok, TrE_DataOpe, TrE_PodmiotTyp, TrE_PodId, TrE_KatId, TrE_TwrId, TrE_TwrNazwa, TrE_TwrEAN, TrE_TwrNumerKat, TrE_TwrKod, TrE_TwrOpis, TrE_TwrSWW, TrE_Stawka, TrE_Flaga, TrE_Zrodlowa, TrE_TwCNumer, TrE_TypNB, TrE_Cena0, TrE_Rabat, TrE_CenaW, TrE_Waluta, TrE_KursNumer, TrE_KursL, TrE_KursM, TrE_CenaT, TrE_Ilosc, TrE_Jm, TrE_JmZ, TrE_JmCalkowite, TrE_JMPrzelicznikL, TrE_JMPrzelicznikM, TrE_IloscJM,
    TrE_WartoscNetto, TrE_WartoscBrutto, TrE_KosztUslugi, TrE_Cena0WD, TrE_CenaWWD, TrE_WartoscNettoWal, TrE_WartoscBruttoWal, TrE_Prog, TrE_UpustTyp, TrE_Upust, TrE_UpustKnt, TrE_UpustKntTyp, TrE_Kaucja,Tre_IloscJMKW,TrE_IloscKW, TrE_Atr1_DeAId, TrE_Atr1_Kod, TrE_Atr1_Wartosc, TrE_Atr2_DeAId, TrE_Atr2_Kod, TrE_Atr2_Wartosc, TrE_Atr3_DeAId, TrE_Atr3_Kod, TrE_Atr3_Wartosc, TrE_Atr4_DeAId, TrE_Atr4_Kod, TrE_Atr4_Wartosc, TrE_Atr5_DeAId, TrE_Atr5_Kod, TrE_Atr5_Wartosc,TrE_WartoscZakupuWylicz ,TrE_WyborDostaw ,TrE_MagId,TrE_TwrTyp ,TrE_TwrKodDostawcy,Tre_CenaZCzteremaMiejscami,Tre_UstawAtrSQL,Tre_UstawAtrSQLDokTyp)
        SELECT               @TrN_TrNId, TrE_Lp, TrE_LpPow, TrE_TypDokumentu, TrE_Aktywny, TrE_DataDok, TrE_DataOpe, TrE_PodmiotTyp, TrE_PodId, TrE_KatId, TrE_TwrId, TrE_TwrNazwa, TrE_TwrEAN, TrE_TwrNumerKat, TrE_TwrKod, TrE_TwrOpis, TrE_TwrSWW, TrE_Stawka, TrE_Flaga, TrE_Zrodlowa, TrE_TwCNumer, TrE_TypNB, TrE_Cena0, TrE_Rabat, TrE_CenaW, TrE_Waluta, TrE_KursNumer, TrE_KursL, TrE_KursM, TrE_CenaT, TrE_Ilosc, TrE_Jm, TrE_JmZ, TrE_JmCalkowite, TrE_JMPrzelicznikL, TrE_JMPrzelicznikM, TrE_IloscJM,
        TrE_WartoscNetto, TrE_WartoscBrutto, TrE_KosztUslugi, TrE_Cena0WD, TrE_CenaWWD, TrE_WartoscNettoWal, TrE_WartoscBruttoWal, TrE_Prog, TrE_UpustTyp, TrE_Upust, TrE_UpustKnt, TrE_UpustKntTyp, TrE_Kaucja,Tre_IloscJMKW,TrE_IloscKW, TrE_Atr1_DeAId, TrE_Atr1_Kod, TrE_Atr1_Wartosc, TrE_Atr2_DeAId, TrE_Atr2_Kod, TrE_Atr2_Wartosc, TrE_Atr3_DeAId, TrE_Atr3_Kod, TrE_Atr3_Wartosc, TrE_Atr4_DeAId, TrE_Atr4_Kod, TrE_Atr4_Wartosc, TrE_Atr5_DeAId, TrE_Atr5_Kod, TrE_Atr5_Wartosc,0 ,0 , TrE_MagId,TrE_TwrTyp ,TrE_TwrKodDostawcy,Tre_CenaZCzteremaMiejscami,0,1
          FROM @TraElem ORDER BY TrE_Lp
  ELSE
    SELECT * FROM @TraElem ORDER BY TrE_Lp
  -- Wyswietlenie komunikatu i rollback całej transakcji
  KOMUNIKAT:
  IF @Komunikat <> ''
    BEGIN
      RAISERROR( @Komunikat, 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF
