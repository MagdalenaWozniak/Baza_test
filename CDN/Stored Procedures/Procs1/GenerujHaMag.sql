CREATE  PROCEDURE CDN.GenerujHaMag
  @TrN_TrNId_Zrd_List TEXT,           -- lista TrN_TrNId dokumentów źródłowych (paragonów, faktur), do których ma być wykonany dokument magazynowy
  @TrN_OpeZalId       INT,            -- Opertor zalogowany do programu, który wykonuje operację przekształcenia
  @TrN_StaZalId       INT,            -- Sanowisko, z którego jest wykonywana operacja przekształcenia
  @ServerCfgString    NVARCHAR(350),   -- nazwa serwera z bazą konfiguracyjną
  @BazaCfgString      NVARCHAR(350),   -- nazwa bazy konfiguracyjnej
  @DataToday          NVARCHAR(100),   -- Data Today z programu (może być inna niż z serwera)
  @Kontekst           INT,             -- Kontekst wywołania:
                                         -- 0 - WZ/PZ/WKA/PKA z formularza,
                                         -- 1 - WZ/PZ/WKA/PKA z listy,
                                         -- 2 - WKA/PKA jako nowy dokument z listy
                                         -- 4 - AI - arkuz wypełniony ilościami na magazynie głównym
                                         -- 5 - PWAI/RWAI do zaznaczonych arkuszy inwentaryzacyjnych
                                         -- 6 - PW/RW do pierwotnych
                                         -- 7 - WZ do PF
           -- 8 - WZ do RO
 @MagazynId          INT,
 @GrupaTowarowa      INT,
 @BezAtrybutow       INT,
 @Seria              NVARCHAR(20)=''
