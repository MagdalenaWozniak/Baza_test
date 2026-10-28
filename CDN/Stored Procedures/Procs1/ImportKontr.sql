CREATE PROCEDURE CDN.ImportKontr
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@Knt_ImportRowId nvarchar(36),
@Knt_Kod nvarchar(20),
@Knt_Zezwolenie nvarchar(40),
@Knt_Opis nvarchar(254),
@Knt_Chroniony TINYINT,
@Knt_Rodzaj_Dostawca TINYINT,
@Knt_Rodzaj_Odbiorca TINYINT,
@Knt_Rodzaj_Konkurencja TINYINT,
@Knt_Rodzaj_Partner TINYINT,
@Knt_Rodzaj_Potencjalny TINYINT,
@Knt_Export SMALLINT,
@Knt_Finalny TINYINT,
@Knt_PodatekVat TINYINT,
@Knt_Medialny TINYINT,
@Knt_PowiazanyUoV TINYINT,
@Knt_Nieaktywny TINYINT,
@Knt_Rolnik TINYINT,
@Knt_NieNaliczajOdsetek TINYINT,
@Knt_MetodaKasowaZak TINYINT,
@Knt_MetodaKasowaSpr TINYINT,
@Knt_KontoOdb nvarchar(50),
@Knt_KontoDost nvarchar(50),
@Kat_KodSzczegolOLD nvarchar(20),
@Kat_ImportRowIdOLD nvarchar(36),
@Kat_KodSzczegol nvarchar(20),
@Kat_ImportRowId nvarchar(36),
@Kat_KodSzczegolZakup nvarchar(20),
@Kat_ImportRowIdZakup nvarchar(36),
@FPl_Nazwa nvarchar(20),
@FPl_ImportRowId nvarchar(36),
@Knt_MaxZwloka SMALLINT,
@Knt_Ceny SMALLINT,
@Knt_LimitFlag TINYINT,
@Knt_LimitKredytu decimal(15,2),
@Knt_NieRozliczac TINYINT,
@Knt_Komornik TINYINT,
@Knt_KomornikOkreg nvarchar(256),
@Knt_KomornikMiasto nvarchar(40),
@Knt_KomornikRewir nvarchar(256),
@Rab_Rabat decimal(15,2),
@Knt_Informacje TINYINT,
@Knt_TerminPlat TINYINT,
@Knt_Termin SMALLINT,
@Knt_NaliczajPlatnosc TINYINT,
@Knt_TerminZwrotuKaucji SMALLINT,
@Knt_KodTransakcji nvarchar(2),
@Knt_ZakazDokumentowHaMag TINYINT,
@Knt_LimitPrzeterKredytFlag TINYINT,
@Knt_LimitPrzeterKredytWartosc decimal(15,2),
--@Knt_ZgodaNaEFaktury TINYINT,
@Knt_KodOdb nvarchar(20),
@Knt_ImportRowIdOdb nvarchar(36),
@Knt_KrajISO nvarchar(9),
@TypOpiek nvarchar(10),
@KodOpiek nvarchar(20),
@StatusAdres nvarchar(15),
@Knt_EAN nvarchar(16),
@Knt_GLN nvarchar(13),
@Knt_Nazwa1 nvarchar(50),
@Knt_Nazwa2 nvarchar(50),
@Knt_Nazwa3 nvarchar(250),
@Knt_Kraj nvarchar(40),
@Knt_Wojewodztwo nvarchar(40),
@Knt_Powiat nvarchar(40),
@Knt_Gmina nvarchar(40),
@Knt_Ulica nvarchar(40),
@Knt_NrDomu nvarchar(10),
@Knt_NrLokalu nvarchar(10),
@Knt_Miasto nvarchar(40),
@Knt_KodPocztowy nvarchar(10),
@Knt_Poczta nvarchar(40),
@Knt_Adres2 nvarchar(40),
@Knt_NipKraj nvarchar(2),
@Knt_NipE nvarchar(32),
@Knt_Regon nvarchar(20),
@Knt_Pesel nvarchar(11),
@Knt_Telefon1 nvarchar(20),
@Knt_Telefon2 nvarchar(20),
@Knt_Fax nvarchar(20),
@Knt_Url nvarchar(254),
@Knt_EMail nvarchar(127),
@Knt_KorKraj NVARCHAR(40),
@Knt_KorMiasto NVARCHAR(40),
@Knt_KorUlica NVARCHAR(40),
@Knt_KorNrDomu NVARCHAR(10),
@Knt_KorNrLokalu NVARCHAR(10),
@Knt_KorKodPocztowy VARCHAR(10),
@Knt_KorPoczta NVARCHAR(40),
--@BNa_Numer nvarchar(10),
--@BNa_ImportRowId nvarchar(36),
--@Knt_RachunekNr nvarchar(50),
--@Knt_Iban TINYINT,
@Knt_Grupa nvarchar(20),
@Knt_Waluta VARCHAR(3),
@Knt_Algorytm TINYINT,
@Knt_NieUwzglVATZD TINYINT,
@Knt_Anonimizacja TINYINT,
@Knt_SplitPay TINYINT,
@OCR TINYINT,
@ZrdId nvarchar(5),
@OpeId int,
@SlowId int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
IF IsNull(@Knt_Anonimizacja, 0) <> 0
BEGIN
 RAISERROR('##OPT33087##', 16, 1) --RAISERROR('Kontrahent został zanonimizowany.', 16, 1)
 RETURN
