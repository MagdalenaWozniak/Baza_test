CREATE PROCEDURE CDN.DodajHaMag
  @TrN_TrNId_Zrd_List  TEXT,         -- lista TrN_TrNId dokumentów źródłowych (paragonów, faktur), do których ma być wykonany dokument magazynowy
  @TrN_Rodzaj_Doc      INT,          -- TrN_Rodzaj dokumentu docelowego
  @TrN_MagZrdId_Doc    INT,          -- Magazyn dokumentu docelowego
  @TrN_DataWys_Doc     DATETIME,     -- TrN_DataWys dokumentu docelowego
  @TrN_DataDok_Doc     DATETIME,     -- TrN_DataDok dokumentu docelowego
  @TrN_DataOpe_Doc     DATETIME,     -- TrN_DataOpe dokumentu docelowego
  @TrN_OpeZalId_Doc    INT,          -- Opertor zalogowany do programu, który wykonuje operację przekształcenia
  @TrN_StaZalId_Doc    INT,          -- Sanowisko, z którego jest wykonywana operacja przekształcenia
  @ServerCfgString     NVARCHAR(250), -- nazwa serwera z bazą konfiguracyjną
  @BazaCfgString       NVARCHAR(250), -- nazwa bazy konfiguracyjnej
  @DataToday           NVARCHAR(100), -- data bieżąca z programu
  @Kontekst            INT,          -- Kontekst wywołania: 0 - WZ/PZ/WKA/PKA z formularza na podstawie elementów faktury, 1 - WZ/PZ/WKA/PK z listy na podstawie elementów faktury, 2 - WKA/PKA jako nowy dokument z listy FA/PA/FZ
  @WywolaniePoDodaniu  INT,
  @Seria               NVARCHAR(20),
  @TrN_TrNId_Doc       INT  OUTPUT   -- zwracany  TrN_TrNId dokumentu docelowego