AS
SET NOCOUNT ON
 declare @OpeZalKod varchar(20), @OpeZalNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @TrN_OpeZalId, @OpeZalKod OUT, @OpeZalNazwisko OUT
  DECLARE
    @TrN_Bufor_Zrd          INT,        -- Bufor
    @TrN_TrNId_Zrd          INT,        -- Pojedyncze TrN_TrNId dokumentu do przekonwertowania, gdy jest tylko jeden dokument źródłowy
    @TrN_TrNId_Doc          INT,        -- Pojedyncze TrN_TrNId dokumentu wynikowego
    @TrN_MagZrdId_Zrd       INT,        -- Magazyn dokumentu źródłowego
    @TrN_MagZrdId_Doc       INT,        -- Magazyn dokumentu docelowego
    @TrN_Rodzaj_Zrd         INT,        -- TrN_Rodzaj dokumentu źródłowego
    @TrN_Rodzaj_Doc         INT,        -- TrN_Rodzaj dokumentu docelowego
    @TrN_OpeZalId_Doc       INT,        -- Id Operatora z dokumentu docelowego
    @TrN_StaZalId_Doc       INT,        -- Id Stanowiska dokumentu docelowego
    @TrN_TrNId_WZzPA        INT,        -- Zmienna do sprawdzenia, czy jest WZ spięta z PA, gdy zapisujemy FA z PA
    @TrN_TrNId_WKAzPA       INT,        -- Zmienna do sprawdzenia, czy jest WKA spięta z PA, gdy zapisujemy FA z PA
    @TrN_TrNId_Zrd_PA       INT,
    -- daty today z czasem i bez czasu
    @DataTodayNoTime        DATETIME,
    @DataTodayWithTime      DATETIME,
    -- daty na dokumencie źródłowym
    @TrN_DataWys_Zrd        DATETIME,
    @TrN_DataDok_Zrd        DATETIME,
    @TrN_DataOpe_Zrd        DATETIME,
    -- daty na dokumencie docelowym
    @TrN_DataWys_Doc        DATETIME,
    @TrN_DataDok_Doc        DATETIME,
    @TrN_DataOpe_Doc        DATETIME,
    -- pomocnicze
    @TrN_DataOpe_BZM        DATETIME,
    @PWRW                   INT,
    @Oddzial                INT,
    -- dla rabatu nagłówka
    @TrN_RazemBruttoWalPrzed DECIMAL (20,2),
    @TrN_RazemBruttoWalPo    DECIMAL (20,2),
    -- dla atrybutow
    @TrE_TwrID               INT,
    -- komunikat
    @Komunikat              NVARCHAR(350),
    @sqltxt                 NVARCHAR (1000),
    @TmpSrvName             SYSNAME,
    @TrN_DataOpe_Doc_Chr    NVARCHAR(10),
 @NumerPelny              NVarchar(30),
 @TypDokumentu    int
  -- tabele tymczasowe
  CREATE TABLE #Notowania   ( Systemowa TINYINT, Waluta NVARCHAR(3), KursNumer INT, KursL DECIMAL(15,4), KursM DECIMAL(5,0), Brak TINYINT )
  DECLARE @Magazyny TABLE ( Idm INT IDENTITY(1,1) ,MagId INT PRIMARY KEY (Idm, MagId) )
  DECLARE @AI TABLE ( Lp INT IDENTITY (1,1), TwrId INT, Waluta NVARCHAR(3), KursNumer INT, KursL DECIMAL(15,4), KursM DECIMAL(5,0), CenaWal DECIMAL(17,4), CenaSys DECIMAL(17,4),Brak INT PRIMARY KEY (Lp,TwrId))
  -- tabela tymczasowa z Lp dla celów tworzenia AI oraz PWAI/RWAI
  DECLARE @Lp TABLE ( Lp_Lp INT IDENTITY ( 1, 1 ), Lp_TwrId INT )
  -- ustalenie dat z czasem do TimeStampa i bez daty do dat dokumentów
  SET @DataTodayWithTime = CONVERT( DATETIME, GETDATE(), 120 )
  SET @DataTodayNoTime   = CONVERT( DATETIME, SUBSTRING( @DataToday, 1, 10 ), 120 )
  SET @Oddzial = ( SELECT ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1470 )
  -- tylko jedno TrN_TrNId dokumentu źródłowego
  IF ( SELECT COUNT(*) FROM CDN.Text2TableInt( @TrN_TrNId_Zrd_List ) ) = 1 or  @Kontekst = 8
    SELECT TOP 1  @TrN_TrNId_Zrd = NextIdINT FROM CDN.Text2TableInt( @TrN_TrNId_Zrd_List )
  -- Sprawdzenie, czy to jest FA z PA
  SELECT
    @TrN_TrNId_Zrd_PA = PA.TrN_TrNId
  FROM cdn.TraNag PA
  JOIN cdn.TraNagRelacje REL on PA.TrN_TrNId = REL.TrR_TrNId
  WHERE REL.TrR_FAId = @TrN_TrNId_Zrd AND REL.TrR_FATYP = 302 AND REL.TrR_TrNTYP = 305
  DECLARE @TrNIDPA TABLE ( TrNId INT)
  insert into @TrNIDPA select PA.TrN_TrNId FROM cdn.TraNag PA
  JOIN cdn.TraNagRelacje REL on PA.TrN_TrNId = REL.TrR_TrNId
  WHERE REL.TrR_FAId = @TrN_TrNId_Zrd AND REL.TrR_FATYP = 302 AND REL.TrR_TrNTYP = 305
  -- Wartości potrzebne do wywołania procedury cdn.DodajHaMag
  IF @TrN_TrNId_Zrd IS NOT NULL
    SELECT TOP 1
      @TrN_Bufor_Zrd     =  TrN_Bufor,
      @TrN_Rodzaj_Zrd    =  TrN_Rodzaj,
      @TrN_DataDok_Zrd   =  TrN_DataDok,
      @TrN_DataWys_Zrd   =  TrN_DataWys,
      @TrN_DataOpe_Zrd   =  TrN_DataOpe,
      @TrN_MagZrdId_Doc  =  TrN_MagZrdId,
      @TrN_OpeZalId_Doc  = @TrN_OpeZalId,
      @TrN_StaZalId_Doc  = @TrN_StaZalId
    FROM cdn.TraNag
    WHERE TrN_TrNId = @TrN_TrNId_Zrd
  -- koniec, jeśli dokument źródłowy jest w buforze
  IF @TrN_Bufor_Zrd = 1
    IF @Kontekst IN ( 0, 1, 7, 8 )
       RETURN
    ELSE IF @Kontekst IN ( 2)
       BEGIN
         SET @Komunikat = '##OPT34466##'--' Nie można dodać nowego dokumentu z opakowaniami. Dokument źródłowy jest w buforze ! '
         GOTO KOMUNIKAT
       END
  -- WZ/PZ/WKA/PKA na podstawie elementów z faktury źródłowej
  IF @Kontekst IN (0,1,7,8)
    BEGIN
      -- formularz - data z dokumentu źródłowego
      IF @Kontekst = 0
        SELECT
          @TrN_DataWys_Doc = @TrN_DataWys_Zrd,
          @TrN_DataDok_Doc = @TrN_DataDok_Zrd,
          @TrN_DataOpe_Doc = @TrN_DataOpe_Zrd
      -- lista - data dokumentu mniejsza od Today
      IF @Kontekst in (1,7)  AND @TrN_DataWys_Zrd <= @DataTodayNoTime
        SELECT
          @TrN_DataWys_Doc = @DataTodayNoTime,
          @TrN_DataDok_Doc = @DataTodayNoTime,
          @TrN_DataOpe_Doc = @DataTodayNoTime
      -- lista - data dokumentu większa od Today
      IF @Kontekst in (1,7)  AND @TrN_DataWys_Zrd > @DataTodayNoTime
        SELECT
          @TrN_DataWys_Doc = @TrN_DataWys_Zrd,
          @TrN_DataDok_Doc = @TrN_DataWys_Zrd,
          @TrN_DataOpe_Doc = @TrN_DataWys_Zrd
      IF @Kontekst in (8)
        SELECT
          @TrN_DataWys_Doc = @DataTodayNoTime,
          @TrN_DataDok_Doc = @DataTodayNoTime,
          @TrN_DataOpe_Doc = @DataTodayNoTime
 --nowe przepisy
  IF @Kontekst in (1) and ( SELECT ISNULL( MAX(Fir_Wartosc), 0 ) FROM cdn.Firma WHERE Fir_Numer =2200) = 1
  SELECT
    @TrN_DataOpe_Doc = @TrN_DataOpe_Zrd
      -- WZ/PZ na podstawie elementów FA/PA/FZ
      -- jeśli jest to FA z PA i istnieje WZ-ka, to tylko przepinamy WZ-ke na FA
      IF ISNULL(@TrN_TrNId_Zrd_PA,0) <> 0
        BEGIN
   -- WKA/PKA - na podstawie FA/PA/FZ
   -- jeśli jest to FA z PA i istnieje WKA-ka, to tylko przepinamy WKA na FA
   -- nie robimy tego, jeśli to nie jest O! oddziałowa (w XL WKA musi być spięte z paragonem - mie może być spięte ze spinaczem).
   IF ( SELECT ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1470 ) <> 4
   BEGIN
    SELECT TOP 1 @TrN_TrNId_WKAzPA = WKA.TrN_TrNId
    FROM cdn.TraNag WKA
     JOIN cdn.TraNagRelacje REL ON WKA.TrN_TrNId = REL.TrR_FAId
     WHERE REL.TrR_TrNId in(select TrNId from @TrNIDPA) AND REL.TrR_FATYP = 314 AND REL.TrR_TrNTYP = 305
     --JOIN cdn.TraNag WKA
     --ON  WKA.TrN_RelTrNId = PA.TrN_TrNId
     --AND WKA.TrN_TypDokumentu = 314
     --AND PA.TrN_TypDokumentu = 305
    --WHERE PA.TrN_TrNId = @TrN_TrNId_Zrd_PA
    IF @TrN_TrNId_WKAzPA IS NOT NULL
    BEGIN
     UPDATE cdn.TraNag SET TrN_RelTrNId = @TrN_TrNId_Zrd WHERE TrN_TrNId = @TrN_TrNId_WKAzPA
     INSERT INTO CDN.TraNagRelacje
        (TrR_TrNTyp, TrR_TrNId,        TrR_FaTyp, TrR_FaId,       TrR_Flaga)
     SELECT 314       ,WKA.TrN_TrNId, 0,         @TrN_TrNId_Zrd, 1
        FROM cdn.TraNag WKA
     JOIN cdn.TraNagRelacje REL ON WKA.TrN_TrNId = REL.TrR_FAId
     WHERE REL.TrR_TrNId in(select TrNId from @TrNIDPA) AND REL.TrR_FATYP = 314 AND REL.TrR_TrNTYP = 305
      --VALUES   (314       ,@TrN_TrNId_WKAzPA, 0,         @TrN_TrNId_Zrd, 1)
     SET NOCOUNT OFF
     UPDATE WZ SET
     TrN_PodmiotTyp = FA.TrN_PodmiotTyp,
     TrN_PodID = FA.TrN_PodID,
     TrN_PodNazwa1 = FA.TrN_PodNazwa1,
     TrN_PodNazwa2 = FA.TrN_PodNazwa2,
     TrN_PodNazwa3 = FA.TrN_PodNazwa3,
     TrN_PodKraj = FA.TrN_PodKraj,
     TrN_PodWojewodztwo = FA.TrN_PodWojewodztwo,
     TrN_PodPowiat = FA.TrN_PodPowiat,
     TrN_PodGmina = FA.TrN_PodGmina,
     TrN_PodUlica = FA.TrN_PodUlica,
     TrN_PodNrDomu = FA.TrN_PodNrDomu,
     TrN_PodNrLokalu = FA.TrN_PodNrLokalu,
     TrN_PodMiasto = FA.TrN_PodMiasto,
     TrN_PodKodPocztowy = FA.TrN_PodKodPocztowy,
     TrN_PodPoczta = FA.TrN_PodPoczta,
     TrN_PodAdres2 = FA.TrN_PodAdres2,
     TrN_PodNipKraj = FA.TrN_PodNipKraj,--
     TrN_ZwolnionyZAkcyzy = FA.TrN_ZwolnionyZAkcyzy,--
     TrN_Pesel = FA.TrN_Pesel,
     TrN_PodNipE   = FA.TrN_PodNipE,
     TrN_DokumentTozsamosci = FA.TrN_DokumentTozsamosci,
     TrN_OpeModID = case when @TrN_OpeZalId > 0 then @TrN_OpeZalId else WZ.TrN_OpeModID end,
     TrN_OpeModKod = case when @TrN_OpeZalId > 0 then @OpeZalKod else WZ.TrN_OpeModKod end,
     TrN_OpeModNazwisko = case when @TrN_OpeZalId > 0 then @OpeZalNazwisko else WZ.TrN_OpeModNazwisko end,
     TrN_TS_Mod = @DataTodayWithTime
     FROM CDN.TRANAG WZ
     LEFT JOIN CDN.TRANAG FA ON FA.TrN_TrNID = @TrN_TrNId_Zrd
     WHERE  WZ.TrN_TrNID IN (SELECT WKA.TrN_TrNId FROM cdn.TraNag WKA
     JOIN cdn.TraNagRelacje REL ON WKA.TrN_TrNId = REL.TrR_FAId
     WHERE REL.TrR_TrNId in(select TrNId from @TrNIDPA) AND REL.TrR_FATYP = 314 AND REL.TrR_TrNTYP = 305)
    END
   END
          SELECT TOP 1 @TrN_TrNId_WZzPA = PA.TrN_TrNId
            FROM cdn.TraNag PA
            JOIN cdn.TraNagRelacje REL on PA.TrN_TrNId = REL.TrR_FAId
            WHERE REL.TrR_TrNId in(select TrNId from @TrNIDPA ) AND REL.TrR_FATYP = 306 AND REL.TrR_TrNTYP = 305
          IF @TrN_TrNId_WZzPA IS NOT NULL
            BEGIN
             UPDATE cdn.TraNag SET TrN_FaId     = @TrN_TrNId_Zrd WHERE TrN_TrNId in(
              SELECT PA.TrN_TrNId
    FROM cdn.TraNag PA
    JOIN cdn.TraNagRelacje REL on PA.TrN_TrNId = REL.TrR_FAId
    WHERE REL.TrR_TrNId in(select TrNId from @TrNIDPA ) AND REL.TrR_FATYP = 306 AND REL.TrR_TrNTYP = 305
             )
     INSERT INTO [CDN].[TraNagRelacje]
                            ([TrR_TrNTyp]
                            ,[TrR_TrNId]
                            ,[TrR_FaTyp]
                            ,[TrR_FaId]
                            ,[TrR_Flaga])
             SELECT  306, PA.TrN_TrNId,0,@TrN_TrNId_Zrd,0
             FROM cdn.TraNag PA
             JOIN cdn.TraNagRelacje REL on PA.TrN_TrNId = REL.TrR_FAId
             WHERE REL.TrR_TrNId in(select TrNId from @TrNIDPA ) AND REL.TrR_FATYP = 306 AND REL.TrR_TrNTYP = 305
             update cdn.TraNag set TrN_Rodzaj = 302004 where TrN_TrNID = @TrN_TrNId_Zrd
    UPDATE WZ  SET
    TrN_PodmiotTyp = FA.TrN_PodmiotTyp,
    TrN_PodID = FA.TrN_PodID,
    TrN_PodNazwa1 = FA.TrN_PodNazwa1,
    TrN_PodNazwa2 = FA.TrN_PodNazwa2,
    TrN_PodNazwa3 = FA.TrN_PodNazwa3,
    TrN_PodKraj = FA.TrN_PodKraj,
    TrN_PodWojewodztwo = FA.TrN_PodWojewodztwo,
    TrN_PodPowiat = FA.TrN_PodPowiat,
    TrN_PodGmina = FA.TrN_PodGmina,
    TrN_PodUlica = FA.TrN_PodUlica,
    TrN_PodNrDomu = FA.TrN_PodNrDomu,
    TrN_PodNrLokalu = FA.TrN_PodNrLokalu,
    TrN_PodMiasto = FA.TrN_PodMiasto,
    TrN_PodKodPocztowy = FA.TrN_PodKodPocztowy,
    TrN_PodPoczta = FA.TrN_PodPoczta,
    TrN_PodAdres2 = FA.TrN_PodAdres2,
    TrN_PodNipKraj = FA.TrN_PodNipKraj,--
    TrN_ZwolnionyZAkcyzy = FA.TrN_ZwolnionyZAkcyzy,--
    TrN_Pesel = FA.TrN_Pesel,
    TrN_PodNipE   = FA.TrN_PodNipE,
    TrN_DokumentTozsamosci = FA.TrN_DokumentTozsamosci,
    TrN_OpeModID = case when @TrN_OpeZalId > 0 then @TrN_OpeZalId else WZ.TrN_OpeModID end,
    TrN_OpeModKod = case when @TrN_OpeZalId > 0 then @OpeZalKod else WZ.TrN_OpeModKod end,
    TrN_OpeModNazwisko = case when @TrN_OpeZalId > 0 then @OpeZalNazwisko else WZ.TrN_OpeModNazwisko end,
    TrN_TS_Mod = @DataTodayWithTime
    FROM CDN.TRANAG WZ
    LEFT JOIN CDN.TRANAG FA ON FA.TrN_TrNID = @TrN_TrNId_Zrd
    WHERE  WZ.TrN_TrNID IN (SELECT WZ.TrN_TrNId FROM cdn.TraNag WZ
    JOIN cdn.TraNagRelacje REL ON WZ.TrN_TrNId = REL.TrR_FAId
    WHERE REL.TrR_TrNId in(select TrNId from @TrNIDPA) AND REL.TrR_FATYP = 306 AND REL.TrR_TrNTYP = 305)
             SET NOCOUNT OFF
             RETURN
           END
       END
      -- rodzaj docelowy
      SELECT
        @TrN_Rodzaj_Doc =
          CASE @TrN_Rodzaj_Zrd
            WHEN 302000 THEN 306004  -- FA zwykła
            WHEN 302004 THEN 306004  -- FA skojarzona z WZ-ką (gdy do FA w buforze dodajemy elementy)
            WHEN 302006 THEN 306004  -- FA skojarzona z paragonem bez WZ-ki
            WHEN 302008 THEN 306004  -- FA skojarzona z RO
            WHEN 302009 THEN 306004  -- FA skojarzona z RO
            WHEN 305000 THEN 306006  -- PA zwykły
            WHEN 305004 THEN 306006  -- PA skojarzony z WZ-ką (gdy do FA w buforze dodajemy elementy)
            WHEN 305008 THEN 306006  -- PA skojarzona z RO
            WHEN 301000 THEN 307004  -- FZ zwykły
            WHEN 301004 THEN 307004  -- FZ skojarzony z PZ-ką (gdy do FZ w buforze dodajemy elementy)
            WHEN 301011 THEN 307004  -- FZ skojarzony z ZD
            WHEN 301050 THEN 307004  -- FZ skojarzony z FRR
            WHEN 320000 THEN 306010  -- PF
            WHEN 320009 THEN 306010  -- PF
            WHEN 320200 THEN 306010  -- PF skojarzony z ZL
   WHEN 308000 THEN 306008  -- RO
            WHEN 308009 THEN 306008  -- RO z PF
            WHEN 308010 THEN 306008  -- RO
            WHEN 308008 THEN 306008  -- RO
   WHEN 308011 THEN 306008  -- RO
          END
      -- wygenerowanie dokumentu WZ/PZ
      EXEC CDN.DodajHaMag
        @TrN_TrNId_Zrd_List,  -- TEXT,            -- TrN_TrNId dodawanego dokumentu
        @TrN_Rodzaj_Doc,      -- INT,            -- TrN_Rodzaj dokumentu docelowego
        @TrN_MagZrdId_Doc,    -- INT,            -- Magazyn dokumentu docelowego
        @TrN_DataWys_Doc,     -- DATETIME,       -- TrN_DataWys dokumentu docelowego
        @TrN_DataDok_Doc,     -- DATETIME,       -- TrN_DataDok dokumentu docelowego
        @TrN_DataOpe_Doc,     -- DATETIME,       -- TrN_DataOpe dokumentu docelowego
        @TrN_OpeZalId_Doc,    -- INT,            -- Opertor zalogowany do programu, który wykonuje operację przekształcenia
        @TrN_StaZalId_Doc,    -- INT,            -- Sanowisko, z którego jest wykonywana operacja przekształcenia
        @ServerCfgString,     -- NVARCHAR(250),   -- nazwa serwera z bazą konfiguracyjną
        @BazaCfgString,       -- NVARCHAR(250),   -- nazwa bazy konfiguracyjnej
        @DataToday,           -- DATETIME        -- data bieżąca z programu
        @Kontekst,            -- INT,            -- Kontekst wywołania: 0 - WZ/PZ/WKA/PKA z formularza na podstawie elementów faktury, 1 - WZ/PZ/WKA/PK z listy na podstawie elementów faktury, 2 - WKA/PKA jako nowy dokument z listy FA/PA/FZ
        1,
        @Seria,
        @TrN_TrNId_Doc OUTPUT -- INT  OUTPUT     -- zwracany  TrN_TrNId dokumentu docelowego
      IF @@ERROR<>0
        BEGIN
          IF @@TranCount<>0 ROLLBACK TRAN
          RETURN
        END
      -- WKA/PKA - na podstawie FA/PA/FZ
      -- jeśli jest to FA z PA i istnieje WKA-ka, to tylko przepinamy WKA na FA
      -- nie robimy tego, jeśli to nie jest O! oddziałowa (w XL WKA musi być spięte z paragonem - mie może być spięte ze spinaczem).
      /*IF ISNULL(@TrN_TrNId_Zrd_PA,0) <> 0  AND ( SELECT ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1470 ) <> 4
        BEGIN
          SELECT TOP 1 @TrN_TrNId_WKAzPA = WKA.TrN_TrNId
            FROM cdn.TraNag WKA
              JOIN cdn.TraNagRelacje REL ON WKA.TrN_TrNId = REL.TrR_TrNId
              WHERE REL.TrR_TrNId in(select TrNId from @TrNIDPA) AND REL.TrR_FATYP = 314 AND REL.TrR_TrNTYP = 305
              --JOIN cdn.TraNag WKA
              --ON  WKA.TrN_RelTrNId = PA.TrN_TrNId
              --AND WKA.TrN_TypDokumentu = 314
              --AND PA.TrN_TypDokumentu = 305
            --WHERE PA.TrN_TrNId = @TrN_TrNId_Zrd_PA
          IF @TrN_TrNId_WKAzPA IS NOT NULL
            BEGIN
             UPDATE cdn.TraNag SET TrN_RelTrNId = @TrN_TrNId_Zrd WHERE TrN_TrNId = @TrN_TrNId_WKAzPA
             INSERT INTO CDN.TraNagRelacje
                            (TrR_TrNTyp, TrR_TrNId,        TrR_FaTyp, TrR_FaId,       TrR_Flaga)
             SELECT 314       ,WKA.TrN_TrNId, 0,         @TrN_TrNId_Zrd, 1
            FROM cdn.TraNag WKA
              JOIN cdn.TraNagRelacje REL ON WKA.TrN_TrNId = REL.TrR_TrNId
              WHERE REL.TrR_TrNId in(select TrNId from @TrNIDPA) AND REL.TrR_FATYP = 314 AND REL.TrR_TrNTYP = 305
                   --VALUES   (314       ,@TrN_TrNId_WKAzPA, 0,         @TrN_TrNId_Zrd, 1)
             SET NOCOUNT OFF
             RETURN
           END
       END*/
      -- Jeśli FA/PA jest z usługami złozonymi to generujemy RW przy generowaniu WZ
   IF EXISTS ( SELECT * FROM cdn.TraElem WHERE TrE_TrNId = @TrN_TrNId_Zrd AND TrE_Kaucja = 2 )
   OR EXISTS ( SELECT * FROM cdn.TraElem WHERE TrE_TrNId in(select TrNId from @TrNIDPA ) AND TrE_Kaucja = 2 )
      BEGIN
      exec CDN.GenerujRWNaUslugiDoFS
        @TrN_TrNId_Zrd_List  ,         -- lista TrN_TrNId dokumentów źródłowych (paragonów, faktur), do których ma być wykonany dokument magazynowy
        @TrN_DataOpe_Doc,     -- TrN_DataWys dokumentu docelowego
        @TrN_OpeZalId_Doc,          -- Opertor zalogowany do programu, który wykonuje operację przekształcenia
        @TrN_StaZalId_Doc,          -- Sanowisko, z którego jest wykonywana operacja przekształcenia
        @ServerCfgString     , -- nazwa serwera z bazą konfiguracyjną
        @BazaCfgString       , -- nazwa bazy konfiguracyjnej
        @DataToday           , -- data bieżąca z programu
        @Seria               ,
        @Kontekst
      END
      if (@Kontekst = 8) -- zmieniamy operatora na RO ktory wygenerował WZ do tego RO (180168)
      BEGIN
  DECLARE @TrNID TABLE ( TrNId INT)
  insert into @TrNID select NextIdInt from  CDN.Text2TableInt ( @TrN_TrNId_Zrd_List )
  update Doc set Doc.TrN_OpeModID = @TrN_OpeZalId_Doc, Doc.TrN_OpeModKod = @OpeZalKod, Doc.TrN_OpeModNazwisko = @OpeZalNazwisko, Doc.TrN_StaModId = @TrN_StaZalId_Doc
  from cdn.tranag Doc where Trn_TrNId in (select TrNId from @TrNID )
      END
      -- Return jeśli nie ma kaucji na dokumencie lub paragonie, jeśli to jest FA z PA
      IF NOT EXISTS ( SELECT * FROM cdn.TraElem WHERE TrE_TrNId = @TrN_TrNId_Zrd AND TrE_Kaucja = 1 )
        AND NOT EXISTS ( SELECT * FROM cdn.TraElem WHERE TrE_TrNId in(select TrNId from @TrNIDPA ) AND TrE_Kaucja = 1 )
        RETURN
      -- Rodzaj docelowy
      SELECT
        @TrN_Rodzaj_Doc =
          CASE CONVERT(INT, @TrN_Rodzaj_Zrd/1000)
            WHEN 302 THEN 314004  -- FA
            WHEN 305 THEN 314006  -- PA
            WHEN 306 THEN 314000  -- WZ
            WHEN 301 THEN 313004  -- FZ
            WHEN 307 THEN 313000  -- FZ
          END
      EXEC CDN.DodajHaMag
        @TrN_TrNId_Zrd_List,  -- TEXT,            -- TrN_TrNId dodawanego dokumentu
        @TrN_Rodzaj_Doc,      -- INT,            -- TrN_Rodzaj dokumentu docelowego
        @TrN_MagZrdId_Doc,    -- INT,            -- Magazyn dokumentu docelowego
        @TrN_DataWys_Doc,     -- DATETIME,       -- TrN_DataWys dokumentu docelowego
        @TrN_DataDok_Doc,     -- DATETIME,       -- TrN_DataDok dokumentu docelowego
        @TrN_DataOpe_Doc,     -- DATETIME,       -- TrN_DataOpe dokumentu docelowego
        @TrN_OpeZalId_Doc,    -- INT,            -- Opertor zalogowany do programu, który wykonuje operację przekształcenia
        @TrN_StaZalId_Doc,    -- INT,            -- Sanowisko, z którego jest wykonywana operacja przekształcenia
        @ServerCfgString,     -- NVARCHAR(250),   -- nazwa serwera z bazą konfiguracyjną
        @BazaCfgString,       -- NVARCHAR(250),   -- nazwa bazy konfiguracyjnej
        @DataToday,           -- DATETIME        -- data bieżąca z programu
        @Kontekst,            -- INT,            -- Kontekst wywołania: 0 - WZ/PZ/WKA/PKA z formularza na podstawie elementów faktury, 1 - WZ/PZ/WKA/PK z listy na podstawie elementów faktury, 2 - WKA/PKA jako nowy dokument z listy FA/PA/FZ
        2,
        @Seria,
        @TrN_TrNId_Doc OUTPUT -- INT  OUTPUT     -- zwracany  TrN_TrNId dokumentu docelowego
      IF @@ERROR<>0
        BEGIN
          IF @@TranCount<>0 ROLLBACK TRAN
          RETURN
        END
  END
  -- WKA/PKA jako nowy dokument na podstawie towarów z dokumentu źródłowego
  IF @Kontekst IN (2)
    BEGIN
      -- tylko jedno TrN_TrNId dokumentu źródłowego
      SELECT TOP 1  @TrN_TrNId_Zrd = NextIdINT FROM CDN.Text2TableInt ( @TrN_TrNId_Zrd_List )
      -- nie wykonujemy nowego WKA, jeśli istnieje inny w buforze
      IF EXISTS ( SELECT * FROM cdn.TraNag JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId WHERE TrN_TypDokumentu IN ( 313, 314 ) AND TrR_FAId =  @TrN_TrNId_Zrd AND TrR_Flaga = 1 AND TrN_Bufor = 1 )
       BEGIN
         SET @Komunikat = '##OPT34467##'--' Utworzenie dokumentu niemożliwe ! Z danym dokumentem jest skojarzony dokument w buforze. '
         GOTO KOMUNIKAT
       END
      -- nie wykonujemy nowego WKA, jeśli na pierwszym są elementy kaucyjne
      IF    EXISTS ( SELECT * FROM cdn.TraElem WHERE TrE_TrNId = @TrN_TrNId_Zrd    AND TrE_Kaucja = 1 )
         OR EXISTS ( SELECT * FROM cdn.TraElem WHERE TrE_TrNId in(select TrNId from @TrNIDPA ) AND TrE_Kaucja = 1 )
       BEGIN
         SET @Komunikat = '##OPT34468##'--' Utworzenie dokumentu niemożliwe ! Na dokumencie źródłowym występują elementy kaucyjne. Najpierw utwórz dokument magazynowy i kaucyjny ! '
         GOTO KOMUNIKAT
       END
      -- nie wykonujemy nowego WKA, jeśli jest to PA ze skojarzoną fakturą
      IF EXISTS ( SELECT * FROM cdn.TraNag PA JOIN cdn.TraNagRelacje REL on PA.TrN_TrNId = REL.TrR_TrNId WHERE REL.TrR_FAId = @TrN_TrNId_Zrd AND REL.TrR_FATYP = 305 AND REL.TrR_TrNTYP = 302 )
       BEGIN
         SET @Komunikat = '##OPT34469##'--' Utworzenie dokumentu niemożliwe ! Paragon jest skojarzony z fakturą !  Wykonanie nowego dokumentu kaucyjnego jest możliwe z poziomu faktury. '
         GOTO KOMUNIKAT
       END
      -- sprawdzamy, czy dany dokument źródłowy jest zafiskalizowany
      IF EXISTS ( SELECT * FROM cdn.TraNag WHERE  TrN_TrNId IN ( SELECT NextIdINT FROM CDN.Text2TableInt ( @TrN_TrNId_Zrd_List )) AND TrN_Fiskalna = 1 AND IsNull(Trn_FiskalnaErr, 0) = 0)
       BEGIN
         SET @Komunikat = '##OPT34470##'--' Utworzenie dokumentu niemożliwe ! Dokument źródłowy jest zafiskalizowany ! '
         GOTO KOMUNIKAT
       END
      -- Rodzaj dokumentu docelowego
      SELECT
        @TrN_Rodzaj_Doc =
          CASE CONVERT(INT, @TrN_Rodzaj_Zrd/1000)
            WHEN 302 THEN 314004  -- FA
            WHEN 305 THEN 314006  -- PA
            WHEN 306 THEN 314000  -- WZ
            WHEN 301 THEN 313004  -- FZ
            WHEN 307 THEN 313000  -- FZ
          END
      -- data Today zupełnie nowy dokument
      SELECT @TrN_DataOpe_BZM = MAX(ISNULL(TrN_DataOpe,0)) FROM cdn.TraNag WHERE TrN_TypDokumentu = 310 AND TrN_Rodzaj = 310005
      IF @TrN_DataOpe_BZM >= @DataTodayNoTime
        SELECT
          @TrN_DataWys_Doc = @TrN_DataOpe_BZM + 1,
          @TrN_DataDok_Doc = @TrN_DataOpe_BZM + 1,
          @TrN_DataOpe_Doc = @TrN_DataOpe_BZM + 1
      ELSE
        SELECT
          @TrN_DataWys_Doc = @DataTodayNoTime,
          @TrN_DataDok_Doc = @DataTodayNoTime,
          @TrN_DataOpe_Doc = @DataTodayNoTime
      EXEC CDN.DodajHaMag
        @TrN_TrNId_Zrd_List,  -- TEXT,           -- TrN_TrNId dodawanego dokumentu
        @TrN_Rodzaj_Doc,      -- INT,            -- TrN_Rodzaj dokumentu docelowego
        @TrN_MagZrdId_Doc,    -- INT,            -- Magazyn dokumentu docelowego
        @TrN_DataWys_Doc,     -- DATETIME,       -- TrN_DataWys dokumentu docelowego
        @TrN_DataDok_Doc,     -- DATETIME,       -- TrN_DataDok dokumentu docelowego
        @TrN_DataOpe_Doc,     -- DATETIME,       -- TrN_DataOpe dokumentu docelowego
        @TrN_OpeZalId_Doc,    -- INT,            -- Opertor zalogowany do programu, który wykonuje operację przekształcenia
        @TrN_StaZalId_Doc,    -- INT,            -- Sanowisko, z którego jest wykonywana operacja przekształcenia
        @ServerCfgString,     -- NVARCHAR(250),   -- nazwa serwera z bazą konfiguracyjną
        @BazaCfgString,       -- NVARCHAR(250),   -- nazwa bazy konfiguracyjnej
        @DataToday,           -- DATETIME        -- data bieżąca z programu
        @Kontekst,            -- INT,            -- Kontekst wywołania: 0 - WZ/PZ/WKA/PKA z formularza na podstawie elementów faktury, 1 - WZ/PZ/WKA/PK z listy na podstawie elementów faktury, 2 - WKA/PKA jako nowy dokument z listy FA/PA/FZ
        3,
        @Seria,
        @TrN_TrNId_Doc OUTPUT -- INT  OUTPUT     -- zwracany  TrN_TrNId dokumentu docelowego
      IF @@ERROR<>0
        BEGIN
          IF @@TranCount<>0 ROLLBACK TRAN
          RETURN
        END
    END
  -- AI z ilościami
  IF @Kontekst in (4,41,42,43,40,410,420,430)
    BEGIN
      -- 1 = "Pobieraj ostatnio ustalony kurs waluty (nie ostrzegaj o zmianie kursu)"
      DECLARE @WalOstrzegaj CHAR(1)
      IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540 )
        SELECT @WalOstrzegaj=Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540
      ELSE
        SELECT @WalOstrzegaj=1
      -- sprawdzenie daty ostatniego BZM
      SELECT @TrN_DataOpe_BZM = MAX(ISNULL(TrN_DataOpe,0)) FROM cdn.TraNag WHERE TrN_TypDokumentu = 310 AND TrN_Rodzaj = 310005
      IF @TrN_DataOpe_BZM >= @DataTodayNoTime
        SET @TrN_DataOpe_Doc = @TrN_DataOpe_BZM + 1
      ELSE
        SET @TrN_DataOpe_Doc = @DataTodayNoTime
       -- kontrola, czy inne arkusze nie są jeszcze otwarte (w buforze lub niezinwentaryzowane)
      IF @Oddzial = 4
        BEGIN
          IF EXISTS ( SELECT * FROM CDN.TraNag
                      WHERE  TrN_TypDokumentu=311
                        AND TrN_Rodzaj<>311001
                        AND ( TrN_Bufor=1 OR
                                   TrN_Bufor=0 AND
                                   TrN_GIDTyp   IS NULL AND
                                   TrN_GIDFirma IS NULL AND
                                   TrN_GIDNumer IS NULL AND
                                   TrN_GIDLp    IS NULL
                            )
                    )
            BEGIN
              SET @Komunikat = '##OPT34471##'--' Nie jest możliwe dodanie nowego arkusza inwentaryzacyjnego ponieważ  arkusz inwentaryzacyjny znajduje się w buforze lub istnieje  zatwierdzony ale nie potwierdzony arkusz inwentaryzacyjny ! '
              GOTO KOMUNIKAT
            END
        END
      -- Tabela z magazynami
      IF ISNULL(@MagazynId,0) <> 0
        INSERT INTO @Magazyny ( MagId )
        SELECT Mag_MagId FROM cdn.Magazyny
        WHERE  Mag_MagId = @MagazynId
          AND Mag_MagId NOT IN(SELECT Mag_MagId FROM CDN.MAGAZYNY
                                 JOIN CDN.MagazynZakazy ON Mag_MagId = Maz_MagId
                                WHERE MaZ_OpeId = @TrN_OpeZalId )
      ELSE
        INSERT INTO @Magazyny ( MagId )
        SELECT Mag_MagId FROM cdn.Magazyny
        WHERE (Mag_Typ = 1 OR Mag_Typ = 3 ) AND Mag_Nieaktywny = 0
          AND Mag_MagId NOT IN(SELECT Mag_MagId FROM CDN.MAGAZYNY
                                 JOIN CDN.MagazynZakazy ON Mag_MagId = Maz_MagId
                                WHERE MaZ_OpeId = @TrN_OpeZalId )
      if not exists(select * from @Magazyny)
   BEGIN
              SET @Komunikat = '##OPT34472##'--'Brak możliwości stworzenia arkusza inwentaryzacyjnego. Operator ma zakaz do wybranego magazynu! '
              GOTO KOMUNIKAT
      END
      -- jeśli OFF-Line, to:
      --  nie powinno być stanów na magazynie głównym
      --  tylko jeden magazyn do tworzenia arkusza (AI ma być tylko na magazynie głównym)
      IF @Oddzial = 4
        BEGIN
          -- najpierw kontrola stanów na innych magazynach (nie powinno być w OFF-Line)
          IF EXISTS (SELECT * FROM CDN.TwrZasoby WHERE TwZ_MagId <> 1)
            BEGIN
              SET @Komunikat = '##OPT34473##'--@Komunikat = 'Nie jest możliwe dodanie nowego arkusza inwentaryzacyjnego ponieważ istnieją zasoby na magazynach innych niż główny. '
              --+ ' Przed wykonaniem akrusza inwentaryzacyjnego przesuń wszystkie stany z magazynów innych niż główny na magazyn główny przy pomocy dokumentów MM.'
              GOTO KOMUNIKAT
            END
          -- AI tylko na magazynie głównym
          DELETE FROM @Magazyny WHERE MagId <> 1
        END
      -- skeszowanie notowań wszystkich walut z konfiguracji
      SET @TrN_DataOpe_Doc_Chr = CONVERT(NVARCHAR(10), @TrN_DataOpe_Doc, 120)
      SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
      IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
        SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
      SET @sqltxt = 'EXEC ['
      IF @ServerCfgString <> @TmpSrvName
        SET @sqltxt = @sqltxt + @ServerCfgString +'].['
      SET @sqltxt = @sqltxt + @BazaCfgString+'].CDN.PobierzNotowania '''', 2,'''+ @TrN_DataOpe_Doc_Chr  + ''',' +  @WalOstrzegaj + ''
--      CREATE TABLE #Notowania   ( Systemowa TINYINT, Waluta NVARCHAR(3), KursNumer INT, KursL DECIMAL(15,4), KursM DECIMAL(5,0), Brak TINYINT )
      INSERT INTO  dbo.#Notowania  ( Systemowa,         Waluta ,           KursNumer,     KursL,               KursM             , Brak         )
      EXEC sp_executesql @sqltxt
      -- tabela tymczasowa cen walutowych i cen PLN dla wszystkich towarów
      IF @Oddzial = 4
   BEGIN
      IF ISNULL(@GrupaTowarowa,0) > -1
      INSERT INTO @AI   (                        TwrId,     Waluta,            KursNumer,     KursL,               KursM,              CenaWal,               CenaSys, Brak              )
        SELECT
          T.Twr_TwrId,
          CASE WHEN N.Waluta IS NULL THEN T.Twr_Waluta    ELSE N.Waluta    END, -- TrE_Waluta
          CASE WHEN N.Waluta IS NULL THEN T.Twr_KursNumer ELSE N.KursNumer END, -- TrE_KursNumer
          CASE WHEN N.Waluta IS NULL THEN T.Twr_KursL     ELSE N.KursL     END, -- TrE_KursL
          CASE WHEN N.Waluta IS NULL THEN T.Twr_KursM     ELSE N.KursM     END, -- TrE_KursM
          ISNULL(C.TwC_Wartosc,0),
          CASE WHEN N.Waluta IS NULL THEN                                       -- TrE_CenaT
            ROUND(ISNULL(C.TwC_Wartosc,0) * T.Twr_KursL / T.Twr_KursM, case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end )
          ELSE
            ROUND(ISNULL(C.TwC_Wartosc,0) * N.KursL / N.KursM, case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end )
          END,
          Brak
        FROM cdn.Towary T
          JOIN cdn.TwrCeny C ON C.TwC_TwrId = T.Twr_TwrID AND C.TwC_TwCNumer = 1
          LEFT OUTER JOIN #Notowania N ON C.Twc_Waluta = N.Waluta
        WHERE T.Twr_Typ = 1 AND T.Twr_TwGGIDNumer = @GrupaTowarowa
        ORDER BY T.Twr_Kod
        ELSE
        INSERT INTO @AI   (                        TwrId,     Waluta,            KursNumer,     KursL,               KursM,              CenaWal,               CenaSys, Brak               )
        SELECT
          T.Twr_TwrId,
          CASE WHEN N.Waluta IS NULL THEN T.Twr_Waluta    ELSE N.Waluta    END, -- TrE_Waluta
          CASE WHEN N.Waluta IS NULL THEN T.Twr_KursNumer ELSE N.KursNumer END, -- TrE_KursNumer
          CASE WHEN N.Waluta IS NULL THEN T.Twr_KursL     ELSE N.KursL     END, -- TrE_KursL
          CASE WHEN N.Waluta IS NULL THEN T.Twr_KursM     ELSE N.KursM     END, -- TrE_KursM
          ISNULL(C.TwC_Wartosc,0),
          CASE WHEN N.Waluta IS NULL THEN                                       -- TrE_CenaT
            ROUND(ISNULL(C.TwC_Wartosc,0) * T.Twr_KursL / T.Twr_KursM, case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end )
          ELSE
            ROUND(ISNULL(C.TwC_Wartosc,0) * N.KursL / N.KursM, case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end )
          END,
          Brak
        FROM cdn.Towary T
          JOIN cdn.TwrCeny C ON C.TwC_TwrId = T.Twr_TwrID AND C.TwC_TwCNumer = 1
          LEFT OUTER JOIN #Notowania N ON C.Twc_Waluta = N.Waluta
        WHERE T.Twr_Typ = 1
        ORDER BY T.Twr_Kod
       END
      ELSE
   BEGIN
      IF ISNULL(@GrupaTowarowa,0) > -1
      INSERT INTO @AI   (                        TwrId,     Waluta,            KursNumer,     KursL,               KursM,              CenaWal,               CenaSys, Brak              )
        SELECT
          T.Twr_TwrId,
          CASE WHEN N.Waluta IS NULL THEN T.Twr_Waluta    ELSE N.Waluta    END, -- TrE_Waluta
          CASE WHEN N.Waluta IS NULL THEN T.Twr_KursNumer ELSE N.KursNumer END, -- TrE_KursNumer
          CASE WHEN N.Waluta IS NULL THEN T.Twr_KursL     ELSE N.KursL     END, -- TrE_KursL
          CASE WHEN N.Waluta IS NULL THEN T.Twr_KursM     ELSE N.KursM     END, -- TrE_KursM
          ISNULL(C.TwC_Wartosc,0),
          CASE WHEN N.Waluta IS NULL THEN                                       -- TrE_CenaT
            ROUND(ISNULL(C.TwC_Wartosc,0) * T.Twr_KursL / T.Twr_KursM, case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end )
          ELSE
            ROUND(ISNULL(C.TwC_Wartosc,0) * N.KursL / N.KursM, case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end )
          END,
          Brak
        FROM cdn.Towary T
          JOIN cdn.TwrCeny C ON C.TwC_TwrId = T.Twr_TwrID AND C.TwC_TwCNumer = 1
          LEFT OUTER JOIN #Notowania N ON T.Twr_Waluta = N.Waluta
        WHERE T.Twr_Typ = 1 AND T.Twr_TwGGIDNumer = @GrupaTowarowa
        ORDER BY T.Twr_Kod
        ELSE
        INSERT INTO @AI   (                        TwrId,     Waluta,            KursNumer,     KursL,               KursM,              CenaWal,               CenaSys, Brak               )
        SELECT
          T.Twr_TwrId,
          CASE WHEN N.Waluta IS NULL THEN T.Twr_Waluta    ELSE N.Waluta    END, -- TrE_Waluta
          CASE WHEN N.Waluta IS NULL THEN T.Twr_KursNumer ELSE N.KursNumer END, -- TrE_KursNumer
          CASE WHEN N.Waluta IS NULL THEN T.Twr_KursL     ELSE N.KursL     END, -- TrE_KursL
          CASE WHEN N.Waluta IS NULL THEN T.Twr_KursM     ELSE N.KursM     END, -- TrE_KursM
          ISNULL(C.TwC_Wartosc,0),
          CASE WHEN N.Waluta IS NULL THEN                                       -- TrE_CenaT
            ROUND(ISNULL(C.TwC_Wartosc,0) * T.Twr_KursL / T.Twr_KursM, case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end )
          ELSE
            ROUND(ISNULL(C.TwC_Wartosc,0) * N.KursL / N.KursM, case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end )
          END,
          Brak
        FROM cdn.Towary T
          JOIN cdn.TwrCeny C ON C.TwC_TwrId = T.Twr_TwrID AND C.TwC_TwCNumer = 1
          LEFT OUTER JOIN #Notowania N ON T.Twr_Waluta = N.Waluta
        WHERE T.Twr_Typ = 1
        ORDER BY T.Twr_Kod
      END
      -- dla kontekstu 41 i 43 usuwamy towary nieaktywne
      IF @Kontekst IN (41,43,410,430)
          DELETE @AI FROM @AI JOIN cdn.Towary ON TwrId = Twr_TwrId WHERE Twr_NieAktywny = 1
      -- notowania niepotrzebne
     DROP TABLE #Notowania
     select top 1 @Komunikat = Waluta from @AI where Brak = 1
     if @Komunikat !=''
     BEGIN
         SET @Komunikat = '##OPT34474##%%Desc%%='+@Komunikat+'##' --' Brak notowania dla waluty '+@Komunikat
         GOTO KOMUNIKAT
       END
     -- SO zamiast kursora po magazynach, pętla WHILE,
     -- dla dużych dokumentów > 200 będzie szybciej
      DECLARE @Licznik INT, @Koniec INT
       SELECT @Licznik = 1
        SELECT @Koniec = MAX(Idm) FROM @Magazyny
         WHILE 1=1
          BEGIN
    SELECT @TrN_MagZrdId_Doc = MagId FROM @Magazyny WHERE Idm=@Licznik
      -- kursor po magazynach, na których ma się pojawić AI
/*
      DECLARE M CURSOR LOCAL FAST_FORWARD FOR
      SELECT MagId FROM @Magazyny
      OPEN M
        WHILE 1=1
          BEGIN
            FETCH NEXT FROM M INTO @TrN_MagZrdId_Doc
            IF @@FETCH_STATUS <> 0 BREAK
*/
            EXEC CDN.DodajTraNag
              @TrN_TrNId_Zrd_List,                    -- @TrN_TrNId_Zrd      INT,           -- TrN_TrNId nagłówka do dodania lub do skopiowania (może być NULL, jeśli @TrN_Rodzaj_Doc IS NOT NULL AND @TrN_MagZrdId_Doc IS NOT NULL )
              311000,                  -- @TrN_Rodzaj_Doc     INT,           -- TrN_Rodzaj dokumentu docelowego ( może być null, jeśli @TrN_TrNId_Zrd IS NOT NULL )
              @TrN_MagZrdId_Doc,       -- @TrN_MagZrdId_Doc   INT,           -- TrN_MagZrdId dokumentu docelowego ( może być null, jeśli @TrN_TrNId_Zrd IS NOT NULL )
              @TrN_DataOpe_Doc,        -- @TrN_DataDok_Doc    DATETIME,      --
              @TrN_DataOpe_Doc,        -- @TrN_DataWys_Doc    DATETIME,      --
              @TrN_DataOpe_Doc,        -- @TrN_DataOpe_Doc    DATETIME,      --
              @ServerCfgString,        -- @SeverCfgString     NVARCHAR(250),  -- nazwa serwera z bazą konfiguracyjną
              @BazaCfgString,          -- @BazaCfgString      NVARCHAR(250),  -- nazwa bazy konfiguracyjnej
              @TrN_OpeZalId,           -- @TrN_OpeZalId_Doc   INT,           -- Opertor zalogowany do programu, który wykonuje operację przekształcenia
              @TrN_StaZalId,           -- @TrN_StaZalId_Doc   INT,           -- Sanowisko, z którego jest wykonywana operacja przekształcenia
              @DataToday,              -- @DataToday          NVARCHAR(100),  -- Data Today z programu (może być inna niż z serwera)
              -1,                      -- @Kontekst           INT,           -- Kontekst wywołania: -1 (minus jeden) - nagłówek z kontrahentem "Nieokreślony"; 0 - WZ/PZ/WKA/PKA z formularza, 1 - WZ/PZ/WKA/PKA z listy, 2 - WKA/PKA jako nowy dokument z listy FA/PA/FZ
              @Seria,
              @TrN_TrNId_Doc OUTPUT    -- @TrN_TrNId_Doc INT OUTPUT   -- zwracany  TrN_TrNId dokumentu docelowego
            UPDATE cdn.TraNag SET
              TrN_Opis = ' Arkusz inwentaryzacyjny wygenerowany automatycznie. '
            WHERE TrN_TrNId = @TrN_TrNId_Doc
 -- dodanie elementów
            INSERT INTO cdn.TraElem
            (
              TrE_TrNId,
              TrE_ZwrId,
              TrE_TrEIdProd,
              TrE_PdRId,
              TrE_Lp,
              TrE_LpPow,
              TrE_TypDokumentu,
              TrE_Aktywny,
              TrE_DataDok,
              TrE_DataOpe,
              TrE_PodmiotTyp,
              TrE_PodID,
              TrE_KatID,
              TrE_TwrId,
              TrE_TwrNazwa,
              TrE_TwrEAN,
     TrE_TwrTyp ,
     TrE_TwrKodDostawcy,
              TrE_TwrNumerKat,
              TrE_TwrKod,
              TrE_TwrOpis,
              TrE_TwrSWW,
              TrE_Stawka,
              TrE_Flaga,
              TrE_Zrodlowa,
              TrE_TwCNumer,
              TrE_TypNB,
              TrE_Cena0,
              TrE_Rabat,
              TrE_CenaW,
              TrE_Waluta,
              TrE_KursNumer,
              TrE_KursL,
              TrE_KursM,
              TrE_CenaT,
              TrE_Ilosc,
              TrE_Jm,
              TrE_JmZ,
              TrE_JmCalkowite,
              TrE_JMPrzelicznikL,
              TrE_JMPrzelicznikM,
              TrE_IloscJM,
              TrE_WartoscNetto,
              TrE_WartoscBrutto,
              TrE_KosztUslugi,
              TrE_WartoscZakupuWylicz,
              TrE_Cena0WD,
              TrE_CenaWWD,
              TrE_WartoscNettoWal,
              TrE_WartoscBruttoWal,
              TrE_Prog,
              TrE_UpustTyp,
              TrE_Upust,
              TrE_UpustKnt,
              TrE_UpustKntTyp,
              TrE_Kaucja,
              TrE_RabatPromocyjny,
              TrE_RabatKorekta,
              TrE_Promocje,
              TrE_IloscJMKW,
              TrE_IloscKW,
              TrE_Atr1_DeAId,
              TrE_Atr1_Kod,
              TrE_Atr1_Wartosc,
              TrE_Atr2_DeAId,
              TrE_Atr2_Kod,
              TrE_Atr2_Wartosc,
              TrE_Atr3_DeAId,
              TrE_Atr3_Kod,
              TrE_Atr3_Wartosc,
              TrE_Atr4_DeAId,
              TrE_Atr4_Kod,
              TrE_Atr4_Wartosc,
              TrE_Atr5_DeAId,
              TrE_Atr5_Kod,
              TrE_Atr5_Wartosc,
              TrE_MagId,
              TrE_WyborDostaw,
     TrE_CenaZCzteremaMiejscami
            )
            SELECT
             @TrN_TrNId_Doc,                                       -- TrE_TrNId
              NULL,                                                -- TrE_ZwrId
              NULL,                                                -- TrE_TrEIdProd
              NULL,                                                -- TrE_PdRId
              AI.Lp,                                               -- TrE_Lp
              AI.Lp,                                               -- TrE_LpPow
              311,                                                 -- TrE_TypDokumentu
              1,                                                   -- TrE_Aktywny
             @TrN_DataOpe_Doc,                                     -- TrE_DataDok
             @TrN_DataOpe_Doc,                                     -- TrE_DataOpe
              1,                                                   -- TrE_PodmiotTyp
              1,                                                   -- TrE_PodId
              T.Twr_KatId,                                         -- TrE_KatId
              T.Twr_TwrId,                                         -- TrE_TwrId
              T.Twr_Nazwa,                                         -- TrE_TwrNazwa
              T.Twr_EAN,                                           -- TrE_TwrEAN
     T.Twr_Typ ,
     T.Twr_KodDostawcy,
              T.Twr_NumerKat,                                      -- TrE_TwrNumerKat
              T.Twr_Kod,                                           -- TrE_TwrKod
              SUBSTRING(T.Twr_Opis, 1, 1024),                      -- TrE_TwrOpis
              T.Twr_SWW,                                           -- TrE_TwrSWW
              T.Twr_StawkaZak,                                     -- TrE_Stawka
              T.Twr_FlagaZak,                                      -- TrE_Flaga
              T.Twr_ZrodlowaZak,                                   -- TrE_Zrodlowa
              1,                                                   -- TrE_TwCNumer
              1,                                                   -- TrE_TypNB
              AI.CenaWal,                                          -- TrE_Cena0
              0,                                                   -- TrE_Rabat
              AI.CenaWal,                                          -- TrE_CenaW
              AI.Waluta,                                           -- TrE_Waluta
              AI.KursNumer,                                        -- TrE_KursNumer
              AI.KursL,                                            -- TrE_KursL
              AI.KursM,                                            -- TrE_KursM
              AI.CenaSys,                                          -- TrE_CenaT
              ISNULL(I.TwI_Ilosc,0),                               -- TrE_Ilosc
              T.Twr_Jm,                                            -- TrE_Jm
              '',                                           -- TrE_JmZ
              T.Twr_JmCalkowite,                                   -- TrE_JmCalkowite
              1,                                                   -- TrE_JMPrzelicznikL
              1,                                                   -- TrE_JMPrzelicznikM
              ISNULL(I.TwI_Ilosc,0),                               -- TrE_IloscJM
              ROUND(ISNULL(I.TwI_Ilosc,0) * AI.CenaSys,2),                                      -- TrE_WartoscNetto
              ROUND(ROUND(ISNULL(I.TwI_Ilosc,0) * AI.CenaSys,2) * (1 + T.Twr_StawkaZak / 100), 2), -- TrE_WartoscBrutto
              0,                                                                                -- TrE_KosztUslugi
              0,
              AI.CenaSys,                                          -- TrE_CenaOWD
              AI.CenaSys,                                          -- TrE_CenaWWD
              ROUND(ISNULL(I.TwI_Ilosc,0) * AI.CenaSys,2),                                      -- TrE_WartoscNettoWal
              ROUND(ROUND(ISNULL(I.TwI_Ilosc,0) * AI.CenaSys,2) * (1 + T.Twr_StawkaZak / 100), 2), -- TrE_WartoscBruttoWal
              0,                                                                                -- TrE_Prog
              0,                                                                                -- TrE_UpustTyp
              0,                                                                                -- TrE_Upust
              0,                                                                                -- TrE_UpustKnt
              0,                                                                                -- TrE_UpustKntTyp
              0,                                                                                -- TrE_Kaucja
              0,                                                                                -- TrE_RabatPromocyjny,
              0,                                                                                -- TrE_RabatKorekta,
              0,                                                                                -- TrE_Promocje
              ISNULL(I.TwI_Ilosc,0),                                                            -- TrE_IloscJMKW,
              ISNULL(I.TwI_Ilosc,0),
              NULL,
              '',
              '',
              NULL,
              '',
              '',
              NULL,
              '',
              '',
              NULL,
              '',
              '',
              NULL,
              '',
              '',
              @TrN_MagZrdId_Doc,
              0,
     Twr_CenaZCzteremaMiejscami
              FROM cdn.Towary T
              JOIN @AI AI ON AI.TwrId = T.Twr_TwrId
              LEFT OUTER JOIN cdn.TwrIlosci I ON I.TwI_TwIId = CDN.TwrIlosciID ( T.Twr_TwrId, @TrN_MagZrdId_Doc, convert(datetime,@TrN_DataOpe_Doc,120))
              --LEFT OUTER JOIN cdn.TwrIlosci I ON T.Twr_TwrId = I.TwI_TwrId AND I.TwI_MagId = @TrN_MagZrdId_Doc AND I.TwI_Data = (SELECT TOP 1 H.TwI_Data FROM CDN.TwrIlosci H WHERE H.TwI_TwrId = T.Twr_TwrId AND H.TwI_MagId = @TrN_MagZrdId_Doc AND H.TwI_Data <=@TrN_DataOpe_Doc ORDER BY H.TwI_Data DESC )
            -- dla 42 i 43 usuwamy stany zerowe
            IF @Kontekst IN (42,43,420,430)
               DELETE FROM cdn.TraElem WHERE Tre_TrNId = @TrN_TrNId_Doc AND TrE_IloscJM = 0
            -- dla 40,410,420,430 ustawiamy zera
            IF @Kontekst in (40,410,420,430)
               UPDATE cdn.TraElem SET TrE_Ilosc = 0, TrE_IloscJM = 0,TrE_WartoscBruttoWal = 0,TrE_WartoscNettoWal = 0,TrE_WartoscBrutto = 0,TrE_WartoscNetto = 0 WHERE Tre_TrNId = @TrN_TrNId_Doc
            -- ustawiamy lp i lppow po kasowaniu
            IF @Kontekst IN (42,43,420,430,40,410,41,410)
            BEGIN
              CREATE TABLE #TrELpPI (TrE_TrEId_Old INT, TrE_Lp_New INT IDENTITY ( 1,1 ) )
              INSERT INTO #TrELpPI ( TrE_TrEId_Old )
                     SELECT TrE_TrEId FROM cdn.TraElem WHERE TrE_TrNId = @TrN_TrNId_Doc
              UPDATE cdn.TraElem SET TrE_Lp = TrE_Lp_New,TrE_LpPow = TrE_Lp_New
                FROM cdn.TraElem JOIN #TrELpPI ON TrE_TrEId_Old = TrE_TrEId
     DROP TABLE #TrELpPI
            END
            -- aktualizacja tabelki VAT
            EXEC CDN.AktualizujTraVATTraNag  @TrN_TrNId_Doc
           --SO dodanie atrybutów, zamiast cursora będzie pęlta While
/*
      DECLARE @TowaryAtrybuty TABLE (Ta_Id INT IDENTITY(1,1), Ta_TwrID INT PRIMARY KEY (Ta_Id))
      DECLARE @TwrIDAtr INT, @Ta_Id INT, @Ta_IdMax INT
        INSERT INTO @TowaryAtrybuty (TA_TwrID)
        SELECT TrE_TwrID FROM cdn.TraElem
              JOIN CDN.TwrAtrybuty ON TwA_TwrId = TrE_TwrId
              JOIN CDN.DefAtrybuty ON TwA_DeaId = DeA_DeAId
                  WHERE DeA_Typ<>5 AND TrE_TrNId = @TrN_TrNId_Doc
 SELECT @Ta_IdMax = MAX(Ta_Id) FROM @TowaryAtrybuty
          IF EXISTS (SELECT * FROM @TowaryAtrybuty)
           BEGIN
             SELECT @Ta_Id = 1
              WHILE 1 = 1 AND @Ta_Id <  @Ta_IdMax
                BEGIN
                 CREATE TABLE #AtrybutyElem (TwrID INT  ,TwA_DeAID1 INT,DeA_Kod1 NVARCHAR(20), TwA_Wartosctxt1 NVARCHAR(100),TwA_DeAID2 INT,DeA_Kod2 NVARCHAR(20), TwA_Wartosctxt2 NVARCHAR(100),TwA_DeAID3 INT,DeA_Kod3 NVARCHAR(20), TwA_Wartosctxt3 NVARCHAR(100),TwA_DeAID4 INT,DeA_Kod4 NVARCHAR(20), TwA_Wartosctxt4 NVARCHAR(100),TwA_DeAID5 INT,DeA_Kod5 NVARCHAR(20), TwA_Wartosctxt5 NVARCHAR(100))
          SELECT @TwrIdAtr = Ta_TwrID FROM @TowaryAtrybuty WHERE Ta_Id = @Ta_Id
                 INSERT INTO  dbo.#AtrybutyElem exec CDN.sp_PobierzAtrybuty 0, 0, @TwrIdAtr
                  UPDATE cdn.traelem SET
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
                      FROM  CDN.TraElem
                      JOIN dbo.#AtrybutyElem on TrE_TwrID = TwrID
                      WHERE TrE_TrNId = @TrN_TrNId_Doc
                       DROP TABLE dbo.#AtrybutyElem
                     IF @Ta_Id >  @Ta_IdMax BREAK
                      SELECT @Ta_Id = @Ta_Id + 1
                  END
             END
*/
   -- dodanie atrybutow
   IF ISNULL(@BezAtrybutow,0) = 0
   BEGIN    -- WiNi 2015-11-04
    INSERT INTO [CDN].[TraElemAtr]
     ([TrA_TrEId]
     ,[TrA_Lp]
     ,[TrA_DeAId]
     ,[TrA_Kod]
     ,[TrA_Wartosc]
     ,[TrA_ESklep])
    SELECT TrE_TrEID,ROW_NUMBER()OVER (PARTITION BY Tre_treid  ORDER BY Twa_lp) as lp, TwA_DeAID, DeA_Kod, TwA_WartoscTxt,0 FROM CDN.TraElem
    Join CDN.TwrAtrybuty on TrE_TwrId = TwA_TwrID
    JOIN CDN.DefAtrybuty ON TwA_DeAID = DeA_DeAID
    WHERE TwA_CzyPrzenosic = 1 AND Tre_TrnID = @TrN_TrNId_Doc
    AND TwA_Zalezny = 0
    /*CREATE TABLE #AtrybutyElem (TrEId INT, Lp INT, TwA_DeAID INT, DeA_Kod NVARCHAR(20), TwA_Wartosctxt NVARCHAR(100))
    INSERT INTO #AtrybutyElem
    SELECT TrE_TrEId, Lp, TwA_DeAID, DeA_Kod, TwA_Wartosctxt
    FROM
    (
     SELECT  TrE_TrEId, TrE_TwrId, TwA_TwrId, TwA_LP, TwA_DeAID, DeA_Kod, TwA_Wartosctxt, RANK() OVER(PARTITION BY TwA_TwrId ORDER BY TwA_LP) Lp
     FROM CDN.TwrAtrybuty
     JOIN CDN.DefAtrybuty ON TwA_DeAID = DeA_DeAID
     JOIN CDN.TraElem ON TrE_TwrId = TwA_TwrId AND TrE_TrNId = @TrN_TrNId_Doc
     WHERE TwA_CzyPrzenosic = 1 AND TwA_Zalezny = 0
    ) X
    WHERE Lp < 6
    UPDATE e SET
      TrE_Atr1_DeAID   =  TwA_DeAID
     ,TrE_Atr1_Kod     =  IsNULL(DeA_Kod,'')
     ,TrE_Atr1_Wartosc =  IsNULL(TwA_Wartosctxt,'')
    FROM cdn.TraElem e JOIN #AtrybutyElem a ON a.TrEId = e.TrE_TrEId AND a.Lp = 1
    UPDATE e SET
      TrE_Atr2_DeAID   =  TwA_DeAID
     ,TrE_Atr2_Kod     =  IsNULL(DeA_Kod,'')
     ,TrE_Atr2_Wartosc =  IsNULL(TwA_Wartosctxt,'')
    FROM cdn.TraElem e JOIN #AtrybutyElem a ON a.TrEId = e.TrE_TrEId AND a.Lp = 2
    UPDATE e SET
      TrE_Atr3_DeAID   =  TwA_DeAID
     ,TrE_Atr3_Kod     =  IsNULL(DeA_Kod,'')
     ,TrE_Atr3_Wartosc =  IsNULL(TwA_Wartosctxt,'')
    FROM cdn.TraElem e JOIN #AtrybutyElem a ON a.TrEId = e.TrE_TrEId AND a.Lp = 3
    UPDATE e SET
      TrE_Atr4_DeAID   =  TwA_DeAID
     ,TrE_Atr4_Kod     =  IsNULL(DeA_Kod,'')
     ,TrE_Atr4_Wartosc =  IsNULL(TwA_Wartosctxt,'')
    FROM cdn.TraElem e JOIN #AtrybutyElem a ON a.TrEId = e.TrE_TrEId AND a.Lp = 4
    UPDATE e SET
      TrE_Atr5_DeAID   =  TwA_DeAID
     ,TrE_Atr5_Kod     =  IsNULL(DeA_Kod,'')
     ,TrE_Atr5_Wartosc =  IsNULL(TwA_Wartosctxt,'')
    FROM cdn.TraElem e JOIN #AtrybutyElem a ON a.TrEId = e.TrE_TrEId AND a.Lp = 5
    DROP TABLE #AtrybutyElem*/
   END
            -- TrN_TrNId utworzonego AI
                  SELECT @TrN_TrNId_Doc
            IF @Licznik >=  @Koniec BREAK
            SELECT @Licznik = @Licznik + 1
          END
  --    CLOSE M
  --    DEALLOCATE M
     END
  -- PWAI/RWAI na podstawie zaznaczonych dokumentów AI/FSKP/FZKP
   IF @Kontekst IN (5,6) -- 5 AI, 6 Korekta do faktury pierwotnej
    BEGIN
      IF @Kontekst =5
        BEGIN
          IF EXISTS ( SELECT * FROM cdn.TraNag JOIN CDN.Text2TableInt( @TrN_TrNId_Zrd_List ) ON NextIdInt = TrN_TrNId AND TrN_Bufor = 1  )
            BEGIN
              SET @Komunikat = '##OPT34476##'--' Inwentaryzacja niemożliwa ! Wśród zaznaczonych arkuszy występuje arkusz w buforze ! '
              GOTO KOMUNIKAT
            END
          IF EXISTS ( SELECT * FROM cdn.TraNag JOIN CDN.Text2TableInt( @TrN_TrNId_Zrd_List ) ON NextIdInt = TrN_TrNId AND TrN_Bufor = -1  )
            BEGIN
              SET @Komunikat = '##OPT34477##'--' Inwentaryzacja niemożliwa ! Wśród zaznaczonych arkuszy występuje arkusz anulowany ! '
              GOTO KOMUNIKAT
            END
          IF EXISTS ( SELECT * FROM cdn.TraNag JOIN CDN.Text2TableInt( @TrN_TrNId_Zrd_List ) ON NextIdInt = TrN_TrNId AND TrN_TypDokumentu = 311 AND TrN_Rodzaj = 311001 )
            BEGIN
              SET @Komunikat = '##OPT34478##'--' Inwentaryzacja niemożliwa ! Wśród zaznaczonych arkuszy występuje arkusz zinwentaryzowany ! '
              GOTO KOMUNIKAT
           END
        END
      IF @Kontekst = 6
        BEGIN
          IF EXISTS ( SELECT * FROM cdn.TraNag JOIN CDN.Text2TableInt( @TrN_TrNId_Zrd_List ) ON NextIdInt = TrN_TrNId AND (TrN_Rodzaj not in(301101,302101,305101) or TrN_Bufor=1)  )
            BEGIN
              SET @Komunikat = '##OPT34479##'--' Przekształcenie niemożliwe ! Zaznaczony dokument jest w buforze lub nie jest korektą do dokumentu pierwotnego ! '
              GOTO KOMUNIKAT
            END
          IF EXISTS ( SELECT * FROM cdn.TraNag JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId JOIN CDN.Text2TableInt( @TrN_TrNId_Zrd_List ) ON NextIdInt = TrR_FAId AND (TrN_TypDokumentu in(303,304) AND TrN_Bufor <> -1)  )
            BEGIN
              SET @Komunikat = '##OPT34480##'--' Przekształcenie niemożliwe ! Do zaznaczonego dokumentu zostały wygenerowane dokumenty RW/PW  ! '
              GOTO KOMUNIKAT
            END
        END
      -- ustawiamy ilosci z podarkuszy
      IF @Kontekst = 5
   BEGIN
        EXEC cdn.PrzeliczIlosciPI @TrN_TrNId_Zrd,0
        EXEC CDN.AktualizujTraVATTraNag  @TrN_TrNId_Zrd
   END
      -- tabela przygotowująca ilości oddzielnie dla każdego arkusza AI
      DECLARE @Ilosci TABLE ( PWRW INT, TwrId INT, Ilosc DECIMAL(20,4), LpPow INT )
      -- kursor po zaznaczonych arkuszach AI
      DECLARE N CURSOR LOCAL FAST_FORWARD FOR
        SELECT NextIdInt FROM CDN.Text2TableInt( @TrN_TrNId_Zrd_List ) WHERE NextIdInt > 0
      OPEN N
        WHILE 1=1
        BEGIN
          FETCH NEXT FROM N INTO @TrN_TrNId_Zrd
          IF @@FETCH_STATUS <> 0 BREAK
          -- dane z nagłówka arkusza źródłowgo
          SELECT
            @TrN_MagZrdId_Doc     = ISNULl(TrN_MagZrdId,1),
            @TrN_DataOpe_Doc      = TrN_DataOpe,
            @DataToday = CONVERT(NVARCHAR(10), TrN_DataOpe, 120)
          FROM cdn.TraNag
          WHERE TrN_TrNId = @TrN_TrNId_Zrd
          -- tabelka ilości do uzupełnienia na PW/RW
          DELETE FROM @Ilosci
          IF @Kontekst =5
            BEGIN
              INSERT INTO @Ilosci ( PWRW, TwrId, Ilosc, LpPow )
                SELECT
                -- Flaga PWRW
                  CASE
                    WHEN ( E.TrE_Ilosc - ISNULL(I.TwI_Ilosc,0) ) > 0 THEN 1
                    WHEN ( E.TrE_Ilosc - ISNULL(I.TwI_Ilosc,0) ) < 0 THEN 2
                  END,
                -- TwrId
                  E.TrE_TwrId,
                -- Ilosc
                  ABS( E.TrE_Ilosc - ISNULL(I.TwI_Ilosc,0) ),
                --LpPow
                  E.TrE_LpPow
                FROM CDN.TraElem E
                  LEFT OUTER JOIN CDN.TwrIlosci I ON E.TrE_TwrId = I.TwI_TwrId AND I.TwI_MagId = @TrN_MagZrdId_Doc
                    AND I.TwI_Data = ( SELECT TOP 1 H.TwI_Data
                                         FROM CDN.TwrIlosci H
                                         WHERE H.TwI_TwrId = E.TrE_TwrId AND H.TwI_MagId = @TrN_MagZrdId_Doc AND H.TwI_Data <= @TrN_DataOpe_Doc
                                         ORDER BY H.TwI_Data DESC
                                     )
                  LEFT OUTER JOIN cdn.TwrCeny C ON C.TwC_TwrId = E.TrE_TwrId AND C.TwC_TwCNumer = 1
                WHERE E.TrE_TrNId = @TrN_TrNId_Zrd AND ABS( E.TrE_Ilosc - ISNULL(I.TwI_Ilosc,0) ) <> 0
            END
          ELSE
            BEGIN
              INSERT INTO @Ilosci ( PWRW, TwrId, Ilosc, LpPow )
              SELECT
              -- Flaga PW(303(1))RW(304(2))
                CASE
                  WHEN  E.TrE_TypDokumentu =301   THEN
                    CASE
                      WHEN ( E.TrE_Ilosc  ) > 0 THEN 1
                      WHEN ( E.TrE_Ilosc  ) < 0 THEN 2
                    END
                  ELSE
                    CASE
                      WHEN ( E.TrE_Ilosc  ) > 0 THEN 2
                      WHEN ( E.TrE_Ilosc  ) < 0 THEN 1
                    END
                END,
              -- TwrId
                E.TrE_TwrId,
              -- Ilosc
                ABS( E.TrE_Ilosc ),
              --LpPow
                E.TrE_LpPow
              FROM CDN.TraElem E
                JOIN cdn.Towary T ON E.TrE_TwrId = T.Twr_TwrId
              WHERE E.TrE_TrNId = @TrN_TrNId_Zrd
                AND T.Twr_Typ = 1
            END
          -- najpierw PW
          SET @PWRW = 1
          WHILE 1 = 1
            BEGIN
              IF @Kontekst = 5
                BEGIN
                  -- PW ( ilosci > 0 )
                  IF @PWRW = 1
                    SET @TrN_Rodzaj_Doc = 303010
                  -- RW ( ilosci < 0 )
                  IF @PWRW = 2
                    SET @TrN_Rodzaj_Doc = 304010
                  IF @PWRW > 2
                    BREAK
                END
              ELSE
                BEGIN
                   -- PW ( ilosci > 0 )
                   IF @PWRW = 1
                      SET @TrN_Rodzaj_Doc = 303000
                   -- RW ( ilosci < 0 )
                   IF @PWRW = 2
                      SET @TrN_Rodzaj_Doc = 304000
                   -- PW ( ilosci > 0 )
                  IF @PWRW > 2
                    BREAK
                END
              IF EXISTS ( SELECT * FROM @Ilosci WHERE @PWRW IN ( 1, 2 ) AND PWRW = @PWRW )
                BEGIN
                  -- Lp w ramach elementów PW lub RW
                  CREATE TABLE #Lp ( Lp_Lp INT IDENTITY ( 1, 1 ), Lp_TwrId INT,Lp_LpPow INT )
                  INSERT INTO #Lp ( Lp_TwrId,Lp_LpPow )
                    SELECT TwrId,LpPow  FROM @Ilosci WHERE PWRW = @PWRW
                  -- nagłówek
                  EXEC CDN.DodajTraNag
                    @TrN_TrNId_Zrd_List,                 -- @TrN_TrNId_Zrd      INT,           -- TrN_TrNId nagłówka do dodania lub do skopiowania (może być NULL, jeśli @TrN_Rodzaj_Doc IS NOT NULL AND @TrN_MagZrdId_Doc IS NOT NULL )
                    @TrN_Rodzaj_Doc,      -- @TrN_Rodzaj_Doc     INT,           -- TrN_Rodzaj dokumentu docelowego ( może być null, jeśli @TrN_TrNId_Zrd IS NOT NULL )
                    @TrN_MagZrdId_Doc,    -- @TrN_MagZrdId_Doc   INT,           -- TrN_MagZrdId dokumentu docelowego ( może być null, jeśli @TrN_TrNId_Zrd IS NOT NULL )
                    @TrN_DataOpe_Doc,     -- @TrN_DataDok_Doc    DATETIME,      --
                    @TrN_DataOpe_Doc,     -- @TrN_DataWys_Doc    DATETIME,      --
                    @TrN_DataOpe_Doc,     -- @TrN_DataOpe_Doc    DATETIME,      --
                    @ServerCfgString,     -- @SeverCfgString     NVARCHAR(250),  -- nazwa serwera z bazą konfiguracyjną
                    @BazaCfgString,       -- @BazaCfgString      NVARCHAR(250),  -- nazwa bazy konfiguracyjnej
                    @TrN_OpeZalId,        -- @TrN_OpeZalId_Doc   INT,           -- Opertor zalogowany do programu, który wykonuje operację przekształcenia
                    @TrN_StaZalId,        -- @TrN_StaZalId_Doc   INT,           -- Sanowisko, z którego jest wykonywana operacja przekształcenia
                    @DataToday,           -- @DataToday          NVARCHAR(100),  -- Data Today z programu (może być inna niż z serwera)
                    -1,                   -- @Kontekst           INT,           -- Kontekst wywołania: -1 (minus jeden) - nagłówek z kontrahentem "Nieokreślony"; 0 - WZ/PZ/WKA/PKA z formularza, 1 - WZ/PZ/WKA/PKA z listy, 2 - WKA/PKA jako nowy dokument z listy FA/PA/FZ
                    @Seria,
                    @TrN_TrNId_Doc OUTPUT -- @TrN_TrNId_Doc INT OUTPUT          -- zwracany TrN_TrNId dokumentu docelowego
                  IF @Kontekst = 5
                    BEGIN
                    -- związanie PW z AI
                      UPDATE cdn.TraNag SET
                        TrN_FaId = @TrN_TrNId_Zrd
                      WHERE TrN_TrNId = @TrN_TrNId_Doc
                  INSERT INTO [CDN].[TraNagRelacje]
                            ([TrR_TrNTyp]
                            ,[TrR_TrNId]
                            ,[TrR_FaTyp]
                            ,[TrR_FaId]
                            ,[TrR_Flaga])
                   VALUES
                           (CONVERT(INT, @TrN_Rodzaj_Doc/1000)
                           ,@TrN_TrNId_Doc
                           ,0
                           ,@TrN_TrNId_Zrd
                           ,0
                           )
                    -- cy PWAI do bufora
                      IF (@PWRW = 2 AND ( SELECT ISNULL( MAX(Fir_Wartosc), 0 ) FROM cdn.Firma WHERE Fir_Numer = 1892 ) = 0 ) OR ( @PWRW = 1 AND ( SELECT ISNULL( MAX(Fir_Wartosc), 0 ) FROM cdn.Firma WHERE Fir_Numer = 1687 ) = 0 )
       Begin
                        UPDATE Cdn.TraNag SET TrN_Bufor = 0 WHERE TrN_TrNId = @TrN_TrNId_Doc
      select @NumerPelny = TrN_numerPelny,@TypDokumentu = trn_typdokumentu from cdn.tranag where trn_trnid = @TrN_TrNId_Doc
      exec [CDN].[RejestrOperacjiDodaj] @TypDokumentu,0, @TrN_TrNId_Doc, @NumerPelny, 103, ''
      Update A SET
      A.TrN_OpeZatwID = A.TrN_OpeModID ,
      A.TrN_OpeZatwKod= A.TrN_OpeModKod ,
      A.TrN_OpeZatwNazwisko= A.TrN_OpeModNazwisko,
      A.TrN_TS_Zatw = A.TrN_TS_Mod
      FROM CDN.TraNag A
      WHERE A.TrN_TrNId = @TrN_TrNId_Doc
       END
                    END
                  IF @Kontekst = 6
                    BEGIN
                    -- związanie PW z FSKP
                      UPDATE cdn.TraNag SET
                        TrN_RelTrnId = @TrN_TrNId_Zrd
                      WHERE TrN_TrNId = @TrN_TrNId_Doc
                   INSERT INTO [CDN].[TraNagRelacje]
                            ([TrR_TrNTyp]
                            ,[TrR_TrNId]
                            ,[TrR_FaTyp]
                            ,[TrR_FaId]
                            ,[TrR_Flaga])
                   VALUES
                           (CONVERT(INT, @TrN_Rodzaj_Doc/1000)
                           ,@TrN_TrNId_Doc
                           ,0
                           ,@TrN_TrNId_Zrd
                           ,0
                           )
     IF CONVERT(INT, @TrN_Rodzaj_Doc/1000) = 304
                   Update A SET
   A.TrN_PodmiotTyp = B.TrN_PodmiotTyp,
   A.TrN_PodID = B.TrN_PodID,
   A.TrN_PodNazwa1 = B.TrN_PodNazwa1,
   A.TrN_PodNazwa2 = B.TrN_PodNazwa2,
   A.TrN_PodNazwa3 = B.TrN_PodNazwa3,
           A.TrN_PodKraj = B.TrN_PodKraj,
           A.TrN_PodWojewodztwo = B.TrN_PodWojewodztwo,
           A.TrN_PodPowiat = B.TrN_PodPowiat,
           A.TrN_PodGmina = B.TrN_PodGmina,
           A.TrN_PodUlica = B.TrN_PodUlica,
           A.TrN_PodNrDomu = B.TrN_PodNrDomu,
           A.TrN_PodNrLokalu = B.TrN_PodNrLokalu,
           A.TrN_PodMiasto = B.TrN_PodMiasto,
           A.TrN_PodKodPocztowy = B.TrN_PodKodPocztowy,
           A.TrN_PodPoczta = B.TrN_PodPoczta,
           A.TrN_PodAdres2 = B.TrN_PodAdres2,
           A.TrN_PodNipKraj = B.TrN_PodNipKraj,
           A.TrN_PodNipE = B.TrN_PodNipE,
           A.TrN_PodmiotGLN = B.TrN_PodmiotGLN,
           A.TrN_Finalny = B.TrN_Finalny,
     A.TrN_PodatekVat = B.TrN_PodatekVat,
     A.TrN_Pesel = B.TrN_Pesel,
           A.TrN_Export = B.TrN_Export
    FROM CDN.TraNag A
    JOIN CDN.TraNag B ON B.TrN_TrNID =  @TrN_TrNId_Zrd
    WHERE A.TrN_TrNId = @TrN_TrNId_Doc
                    --  RW na stałe
                      IF @PWRW = 2
       Begin
                        UPDATE cdn.TraNag SET TrN_Bufor = 0 WHERE TrN_TrNId = @TrN_TrNId_Doc
      select @NumerPelny = TrN_numerPelny,@TypDokumentu = trn_typdokumentu from cdn.tranag where trn_trnid = @TrN_TrNId_Doc
      exec [CDN].[RejestrOperacjiDodaj] @TypDokumentu,0, @TrN_TrNId_Doc, @NumerPelny, 103, ''
      Update A SET
      A.TrN_OpeZatwID = A.TrN_OpeModID ,
      A.TrN_OpeZatwKod= A.TrN_OpeModKod ,
      A.TrN_OpeZatwNazwisko= A.TrN_OpeModNazwisko,
      A.TrN_TS_Zatw = A.TrN_TS_Mod
      FROM CDN.TraNag A
      WHERE A.TrN_TrNId = @TrN_TrNId_Doc
       END
                      IF @PWRW = 1
                        UPDATE cdn.TraNag SET TrN_Bufor = 1 WHERE TrN_TrNId = @TrN_TrNId_Doc
                    END
                  -- elementy
                  INSERT INTO cdn.TraElem
                  (
                    TrE_TrNId,
                    TrE_ZwrId,
                    TrE_TrEIdProd,
                    TrE_PdRId,
                    TrE_Lp,
                    TrE_LpPow,
                    TrE_TypDokumentu,
                    TrE_Aktywny,
                    TrE_DataDok,
                    TrE_DataOpe,
                    TrE_PodmiotTyp,
                    TrE_PodId,
                    TrE_KatId,
                    TrE_TwrId,
                    TrE_TwrNazwa,
                    TrE_TwrEAN,
     TrE_TwrTyp ,
     TrE_TwrKodDostawcy,
                    TrE_TwrNumerKat,
                    TrE_TwrKod,
                    TrE_TwrOpis,
                    TrE_TwrSWW,
                    TrE_Stawka,
                    TrE_Flaga,
                    TrE_Zrodlowa,
                    TrE_TwCNumer,
                    TrE_TypNB,
                    TrE_Cena0,
                    TrE_Rabat,
                    TrE_CenaW,
                    TrE_Waluta,
                    TrE_KursNumer,
                    TrE_KursL,
                    TrE_KursM,
                    TrE_CenaT,
                    TrE_Ilosc,
                    TrE_Jm,
                    TrE_JmZ,
                    TrE_JmCalkowite,
                    TrE_JMPrzelicznikL,
                    TrE_JMPrzelicznikM,
                    TrE_IloscJM,
                    TrE_WartoscNetto,
                    TrE_WartoscBrutto,
                    TrE_KosztUslugi,
                    TrE_WartoscZakupuWylicz,
                    TrE_Cena0WD,
                    TrE_CenaWWD,
                    TrE_WartoscNettoWal,
                    TrE_WartoscBruttoWal,
                    TrE_Prog,
                    TrE_UpustTyp,
                    TrE_Upust,
                    TrE_UpustKnt,
                    TrE_UpustKntTyp,
                    TrE_Kaucja,
                    TrE_RabatPromocyjny,
                    TrE_RabatKorekta,
                    TrE_Promocje,
                    TrE_IloscJMKW,
                    TrE_IloscKW,
                    TrE_Atr1_DeAId,
                    TrE_Atr1_Kod,
                    TrE_Atr1_Wartosc,
                    TrE_Atr2_DeAId,
                    TrE_Atr2_Kod,
                    TrE_Atr2_Wartosc,
                    TrE_Atr3_DeAId,
                    TrE_Atr3_Kod,
                    TrE_Atr3_Wartosc,
                    TrE_Atr4_DeAId,
                    TrE_Atr4_Kod,
                    TrE_Atr4_Wartosc,
                    TrE_Atr5_DeAId,
                    TrE_Atr5_Kod,
                    TrE_Atr5_Wartosc,
                    TrE_MagId,
                    TrE_WyborDostaw,
     TrE_CenaZCzteremaMiejscami
                  )
                  SELECT
                   @TrN_TrNId_Doc,                                                              -- TrE_TrNId
                    NULL,                                                                       -- TrE_ZwrId
                    NULL,                                                                       -- TrE_TrEIdProd
                    NULL,                                                                       -- TrE_PdRId
                    Lp_Lp,                                                                      -- TrE_Lp
                    E.TrE_LpPow,                                                                -- TrE_LpPow
                    CONVERT(INT, @TrN_Rodzaj_Doc/1000),                                         -- TrE_TypDokumentu
                    1,                                                                          -- TrE_Aktywny
                   @TrN_DataOpe_Doc,                                                            -- TrE_DataDok
                   @TrN_DataOpe_Doc,                                                            -- TrE_DataOpe
                    1,                                                                          -- TrE_PodmiotTyp
                    1,                                                                          -- TrE_PodId
                    NULL,                                                                       -- TrE_KatId
                    E.TrE_TwrId,                                                                -- TrE_TwrId
                    E.TrE_TwrNazwa,                                                             -- TrE_TwrNazwa
                    E.TrE_TwrEAN,                                                               -- TrE_TwrEAN
     E.TrE_TwrTyp ,
     E.TrE_TwrKodDostawcy,
                    E.TrE_TwrNumerKat,                                                          -- TrE_TwrNumerKat
                    E.TrE_TwrKod,                                                               -- TrE_TwrKod
                    E.TrE_TwrOpis,                                                              -- TrE_TwrOpis
                    E.TrE_TwrSWW,                                                               -- TrE_TwrSWW
                    E.TrE_Stawka,                                                               -- TrE_Stawka
                    E.TrE_Flaga,                                                                -- TrE_Flaga
                    E.TrE_Zrodlowa,                                                             -- TrE_Zrodlowa
                    E.TrE_TwCNumer,                                                             -- TrE_TwCNumer
                    1,                                                                          -- TrE_TypNB
                    E.TrE_Cena0,                                                                -- TrE_Cena0
                    0,                                                                          -- TrE_Rabat
                    E.TrE_CenaW,                                                                -- TrE_CenaW
                    E.TrE_Waluta,                                                               -- TrE_Waluta
                    E.TrE_KursNumer,                                                            -- TrE_KursNumer
                    E.TrE_KursL,                                                                -- TrE_KursL
                    E.TrE_KursM,                                                                -- TrE_KursM
                    E.TrE_CenaT,                                                                -- TrE_CenaT
                    I.Ilosc,                                                                    -- TrE_Ilosc
                    E.TrE_Jm,                                                                   -- TrE_Jm
                    E.TrE_JmZ,                                                                  -- TrE_JmZ
                    E.TrE_JmCalkowite,                                                          -- TrE_JmCalkowite
                    E.TrE_JMPrzelicznikL,                                                       -- TrE_JMPrzelicznikL
                    E.TrE_JMPrzelicznikM,                                                       -- TrE_JMPrzelicznikM
                    ROUND ( E.TrE_JMPrzelicznikM / E.TrE_JMPrzelicznikL * I.Ilosc, 4),          -- TrE_IloscJM
                    ROUND(ROUND ( E.TrE_JMPrzelicznikM / E.TrE_JMPrzelicznikL * I.Ilosc, 4)* E.TrE_CenaT,2),                                          -- TrE_WartoscNetto
                    ROUND(ROUND(ROUND ( E.TrE_JMPrzelicznikM / E.TrE_JMPrzelicznikL * I.Ilosc, 4)* E.TrE_CenaT,2) * ( 1 + E.TrE_Stawka / 100 ),2),    -- TrE_WartoscBrutto
                    0,                                                                                                                                -- TrE_KosztUslugi
                    0,
                    E.TrE_Cena0WD,                                                              -- TrE_Cena0WD
                    E.TrE_CenaWWD,                                                              -- TrE_CenaWWD
                    ROUND(ROUND ( E.TrE_JMPrzelicznikM / E.TrE_JMPrzelicznikL * I.Ilosc, 4) * E.TrE_CenaWWD,2),                                       -- TrE_WartoscNettoWal
                    ROUND(ROUND(ROUND ( E.TrE_JMPrzelicznikM / E.TrE_JMPrzelicznikL * I.Ilosc, 4) * E.TrE_CenaWWD,2) * ( 1 + E.TrE_Stawka / 100 ),2), -- TrE_WartoscBruttoWal
                    0,                                                                          -- TrE_Prog
                    0,                                                                          -- TrE_UpustTyp
                    0,                                                                          -- TrE_Upust
                    0,                                                                          -- TrE_UpustKnt
                    0,                                                                          -- TrE_UpustKntTyp
                    0,                                                                          -- TrE_Kaucja
                    0,                                                                          -- TrE_RabatPromocyjny,
                    0,                                                                          -- TrE_RabatKorekta,
                    0,                                                                          -- TrE_Promocje
                    0,                                                                          -- TrE_IloscJMKW,
                    0,
                    E.TrE_Atr1_DeAId,
                    E.TrE_Atr1_Kod,
                    E.TrE_Atr1_Wartosc,
                    E.TrE_Atr2_DeAId,
                    E.TrE_Atr2_Kod,
                    E.TrE_Atr2_Wartosc,
                    E.TrE_Atr3_DeAId,
                    E.TrE_Atr3_Kod,
                    E.TrE_Atr3_Wartosc,
                    E.TrE_Atr4_DeAId,
                    E.TrE_Atr4_Kod,
                    E.TrE_Atr4_Wartosc,
                    E.TrE_Atr5_DeAId,
                    E.TrE_Atr5_Kod,
                    E.TrE_Atr5_Wartosc,
                    E.TrE_MagId,
                    0,
     E.TrE_CenaZCzteremaMiejscami
                  FROM cdn.TraElem E
                    JOIN @Ilosci I ON E.TrE_TwrId = I.TwrId AND I.PWRW = @PWRW AND E.TrE_LpPow = I.LpPow
                    JOIN #Lp L ON L.Lp_TwrId = I.TwrId AND L.Lp_LpPow = I.LpPow
                  WHERE TrE_TrNId = @TrN_TrNId_Zrd
                  -- ceny zakupu dla PW
                   IF @Kontekst = 6 AND @PWRW=1
                     Update CDN.TraElem SET
                            TrE_TwCNumer=1,
                            TrE_Cena0=TwC_Wartosc,
                            TrE_CenaW=ROUND(TwC_Wartosc*TrE_JMPrzelicznikL / TrE_JMPrzelicznikM, 2),
                            TrE_Waluta=TwC_Waluta,
                            TrE_KursL=Twr_KursL,
                            TrE_KursM=Twr_KursM,
                            --TrE_Stawka=Twr_StawkaZak,
                            --TrE_Flaga=Twr_FlagaZak,
                            --TrE_Zrodlowa=Twr_ZrodlowaZak,
                            TrE_CenaT=ROUND(TwC_Wartosc*Twr_KursL/Twr_KursM*TrE_JMPrzelicznikL / TrE_JMPrzelicznikM, case when TrE_CenaZCzteremaMiejscami = 1 then 4 else 2 end),
                            TrE_Cena0WD=ROUND(TwC_Wartosc*Twr_KursL/Twr_KursM, case when TrE_CenaZCzteremaMiejscami = 1 then 4 else 2 end),
                            TrE_CenaWWD=ROUND(TwC_Wartosc*Twr_KursL/Twr_KursM*TrE_JMPrzelicznikL / TrE_JMPrzelicznikM, case when TrE_CenaZCzteremaMiejscami = 1 then 4 else 2 end),
                            TrE_WartoscNetto=ROUND(Tre_Ilosc*TwC_Wartosc*Twr_KursL/Twr_KursM, 2),
                            TrE_WartoscBrutto=ROUND(ROUND(Tre_Ilosc*TwC_Wartosc*Twr_KursL/Twr_KursM, 2) * (100 + TrE_Stawka )/100, 2),
                            TrE_WartoscNettoWal=ROUND(Tre_Ilosc*TwC_Wartosc*Twr_KursL/Twr_KursM, 2),
                            TrE_WartoscBruttoWal= ROUND(ROUND(Tre_Ilosc*TwC_Wartosc*Twr_KursL/Twr_KursM, 2) * (100 + TrE_Stawka )/100, 2)
                     FROM cdn.TraElem JOIN cdn.Towary
                     ON TrE_TwrId = Twr_TwrId JOIN cdn.Twrceny
                     ON TwC_TwrId = Twr_TwrId AND TwC_TwCNumer =1
                     WHERE TrE_TrNId =@TrN_TrNId_Doc
     INSERT INTO [CDN].[TraElemAtr]
      ([TrA_TrEId]
      ,[TrA_Lp]
      ,[TrA_DeAId]
      ,[TrA_Kod]
      ,[TrA_Wartosc]
      ,[TrA_ESklep])
     select
      B.tre_treid,
      TrA_Lp,
      TrA_DeAId,
      TrA_Kod,
      TrA_Wartosc,
      TrA_ESklep
     FROM cdn.TraElemAtr
     left join cdn.TraElem A on TrA_TrEId = a.TrE_TrEID
     left join cdn.traelem B on B.TrE_LpPow = a.TrE_LpPow
     where  B.TrE_TrNId = @TrN_TrNId_Doc and A.TrE_TrNID = @TrN_TrNId_Zrd
                  -- nagłówek
                  EXEC CDN.AktualizujTraVATTraNag @TrN_TrNId_Doc
                  DROP TABLE #Lp
                END
              -- teraz RW
              SET @PWRW = @PWRW + 1
            END -- END WHILE
          -- Ustawienie na AI nowego rodzaju
          IF @Kontekst = 5
          UPDATE cdn.TraNag SET
            TrN_Rodzaj = 311001
          WHERE TrN_TrNId = @TrN_TrNId_Zrd
         END -- END CURSOR
      CLOSE N
      DEALLOCATE N
    END
/*
  -- Ofertowanie
  IF @Kontekst IN (2)
    BEGIN
  -- Oferta
  IF CONVERT( INT, @TrN_Rodzaj_Doc/1000 ) = 800
    SELECT
      @TrN_Rodzaj_Doc = 800000 -- Ofertowanie (nie TraNag)
  -- Ofertowanie
  IF @TrN_Rodzaj_Doc = 320000
    SELECT
      @TrN_DataWys_Doc = @DataTodayNoTime,
      @TrN_DataDok_Doc = @DataTodayNoTime,
      @TrN_DataOpe_Doc = @DataTodayNoTime
    END
  -- Pro-Forma z ofertowania
  IF @Kontekst IN (2)
    BEGIN
  -- FPF do oferty
  IF CONVERT( INT, @TrN_Rodzaj_Doc/1000 ) = 320
    SELECT
      @TrN_Rodzaj_Doc = @TrN_Rodzaj_Doc -- FPF do oferty
  -- ProForma
  IF @TrN_Rodzaj_Doc = 800000
    SELECT
      @TrN_DataWys_Doc = @DataTodayNoTime,
      @TrN_DataDok_Doc = @DataTodayNoTime,
      @TrN_DataOpe_Doc = @DataTodayNoTime
    END
*/
/*
  -- FA/FZ na podstawie wielu dokumentów WZ/PZ/WKA/PKA
  IF @Kontekst IN (3)
    BEGIN
      -- Kursor po dokumentach do przekonwertowania (jheśli jeden, to tylko podmiana)
     EXEC cdn.sp_DodajHaMag
    END
*/
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