END
IF @OnlyNew <> 1
BEGIN
 DECLARE @LpAnonimizacji INT
 SELECT @LpAnonimizacji = case IsNull(@Knt_ImportRowId, '') when '' then (SELECT TOP 1 Knt_LpAnonimizacji FROM CDN.Kontrahenci WHERE Knt_Kod = @Knt_Kod) else (SELECT TOP 1 Knt_LpAnonimizacji FROM CDN.Kontrahenci WHERE Knt_ImportRowId = @Knt_ImportRowId OR Knt_Kod = @Knt_Kod) end
 IF IsNull(@LpAnonimizacji, 0) > 0
 BEGIN
  RAISERROR('##OPT33087##', 16, 1) --RAISERROR('Kontrahent został zanonimizowany.', 16, 1)
  RETURN
 END
END
DECLARE @OperationType INT
SET @OperationType = 0
DECLARE @MetodaKasowaBrakTagow TINYINT
SELECT @MetodaKasowaBrakTagow = CASE WHEN @Knt_MetodaKasowaZak Is Null AND @Knt_MetodaKasowaSpr Is Null THEN 1 ELSE 0 END
 IF @Knt_MetodaKasowaZak Is Null
 SET @Knt_MetodaKasowaZak = 0
 IF @Knt_MetodaKasowaSpr Is Null
 SET @Knt_MetodaKasowaSpr = 0
DECLARE @Knt_MetodaKasowa INT
SET @Knt_MetodaKasowa = 0
IF @Knt_MetodaKasowaZak = 0
BEGIN
  IF @Knt_MetodaKasowaSpr = 0
    SET @Knt_MetodaKasowa = 0
  ELSE
    SET @Knt_MetodaKasowa = 2
END
ELSE
BEGIN
  IF @Knt_MetodaKasowaSpr = 0
    SET @Knt_MetodaKasowa = 1
  ELSE
    SET @Knt_MetodaKasowa = 3
END
 DECLARE @Knt_FplId INT
 DECLARE @Knt_KatId INT
 DECLARE @Knt_KatZakId INT
 DECLARE @Knt_OdbiorcaId INT
