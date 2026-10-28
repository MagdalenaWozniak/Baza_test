CREATE PROCEDURE CDN.ImportRejZak
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@VaN_ImportRowId nvarchar(36),
@Modul nvarchar(20),
@Typ nvarchar(30),
@VaN_Rejestr nvarchar(20),
@VaN_DataWys nvarchar(10),
@VaN_DataOpe nvarchar(10),
@VaN_DataZap nvarchar(10),
@VaN_Termin nvarchar(10),
@VaN_DataObowiazkuPodatkowego nvarchar(10),
@VaN_DataPrawaOdliczenia nvarchar(10),
@VaN_Dokument nvarchar(256),
@VaN_Korekta tinyint,
@VaN_KorektaDo nvarchar(256),
@VaN_Wewnetrzna tinyint,
@VaN_MetodaKasowa tinyint,
@VaN_Fiskalna tinyint,
@VaN_Detal tinyint,
@VaN_Export smallint,
@VaN_Finalny tinyint,
@VaN_PodatekVAT tinyint,
@VaN_IdentKsieg nvarchar(30),
@Pod_TypOpis nvarchar(20),
@Pod_Kod nvarchar(20),
@Pod_ImportRowId nvarchar(36),
@Pod_NIP nvarchar(20),
@VaN_KntNazwa1 nvarchar(50),
@VaN_KntNazwa2 nvarchar(50),
@VaN_KntNazwa3 nvarchar(250),
@VaN_KntNipKraj nvarchar(2),
@VaN_KntNipE nvarchar(32),
@VaN_KntKraj nvarchar(40),
@VaN_KntWojewodztwo nvarchar(40),
@VaN_KntPowiat nvarchar(40),
@VaN_KntGmina nvarchar(40),
@VaN_KntUlica nvarchar(40),
@VaN_KntNrDomu nvarchar(10),
@VaN_KntNrLokalu nvarchar(10),
@VaN_KntMiasto nvarchar(40),
@VaN_KntKodPocztowy nvarchar(10),
@VaN_KntPoczta nvarchar(40),
@VaN_KntAdres2 nvarchar(40),
@VaN_Pesel nvarchar(11),
@Zal_TypOpis nvarchar(20),
@Zal_Kod nvarchar(20),
@Zal_ImportRowId nvarchar(36),
@Zal_NIP nvarchar(20),
@VaN_Rolnik tinyint,
@VaN_PlatnikTypOpis nvarchar(10),
@VaN_PlatnikKod nvarchar(20),
@VaN_PlatnikImportRowID nvarchar(36),
@VaN_PlatnikNIP nvarchar(20),
@VaN_PlatnikRachunekNr0 nvarchar(51),
@Kat_KodSzczegol nvarchar(20),
@Kat_ImportRowId nvarchar(36),
@VaN_Kategoria nvarchar(50),
@FPl_Nazwa nvarchar(20),
@FPl_ImportRowId nvarchar(36),
@VaN_DeklVat7 nvarchar(10),
@VaN_DeklUE nvarchar(10),
@VaN_Waluta nvarchar(3),
@WKu_Symbol nvarchar(5),
@VaN_KursL decimal(15, 4),
@VaN_KursM decimal(5, 0),
@VaN_DataKur nvarchar(10),
@VaN_KursDoKsiegowania tinyint,
@WKu_Symbol2 nvarchar(5),
@VaN_KursLDoVAT decimal(15, 4),
@VaN_KursMDoVAT decimal(5, 0),
@VaN_DataKurDoVAT nvarchar(10),
@VaN_TrybNettoVAT tinyint,
@VaN_AkcyzaWegiel DECIMAL(15,2),
@VaN_AkcyzaWegiel_KolumnaKPR tinyint,
@VaN_JPK_FA tinyint,
@Zak_Symbol nvarchar(30),
@Zak_ImportRowId nvarchar(36),
@VaN_MPP tinyint,
@netto decimal(15,2),
@vat decimal(15,2),
@nettoSys decimal(15,2),
@vatSys decimal(15,2),
@nettoSys2 decimal(15,2),
@vatSys2 decimal(15,2),
@walutaPlat nvarchar(3),
@symbolPlat nvarchar(5),
@kursLPlat decimal(15, 4),
@kursMPlat decimal(5, 0),
@dataKurPlat nvarchar(10),
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 DECLARE
  @Lp       int,
  @DeklRokMiesKasa   int,
  @RozliczacVat7    tinyint,
  @AutoVat7Kasa    tinyint,
  @KorektaVAT     nvarchar(30),
  @PodTyp      smallint,
  @PodId      int,
  @ZalTyp      smallint,
  @ZalId      int,
  @KntKonto     nvarchar(20),
  @MalyPod     tinyint,
  @FplId      int,
  @Rozliczono     tinyint,
  @KursNumer     int,
  @KursNumer2     int,
  @Zaplata     decimal(15,2),
  @WartoscZak     decimal(15,2),
  @TrNId      int,
  @VanOrgId     int,
  @CloProc     decimal(5,2),
  @CloWart     decimal(15,2),
  @AkcyzaProc     decimal(5,2),
  @AkcyzaWart     decimal(15,2),
  @PodImpProc     decimal(5,2),
  @PodImpWart     decimal(15,2),
  @MetodaRozlicz    nvarchar(4000),
  @RozliczKwart    nvarchar(4000),
  @KntMedialny    tinyint,
  @FAPATerminOd    tinyint,
  @KatId      int,
  @Error      nvarchar(256),
  @IdentKsieg     nvarchar(30),
  @DeklRokMies    int,
  @BraId      int,
  @BRpID      int,
  @BRpLP      int,
  @DDfId      int,
  @BNaId      int,
  @RachunekNr     nvarchar(51),
  @MaxNr      int,
  @BZp_NumerString   nvarchar(31),
  @BZp_Schemat    nvarchar(50),
  @CzySeriaOper    int,
  @seriaOper     nvarchar(5),
  @WkuIdPlat     int,
  @IBAN      tinyint,
  @notUsed     int
 DECLARE @DocAlreadyExists TINYINT
 IF ((SELECT count(*) FROM CDN.VatNag WHERE VaN_ImportRowId = @VaN_ImportRowId) = 0)
  SELECT @DocAlreadyExists = 0
 ELSE
  SELECT @DocAlreadyExists = 1
 IF @DocAlreadyExists = 0 AND @Modul = 'Rejestr Vat - OCR'
 BEGIN
  IF ((SELECT COUNT(*) FROM cdn.VatNag WHERE VaN_Dokument = @VaN_Dokument AND VaN_KntNipE = REPLACE(@VaN_KntNipE, ' ', '') AND VaN_RazemNetto = @nettoSys AND VaN_DataWys = CONVERT(DATETIME, @VaN_DataWys, 120)) > 0)
   SELECT @DocAlreadyExists = 1
 END
 IF(@DocAlreadyExists = 0)
 BEGIN
  IF @Modul = 'Handel'
  BEGIN
   SET @IdentKsieg = case (SELECT Fir_Wartosc
         FROM CDN.Firma
         WHERE Fir_Numer = 1762)
        when '1' then @VaN_IdentKsieg
        else ''
        end
  END
  ELSE SET @IdentKsieg = ''
  IF(SELECT Fir_Wartosc
   FROM CDN.Firma
   WHERE Fir_Numer = 1201) = '1'
  BEGIN
    SELECT TOP 1 @Lp = IsNull(VaN_Lp, 0) + 1
    FROM CDN.VatNag
    WHERE YEAR(convert(datetime, @VaN_DataZap, 120)) = YEAR(VaN_DataZap) and VaN_Rejestr = @VaN_Rejestr AND VaN_Typ = 1
    ORDER BY VaN_Lp
    DESC
  END
  ELSE
  BEGIN
    SELECT TOP 1 @Lp = IsNull(VaN_Lp, 0) + 1
    FROM CDN.VatNag
    WHERE (convert(nvarchar(4), YEAR(convert(datetime, @VaN_DataZap, 120))) +
     case LEN(convert(nvarchar(2), MONTH(convert(datetime, @VaN_DataZap, 120)))) when 1 then '0' else '' end +
     convert(nvarchar(2), MONTH(convert(datetime, @VaN_DataZap, 120)))) = VaN_RokMies and VaN_Rejestr = @VaN_Rejestr AND VaN_Typ = 1
    ORDER BY VaN_Lp
    DESC
  END
  IF(@Lp is NULL) SET @Lp = 1
  SET @Warnings = ''
  IF LEN(REPLACE(REPLACE(@VaN_KntNipE, '-', ''), ' ', '')) > 20 OR LEN(REPLACE(@VaN_KntNipE, ' ', '')) > 20
  BEGIN
   RAISERROR('##OPT33073##', 16, 1) --RAISERROR('Wystąpił błąd przy imporcie składnika. Numer NIP jest zbyt długi.', 16, 1)
   RETURN
  END
  IF(@Fpl_Nazwa is NULL OR @Fpl_Nazwa = '') SET @Fpl_Nazwa = 'gotówka'
  SELECT @FplId = Fpl_FplId, @BraId = Fpl_BraId
  FROM CDN.FormyPlatnosci
  WHERE Fpl_ImportRowId = @Fpl_ImportRowId
  IF @FplId is NULL
   SELECT @FplId = Fpl_FplId
   FROM CDN.FormyPlatnosci
   WHERE Fpl_Nazwa = @Fpl_Nazwa
  IF @Modul = 'Rejestr Vat - OCR' AND @Pod_TypOpis = 'kontrahent'
  BEGIN
   SELECT TOP 1 @PodId = Knt_KntId, @PodTyp = 1 FROM CDN.Kontrahenci WHERE Knt_Kod = @Pod_Kod AND Knt_Nieaktywny = 0 AND Knt_NadID Is Null ORDER BY Knt_KntId
   IF (@PodId IS NULL AND IsNull(@VaN_KntNipE, '') <> '')
    SELECT TOP 1 @PodId = Knt_KntId, @PodTyp = 1 FROM CDN.Kontrahenci WHERE Knt_Nip = REPLACE(@Pod_NIP, '-', '') AND Knt_Nieaktywny = 0 AND Knt_NadID Is Null ORDER BY Knt_KntId
   IF (@PodID is NULL) -- jeśli nie ma kontrahenta w bazie dodajemy ostrzeżenie i przypisujemy kontrahenta nieokreślonego
   BEGIN
    SET @Warnings = @Warnings + '##OPT33138##%%podmiot%%=' + IsNull(@Pod_Kod, '') + '##\'
    SELECT @PodID = Knt_KntId, @PodTyp = 1 FROM CDN.Kontrahenci WHERE Knt_Kod = '!NIEOKREŚLONY!'
   END
  END
  ELSE
   EXEC CDN.GetPodmiotDlaPracyRozproszonej  @Pod_TypOpis, @Pod_Kod, @Pod_ImportRowId, @VaN_KntNipE, 1, @PodID OUTPUT, @PodTyp OUTPUT, @notUsed OUTPUT, @Warnings OUTPUT
  if(@Zal_TypOpis IS NOT NULL)
   EXEC CDN.GetPodmiotDlaPracyRozproszonej @Zal_TypOpis, @Zal_Kod, @Zal_ImportRowId, @Zal_NIP, 2, @ZalID OUTPUT, @ZalTyp OUTPUT, @notUsed OUTPUT, @Warnings OUTPUT
  DECLARE @PlatnikTyp int
  DECLARE @PlatnikID int
  DECLARE @PlatnikRachunekLp int
  SET @PlatnikRachunekLp = NULL
  IF @VaN_PlatnikTypOpis Is Not Null
  BEGIN
   IF @Modul = 'Rejestr Vat - OCR' AND @VaN_PlatnikTypOpis = 'kontrahent'
   BEGIN
    SELECT TOP 1 @PlatnikID = Knt_KntId, @PlatnikTyp = 1 FROM CDN.Kontrahenci WHERE Knt_Kod = @VaN_PlatnikKod AND Knt_Nieaktywny = 0 AND Knt_NadID Is Null ORDER BY Knt_KntId
    IF (@PlatnikID IS NULL AND IsNull(@VaN_PlatnikNIP, '') <> '')
     SELECT TOP 1 @PlatnikID = Knt_KntId, @PlatnikTyp = 1 FROM CDN.Kontrahenci WHERE Knt_Nip = REPLACE(@VaN_PlatnikNIP, '-', '') AND Knt_Nieaktywny = 0 AND Knt_NadID Is Null ORDER BY Knt_KntId
    IF @PlatnikID Is Not Null
    BEGIN
     IF @VaN_PlatnikRachunekNr0 Is Not Null AND @VaN_PlatnikRachunekNr0 <> ''
      SELECT @PlatnikRachunekLp = SPl_SPlID FROM CDN.SchematPlatnosci WHERE SPl_PodmiotTyp = @PlatnikTyp AND SPl_PodmiotID = @PlatnikID AND SPl_RachunekNr0 = @VaN_PlatnikRachunekNr0
    END
   END
   ELSE
    EXEC CDN.GetPlatnikDlaPracyRozproszonej @VaN_PlatnikTypOpis, @VaN_PlatnikKod, @VaN_PlatnikImportRowID, @VaN_PlatnikNIP, @VaN_PlatnikRachunekNr0,
     1,
     @PlatnikTyp OUTPUT, @PlatnikID OUTPUT, @PlatnikRachunekLp OUTPUT, @Warnings OUTPUT
   IF(@PlatnikID is NULL) -- jeśli nie ma podmiotu w bazie to zaliczkobiorca nie będzie wypełniony
   BEGIN
    SET @PlatnikTyp = @PodTyp
    SET @PlatnikID = @PodId
   END
  END
    ELSE
    BEGIN
      SET @PlatnikTyp = @PodTyp
      SET @PlatnikID = @PodId
    END
  EXECUTE @KursNumer = CDN.GetTypKursuWaluty @WKu_Symbol, @ConfigDBName, @ServerName
  if(@KursNumer is NULL)
   RAISERROR('##OPT32090##', 16, 1) --RAISERROR('Brak kursu waluty',  16, 1)
  --drugi kurs waluty
  EXECUTE @KursNumer2 = CDN.GetTypKursuWaluty @Wku_Symbol2, @ConfigDBName, @ServerName
  IF(@KursNumer2 is NULL AND @WKu_Symbol2 <> '')
   RAISERROR('##OPT33074##', 16, 1) --RAISERROR('Brak drugiego kursu waluty',  16, 1)
  --kurs waluty dla platnosci
  EXECUTE @WkuIdPlat = CDN.GetTypKursuWaluty @symbolPlat, @ConfigDBName, @ServerName
  IF @WkuIdPlat is NULL
   RAISERROR('##OPT33075##', 16, 1) --RAISERROR('Brak kursu waluty dla automatycznego zapisu',  16, 1)
  SELECT @TrNId = TrN_TrNId
  FROM CDN.TraNag
  WHERE TrN_TypDokumentu = 301 AND TrN_NumerPelny = @VaN_Dokument
  SET @AutoVat7Kasa = 1
  SELECT TOP 1 @MetodaRozlicz = CFW_Wartosc
  FROM CDN.cfgwartosci W
  WHERE (SELECT CFK_Nazwa
   FROM CDN.cfgklucze
   WHERE CFK_CfkId = W.CFW_CfkId) = 'Metoda rozliczania VAT'
  ORDER BY CFW_TS_Mod DESC
  SELECT TOP 1 @RozliczKwart = CFW_Wartosc
  FROM CDN.cfgwartosci W
  WHERE (SELECT CFK_Nazwa
   FROM CDN.cfgklucze
   WHERE CFK_CfkId = W.CFW_CfkId) = 'Rozliczanie VAT kwartalnie'
  ORDER BY CFW_TS_Mod DESC
  If(@KntMedialny = 1 AND @MetodaRozlicz = 1)
   SET @DeklRokMiesKasa = (100 * YEAR(convert(datetime, @VaN_DataWys, 120)) + MONTH(convert(datetime, @VaN_DataWys, 120)))
  ELSE SET @DeklRokMiesKasa = 0
  SELECT @FAPATerminOd = Fir_Wartosc
  FROM CDN.Firma
  WHERE Fir_Numer = 1573
  IF (NOT EXISTS( SELECT *
      FROM CDN.Grupy
      WHERE Gru_Typ = 1 and Gru_Nazwa = @Van_Rejestr) AND @Van_Rejestr<> '')
   INSERT INTO CDN.Grupy
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
   1,
   @VaN_Rejestr,
   'Rejestr zakupu VAT',
   NULL,
   GetDate(),
   GetDate()
   )
  SET @KorektaVAT = 0
  SET @KntKonto = ''
  SET @MalyPod = 0
  SET @Rozliczono = 0
  SET @Zaplata = 0
  SET @WartoscZak = 0
  SET @VanOrgId = NULL;
  SET @CloProc = 0
  SET @CloWart = 0
  SET @AkcyzaProc = 0
  SET @AkcyzaWart = 0
  SET @PodImpProc = 0
  SET @PodImpWart = 0
  IF(@KursNumer2 is NULL OR @VaN_KursLDoVAT is NULL OR @VaN_KursMDoVAT is NULL OR @VaN_DataKurDoVAT is NULL)
  BEGIN
   SET @KursNumer2 = @KursNumer
   SET @VaN_KursLDoVAT = @VaN_KursL
   SET @VaN_KursMDoVAT = @VaN_KursM
   SET @VaN_DataKurDoVAT = @VaN_DataKur
  END
  DECLARE @VaN_KntNazwa1_ nvarchar(50)
  DECLARE @VaN_KntNazwa2_ nvarchar(50)
  DECLARE @VaN_KntNazwa3_ nvarchar(250)
  IF (@Modul = 'Rejestr Vat - OCR')
  BEGIN
   IF (IsNull(@VaN_KntNazwa1, '') = '' OR IsNull(@VaN_KntNazwa2, '') = ''  OR IsNull(@VaN_KntNazwa3, '') = '' OR
    IsNull(@VaN_KntNipKraj, '') = '' OR IsNull(@VaN_KntKraj, '') = '' OR IsNull(@VaN_KntWojewodztwo, '') = '' OR IsNull(@VaN_KntPowiat, '') = '' OR IsNull(@VaN_KntGmina, '') = '' OR IsNull(@VaN_KntUlica, '') = '' OR IsNull(@VaN_KntNrDomu, '') = ''
              OR IsNull(@VaN_KntNrLokalu, '') = '' OR IsNull(@VaN_KntMiasto, '') = '' OR IsNull(@VaN_KntKodPocztowy, '') = '' OR IsNull(@VaN_KntPoczta, '') = '' OR IsNull(@VaN_KntAdres2, '') = '' OR
              IsNull(@VaN_Pesel, '') = '' OR @VaN_PodatekVAT Is NULL)
   BEGIN
    DECLARE @VaN_KntNipKraj_ nvarchar(2)
    DECLARE @VaN_KntKraj_ nvarchar(40)
    DECLARE @VaN_KntWojewodztwo_ nvarchar(40)
    DECLARE @VaN_KntPowiat_ nvarchar(40)
    DECLARE @VaN_KntGmina_ nvarchar(40)
    DECLARE @VaN_KntUlica_ nvarchar(40)
    DECLARE @VaN_KntNrDomu_ nvarchar(10)
    DECLARE @VaN_KntNrLokalu_ nvarchar(10)
    DECLARE @VaN_KntMiasto_ nvarchar(40)
    DECLARE @VaN_KntKodPocztowy_ nvarchar(10)
    DECLARE @VaN_KntPoczta_ nvarchar(40)
    DECLARE @VaN_KntAdres2_ nvarchar(40)
    DECLARE @VaN_Pesel_ nvarchar(11)
    DECLARE @VaN_PodatekVAT_ tinyint
    SELECT @VaN_KntNazwa1_ = Knt_Nazwa1, @VaN_KntNazwa2_ = Knt_Nazwa2, @VaN_KntNazwa3_ = Knt_Nazwa3, @VaN_KntNipKraj_ = Knt_NipKraj,
     @VaN_KntKraj_ = Knt_Kraj, @VaN_KntWojewodztwo_ = Knt_Wojewodztwo, @VaN_KntPowiat_ = Knt_Powiat, @VaN_KntGmina_ = Knt_Gmina, @VaN_KntUlica_ = Knt_Ulica, @VaN_KntNrDomu_ = Knt_NrDomu, @VaN_KntNrLokalu_ = Knt_NrLokalu,
     @VaN_KntMiasto_ = Knt_Miasto, @VaN_KntKodPocztowy_ = Knt_KodPocztowy, @VaN_KntPoczta_ = Knt_Poczta, @VaN_KntAdres2_ = Knt_Adres2, @VaN_Pesel_ = Knt_Pesel, @VaN_PodatekVAT_ = Knt_PodatekVAT
    FROM CDN.Kontrahenci
    WHERE Knt_KntId = @PodId AND @PodTyp = 1
    IF(IsNull(@VaN_KntNazwa1, '') = '')
     SELECT @VaN_KntNazwa1 = @VaN_KntNazwa1_
    IF(IsNull(@VaN_KntNazwa2, '') = '')
     SELECT @VaN_KntNazwa2 = @VaN_KntNazwa2_
    IF(IsNull(@VaN_KntNazwa3, '') = '')
     SELECT @VaN_KntNazwa3 = @VaN_KntNazwa3_
    IF(IsNull(@VaN_KntNipKraj, '') = '')
     SELECT @VaN_KntNipKraj = @VaN_KntNipKraj_
    IF(IsNull(@VaN_KntKraj, '') = '')
     SELECT @VaN_KntKraj = @VaN_KntKraj_
    IF(IsNull(@VaN_KntWojewodztwo, '') = '')
     SELECT @VaN_KntWojewodztwo = @VaN_KntWojewodztwo_
    IF(IsNull(@VaN_KntPowiat, '') = '')
     SELECT @VaN_KntPowiat = @VaN_KntPowiat_
    IF(IsNull(@VaN_KntGmina, '') = '')
     SELECT @VaN_KntGmina = @VaN_KntGmina_
    IF(IsNull(@VaN_KntUlica, '') = '')
     SELECT @VaN_KntUlica = @VaN_KntUlica_
    IF(IsNull(@VaN_KntNrDomu, '') = '')
     SELECT @VaN_KntNrDomu = @VaN_KntNrDomu_
    IF(IsNull(@VaN_KntNrLokalu, '') = '')
     SELECT @VaN_KntNrLokalu = @VaN_KntNrLokalu_
    IF(IsNull(@VaN_KntMiasto, '') = '')
     SELECT @VaN_KntMiasto = @VaN_KntMiasto_
    IF(IsNull(@VaN_KntKodPocztowy, '') = '')
     SELECT @VaN_KntKodPocztowy = @VaN_KntKodPocztowy_
    IF(IsNull(@VaN_KntPoczta, '') = '')
     SELECT @VaN_KntPoczta = @VaN_KntPoczta_
    IF(IsNull(@VaN_KntAdres2, '') = '')
     SELECT @VaN_KntAdres2 = @VaN_KntAdres2_
    IF(IsNull(@VaN_Pesel, '') = '')
     SELECT @VaN_Pesel = @VaN_Pesel_
    IF(@VaN_PodatekVAT is NULL)
     SELECT @VaN_PodatekVAT = @VaN_PodatekVAT_
   END
  END
  ELSE
  BEGIN
   IF (@VaN_KntNazwa1 is NULL OR @VaN_KntNazwa2 is NULL OR @VaN_KntNazwa3 is NULL)
   BEGIN
    SELECT @VaN_KntNazwa1_ = Knt_Nazwa1, @VaN_KntNazwa2_ = Knt_Nazwa2, @VaN_KntNazwa3_ = Knt_Nazwa3
    FROM CDN.Kontrahenci
    WHERE Knt_KntId = @PodId AND @PodTyp = 1
    IF(@VaN_KntNazwa1 is NULL)
     SELECT @VaN_KntNazwa1 = @VaN_KntNazwa1_
    IF(@VaN_KntNazwa2 is NULL)
     SELECT @VaN_KntNazwa2 = @VaN_KntNazwa2_
    IF(@VaN_KntNazwa3 is NULL)
     SELECT @VaN_KntNazwa3 = @VaN_KntNazwa3_
   END
  END
  DECLARE @KategoriaZKontrahenta TINYINT
  SELECT @KategoriaZKontrahenta = 0
  IF(@Kat_ImportRowId is not NULL OR @Kat_KodSzczegol is not NULL)
  BEGIN
   SET @KatId = NULL
   SELECT @KatId = Kat_KatId
   FROM CDN.Kategorie
   WHERE Kat_ImportRowId = @Kat_ImportRowId
   IF @KatId is NULL
   BEGIN
    SELECT @KatId = Kat_KatId
    FROM CDN.Kategorie
    WHERE Kat_KodSzczegol = @Kat_KodSzczegol
    IF @KatId is NULL
     --SET @Warnings = 'Brak kategorii ' + IsNull(@Kat_KodSzczegol, '') + ' w bazie docelowej. Kategoria nie została zaimportowana.\'
     SET @Warnings = '##OPT33150##%%kategoria%%=' + IsNull(@Kat_KodSzczegol, '') + '##\'
   END
  END
  ELSE IF @PodTyp = 1 AND (SELECT IsNull(Fir_Wartosc, '') FROM cdn.Firma WHERE Fir_Numer = 3139) = '1'
  BEGIN
   SELECT @KatID = Knt_KatZakID FROM cdn.Kontrahenci WHERE Knt_KntID = @PodID
   IF @KatID Is NOT NULL
    SELECT @KategoriaZKontrahenta = 1
  END
  IF(@VaN_Kategoria is NULL OR @VaN_Kategoria = '' AND @KategoriaZKontrahenta = 1)
  BEGIN
   SELECT @VaN_Kategoria = Kat_Opis FROM CDN.Kategorie WHERE Kat_KatId = @KatID
   SELECT @VaN_Kategoria = IsNull(@VaN_Kategoria, '')
  END
  DECLARE @sqltxt NVARCHAR (1000), @TmpSrvName SYSNAME
  SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
  IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
   SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
  SET @sqltxt = 'SELECT Ope_BlokadaVATDoVAT7 as blokada FROM ['
  IF @ServerName <> @TmpSrvName
   SET @sqltxt = @sqltxt + @ServerName +'].['
  SET @sqltxt = @sqltxt + @ConfigDBName + ']' + '.[CDN].[Operatorzy] WHERE Ope_OpeID = ' + convert(nvarchar(10), @OpeId)
  CREATE TABLE #TmpTable (blokada TINYINT)
  INSERT INTO #TmpTable (blokada)
  EXEC sp_executesql @sqltxt
  DECLARE @BlokadaVATDoVAT7 INT
  SELECT @BlokadaVATDoVAT7 = BLOKADA FROM #TmpTable
  DROP TABLE #TmpTable
  DECLARE @DeklaracjaVAT7Zablokowana INT
  EXEC CDN.CzyDeklaracjaVAT7Zablokowana @ConfigDBName, @ServerName, @VaN_DataZap, @OpeId, @DeklaracjaVAT7Zablokowana OUTPUT
  IF @DeklaracjaVAT7Zablokowana = 1
   --SET @Warnings = @VaN_Dokument + '. Deklaracja VAT-7 za podany okres została zatwierdzona. Należy ponownie sporządzić deklarację lub korektę do deklaracji.\'
   SET @Warnings = '##OPT33187##%%dokument%%=' + @VaN_Dokument + '##\'
  ELSE IF @DeklaracjaVAT7Zablokowana = 2
  BEGIN
   SET @Error = @VaN_Dokument + '. Dokument nie został dodany. Dotyczy deklaracji VAT-7, która została już zatwierdzona. Administrator zablokował możliwość wprowadzania zmian na takich dokumentach.'
   RAISERROR('##OPT33076##%%dokument%%=%s##', 16, 1, @VaN_Dokument) --RAISERROR( @Error, 16, 1)
  END
  IF @VaN_MetodaKasowa Is Null
   SELECT @VaN_MetodaKasowa = 0
  DECLARE @VaN_DataOpeDT DATETIME
  SET @VaN_DataOpeDT = convert(datetime, @VaN_DataOpe, 120)
  DECLARE @VaN_DataZapDT DATETIME
  SET @VaN_DataZapDT = convert(datetime, @VaN_DataZap, 120)
  DECLARE @VaN_DataObowiazkuPodatkowegoDT DATETIME
  IF IsNull(@VaN_DataObowiazkuPodatkowego, '') <> ''
   SET @VaN_DataObowiazkuPodatkowegoDT = convert(datetime, @VaN_DataObowiazkuPodatkowego, 120)
  ELSE
  BEGIN
   IF YEAR(@VaN_DataOpeDT)>=2014
   BEGIN
    DECLARE @Medialny INT
    DECLARE @Export INT
    IF @PodTyp = 1
     -- SELECT @Medialny = IsNull(CASE Knt_Medialny WHEN 0 THEN 0 ELSE 1 END, 0), @Export = IsNull(CASE Knt_Export WHEN 0 THEN 0 ELSE 1 END, 0) FROM cdn.Kontrahenci WHERE Knt_KntID = @PodId
     SELECT @Medialny = IsNull(CASE Knt_Medialny WHEN 0 THEN 0 ELSE 1 END, 0) FROM cdn.Kontrahenci WHERE Knt_KntID = @PodId
    ELSE
    BEGIN
     SET @Medialny = 0
     -- SET @Export = 0
    END
    SET @Export = @VaN_Export
    IF @Medialny = 1
     SET @VaN_DataObowiazkuPodatkowegoDT = convert(datetime, @VaN_DataWys, 120)
    ELSE
    BEGIN
     IF @Export = 3 OR @Export = 4
      SET @VaN_DataObowiazkuPodatkowegoDT = convert(datetime, @VaN_DataWys, 120)
     ELSE
      SET @VaN_DataObowiazkuPodatkowegoDT = convert(datetime, @VaN_DataOpe, 120)
    END
   END
   ELSE
    SET @VaN_DataObowiazkuPodatkowegoDT = @VaN_DataZapDT
  END
  DECLARE @VaN_DataPrawaOdliczeniaDT DATETIME
  IF IsNull(@VaN_DataPrawaOdliczenia, '') <> ''
   SET @VaN_DataPrawaOdliczeniaDT = convert(datetime, @VaN_DataPrawaOdliczenia, 120)
  ELSE
  BEGIN
   IF YEAR(@VaN_DataOpeDT)>=2014
   BEGIN
    IF @VaN_DataZapDT >= @VaN_DataObowiazkuPodatkowegoDT
     SET @VaN_DataPrawaOdliczeniaDT = @VaN_DataZapDT
    ELSE
     SET @VaN_DataPrawaOdliczeniaDT = @VaN_DataObowiazkuPodatkowegoDT
    END
   ELSE
    SET @VaN_DataPrawaOdliczeniaDT = @VaN_DataZapDT
  END
  IF @VaN_DeklVat7 <> 'Nie'
  BEGIN
   IF @VaN_DeklVat7 <> ''
    SET @DeklRokMies = convert(int, replace(@VaN_DeklVat7, '-', ''))
   ELSE
   BEGIN
    IF YEAR(convert(datetime, @VaN_DataOpe, 120)) >= 2014
     SET @DeklRokMies = (100 * YEAR(@VaN_DataPrawaOdliczeniaDT) + MONTH(@VaN_DataPrawaOdliczeniaDT))
    ELSE
     SET @DeklRokMies = (100 * YEAR(convert(datetime, @VaN_DataZap, 120)) + MONTH(convert(datetime, @VaN_DataZap, 120)))
   END
  END
  ELSE IF @VaN_DeklUE <> 'Nie'
    SET @DeklRokMies = convert(int, replace(@VaN_DeklUE, '-', ''))
    ELSE
    BEGIN
    IF YEAR(convert(datetime, @VaN_DataOpe, 120)) >= 2014
     SET @DeklRokMies = (100 * YEAR(@VaN_DataPrawaOdliczeniaDT) + MONTH(@VaN_DataPrawaOdliczeniaDT))
    ELSE
     SET @DeklRokMies = (100 * YEAR(convert(datetime, @VaN_DataZap, 120)) + MONTH(convert(datetime, @VaN_DataZap, 120)))
    END
  IF 100*YEAR(@VaN_DataPrawaOdliczeniaDT)+MONTH(@VaN_DataPrawaOdliczeniaDT) <> @DeklRokMies
   --SET @Warnings = @Warnings + 'Data prawa do odliczenia nie jest zgodna z datą rozliczenia w deklaracji VAT-7. Dokument został zaimportowany.\'
   SET @Warnings = @Warnings + '##OPT33190##\'
    DECLARE @Zak_Id int
    EXEC CDN.GetZakladDlaPracyRozproszonej @Zak_Symbol, @Zak_ImportRowId, 3, @Zak_ID OUTPUT, @Warnings OUTPUT
   INSERT
  INTO CDN.VatNag
  (
  VaN_Typ,
  VaN_Rodzaj,
  VaN_Rejestr,
  VaN_RokMies,
  VaN_Lp,
  VaN_DataZap,
  VaN_DataWys,
  VaN_DataOpe,
  VaN_DataObowiazkuPodatkowego,
  VaN_DataPrawaOdliczenia,
  VaN_DeklRokMies,
  VaN_DeklRokMiesKasa,
  VaN_RozliczacVat7,
  VaN_RozliczacVatUE,
  VaN_AutoVat7Kasa,
  VaN_IdentKsieg,
  VaN_Dokument,
  VaN_KorektaDo,
  VaN_Korekta,
  VaN_Fiskalna,
  VaN_KorektaVAT,
  VaN_Detal,
  VaN_Wewnetrzna,
  VaN_MetodaKasowa,
  VaN_PodmiotTyp,
  VaN_PodID,
  VaN_KntNazwa1,
  VaN_KntNazwa2,
  VaN_KntNazwa3,
  VaN_KntKraj,
  VaN_KntWojewodztwo,
  VaN_KntPowiat,
  VaN_KntGmina,
  VaN_KntUlica,
  VaN_KntNrDomu,
  VaN_KntNrLokalu,
  VaN_KntMiasto,
  VaN_KntKodPocztowy,
  VaN_KntPoczta,
  VaN_KntAdres2,
  VaN_Pesel,
  VaN_PodmiotZalTyp,
  VaN_PodZalId,
  VaN_KntNipKraj,
  VaN_KntNipE,
  VaN_KntKonto,
  VaN_Finalny,
  VaN_PodatekVAT,
  VaN_Export,
  VaN_MalyPod,
  VaN_Rolnik,
  VaN_PlatnikTyp,
  VaN_PlatnikID,
  VaN_PlatnikRachunekLp,
  VaN_PlatnikRachunekNr,
  VaN_Kategoria,
  VaN_Rozliczono,
  VaN_FplID,
  VaN_Termin,
  VaN_RazemNetto,
  VaN_RazemNettoDoVAT,
  VaN_RazemVAT,
  VaN_RazemVatDoVAT,
  VaN_RazemBrutto,
  VaN_RazemBruttoDoVAT,
  VaN_RazemBruttoWal,
  --VaN_RazemBruttoWal2,
  VaN_Waluta,
  VaN_KursNumer,
  VaN_KursDoKsiegowania,
  VaN_KursL,
  VaN_KursM,
  VaN_WalutaDoVAT,
  VaN_KursNumerDoVAT,
  VaN_KursLDoVAT,
  VaN_KursMDoVAT,
  VaN_DataKurDoVAT,
  VaN_TrybNettoVAT,
  VaN_AkcyzaWegiel,
  VaN_AkcyzaWegiel_KolumnaKPR,
  VaN_JPK_FA,
  VaN_RozliczacVat27,
  VaN_Zaplata,
  VaN_WartoscZak,
  VaN_TrnID,
  VaN_VanOrgId,
  VaN_CloProc,
  VaN_CloWart,
  VaN_AkcyzaProc,
  VaN_AkcyzaWart,
  VaN_PodImpProc,
  VaN_PodImpWart,
  VaN_KpRID,
  VaN_RycID,
  VaN_DekID,
  VaN_ZakID,
  VaN_ImportAppId,
  VaN_ImportRowId,
  VaN_OpeZalID,
  VaN_OpeZalKod,
  VaN_OpeZalNazwisko,
  VaN_StaZalId,
  VaN_TS_Zal,
  VaN_OpeModID,
  VaN_OpeModKod,
  VaN_OpeModNazwisko,
  VaN_StaModId,
  VaN_TS_Mod,
  VaN_KatId,
  VaN_DataKur,
  VaN_SplitPay,
  VaN_OCR
  )
  VALUES
  (
  1,
  0,
  @VaN_Rejestr,
  (100 * YEAR(convert(datetime, @VaN_DataWys, 120)) + MONTH(convert(datetime, @VaN_DataWys, 120))),
  @Lp,
  convert(datetime, @VaN_DataZap, 120),
  convert(datetime, @VaN_DataWys, 120),
  convert(datetime, @VaN_DataOpe, 120),
  @VaN_DataObowiazkuPodatkowegoDT,
  @VaN_DataPrawaOdliczeniaDT,
  @DeklRokMies,
  @DeklRokMiesKasa,
  --case @VaN_DeklVat7 when 'Nie' then 0 else case @VaN_DeklUE when 'Tak' then 1 when 'Nie' then 0 end end,
  case @VaN_DeklVat7 when 'Nie' then 0 else 1 end,
  case @VaN_DeklUE when 'Nie' then 0 when '' then 0 else 1 end,
  @AutoVat7Kasa,
  @IdentKsieg,
  @VaN_Dokument,
  @VaN_KorektaDo,
  @VaN_Korekta,
  @VaN_Fiskalna,
  @KorektaVAT,
  @VaN_Detal,
  @VaN_Wewnetrzna,
  @VaN_MetodaKasowa,
  @PodTyp,
  @PodId,
  @VaN_KntNazwa1,
  @VaN_KntNazwa2,
  @VaN_KntNazwa3,
  @VaN_KntKraj,
  @VaN_KntWojewodztwo,
  @VaN_KntPowiat,
  @VaN_KntGmina,
  @VaN_KntUlica,
  @VaN_KntNrDomu,
  @VaN_KntNrLokalu,
  @VaN_KntMiasto,
  @VaN_KntKodPocztowy,
  @VaN_KntPoczta,
  @VaN_KntAdres2,
  ISNULL(@VaN_Pesel, ''),
  @ZalTyp,
  @ZalId,
  @VaN_KntNipKraj,
  REPLACE(@VaN_KntNipE, ' ', ''),
  @KntKonto,
  @VaN_Finalny,
  CASE WHEN @VaN_Export = 0 AND @VaN_Finalny = 0 THEN ISNULL(@VaN_PodatekVAT, 1) ELSE ISNULL(@VaN_PodatekVAT, 0) END,
  case @VaN_Export
   when 2 then 1
      when 6 then 0
   when 7 then 0
   else @VaN_Export end,
  @MalyPod,
  @VaN_Rolnik,
  @PlatnikTyp,
  @PlatnikID,
  @PlatnikRachunekLp,
    CASE WHEN IsNull(@PlatnikRachunekLp, 0) <>0 THEN @VaN_PlatnikRachunekNr0 ELSE '' END,
  @VaN_Kategoria,
  @Rozliczono,
  @FplId,
  convert(datetime, @VaN_Termin, 120),
  @nettoSys,
  @nettoSys2,
  @vatSys,
  @vatSys2,
  @nettoSys + @vatSys,
  @nettoSys2 + @vatSys2,
  @netto + @vat,
  --0,
  @VaN_Waluta,
  @KursNumer,
  @VaN_KursDoKsiegowania,
  case when @VaN_KursL=0 then 1 else @Van_KursL end,
  case when @VaN_KursM=0 then 1 else @Van_KursM end,
  @VaN_Waluta,
  @KursNumer2,
  case when @VaN_KursLDoVAT=0 then 1 else @Van_KursLDoVAT end,
  case when @VaN_KursMDoVAT=0 then 1 else @Van_KursMDoVAT end,
  convert(datetime, @VaN_DataKurDoVAT, 120),
  @VaN_TrybNettoVAT,
  ISNULL(@VaN_AkcyzaWegiel, 0),
  CASE WHEN @VaN_AkcyzaWegiel_KolumnaKPR IS NULL THEN CASE ISNULL(@VaN_AkcyzaWegiel, 0) WHEN 0 THEN 0 ELSE 7 END ELSE @VaN_AkcyzaWegiel_KolumnaKPR END,
  IsNull(@VaN_JPK_FA, 0),
  0,
  @Zaplata,
  @WartoscZak,
  @TrnID,
  @VanOrgId,
  @CloProc,
  @CloWart,
  @AkcyzaProc,
  @AkcyzaWart,
  @PodImpProc,
  @PodImpWart,
  NULL,
  NULL,
  NULL,
  @Zak_Id,
  @ZrdId,
  @VaN_ImportRowId,
  @OpeId,
  @OpeModKod,
  @OpeModNazwisko,
  NULL,
  GETDATE(),
  @OpeId,
  @OpeModKod,
  @OpeModNazwisko,
  NULL,
  GETDATE(),
  @KatId,
  convert(datetime, @VaN_DataKur, 120),
  IsNull(@VaN_MPP, 0),
  CASE WHEN @Modul = 'Rejestr Vat - OCR' THEN 1 ELSE 0 END
  )
  SET @IdParam = SCOPE_IDENTITY()
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 999, -- e_op_KlasaRejestrVat
    @ObiektSubTyp = 1,
    @ObiektID = @IdParam,
    @ObiektNazwa = @VaN_Dokument,
    @OperacjaTyp = 1, -- OptimaOperationType_Dodanie
    @Opis = '' --@VaN_Dokument
  IF @Modul = 'Rejestr Vat - OCR' AND @PodTyp = 1
  BEGIN
   /*
   W przypadku pliku XML pochodzącego z OCR, w węźle dokumentu nie ma gałęzi KODY_JPK i dlatego są one dziedziczone z kontrahenta i kategorii
   */
   INSERT INTO cdn.DokKodyJPKV7 (DKV7_ParentTyp, DKV7_ParentID, DKV7_KV7ID, DKV7_Status)
    SELECT 2, @IdParam, A.DKV7_KV7ID, A.DKV7_Status FROM cdn.DokKodyJPKV7 A INNER JOIN cdn.KodyJPKV7 ON KV7_KV7ID = A.DKV7_KV7ID
     WHERE A.DKV7_ParentTyp = 0 AND A.DKV7_ParentID = @PodId AND KV7_Typ IN (0, 1) AND KV7_Rodzaj <> 1
   DECLARE @KV7ID INT
   DECLARE @KntRolnik INT
   SELECT @KntRolnik = IsNull(Knt_Rolnik, 0) FROM cdn.Kontrahenci WHERE Knt_KntID = @PodId
   IF @KntRolnik <> 0
   BEGIN
    SELECT @KV7ID = KV7_KV7ID FROM cdn.KodyJPKV7 WHERE KV7_Kod = 'VAT_RR'
    IF @KV7ID IS NOT NULL
    BEGIN
     IF NOT EXISTS(SELECT * FROM cdn.DokKodyJPKV7 WHERE DKV7_ParentTyp = 2 AND DKV7_ParentID = @IdParam AND DKV7_KV7ID = @KV7ID)
      INSERT INTO cdn.DokKodyJPKV7 (DKV7_ParentTyp, DKV7_ParentID, DKV7_KV7ID, DKV7_Status) VALUES(2, @IdParam, @KV7ID, 1)
    END
   END
   DECLARE @KntMetodaKasowa INT
   SELECT @KntMetodaKasowa = IsNull(Knt_MetodaKasowa, 0) FROM cdn.Kontrahenci WHERE Knt_KntID = @PodId
   IF @KntMetodaKasowa = 1 OR @KntMetodaKasowa = 3 -- Zaznaczone Metoda kasowa - zakup
   BEGIN
    SELECT @KV7ID = KV7_KV7ID FROM cdn.KodyJPKV7 WHERE KV7_Kod = 'MK'
    IF @KV7ID IS NOT NULL
    BEGIN
     IF NOT EXISTS(SELECT * FROM cdn.DokKodyJPKV7 WHERE DKV7_ParentTyp = 2 AND DKV7_ParentID = @IdParam AND DKV7_KV7ID = @KV7ID)
      INSERT INTO cdn.DokKodyJPKV7 (DKV7_ParentTyp, DKV7_ParentID, DKV7_KV7ID, DKV7_Status) VALUES(2, @IdParam, @KV7ID, 1)
    END
   END
   IF IsNull(@KatId, 0) <> 0
    INSERT INTO cdn.DokKodyJPKV7 (DKV7_ParentTyp, DKV7_ParentID, DKV7_KV7ID, DKV7_Status)
     SELECT 2, @IdParam, A.DKV7_KV7ID, A.DKV7_Status FROM cdn.DokKodyJPKV7 A INNER JOIN cdn.KodyJPKV7 ON KV7_KV7ID = A.DKV7_KV7ID
      WHERE A.DKV7_ParentTyp = 3 AND A.DKV7_ParentID = @KatId AND KV7_Typ IN (0, 1) AND KV7_Rodzaj <> 1
      AND NOT EXISTS (SELECT * FROM cdn.DokKodyJPKV7 B WHERE B.DKV7_ParentTyp = 2 AND B.DKV7_ParentID = @IdParam AND B.DKV7_KV7ID = A.DKV7_KV7ID)
  END
 END
 ELSE
 BEGIN
  SET @Error = @VaN_Dokument + '. Taki dokument już istnieje w bazie.'
  RAISERROR('##OPT33077##%%dokument%%=%s##', 16, 1, @VaN_Dokument) --SET @Error = @VaN_Dokument + '. Taki dokument już istnieje w bazie.'; RAISERROR( @Error, 16, 1)
 END
END