AS
SET NOCOUNT ON
  DECLARE
    @TrN_TrNId_Zrd        INT,  -- Pojedyncze TrN_TrNId dokumentu do przekonwertowania, gdy jest tylko jeden dokument źródłowy
    @MagId                INT,  -- id magazynu
    @PoprawZrodl          INT,
    @TrN_TrNId_Zrd_PA     INT,   -- id PA do FA
    @SaElem      INT
  DECLARE @Mag TABLE ( MagId INT) -- tabela z magazynami wystepujacymi na elementach
  DECLARE @TrNID TABLE ( TrNId INT)
  insert into @TrNID select NextIdInt from  CDN.Text2TableInt ( @TrN_TrNId_Zrd_List )
  -- dodanie nagłówka
  SELECT TOP 1 @TrN_TrNId_Zrd = NextIdINT FROM cdn.Text2TableINT ( @TrN_TrNId_Zrd_List )
  --na FSPF nowa pozycja ma ujemne lppow. przed przekształceniem do WZ trzeba ustawic na plus. Jak jest FSWZ to ma zostać ujemne, bo wtedy tylko WZ tworzymy dla ujemnych
   IF @WywolaniePoDodaniu = 1
    BEGIN
      IF EXISTS ( SELECT * FROM cdn.TraNag WHERE TrN_TrNId = @TrN_TrNId_Zrd and TrN_rodzaj = 302009 )
        BEGIN
            -- Poprawa TrE_LpPow ujemnych na dokumencie magazynowym i handlowym
          UPDATE cdn.TraElem SET TrE_LpPow = -TrE_LpPow
            WHERE TrE_LpPow < 0 AND TrE_TrNId IN ( @TrN_TrNId_Zrd )
       END
   END
  INSERT INTO @Mag ( MagId )
  SELECT TrE_MagId AS TrE_MagId FROM CDN.TraElem WHERE TrE_TrNId in (select TrNId from @TrNID )  GROUP BY TrE_MagId
  SET @PoprawZrodl = 0
  SET @SaElem = 0
  DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
   SELECT MagId
     FROM @Mag
   OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO @MagId
          IF @@FETCH_STATUS <> 0 BREAK
    EXEC CDN.DodajTraNag
   @TrN_TrNId_Zrd_List,        -- TrN_TrNId nagłówka do dodania lub do skopiowania (może być NULL, jeśli @TrN_Rodzaj_Doc IS NOT NULL AND @TrN_MagZrdId_Doc IS NOT NULL)
   @TrN_Rodzaj_Doc,       -- TrN_Rodzaj dokumentu docelowego (może być null, jeśli @TrN_TrNId_Zrd IS NOT NULL )
   @MagId,                -- TrN_MagZrdId dokumentu docelowego (może być null, jeśli @TrN_TrNId_Zrd IS NOT NULL )
   @TrN_DataDok_Doc,      --
   @TrN_DataWys_Doc,      --
   @TrN_DataOpe_Doc,      --
   @ServerCfgString,      -- nazwa serwera z bazą konfiguracyjną
   @BazaCfgString,        -- nazwa bazy konfiguracyjnej
   @TrN_OpeZalId_Doc,     -- Opertor zalogowany do programu, który wykonuje operację przekształcenia
   @TrN_StaZalId_Doc,     -- Sanowisko, z którego jest wykonywana operacja przekształcenia
   @DataToday,            -- Data bieżąca z programu
   @Kontekst,             -- Kontekst wywołania: 0 - WZ/PZ/WKA/PKA z formularza, 1 - WZ/PZ/WKA/PKA z listy, 2 - WKA/PKA jako nowy dokument z listy FA/PA/FZ
   @Seria,
   @TrN_TrNId_Doc OUTPUT  -- zwracany  TrN_TrNId dokumentu docelowego
    IF @@ERROR<>0
   BEGIN
     IF @@TranCount<>0 ROLLBACK TRAN
     RETURN
   END
    -- dodanie elementów
    EXEC CDN.DodajTraElem
   @TrN_TrNId_Zrd_List,  -- TEXT,         -- TrN_TrNId nagłówków dokumentów, które biorą udział w dodawaniu elementów
   @TrN_TrNId_Doc,       -- INT,          -- TrN_TrNId nagłówka do dodania lub do skopiowania
   @TrN_Rodzaj_Doc,      -- INT,          -- Rodzaj dokumentu docelowego
   @TrN_DataDok_Doc,     -- DATETIME,     --
   @TrN_DataWys_Doc,     -- DATETIME,     --
   @TrN_DataOpe_Doc,     -- DATETIME,     --
   @ServerCfgString,     -- NVARCHAR(250), -- nazwa serwera z bazą konfiguracyjną
   @BazaCfgString,       -- NVARCHAR(250), -- nazwa bazy konfiguracyjnej
   @DataToday,           -- NVARCHAR(100), -- Data Today z programu (może być inna niż z serwera)
   @Kontekst,             -- INT           -- Kontekst wywołania: 0 - WZ/PZ z formularza, 1 - WZ/PZ z listy, 2 - WKA/PKA z formularza, 3 - WKA/PKA z listy
   @MagId
    IF @@ERROR<>0
   BEGIN
     IF @@TranCount<>0 ROLLBACK TRAN
     RETURN
   END
    -- WZ z RO nie zawsze bedzie miala pozycje i trzeba skasowac
    if @TrN_Rodzaj_Doc = 306008
      begin
    if (select COUNT(tre_treid) from cdn.TraElem where TrE_TrNId = @TrN_TrNId_Doc) = 0
    begin
     delete from cdn.TraNag where TrN_TrNID = @TrN_TrNId_Doc
     continue
    end
    else
     set @SaElem = 1
      end
    -- wyliczeni TrN_WartoscOO i splitpay dla WZ/PZ
    IF CONVERT(INT, @TrN_Rodzaj_Doc/1000) in (306,307)
      UPDATE CDN.TraNag SET
      TrN_WartoscOO     = ISNULL(TrE_WartoscNetto,0)
      FROM CDN.TraNag LEFT OUTER JOIN
      ( SELECT
      TrE_TrNId     = TrE_TrNId,
      TrE_WartoscNetto     = SUM(TrE_WartoscNetto)
      FROM CDN.TraElem
      WHERE TrE_TrNId = @TrN_TrNId_Doc  and Tre_OdwrotneObciazenie = 2
      GROUP BY TrE_TrNId
      ) AS TraElemTmp ON TrN_TrNId = TrE_TrNId
      WHERE TrN_TrNId = @TrN_TrNId_Doc
    IF CONVERT(INT, @TrN_Rodzaj_Doc/1000) in (306,307)
    BEGIN
       update CDN.TraElem  set TrE_SplitPay = twr_splitpay
       from
       CDN.TraElem
       join CDN.Towary on TrE_TwrId = Twr_TwrId
       where TrE_TrNId = @TrN_TrNId_Doc
       update CDN.TraNag set TrN_WartoscSP =
    isnull((select SUM(TrE_WartoscBrutto) from CDN.TraElem where TrE_TrNId = @TrN_TrNId_Doc and TrE_SplitPay = 1 and TrE_Flaga != 4),0)
    where TrN_TrNID = @TrN_TrNId_Doc
    END
    -- dodanie tabelki VAT
    EXEC CDN.DodajTraVAT
   @TrN_TrNId_Zrd_List,  -- TEXT,         -- TrN_TrNId nagłówka do dodania lub do skopiowania
   @TrN_TrNId_Doc        -- INT           -- TrN_TrNId nagłówka do dodania lub do skopiowania
    IF @@ERROR<>0
   BEGIN
     IF @@TranCount<>0 ROLLBACK TRAN
     RETURN
   END
    -- dodanie płatności
    EXEC CDN.DodajBnkZdarzenia
   @TrN_TrNId_Doc,
   @ServerCfgString,
   @BazaCfgString,
   @Kontekst
    IF @@ERROR<>0
   BEGIN
     IF @@TranCount<>0 ROLLBACK TRAN
     RETURN
   END
    -- kontrola wartosci zakupu na PZ jeśli są dostawy
    IF CONVERT(INT, @TrN_Rodzaj_Doc/1000) = 307
   BEGIN
     EXEC CDN.UstawRoznieceWartosciNaDost @TrN_TrNId_Doc
     IF @@ERROR<>0
              BEGIN
     IF @@TranCount<>0 ROLLBACK TRAN
     RETURN
    END
    END
    IF @WywolaniePoDodaniu = 1
    BEGIN
      IF EXISTS ( SELECT * FROM cdn.TraNag WHERE TrN_TrNId = @TrN_TrNId_Doc )
        BEGIN
          -- Uzupełnienie TrN_Rodzaj na fakturze źródłowej (tylko dla skojarzeń z WZ/PZ)
    if @TrN_Rodzaj_Doc != 306008
   UPDATE cdn.TraNag SET TrN_Rodzaj = CONVERT(INT, TrN_Rodzaj/1000)* 1000 + 4 WHERE TrN_TrNId = @TrN_TrNId_Zrd AND TrN_Rodzaj<>301050 AND TrN_TypDokumentu<>320
          -- Poprawa TrE_LpPow ujemnych na dokumencie magazynowym i handlowym
          UPDATE cdn.TraElem SET TrE_LpPow = -TrE_LpPow
            WHERE TrE_LpPow < 0 AND TrE_TrNId IN ( @TrN_TrNId_Doc )
          SET @PoprawZrodl = 1
          -- renumeracja Lp na dokumencie wynikowym
          --DECLARE @TrELp TABLE (TrE_TrEId_Old INT, TrE_Lp_New INT IDENTITY ( 1,1 ) )
          CREATE TABLE #TrELp(TrE_TrEId_Old INT, TrE_Lp_New INT IDENTITY ( 1,1 ) )
          INSERT INTO #TrELp ( TrE_TrEId_Old )
            SELECT TrE_TrEId FROM cdn.TraElem WHERE TrE_TrNId = @TrN_TrNId_Doc
            ORDER BY TrE_Lp,TrE_TrEId
          UPDATE cdn.TraElem SET TrE_Lp = TrE_Lp_New
            FROM cdn.TraElem JOIN #TrELp ON TrE_TrEId_Old = TrE_TrEId
          DROP TABLE #TrELp
        END
    END
    IF @WywolaniePoDodaniu = 2
    BEGIN
   -- ustawiamy lp
   CREATE TABLE #TrELpk(TrE_TrEId_Old INT, TrE_Lp_New INT IDENTITY ( 1,1 ) )
          INSERT INTO #TrELpk ( TrE_TrEId_Old )
            SELECT TrE_TrEId FROM cdn.TraElem WHERE TrE_TrNId = @TrN_TrNId_Doc
            ORDER BY TrE_Lp,TrE_TrEId
          UPDATE cdn.TraElem SET TrE_Lp = TrE_Lp_New
            FROM cdn.TraElem JOIN #TrELpk ON TrE_TrEId_Old = TrE_TrEId
          DROP TABLE #TrELpk
      -- Wyliczenie rabatu nagłówka na podstawie utworzonych elementów
      EXEC CDN.TraNagRabatSredni @TrN_TrNId_Doc
      -- przepinanie zdarzeń, jeśli istnieją i istnieje dokument docelowy
      SELECT
         @TrN_TrNId_Zrd_PA = PA.TrN_TrNId
      FROM cdn.TraNag PA
      JOIN cdn.TraNagRelacje REL on PA.TrN_TrNId = REL.TrR_TrNId
      WHERE REL.TrR_FAId = @TrN_TrNId_Zrd AND REL.TrR_FATYP = 302 AND REL.TrR_TrNTYP = 305
      IF EXISTS ( SELECT * FROM cdn.TraNag WHERE TrN_TrNId = @TrN_TrNId_Doc )
        BEGIN
          DECLARE @TrN_NumerPelny_Doc NVARCHAR(31)
          SELECT @TrN_NumerPelny_Doc = TrN_NumerPelny FROM cdn.TraNag WHERE TrN_TrNId = @TrN_TrNId_Doc
          UPDATE CDN.BnkZdarzenia SET
            BzD_DokumentTyp = 1,
            BzD_PrwTyp = 1,
            BzD_DokumentId = @TrN_TrNId_Doc,
            BzD_NumerPelny = @TrN_NumerPelny_Doc
          WHERE BzD_DokumentTyp = 101 AND ( BzD_DokumentId = @TrN_TrNId_Zrd OR BzD_DokumentId = ISNULL(@TrN_TrNId_Zrd_PA,0) )
        END
      -- nowy numer dla zapisu KB (tylko dla formularza)
      IF @Kontekst IN (0)
        BEGIN
          DECLARE
            @BZp_BZpId INT,
            @BZp_DDFId INT,
            @BZp_NumerString NVARCHAR(31),
            @BZp_NumerNr INT,
   @BZp_NumerNrDok INT
          -- Id zapisu i parametry z nagłówka
          SELECT TOP 1
            @BZp_BZpId = BZp_BZpId,
            @BZp_DDFId = TrN_DDFId,
            @BZp_NumerString = TrN_NumerString,
   @BZp_NumerNrDok = TrN_NumerNr
          FROM cdn.BnkZapisy
            JOIN cdn.BnkRozRelacje ON BRR_DDokTyp = 2 AND BRR_DDokId = BZp_BZpId
            JOIN cdn.BnkZdarzenia  ON BRR_ZDokTyp = 1 AND BRR_ZDokId = BZd_BZdId
            JOIN cdn.TraNag ON BzD_DokumentTyp = 1 AND BZd_DokumentId = TrN_TrNId
          WHERE TrN_TrNId = @TrN_TrNId_Doc
          -- nowy NumerNr
          SELECT @BZp_NumerNr = ISNULL(MAX(BzP_NumerNr),0) + 1 FROM cdn.BnkZapisy WHERE BZp_NumerString = @BZp_NumerString
          IF  ( SELECT ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1777 ) <> 1
            UPDATE cdn.BnkZapisy SET
              BZp_DDFId = @BZp_DDFId,
              BZp_NumerString = @BZp_NumerString,
              BZp_NumerNr = @BZp_NumerNrDok,
              BZp_NumerObcy = CDN.FN_NUMERPELNY(@BZp_NumerNrDok, @BZp_NUMERSTRING),
              BZp_Opis = 'Dok.: ' + CDN.FN_NUMERPELNY(@BZp_NumerNrDok, @BZp_NUMERSTRING)  + ' (Kaucje)'
            WHERE BZp_BZpId = @BZp_BZpId
          ELSE
            UPDATE cdn.BnkZapisy SET
              BZp_NumerObcy = CDN.FN_NUMERPELNY(@BZp_NumerNrDok, @BZp_NUMERSTRING),
              BZp_Opis = 'Dok.: ' + CDN.FN_NUMERPELNY(@BZp_NumerNrDok, @BZp_NUMERSTRING)  + ' (Kaucje)'
            WHERE BZp_BZpId = @BZp_BZpId
        END
    END
    IF @WywolaniePoDodaniu = 3
    BEGIN
      -- Wyliczenie rabatu nagłówka na podstawie utworzonych elementów
      EXEC CDN.TraNagRabatSredni @TrN_TrNId_Doc
    END
    END
 --ustawianie statusu rezerwacji RO->WZ
 IF  @TrN_Rodzaj_Doc IN ( 307010, 302008, 305008, 306008,  301011 , 306004, 307004,302009, 306010,304000,304008,312008,312100)
 and exists (select trr_trrid from cdn.TraNagRelacje where trr_trnid = @TrN_TrNId_Doc and trr_fatyp in (308,309))
  EXECUTE CDN.UstawStatusRezerwacji_New 0,@TrN_TrNId_Doc
    CLOSE Dodawane
    DEALLOCATE Dodawane
    IF @WywolaniePoDodaniu = 1 AND @PoprawZrodl = 1
    BEGIN
       -- Poprawa TrE_LpPow ujemnych na dokumencie magazynowym i handlowym
       UPDATE cdn.TraElem SET TrE_LpPow = -TrE_LpPow
        WHERE TrE_LpPow < 0 AND TrE_TrNId IN ( @TrN_TrNId_Zrd)
    END
 -- jak na WZ z RO nie ma pozycji to komunikat
 if @TrN_Rodzaj_Doc = 306008  and @SaElem = 0
    BEGIN
  RAISERROR('##OPT34475##', 16, 1)
  rollback
  SET NOCOUNT OFF
  RETURN
   END
SET NOCOUNT OFF