-- DECLARE @Knt_BNaID INT
 DECLARE @Knt_KodPod nvarchar (20)
 DECLARE @Knt_Odbiorca nvarchar(20)
 DECLARE @OpiekId int
 DECLARE @OpiekTyp int
 DECLARE @OperSql nvarchar(1000)
 DECLARE @TmpAkr nvarchar(20)
 SET @Warnings = ''
 IF(@TypOpiek = 'pracownik')
 BEGIN
  SET @OpiekId = NULL
  SET @OpiekTyp = 3
  SELECT @OpiekId = PRa_PraId
  FROM CDN.PracKod
  WHERE PRA_kod = @KodOpiek
  IF @OpiekId is NULL
  BEGIN
   SET @Opiektyp = NULL
   --SET @Warnings = @Warnings + 'Błąd tworzenia operatora.\'
   SET @Warnings = @Warnings + '##OPT33194##\';
  END
 END
 ELSE
 IF(@TypOpiek = 'operator')
 BEGIN
  SET @OpiekTyp = 8
  SET @OperSql =
  'SELECT Ope_OpeId as Id
  FROM [' + @ServerName + '].[' + @ConfigDBName + '].CDN.Operatorzy '
  + 'WHERE Ope_Kod = ''' + @KodOpiek + ''''
  CREATE TABLE #OpeId (id INT)
  INSERT INTO #OpeId (id)
  EXEC sp_executesql @OperSql
  SELECT @OpiekId = Id
  FROM #OpeId
  IF @OpiekId is NULL
 --SET @Warnings = @Warnings + 'Błąd tworzenia operatora.\'
 SET @Warnings = @Warnings + '##OPT33194##\';
 END
 ELSE
 BEGIN
  SET @OpiekId = NULL
  SET @OpiekTyp = NULL
 END
 IF @OpiekId Is Null
  SET @OpiekTyp = NULL
 SET @Knt_FplId = NULL
 DECLARE @FPlParamIsNull TINYINT
 IF (@FPl_ImportRowId Is Null AND @FPl_Nazwa Is Null)
  SET @FPlParamIsNull = 1
 ELSE
  SET @FPlParamIsNull = 0
 IF(@FPlParamIsNull = 0)
 BEGIN
  SELECT @Knt_FplId = Fpl_FplId FROM CDN.FormyPlatnosci
  WHERE IsNull(@FPl_ImportRowID, '') <> '' AND FPl_ImportRowId = @FPl_ImportRowId
   IF (IsNull(@Knt_FplID, 0) = 0)
    SELECT @Knt_FplID = Fpl_FplID FROM CDN.FormyPlatnosci
      WHERE FPl_Nazwa = @FPl_Nazwa
 END
 IF @Knt_FPlID Is Null
  SELECT TOP 1 @Knt_FplId = Fpl_FplID FROM CDN.FormyPlatnosci WHERE FPl_Nazwa = 'gotówka'
 SET @Warnings = ''
 IF(@Kat_ImportRowIdOLD is not NULL OR @Kat_KodSzczegolOLD is not NULL)
 BEGIN
  SET @Knt_KatId = NULL
  SELECT @Knt_KatId = Kat_KatId
  FROM CDN.Kategorie
  WHERE Kat_ImportRowId = @Kat_ImportRowIdOLD
  IF(@Knt_KatId is NULL)
  BEGIN
   SELECT @Knt_KatId = Kat_KatId
   FROM CDN.Kategorie
   WHERE Kat_KodSzczegol = @Kat_KodSzczegolOLD
   IF(@Knt_KatId is NULL)
    --SET @Warnings = 'Brak kategorii ' + IsNull(@Kat_KodSzczegolOLD, '') + ' w bazie docelowej. Kategoria nie została zaimportowana.\'
 SET @Warnings = '##OPT33150##%%kategoria%%=' + IsNull(@Kat_KodSzczegolOLD, '') + '##\'
  END
 END
 SET @Knt_KatZakId = @Knt_KatId;
 SET @Knt_KatId = NULL
 IF(@Kat_ImportRowId = '' AND @Kat_KodSzczegol = '')
   SET @Knt_KatId = 0
 ELSE
 IF(@Kat_ImportRowId is not NULL OR @Kat_KodSzczegol is not NULL)
 BEGIN
  SET @Knt_KatId = NULL
  SELECT @Knt_KatId = Kat_KatId
  FROM CDN.Kategorie
  WHERE Kat_ImportRowId = @Kat_ImportRowId
  IF(@Knt_KatId is NULL)
  BEGIN
   SELECT @Knt_KatId = Kat_KatId
   FROM CDN.Kategorie
   WHERE Kat_KodSzczegol = @Kat_KodSzczegol
   IF(@Knt_KatId is NULL)
    --SET @Warnings = 'Brak kategorii ' + IsNull(@Kat_KodSzczegol, '') + ' w bazie docelowej. Kategoria nie została zaimportowana.\'
 SET @Warnings = '##OPT33150##%%kategoria%%=' + IsNull(@Kat_KodSzczegol, '') + '##\'
  END
 END
 SET @Knt_KatZakId = NULL
 IF(@Kat_ImportRowIdZakup = '' AND @Kat_KodSzczegolZakup = '')
   SET @Knt_KatZakId = 0
 ELSE
 IF(@Kat_ImportRowIdZakup is not NULL OR @Kat_KodSzczegolZakup is not NULL)
 BEGIN
  SET @Knt_KatZakId = NULL
  SELECT @Knt_KatZakId = Kat_KatId
  FROM CDN.Kategorie
  WHERE Kat_ImportRowId = @Kat_ImportRowIdZakup
  IF(@Knt_KatZakId is NULL)
  BEGIN
   SELECT @Knt_KatZakId = Kat_KatId
   FROM CDN.Kategorie
   WHERE Kat_KodSzczegol = @Kat_KodSzczegolZakup
   IF(@Knt_KatZakId is NULL)
    --SET @Warnings = 'Brak kategorii ' + IsNull(@Kat_KodSzczegolZakup, '') + ' w bazie docelowej. Kategoria nie została zaimportowana.\'
 SET @Warnings = '##OPT33150##%%kategoria%%=' + IsNull(@Kat_KodSzczegolZakup, '') + '##\'
  END
 END
 IF ((@Knt_ImportRowIdOdb IS NULL) OR (@Knt_ImportRowIdOdb = ''))
  SELECT @Knt_OdbiorcaId = Knt_KntID FROM CDN.Kontrahenci
          WHERE Knt_Kod = @Knt_KodOdb
 ELSE
  SELECT @Knt_OdbiorcaId = Knt_KntID FROM CDN.Kontrahenci
        WHERE Knt_ImportRowId = @Knt_ImportRowIdOdb
-- SELECT @Knt_BNaID = BNa_BNaId
-- FROM CDN.BnkNazwy
--    WHERE BNa_ImportRowId = @BNa_ImportRowId
-- IF @Knt_BNaID is NULL
--  SELECT @Knt_BNaID = BNa_BNaId
--  FROM CDN.BnkNazwy
--  WHERE BNa_Numer= @BNa_Numer
 IF(SELECT Fir_Wartosc
  FROM CDN.Firma
  WHERE Fir_Numer = 2) = 1
 BEGIN
   SET @TmpAkr = @Knt_Kod
   SET @TmpAkr = REPLACE(REPLACE(REPLACE(REPLACE(@TmpAkr, ',', '.'), ' ', '.'), '-', '.'), '''', '.')
   IF CHARINDEX('.', @TmpAkr) <> 0
 --SET @Warnings = @Warnings + 'Akronim zawiera znaki specjalne.\'
 SET @Warnings = @Warnings + '##OPT33152##\'
 END
 IF((SELECT count(*)
      FROM CDN.Grupy
      WHERE Gru_Nazwa = @Knt_Grupa and Gru_Typ = 31) = 0
   AND @Knt_Grupa <> '')
  BEGIN
   INSERT
   INTO CDN.Grupy
   (
   Gru_Typ,
   Gru_Nazwa,
   Gru_Opis,
   Gru_Flaga,
 Gru_TS_Zal,
 Gru_TS_Mod
   )
   VALUES
   (
   31,
   @Knt_Grupa,
   '',
   NULL,
 GetDate(),
 GetDate()
   )
  END
 IF(SELECT Fir_Wartosc
  FROM CDN.Firma
  WHERE Fir_Numer = 1494) = '1'
 BEGIN
  IF @Knt_Export <> 1 AND @Knt_Export <> 2 AND @Knt_Export <> 9 -- Dla kontrahenta pozaunijnego nie sprawdzamy NIP-u
  BEGIN
   IF CDN.IsCorrectNIP(@Knt_NipKraj, REPLACE(@Knt_NipE, '-', '')) = 0
   BEGIN
    --SET @Warnings = @Warnings + 'Niepoprawny NIP kontrahenta.\'
 SET @Warnings = @Warnings + '##OPT33195##\'
    SET @Knt_NipE = ''
   END
  END
 END
 IF LEN(REPLACE(REPLACE(@Knt_NipE, '-', ''), ' ', '')) > 20 OR LEN(REPLACE(@Knt_NipE, ' ', '')) > 20
 BEGIN
 RAISERROR('##OPT33073##', 16, 1) --RAISERROR('Wystąpił błąd przy imporcie składnika. Numer NIP jest zbyt długi.', 16, 1)
 RETURN
 END
 IF(SELECT Fir_Wartosc
  FROM CDN.Firma
  WHERE Fir_Numer = 1499) = '1'
 BEGIN
  IF CDN.IsCorrectPesel(@Knt_Pesel) = 0
  BEGIN
   --SET @Warnings = @Warnings + 'Niepoprawny Pesel kontrahenta.\'
   SET @Warnings = @Warnings + '##OPT33196##\'
   SET @Knt_Pesel = ''
  END
 END
-- IF @Knt_ZgodaNaEFaktury IS NULL  -- import kontrahenta ze starszej wersji
--  SET @Knt_ZgodaNaEFaktury = 0;
 SELECT @Knt_SplitPay = IsNull(@Knt_SplitPay, 0)
 DECLARE @RachID INT, @WarningsRach nvarchar(1000);
 IF (SELECT case IsNull(@Knt_ImportRowId, '')
    when '' then (SELECT count(*)
        FROM CDN.Kontrahenci
        WHERE Knt_Kod = @Knt_Kod)
    else (SELECT count(*)
      FROM CDN.Kontrahenci
      WHERE Knt_ImportRowId = @Knt_ImportRowId OR Knt_Kod = @Knt_Kod)
    end) = 0
 BEGIN
  /*Set @Knt_BNaID = NULL
  Set @Knt_OdbiorcaId = NULL
  Set @Knt_KatId = NULL
  Set @Knt_FplId = NULL*/
  DECLARE @DupNIP TINYINT
  IF @Knt_NipE Is Not NULL AND @Knt_NipE <> ''
    SELECT @DupNIP = CASE WHEN EXISTS(SELECT TOP 1 * FROM cdn.Kontrahenci WHERE Knt_Nip = REPLACE(REPLACE(@Knt_NipE, '-', ''), ' ', '')) THEN 1 ELSE 0 END
  ELSE
    SET @DupNIP = 0
  DECLARE @ReturnDupNIP TINYINT
  SET @ReturnDupNIP = 0
  IF @DupNIP = 1
  BEGIN
  DECLARE @KontrolaDup INT
  SELECT @KontrolaDup = Fir_Wartosc FROM cdn.Firma WHERE Fir_Opis = 'Kontrola duplikacji kontrahentów'
  IF @KontrolaDup = 2
   SET @ReturnDupNIP = 1
  ELSE IF @KontrolaDup = 1
   --SET @Warnings = @Warnings + 'W bazie docelowej istnieje kontrahent o numerze NIP takim samym jak u importowanego kontrahenta ' + @Knt_Kod + '.\'
   SET @Warnings = @Warnings + '##OPT33197##%%kontrahent%%=' +  @Knt_Kod + '##\';
  END
  IF @ReturnDupNIP = 1
  RAISERROR('##OPT33088##', 16, 1) --RAISERROR('Kontrahent o takim numerze NIP już istnieje. Kontrahent nie został dodany.', 16, 1)
 ELSE
 BEGIN
  DECLARE @Knt_AlgorytmIns TINYINT
  SELECT @Knt_AlgorytmIns = @Knt_Algorytm
  IF @Knt_AlgorytmIns Is Null
  BEGIN
   SELECT @Knt_AlgorytmIns = 0
   IF IsNull(@Knt_Finalny, 0) = 1 AND IsNull(@Knt_Ceny, 0) <> 0
  BEGIN
    DECLARE @nb TINYINT
   select @nb = IsNull(DfC_Typ, 0) from cdn.defceny where dfc_dfcid = @Knt_Ceny
   IF @nb = 2
    SELECT @Knt_AlgorytmIns = 1
   END
  END
  INSERT INTO CDN.Kontrahenci(
  Knt_Kod,
  Knt_GLN,
  Knt_Grupa,
  Knt_Nazwa1,
  Knt_Nazwa2,
  Knt_Nazwa3,
  Knt_Kraj,
  Knt_Wojewodztwo,
  Knt_Powiat,
  Knt_Gmina,
  Knt_Ulica,
  Knt_NrDomu,
  Knt_NrLokalu,
  Knt_Miasto,
  Knt_KodPocztowy,
  Knt_Poczta,
  Knt_Adres2,
  Knt_Nip,
  Knt_NipE,
  Knt_NipKraj,
  Knt_Regon,
  Knt_Pesel,
  Knt_Telefon1,
  Knt_Telefon2,
  Knt_Fax,
  Knt_Email,
  Knt_URL,
  Knt_Zezwolenie,
 --  Knt_BNaID,
  Knt_RachunekNr,
  Knt_IBAN,
  Knt_OsTytul,
  Knt_OsPlec,
  Knt_OsNazwisko,
  Knt_OsKraj,
  Knt_OsWojewodztwo,
  Knt_OsPowiat,
  Knt_OsGmina,
  Knt_OsUlica,
  Knt_OsNrDomu,
  Knt_OsNrLokalu,
  Knt_OsMiasto,
  Knt_OsKodPocztowy,
  Knt_OsPoczta,
  Knt_OsAdres2,
  Knt_OsTelefon,
  Knt_OsGSM,
  Knt_OsEmail,
  Knt_Informacje,
  Knt_LimitFlag,
  Knt_LimitKredytu,
  Knt_Ceny,
  Knt_FplID,
  Knt_MaxZwloka,
  Knt_TerminPlat,
  Knt_Termin,
  Knt_KontoOdb,
  Knt_KontoDost,
  Knt_KatID,
  Knt_KatZakID,
  Knt_PodatekVat,
  Knt_Finalny,
  Knt_Export,
  Knt_Medialny,
  Knt_PowiazanyUoV,
  Knt_Nieaktywny,
  Knt_Chroniony,
  Knt_Opis,
  Knt_OdbiorcaId,
  Knt_ImportRowId,
  Knt_OpiekunTyp,
  Knt_OpiekunId,
  Knt_EAN,
  Knt_NieRozliczac,
  Knt_Komornik,
  Knt_KomornikOkreg,
  Knt_KomornikMiasto,
  Knt_KomornikRewir,
  Knt_KodTransakcji,
  Knt_Rolnik,
  Knt_NieNaliczajOdsetek,
  Knt_MetodaKasowa,
  Knt_ZakazDokumentowHaMag,
  Knt_LimitPrzeterKredytFlag,
  Knt_LimitPrzeterKredytWartosc,
  Knt_NaliczajPlatnosc,
  Knt_TerminZwrotuKaucji,
  Knt_Rodzaj_Odbiorca,
  Knt_Rodzaj_Dostawca,
  Knt_Rodzaj_Partner,
  Knt_Rodzaj_Konkurencja,
  Knt_Rodzaj_Potencjalny,
  Knt_ZgodaNaEFaktury,
  Knt_TS_Mod,
  Knt_TS_Zal,
  Knt_MalyPod,
  Knt_Rodzaj,
  Knt_LimitKredytuWykorzystany,
  Knt_BlokadaDok,
  Knt_Upust,
  Knt_LimitKredytuWal,
  Knt_KrajISO,
  Knt_OpeZalID,
  Knt_OpeZalKod,
  Knt_OpeZalNazwisko,
  Knt_OpeModID,
  Knt_OpeModKod,
  Knt_OpeModNazwisko,
  Knt_TS_Export,
  Knt_ImportAppId,
  Knt_OpiekunKsiegDomyslny,
  Knt_KorKraj,
  Knt_KorMiasto,
  Knt_KorUlica,
  Knt_KorNrDomu,
  Knt_KorNrLokalu,
  Knt_KorKodPocztowy,
  Knt_KorPoczta,
  Knt_Waluta,
  Knt_Algorytm,
  Knt_NieUwzglVATZD,
  Knt_SplitPay
  )
  VALUES
  (
  UPPER(@Knt_Kod),
  @Knt_GLN,
  @Knt_Grupa,
  @Knt_Nazwa1,
  @Knt_Nazwa2,
  @Knt_Nazwa3,
  @Knt_Kraj,
  @Knt_Wojewodztwo,
  @Knt_Powiat,
  @Knt_Gmina,
  @Knt_Ulica,
  @Knt_NrDomu,
  @Knt_NrLokalu,
  @Knt_Miasto,
  @Knt_KodPocztowy,
  @Knt_Poczta,
  @Knt_Adres2,
  REPLACE(REPLACE(@Knt_NipE, '-', ''), ' ', ''),
  REPLACE(@Knt_NipE, ' ', ''),
  @Knt_NipKraj,
  @Knt_Regon,
  @Knt_Pesel,
  @Knt_Telefon1,
  @Knt_Telefon2,
  @Knt_Fax,
  @Knt_Email,
  @Knt_URL,
  @Knt_Zezwolenie,
 --  @Knt_BNaID, -- 29
  '',--  IsNull(@Knt_RachunekNr, '' ),
  '',--  IsNull(@Knt_IBAN, 0 ),
  '',
  0,
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  @Knt_Informacje,
  @Knt_LimitFlag,
  @Knt_LimitKredytu,
  @Knt_Ceny,
  @Knt_FplID,
  @Knt_MaxZwloka,
  CASE WHEN @Knt_TerminPlat Is Not Null THEN @Knt_TerminPlat ELSE 0 END,
  CASE WHEN @Knt_Termin Is Not Null THEN @Knt_Termin ELSE 0 END,
  @Knt_KontoOdb,
  @Knt_KontoDost,
   -- Jeśli w pliku były tagi z kategorią, ale o wartości pustej (czyli wyliczone @KatID = 0), znaczy to, że na dodawanym rekordzie trzeba podstawić NULL-ową kategorię
  CASE WHEN @Knt_KatId <> 0 THEN @Knt_KatId ELSE NULL END,
  CASE WHEN @Knt_KatZakId <> 0 THEN @Knt_KatZakId ELSE NULL END,
  @Knt_PodatekVat,
  @Knt_Finalny,
  @Knt_Export,
  @Knt_Medialny,
  IsNull(@Knt_PowiazanyUoV, 0),
  @Knt_Nieaktywny,
  @Knt_Chroniony,
  @Knt_Opis,
  @Knt_OdbiorcaId,
  @Knt_ImportRowId,
  @OpiekTyp,
  @OpiekId,
  @Knt_EAN,
  CASE WHEN @Knt_NieRozliczac Is Not Null THEN @Knt_NieRozliczac ELSE 0 END,
  @Knt_Komornik,
  @Knt_KomornikOkreg,
  @Knt_KomornikMiasto,
  @Knt_KomornikRewir,
  @Knt_KodTransakcji,
  IsNull(@Knt_Rolnik, 0),
  CASE WHEN @Knt_NieNaliczajOdsetek Is Not Null THEN @Knt_NieNaliczajOdsetek ELSE 0 END,
  @Knt_MetodaKasowa,
  @Knt_ZakazDokumentowHaMag,
  @Knt_LimitPrzeterKredytFlag,
  @Knt_LimitPrzeterKredytWartosc,
  CASE WHEN @Knt_NaliczajPlatnosc Is Not Null THEN @Knt_NaliczajPlatnosc ELSE 0 END,
  @Knt_TerminZwrotuKaucji,
  CASE WHEN @Knt_Rodzaj_Odbiorca Is Not Null THEN @Knt_Rodzaj_Odbiorca ELSE 0 END,
  CASE WHEN @Knt_Rodzaj_Dostawca Is Not Null THEN @Knt_Rodzaj_Dostawca ELSE 0 END,
  CASE WHEN @Knt_Rodzaj_Partner Is Not Null THEN @Knt_Rodzaj_Partner ELSE 0 END,
  CASE WHEN @Knt_Rodzaj_Konkurencja Is Not Null THEN @Knt_Rodzaj_Konkurencja ELSE 0 END,
  CASE WHEN @Knt_Rodzaj_Potencjalny Is Not Null THEN @Knt_Rodzaj_Potencjalny ELSE 0 END,
  0,--@Knt_ZgodaNaEFaktury,
  GETDATE(),
  GETDATE(),
  1,
  1,
  0.0,
  1,
  @Rab_Rabat,
  '',
  @Knt_KrajISO,
  @OpeId,
  @OpeModKod,
  @OpeModNazwisko,
  @OpeId,
  @OpeModKod,
  @OpeModNazwisko,
  GETDATE(),
  @ZrdId,
  1,
  @Knt_KorKraj,
  @Knt_KorMiasto,
  @Knt_KorUlica,
  @Knt_KorNrDomu,
  @Knt_KorNrLokalu,
  @Knt_KorKodPocztowy,
  @Knt_KorPoczta,
  IsNull(@Knt_Waluta, ''),
  @Knt_AlgorytmIns,
  @Knt_NieUwzglVATZD,
  @Knt_SplitPay
  )
  SELECT @SlowID = SCOPE_IDENTITY()
  SET @OperationType = 1 -- OptimaOperationType_Dodanie
  IF(IsNull(@Rab_Rabat, 0)<>0 AND (Select Rab_Rabat=IsNull(Rab_Rabat,0)
  From CDN.Kontrahenci Left Outer Join CDN.Rabaty
   On Rab_Typ = 2 And Rab_TwrID
   Is Null And Rab_PodmiotTyp = 1 And Rab_PodmiotId = Knt_KntId
  Where Knt_KntId = @SlowId) = 0)
  BEGIN
   INSERT INTO CDN.Rabaty
   (
   Rab_Typ,
   Rab_TypCenyNB,
   Rab_TwrId,
   Rab_PodmiotTyp,
   Rab_PodmiotId,
   Rab_Rabat,
   Rab_Cena,
   Rab_Waluta,
   Rab_Opis
   )
   VALUES
   (
   2,
   0,
   NULL,
   1,
   @SlowId,
   @Rab_Rabat,
   0.00,
   '',
   ''
   )
  END
  DELETE FROM CDN.SchematPlatnosci WHERE Spl_PodmiotTyp=1 AND Spl_PodmiotID = @SlowID
 --  IF ISNULL(@Knt_RachunekNr, '' ) != ''
 --   EXEC CDN.ImportKntRach @SlowID, @OnlyNew, @ConfigDBName, @ServerName,
 --    @FPl_Nazwa,
 --    @FPl_ImportRowId,
 --    @BNa_Numer, @BNa_ImportRowId,
 --    '', --@Spl_Opis,
 --    1, --@Spl_Reszta,
 --    1, --@Spl_LiczbaPorz,
 --    @Knt_IBAN, --@Spl_IBAN,
 --    @Knt_RachunekNr, --@Spl_RachunekNr,
 --    @ZrdId,
 --    @OpeId,
 --    @RachID,
 --    @WarningsRach
  UPDATE CDN.Kontrahenci
  SET Knt_TS_Export = GETDATE()
  WHERE Knt_KntId = @SlowID
 END
 END
 ELSE IF(@OnlyNew <> 1)
 BEGIN
 SELECT @SlowId = Knt_KntId FROM CDN.Kontrahenci WHERE IsNull(@Knt_ImportRowId, '') <> '' AND  Knt_ImportRowId = @Knt_ImportRowId
 IF (ISNULL(@SlowID, 0) = 0)
 BEGIN
  IF IsNull(@OCR, 0) <> 0
  BEGIN
   SELECT @SlowID = Knt_KntID FROM CDN.Kontrahenci WHERE Knt_Kod = @Knt_Kod AND Knt_Nieaktywny = 0
   IF (ISNULL(@SlowID, 0) = 0)
    SELECT @SlowID = Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NipE = @Knt_NipE AND Knt_Nieaktywny = 0
  END
  ELSE
   SELECT @SlowID = Knt_KntID FROM CDN.Kontrahenci WHERE Knt_Kod = @Knt_Kod
 END
 IF IsNull(@OCR, 0) = 0
 BEGIN
  UPDATE CDN.Kontrahenci
  SET
    Knt_Kod = UPPER(@Knt_Kod),
    Knt_GLN = @Knt_GLN,
    Knt_Grupa = @Knt_Grupa,
    Knt_Nazwa1 = @Knt_Nazwa1,
    Knt_Nazwa2 = @Knt_Nazwa2,
    Knt_Nazwa3 = @Knt_Nazwa3,
    Knt_Kraj = @Knt_Kraj,
    Knt_Wojewodztwo = @Knt_Wojewodztwo,
    Knt_Powiat = @Knt_Powiat,
    Knt_Gmina = @Knt_Gmina,
    Knt_Ulica = @Knt_Ulica,
    Knt_NrDomu = @Knt_NrDomu,
    Knt_NrLokalu = @Knt_NrLokalu,
    Knt_Miasto = @Knt_Miasto,
    Knt_KodPocztowy = @Knt_KodPocztowy,
    Knt_Poczta = @Knt_Poczta,
    Knt_Adres2 = @Knt_Adres2,
    Knt_Nip = REPLACE(REPLACE(@Knt_NipE, '-', ''), ' ', ''),
    Knt_NipE = REPLACE(@Knt_NipE, ' ', ''),
    Knt_NipKraj = @Knt_NipKraj,
    Knt_Regon = @Knt_Regon,
    Knt_Pesel = @Knt_Pesel,
    Knt_Telefon1 = @Knt_Telefon1,
    Knt_Telefon2 = @Knt_Telefon2,
    Knt_Fax = @Knt_Fax,
    Knt_Email = @Knt_Email,
    Knt_URL = @Knt_URL,
    Knt_Zezwolenie = @Knt_Zezwolenie,
  --  Knt_BNaID = @Knt_BNaID,
  --  Knt_RachunekNr = IsNull(@Knt_RachunekNr, '' ),
  --  Knt_IBAN = IsNull(@Knt_IBAN, 0 ),
    Knt_Informacje = @Knt_Informacje,
    Knt_LimitFlag = @Knt_LimitFlag,
    Knt_LimitKredytu = @Knt_LimitKredytu,
    Knt_Ceny = @Knt_Ceny,
    --Knt_FplID = @Knt_FplId,
   --Jeśli w pliku nie ma odnośnych tagów, nie zmieniamy formy płatności czyli podstawiamy to, co było, w przeciwnym przypadku podstawiamy wartość odczytaną z bazy lub domyślną.
    Knt_FplID = CASE WHEN @FPlParamIsNull = 1 THEN Knt_FplID ELSE @Knt_FplID END,
    Knt_MaxZwloka = @Knt_MaxZwloka,
    Knt_TerminPlat = CASE WHEN @Knt_TerminPlat Is Not Null THEN @Knt_TerminPlat ELSE Knt_TerminPlat END,
    Knt_Termin = CASE WHEN @Knt_Termin Is Not Null THEN @Knt_Termin ELSE Knt_Termin END,
   --Jeśli @KatId nie jest NULL-em, znaczy to, że w pliku jest tag - zmieniamy więc kategorię w zależności czy wartość jest zerowa (czyścimy, czyli podstawiamy NULL-a) czy niezerowa
   --Jeśli @KatId jest NULL-em, znaczy to, że w pliku nie ma taga - nie zmieniamy więc kategorii czyli podstawiamy to, co było
    Knt_KatID = CASE WHEN @Knt_KatId Is Not Null THEN (CASE WHEN @Knt_KatId <> 0 THEN @Knt_KatId ELSE NULL END) ELSE Knt_KatID END,
    Knt_KatZakID = CASE WHEN @Knt_KatZakId Is Not Null THEN (CASE WHEN @Knt_KatZakId <> 0 THEN @Knt_KatZakID ELSE NULL END) ELSE Knt_KatZakId END,
    Knt_PodatekVat = @Knt_PodatekVat,
    Knt_Finalny = @Knt_Finalny,
    Knt_Export = @Knt_Export,
    Knt_Medialny = @Knt_Medialny,
    Knt_PowiazanyUoV = CASE WHEN @Knt_PowiazanyUoV Is Not Null THEN @Knt_PowiazanyUoV ELSE Knt_PowiazanyUoV END,
    Knt_Nieaktywny = @Knt_Nieaktywny,
    Knt_Chroniony = @Knt_Chroniony,
    Knt_Opis = @Knt_Opis,
    Knt_OdbiorcaId = @Knt_OdbiorcaId,
    Knt_ImportRowId = @Knt_ImportRowId,
    Knt_OpiekunTyp = @OpiekTyp,
    Knt_OpiekunId = @OpiekId,
    Knt_EAN = @Knt_EAN,
    Knt_NieRozliczac = CASE WHEN @Knt_NieRozliczac Is Not Null THEN @Knt_NieRozliczac ELSE Knt_NieRozliczac END,
    Knt_Komornik = @Knt_Komornik,
    Knt_KomornikOkreg = @Knt_KomornikOkreg,
    Knt_KomornikMiasto = @Knt_KomornikMiasto,
    Knt_KomornikRewir = @Knt_KomornikRewir,
    Knt_KodTransakcji = @Knt_KodTransakcji,
    Knt_Rolnik = CASE WHEN @Knt_Rolnik Is Not Null THEN @Knt_Rolnik ELSE Knt_Rolnik END,
    Knt_NieNaliczajOdsetek = CASE WHEN @Knt_NieNaliczajOdsetek Is Not Null THEN @Knt_NieNaliczajOdsetek ELSE Knt_NieNaliczajOdsetek END,
    --Knt_MetodaKasowa = CASE WHEN @OCR = 1 AND @MetodaKasowaBrakTagow = 1 THEN Knt_MetodaKasowa ELSE @Knt_MetodaKasowa END,
    Knt_MetodaKasowa = @Knt_MetodaKasowa,
    Knt_ZakazDokumentowHaMag = @Knt_ZakazDokumentowHaMag,
    Knt_LimitPrzeterKredytFlag = @Knt_LimitPrzeterKredytFlag,
    Knt_LimitPrzeterKredytWartosc = @Knt_LimitPrzeterKredytWartosc,
    Knt_NaliczajPlatnosc = CASE WHEN @Knt_NaliczajPlatnosc Is Not Null THEN @Knt_NaliczajPlatnosc ELSE Knt_NaliczajPlatnosc END,
    Knt_TerminZwrotuKaucji = @Knt_TerminZwrotuKaucji,
    Knt_Rodzaj_Odbiorca = CASE WHEN @Knt_Rodzaj_Odbiorca Is Not Null THEN @Knt_Rodzaj_Odbiorca ELSE Knt_Rodzaj_Odbiorca END,
    Knt_Rodzaj_Dostawca = CASE WHEN @Knt_Rodzaj_Dostawca Is Not Null THEN @Knt_Rodzaj_Dostawca ELSE Knt_Rodzaj_Dostawca END,
    Knt_Rodzaj_Partner = CASE WHEN @Knt_Rodzaj_Partner Is Not Null THEN @Knt_Rodzaj_Partner ELSE Knt_Rodzaj_Partner END,
    Knt_Rodzaj_Konkurencja = CASE WHEN @Knt_Rodzaj_Konkurencja Is Not Null THEN @Knt_Rodzaj_Konkurencja ELSE Knt_Rodzaj_Konkurencja END,
    Knt_Rodzaj_Potencjalny = CASE WHEN @Knt_Rodzaj_Potencjalny Is Not Null THEN @Knt_Rodzaj_Potencjalny ELSE Knt_Rodzaj_Potencjalny END,
    Knt_TS_Mod = GETDATE(),
    -- Knt_TS_Zal = GETDATE(), 136354
    Knt_MalyPod = 1,
    Knt_Rodzaj = 1,
    Knt_BlokadaDok = 1,
    Knt_Upust = @Rab_Rabat,
    -- Knt_LimitKredytuWal = '',
    Knt_KrajISO = @Knt_KrajISO,
    Knt_OpeModID = @OpeId,
    Knt_OpeModKod = @OpeModKod,
    Knt_OpeModNazwisko = @OpeModNazwisko,
    Knt_TS_Export = GETDATE(),
    Knt_KorKraj = @Knt_KorKraj,
    Knt_KorMiasto = @Knt_KorMiasto,
    Knt_KorUlica = @Knt_KorUlica,
    Knt_KorNrDomu = @Knt_KorNrDomu,
    Knt_KorNrLokalu = @Knt_KorNrLokalu,
    Knt_KorKodPocztowy = @Knt_KorKodPocztowy,
    Knt_KorPoczta = @Knt_KorPoczta,
    Knt_Waluta = CASE WHEN @Knt_Waluta Is Not Null THEN @Knt_Waluta ELSE Knt_Waluta END,
    Knt_Algorytm = CASE WHEN @Knt_Algorytm Is Not Null THEN @Knt_Algorytm ELSE Knt_Algorytm END,
    Knt_NieUwzglVATZD = @Knt_NieUwzglVATZD,
    Knt_SplitPay = CASE WHEN @Knt_SplitPay Is Not Null THEN @Knt_SplitPay ELSE Knt_SplitPay END
  WHERE Knt_KntID = @SlowId
  SET @OperationType = 2 -- OptimaOperationType_Modyfikacja
  UPDATE CDN.Rabaty SET Rab_Rabat = @Rab_Rabat WHERE Rab_PodmiotId = @SlowId and Rab_PodmiotTyp = 1 AND Rab_Typ = 2
  -- DELETE FROM CDN.SchematPlatnosci WHERE Spl_PodmiotTyp=1 AND Spl_PodmiotID = @SlowID
 END
 END
 ELSE
 RAISERROR('##OPT33041##', 16, 1) --RAISERROR('Taki zapis już istnieje. Element nie został dodany', 16, 1)
 IF @OperationType <> 0
 BEGIN
  DECLARE @Knt_KodU nvarchar(20)
  SELECT @Knt_KodU = UPPER(@Knt_Kod)
  EXEC CDN.RejestrOperacjiZapiszKontrahenta
    @ID = @SlowID,
    @Kod = @Knt_KodU,
    @TypOperacji = @OperationType
 END
END
