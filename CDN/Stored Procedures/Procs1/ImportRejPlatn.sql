CREATE PROCEDURE CDN.ImportRejPlatn
@DokId int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@BZd_ImportRowId nvarchar(36),
@BZd_Termin nvarchar(10),
@FPl_Nazwa nvarchar(20),
@FPl_ImportRowId nvarchar(36),
@BZd_Kwota decimal(15,2),
@BZd_Waluta nvarchar(3),
@WKu_Symbol nvarchar(5),
@BZd_KursL decimal(15,4),
@BZd_KursM decimal(5,0),
@BZd_KwotaSys decimal(15,2),
@BZd_Kierunek smallint,
@BZd_Rozliczono tinyint,
@BZd_KontoPrzeciwstawne nvarchar(50),
@BZd_NieNaliczajOdsetek tinyint,
@BZd_PrzelewSEPA tinyint,
@DataKur nvarchar(10),
@BZd_WalutaDok nvarchar(10),
--@VaN_Waluta nvarchar(10),
@BZd_PodmiotTypOpis nvarchar(20),
@BZd_PodmiotKod nvarchar(20),
@BZd_PodmiotImportRowID nvarchar(36),
@BZd_PodmiotNIP nvarchar(20),
@BZd_PodmiotRachunekNr0 nvarchar(51),
@Kat_KodSzczegol nvarchar(20),
@Kat_ImportRowId nvarchar(36),
@BZd_ElixirO1 nvarchar(35),
@BZd_ElixirO2 nvarchar(35),
@BZd_ElixirO3 nvarchar(35),
@BZd_ElixirO4 nvarchar(35),
@FAzPA tinyint,
@VaN_FA_z_PA tinyint,
@BZd_SplitPay tinyint,
@BZd_SplitPayKwotaVAT decimal(15,2),
@BZd_SplitPayNipE  nvarchar(20),
@BZd_SplitPayNrDok nvarchar(30),
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 DECLARE
 --@BZd_Waluta            nvarchar(3),
 @BRa_BRaId             int,
 @DomyslnaKasa        nvarchar(20),
 @DomyslnyBank       nvarchar(20),
 @BZd_DokumentTyp       int,
 @BZd_DokumentId        int,
 @TrN_BlokadaPlatnosci  int,
 @BZd_NumerPelny         nvarchar(30),
 @BZd_NumerObcy          nvarchar(256),
 @BZd_PodmiotTyp         smallint,
 @BZd_PodmiotID          Int,
 @BZd_PodmiotRachunekLp  Int,
 @BZd_DDfID              Int,
 @BZd_KatID              Int,
 @BZd_FPlId              Int,
 @FPl_Typ              SMALLINT,
 @BZd_DataDok            datetime,
 --@BZd_KursNumer        int,
 --@BZd_KursL            decimal(15,4),
 --@BZd_KursM            decimal(5,0),
 @BZd_Stan               smallInt,
 @BZd_Opis               nvarchar(254),
 @BZD_StaId              int,
 @BZd_OpeId              int,
 @BZd_TS_Zal             datetime,
 @Termin   datetime,
 @DKur   datetime,
 @TmpSrvName  nvarchar(20),
 @sqltxt   nvarchar(1000),
 @WKuId   int,
 @BNaId   int,
 @RachunekNr  nvarchar(51),
 @IBAN   smallint,
 @Zwloka   smallint,
 @KontoPrzeciwstawne nvarchar(50),
 @DataReal  datetime,
 @ZrdBNaId  int,
 @VaNTyp   smallint,
 @KntMedialny tinyint,
 @VaN_Kategoria nvarchar(50),
 @VaN_KntNipE nvarchar(20),
 @VaN_DataOpe DATETIME,
 @VaN_OCR INT
 SET @Termin = CONVERT(datetime, @BZd_Termin, 120)
 /*
 SELECT
 @BZd_Waluta                =  TrN_Waluta,
 @BZD_OpeId                 =  TrN_OpeModId
 FROM cdn.TraNag
 WHERE TrN_TrNId = @DokId */
 SET @BRa_BraId = NULL
 SELECT
  @BZd_DokumentTyp       = 2,
  @BZd_DokumentID        = @DokId,
  @BZd_NumerPelny        = VaN_Dokument,
  @BZd_NumerObcy         = VaN_Dokument,
  @BZd_PodmiotTyp        = VaN_PlatnikTyp,
  @BZd_PodmiotID         = VaN_PlatnikID,
  @BZd_KatID             = CASE WHEN ISNULL(VaN_KatId, 0) = 0 THEN NULL ELSE VaN_KatId END,
  @BZd_DataDok           = VaN_DataZap, -- ustawiane jeszcze później w zależności od konfiguracji
  --@BZd_Termin          = VaN_Termin,
  @VaNTyp     = VaN_Typ,
  @BZd_Stan              = 1,                  -- 0 (bufor)
  @BZd_Opis              = 'Dok.: ' + VaN_Dokument,
  @BZd_OpeId    = VaN_OpeModId,
  @BZd_StaId    = VaN_StaModId,
  @BZd_TS_Zal   = VaN_TS_Mod,
  @VaN_Kategoria   = VaN_Kategoria,
  @VaN_KntNipE   = VaN_KntNipE,
  @VaN_DataOpe   = VaN_DataOpe,
  @VaN_OCR    = VaN_OCR
  FROM CDN.VatNag WHERE VaN_VaNId = @DokID
 SELECT @BZd_FplId = Fpl_FplId, @FPl_Typ = Fpl_Typ FROM CDN.FormyPlatnosci WHERE Fpl_ImportRowId = @Fpl_ImportRowId
 DECLARE @KatID Int
 SET @KatID = NULL
 IF(@Kat_ImportRowId is not NULL OR @Kat_KodSzczegol is not NULL)
 BEGIN
  SELECT @KatID = Kat_KatId FROM CDN.Kategorie WHERE Kat_ImportRowId = @Kat_ImportRowId
  IF(@KatID is NULL)
   SELECT @KatID = Kat_KatId FROM CDN.Kategorie WHERE Kat_KodSzczegol = @Kat_KodSzczegol
 END
 IF @KatID Is Not Null
  SET @BZd_KatID = @KatID
 IF @BZd_FplId is NULL
  SELECT @BZd_FplId = Fpl_FplId, @FPl_Typ = Fpl_Typ FROM CDN.FormyPlatnosci WHERE Fpl_Nazwa = @Fpl_Nazwa
 IF @BZd_FPlId is NULL
  RAISERROR('##OPT33045##', 16, 1) --RAISERROR('Nie znaleziono odpowiedniej formy płatności.', 16, 1)
 SELECT @BZd_PodmiotRachunekLp = Case @BZd_PodmiotTyp When 5 Then 1 Else 0 End
 DECLARE @PlatnikTyp int
 DECLARE @PlatnikID int
 DECLARE @PlatnikRachunekLp int
 IF @BZd_PodmiotTypOpis Is Not Null
 BEGIN
  EXEC CDN.GetPlatnikDlaPracyRozproszonej @BZd_PodmiotTypOpis, @BZd_PodmiotKod, @BZd_PodmiotImportRowID, @BZd_PodmiotNIP, @BZd_PodmiotRachunekNr0,
            2,
            @PlatnikTyp OUTPUT, @PlatnikID OUTPUT, @PlatnikRachunekLp OUTPUT, @Warnings OUTPUT
  IF(@PlatnikID is Not NULL)
  BEGIN
   SET @BZd_PodmiotTyp = @PlatnikTyp
   SET @BZd_PodmiotID = @PlatnikID
   IF @PlatnikRachunekLp IS NOT NULL
    SET @BZd_PodmiotRachunekLp = @PlatnikRachunekLp
  END
  ELSE
  BEGIN
   -- jeśli nie ma podmiotu w bazie to zaliczkobiorca nie bedzie wypełniony
   --SET @Warnings = @Warnings + 'Brak podmiotu ' + IsNull(@BZd_PodmiotKod, '') + ' w bazie docelowej. Płatność zapisano z podmiotem równym płatnikowi dokumentu.\'
   SET @Warnings = @Warnings + '##OPT33191##%%podmiot%%=' + IsNull(@BZd_PodmiotKod, '') + '##\'
  END
 END
 ELSE
 BEGIN
  SELECT @PlatnikTyp = FPl_PodmiotTyp, @PlatnikID = FPl_PodmiotID FROM cdn.FormyPlatnosci WHERE FPl_FPlID = @BZd_FplId
  IF @PlatnikTyp Is Not NULL AND @PlatnikID Is Not NULL
  BEGIN
   SET @BZd_PodmiotTyp = @PlatnikTyp
   SET @BZd_PodmiotID = @PlatnikID
  END
 END
 DECLARE @KopiujPodanyRachunekNr TINYINT
 SET @KopiujPodanyRachunekNr = 0
 IF(IsNull(@VaN_OCR, 0) = 1 AND @PlatnikID is NULL AND IsNull(@BZd_PodmiotTyp, 0) = 1 AND IsNull(@BZd_PodmiotID, 0) <> 0) --289783
 BEGIN
  IF IsNull(@BZd_PodmiotRachunekNr0, '') <> ''
  BEGIN
   SELECT @BZd_PodmiotRachunekLp = SPl_SPlID FROM CDN.SchematPlatnosci WHERE SPl_PodmiotTyp = @BZd_PodmiotTyp AND SPl_PodmiotID = @BZd_PodmiotID AND SPl_RachunekNr0 = @BZd_PodmiotRachunekNr0
   IF IsNull(@BZd_PodmiotRachunekLp, 0) <> 0
    SET @KopiujPodanyRachunekNr = 1
  END
 END
 IF @BZd_PodmiotRachunekLp Is Null
 BEGIN
  IF @BZd_PodmiotTyp = 5
   SET @BZd_PodmiotRachunekLp = 1
  ELSE
   SET @BZd_PodmiotRachunekLp = 0
 END
 SELECT @BZd_DDfId = CASE WHEN LEN(ISNULL(Fir_Wartosc,''))=0 THEN NULL ELSE Fir_Wartosc END FROM CDN.Firma WHERE Fir_Numer=CASE @VANTYP WHEN 1 THEN 1276 ELSE 1275 END
 IF @BZd_DDfId IS NULL
  SELECT @BZd_DDfId = DDf_DDfId FROM CDN.DokDefinicje WHERE DDf_Symbol = case @VaNTyp when 1 then 'RVZ' when 2 then 'RVS' end
 DECLARE @dateType int;
 IF @VaNTyp = 1 -- zakupy
 BEGIN
  -- wybranie odpowiedniej daty zdarzenia w preliminarzu, w zależności od konfiguracji
  -- 1 - data wystawienia
  -- 2 - data zakupu
  -- 3 - data wpływu
  SELECT @dateType = Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = 1584;
  IF @dateType=2
   SELECT @BZd_DataDok = VAN_DataOpe FROM CDN.VatNag WHERE VaN_VaNID=@DokId
  ELSE IF @dateType=3
   SELECT @BZd_DataDok = VAN_DataZap FROM CDN.VatNag WHERE VaN_VaNID=@DokId
  ELSE
   SELECT @BZd_DataDok = VAN_DataWys FROM CDN.VatNag WHERE VaN_VaNID=@DokId
 END
 IF @VaNTyp = 2 -- sprzedaż
 BEGIN
  -- wybranie odpowiedniej daty zdarzenia w preliminarzu, w zależności od konfiguracji
  -- 1 - data wystawienia
  -- 2 - data operacji
  -- 3 - data wpływu
  SELECT @dateType = Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = 2164;
  IF @dateType=1
   SELECT @BZd_DataDok = VAN_DataZap FROM CDN.VatNag WHERE VaN_VaNID=@DokId
  ELSE
   SELECT @BZd_DataDok = VAN_DataOpe FROM CDN.VatNag WHERE VaN_VaNID=@DokId
 END
 IF (
  @BZd_KatID IS NOT NULL AND
   (@BZd_ElixirO1 Is Null OR @BZd_ElixirO1 = '' OR @BZd_ElixirO2 Is Null OR @BZd_ElixirO2 = '' OR @BZd_ElixirO3 Is Null OR @BZd_ElixirO3 = '' OR @BZd_ElixirO4 Is Null OR @BZd_ElixirO4 = '')
  )
  -- jeśli choć jeden z opisów przekazanych w pliku jest pusty lub nie występuje, to bedziemy próbowali podstawić go z kategorii
 BEGIN
  DECLARE @Kat_ElixirO1 nvarchar(35)
  DECLARE @Kat_ElixirO2 nvarchar(35)
  DECLARE @Kat_ElixirO3 nvarchar(35)
  DECLARE @Kat_ElixirO4 nvarchar(35)
  SELECT @Kat_ElixirO1 = Kat_ElixirO1, @Kat_ElixirO2 = Kat_ElixirO2, @Kat_ElixirO3 = Kat_ElixirO3, @Kat_ElixirO4 = Kat_ElixirO4 FROM CDN.Kategorie WHERE Kat_KatID = @BZd_KatID
  IF (@BZd_ElixirO1 Is Null OR @BZd_ElixirO1 = '') AND @Kat_ElixirO1 Is Not Null AND @Kat_ElixirO1 <> ''
  BEGIN
   SET @BZd_ElixirO1 = @Kat_ElixirO1
   -- makra rozwijamy tylko w przypadku pobierania linii opisu z kategorii
   SET @BZd_ElixirO1 = REPLACE( @BZd_ElixirO1, '@DATA', CONVERT(nvarchar(10), @BZd_DataDok, 120) );
   SET @BZd_ElixirO1 = REPLACE( @BZd_ElixirO1, '@DOC',  @BZd_NumerPelny  );
  END
  IF (@BZd_ElixirO2 Is Null OR @BZd_ElixirO2 = '') AND @Kat_ElixirO2 Is Not Null AND @Kat_ElixirO2 <> ''
  BEGIN
   SET @BZd_ElixirO2 = @Kat_ElixirO2
   -- makra rozwijamy tylko w przypadku pobierania linii opisu z kategorii
   SET @BZd_ElixirO2 = REPLACE( @BZd_ElixirO2, '@DATA', CONVERT(nvarchar(10), @BZd_DataDok, 120) );
   SET @BZd_ElixirO2 = REPLACE( @BZd_ElixirO2, '@DOC',  @BZd_NumerPelny  );
  END
  IF (@BZd_ElixirO3 Is Null OR @BZd_ElixirO3 = '') AND @Kat_ElixirO3 Is Not Null AND @Kat_ElixirO3 <> ''
  BEGIN
   SET @BZd_ElixirO3 = @Kat_ElixirO3
   -- makra rozwijamy tylko w przypadku pobierania linii opisu z kategorii
   SET @BZd_ElixirO3 = REPLACE( @BZd_ElixirO3, '@DATA', CONVERT(nvarchar(10), @BZd_DataDok, 120) );
   SET @BZd_ElixirO3 = REPLACE( @BZd_ElixirO3, '@DOC',  @BZd_NumerPelny  );
  END
  IF (@BZd_ElixirO4 Is Null OR @BZd_ElixirO4 = '') AND @Kat_ElixirO4 Is Not Null AND @Kat_ElixirO4 <> ''
  BEGIN
   SET @BZd_ElixirO4 = @Kat_ElixirO4
   -- makra rozwijamy tylko w przypadku pobierania linii opisu z kategorii
   SET @BZd_ElixirO4 = REPLACE( @BZd_ElixirO4, '@DATA', CONVERT(nvarchar(10), @BZd_DataDok, 120) );
   SET @BZd_ElixirO4 = REPLACE( @BZd_ElixirO4, '@DOC',  @BZd_NumerPelny  );
  END
 END
 SET @BZd_ElixirO1 = ISNULL(@BZd_ElixirO1,'')
 SET @BZd_ElixirO2 = ISNULL(@BZd_ElixirO2,'')
 SET @BZd_ElixirO3 = ISNULL(@BZd_ElixirO3,'')
 SET @BZd_ElixirO4 = ISNULL(@BZd_ElixirO4,'')
 IF ISNULL(@BZd_Waluta,'') <> '' AND UPPER(ISNULL(@BZd_Waluta,'')) <> CDN.Waluta('')
  SELECT @BRa_BraId = FPW_BRaId FROM cdn.FormyPlatnWaluty JOIN cdn.BnkRachunki ON FPW_BRaId = BRa_BraId WHERE FPW_FPlId = @BZd_FplId AND BRa_Waluta = @BZd_Waluta
 IF @BRa_BraId IS NULL
  SELECT @BRa_BraId = FPl_BRaId FROM cdn.FormyPlatnosci JOIN cdn.BnkRachunki ON FPl_BRaId = BRa_BraId WHERE Fpl_FplId = @BZd_FplId
 IF @BRa_BraId IS NULL
 BEGIN
  EXEC CDN.DomyslnaKasaBankOperatora @ServerName, @ConfigDBName, @OpeId, @DomyslnaKasa OUTPUT, @DomyslnyBank OUTPUT
  SELECT @BRa_BraId = BRa_BRaId FROM CDN.BnkRachunki WHERE Bra_Akronim=(CASE @FPl_Typ WHEN 2 THEN @DomyslnyBank ELSE @DomyslnaKasa END)
 END
 IF @BRa_BraId IS NULL
 BEGIN
  IF @Fpl_Typ = 2
   RAISERROR('##OPT33046##', 16, 1) --RAISERROR( 'Bank domyślny [-brak-] dla zalogowanego operatora nie istnieje.', 16, 1)
  ELSE
  RAISERROR('##OPT33047##', 16, 1) --RAISERROR( 'Kasa domyślna [-brak-] dla zalogowanego operatora nie istnieje.', 16, 1)
 END
 SET @DKur = convert(datetime, @DataKur, 120)
 EXECUTE @WKuId = CDN.GetTypKursuWaluty @Wku_Symbol, @ConfigDBName, @ServerName
 IF @WKuId is null
  RAISERROR('##OPT33048##', 16, 1) --RAISERROR('Brak kursu waluty w płatności', 16, 1)
 If @BZd_PodmiotTyp = 1
 Begin
  Select @BNaId = Knt_BNaId, @RachunekNr = Knt_RachunekNr, @IBAN = Knt_IBAN, @Zwloka = Knt_MaxZwloka From CDN.Kontrahenci Where Knt_KntId = @BZd_PodmiotId
 End
 Else If @BZd_PodmiotTyp = 3
 Begin
  Select Top 1 @BNaId = SPL_BNaId, @RachunekNr = SPL_RachunekNr, @IBAN = SPL_IBAN, @Zwloka = 0 From CDN.PracEtaty Join CDN.SchematPlatnosci On SPL_PodmiotId = PRE_PREId
   Where PRE_PRAId = @BZd_PodmiotId And PRE_DataDo = Convert(DateTime, '2999-12-31', 120) AND SPL_PodmiotTyp=3
   Order By SPL_LiczbaPorz
 End
 Else If @BZd_PodmiotTyp = 5
 Begin
  Select @BNaId = URa_BNaId, @RachunekNr = URa_RachunekNr, @IBAN = URa_IBAN, @Zwloka = 0 From CDN.Urzedy LEFT JOIN CDN.Urzrachunki ON Urz_UrzId = URa_UrzId Where URa_UrzId = @BZd_PodmiotId And URa_Lp = 1
 End
 Else If @BZd_PodmiotTyp = 2
 BEGIN
  SELECT @BNaId = BNa_BNaId, @RachunekNr = '', @IBAN = 1, @Zwloka = 0 FROM CDN.BnkNazwy WHERE BNa_BNaId = @BZd_PodmiotId
 END
 IF((@BZd_PodmiotTyp = 1 OR @BZd_PodmiotTyp = 3 OR @BZd_PodmiotTyp = 5) AND (@PlatnikID is Not NULL AND @PlatnikRachunekLp IS NOT NULL OR @KopiujPodanyRachunekNr = 1))
 BEGIN
  -- Zmienne @BNaID, @RachunekNr i @IBAN zostały pobrane wyżej jako rachunki domyślne z karty podmiotu. Jednak w przypadku kontrahenta, pracownika i urzedu,
  -- zdarzenie mogło mieć przypisany nr rachunku inny niż domyślny na karcie - na podstawie tego numeru znaleźliśmy @PlatnikRachunekLp i teraz musimy
  -- uzgodnić BZd_BNaID, BZd_RachunekNr i BZd_IBAN ze znalezionym @PlatnikRachunekLp.
  SET @RachunekNr = @BZd_PodmiotRachunekNr0
  IF(@BZd_PodmiotTyp = 1 OR @BZd_PodmiotTyp = 3)
   SELECT @BNaID = SPl_BNaID, @IBAN = SPl_IBAN FROM cdn.SchematPlatnosci WHERE SPl_SPlID = @PlatnikRachunekLp
  ELSE
   SELECT @BNaID = URa_BNaID, @IBAN = URa_IBAN FROM cdn.UrzRachunki WHERE URa_Lp = @PlatnikRachunekLp
 END
 Select @ZrdBNaId = BRa_BNaId From CDN.BnkRachunki Where BRa_BRaId = @BRa_BRaId
 If @BZd_Kierunek = 1
 Begin
  Select @DataReal = DateAdd(day, @Zwloka-BNa_CzasRealizacji, @Termin) From CDN.BnkNazwy Where BNa_BNaId = IsNull(@ZrdBNaId, 1)
  If Cast(@DataReal As Int)%7 = 6 Set @DataReal = DateAdd(day, 1, @DataReal)
  If Cast(@DataReal As Int)%7 = 5 Set @DataReal = DateAdd(day, 2, @DataReal)
 End
 Else
 Begin
  Select @DataReal = DateAdd(day, @Zwloka+BNa_CzasRealizacji, @Termin) From CDN.BnkNazwy Where BNa_BNaId = IsNull(@BNaId, 1)
  If Cast(@DataReal As Int)%7 = 6 Set @DataReal = DateAdd(day, -2, @DataReal)
  If Cast(@DataReal As Int)%7 = 5 Set @DataReal = DateAdd(day, -1, @DataReal)
 End
 IF @BZd_PodmiotTypOpis = 'kontrahent'
 BEGIN
  SELECT @KntMedialny = Knt_Medialny FROM CDN.Kontrahenci WHERE Knt_Kod = @BZd_PodmiotKod IF(@KntMedialny = 1)
  BEGIN
   IF (YEAR(@VaN_DataOpe) < 2014)
   BEGIN
    UPDATE CDN.VatNag SET VaN_DeklRokMies = (100 * YEAR(convert(datetime, @BZd_Termin, 120)) + MONTH(convert(datetime, @BZd_Termin, 120))) WHERE VaN_VaNId = @DokId
    /*
    235493 - dodanie nagłówka zostało już zalogowane w ImportRejSprz/ImportRejZak
    EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 999, -- e_op_KlasaRejestrVat
    @ObiektSubTyp = @VaNTyp,
    @ObiektID = @DokId,
    @ObiektNazwa = @BZd_NumerPelny,
    @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
    @Opis = @BZd_NumerPelny
   */
   END
  END
 END
 IF(@BZd_WalutaDok IS NULL)
  --SET @BZd_WalutaDok = @Van_Waluta;
  RAISERROR('##OPT33080##', 16, 1) --RAISERROR('Dokument nie został zaimportowany. Waluta dokumentu nie zgadza się z walutą płatności.', 16, 1)
 IF @BZd_PrzelewSEPA <> 0 AND cdn.CzyMoznaUstawicSEPA(@BRa_BraId) = 0
 BEGIN
  --SET @Warnings = @Warnings + 'Rejestr przelewu nie spełnia warunków SEPA. Rejestr nie zostanie ustawiony jako przelew SEPA.\'
  SET @Warnings = @Warnings + '##OPT33185##\'
  SET @BZd_PrzelewSEPA = 0
 END
 DECLARE @Rozliczono INT
 SELECT @Rozliczono = CDN.StatusRozliczeniaPR(@BZd_Rozliczono, @BZd_PodmiotTyp, @BZd_PodmiotID, @BZd_DataDok)
 IF @FAzPA = 1 OR @VaN_FA_z_PA = 1
 BEGIN
  IF @VaN_DataOpe >= CONVERT(DATETIME, '2020-07-01', 120) OR EXISTS(SELECT * FROM cdn.BnkZdarzenia WHERE BZd_ImportRowId = @BZd_ImportRowId)
   SET @BZd_ImportRowId = NEWID()
  SET @Rozliczono = 0
 END
 ELSE
 BEGIN
  IF EXISTS(SELECT * FROM cdn.BnkZdarzenia WHERE BZd_ImportRowId = @BZd_ImportRowId)
   RAISERROR('##OPT33083##', 16, 1) --RAISERROR('W bazie danych występuje już płatność z takim samym numerem row id. do innego dokumentu.', 16, 1)
 END
 SET @BZd_SplitPay = ISNULL(@BZd_SplitPay, 0)
 SET @BZd_SplitPayKwotaVAT = ISNULL(@BZd_SplitPayKwotaVAT, 0)
 IF @BZd_SplitPayNipE Is Null
  SET @BZd_SplitPayNipE = @VaN_KntNipE
 SET @BZd_SplitPayNipE = IsNull(@BZd_SplitPayNipE, '')
 IF @BZd_SplitPayNrDok Is Null
  SET @BZd_SplitPayNrDok = @BZd_NumerPelny
 SET @BZd_SplitPayNrDok = IsNull(@BZd_SplitPayNrDok, '')
 INSERT INTO CDN.BnkZdarzenia
 (
  BZd_RelTyp,
  BZd_RelID,
  BZd_PrwTyp,
  BZd_PrwID,
  BZd_BRaID,
  BZd_DDfID,
  BZd_DokumentTyp,
  BZd_DokumentID,
  BZd_NumerPelny,
  BZd_NumerObcy,
  BZd_PodmiotTyp,
  BZd_PodmiotID,
  BZd_PodmiotRachunekLp,
  BZd_BNaID,
  BZd_RachunekNr,
  BZd_IBAN,
  BZd_KatID,
  BZd_FPlId,
  BZd_DataDok,
  BZd_DataKur,
  BZd_Termin,
  BZd_DataReal,
  BZd_KwotaSys,
  BZd_KwotaRozSys,
  BZd_Kwota,
  BZd_KwotaRoz,
  BZd_Waluta,
  BZd_KursNumer,
  BZd_KursL,
  BZd_KursM,
  BZd_Kierunek,
  BZd_Zwloka,
  BZd_Priorytet,
  BZd_Rozliczono,
  BZd_Rozliczono2,
  BZd_Stan,
  BZd_ElixirO1,
  BZd_ElixirO2,
  BZd_ElixirO3,
  BZd_ElixirO4,
  BZd_Opis,
  BZd_KontoPrzeciwstawne,
  BZd_NieNaliczajOdsetek,
  BZd_PrzelewSEPA,
  BZd_SplitPay,
  BZd_SplitPayKwotaVAT,
  BZd_SplitPayNipE,
  BZd_SplitPayNrDok,
  BZd_ImportAppId,
  BZd_ImportRowId,
  BZd_OpeZalId,
  BZd_OpeZalKod,
  BZd_OpeZalNazwisko,
  BZd_StaZalId,
  BZd_TS_Zal,
  BZd_StaModId,
  BZd_OpeModId,
  BZd_OpeModKod,
  BZd_OpeModNazwisko,
  BZd_TS_Mod,
  BZd_WalutaDok
 )
 VALUES (
  0,
  0,
  2,
  @DokId,
  @BRa_BraId,
  @BZd_DDfID,
  2,
  @DokId,
  @BZd_NumerPelny,
  @BZd_NumerObcy,
  @BZd_PodmiotTyp,
  @BZd_PodmiotID,
  @BZd_PodmiotRachunekLp,
  @BNaID,
  @RachunekNr,
  @IBAN,
  @BZd_KatID,
  @BZd_FPlId,
  @BZd_DataDok,
  @DKur,
  @Termin,
  @DataReal,
  @BZd_KwotaSys,
  0,
  @BZd_Kwota,
  0,
  @BZd_Waluta,
  @WKuId,
  Case when @BZd_KursL=0 then 1 else @BZd_KursL end,
  Case when @BZd_KursM=0 then 1 else @BZd_KursM end,
  @BZd_Kierunek,
  @Zwloka,
  2,
  @Rozliczono,
  @Rozliczono,
  @BZd_Stan,
  @BZd_ElixirO1,
  @BZd_ElixirO2,
  @BZd_ElixirO3,
  @BZd_ElixirO4,
  --@BZd_Opis + ' ' + @VaN_Kategoria,
  CASE WHEN LEN(@BZd_Opis) + 1 + LEN(@VaN_Kategoria) <= COL_LENGTH('cdn.BnkZdarzenia','BZd_Opis')/2 THEN @BZd_Opis + ' ' + @VaN_Kategoria ELSE SUBSTRING(@BZd_Opis + ' ' + @VaN_Kategoria, 1, COL_LENGTH('cdn.BnkZdarzenia','BZd_Opis')/2) END,
  @BZd_KontoPrzeciwstawne,
  @BZd_NieNaliczajOdsetek,
  @BZd_PrzelewSEPA,
  @BZd_SplitPay,
  @BZd_SplitPayKwotaVAT,
  @BZd_SplitPayNipE,
  @BZd_SplitPayNrDok,
  @ZrdId,
  @BZd_ImportRowId,
  @OpeId,
  @OpeModKod,
  @OpeModNazwisko,
  NULL,
  GetDate(),
  NULL,
  @OpeId,
  @OpeModKod,
  @OpeModNazwisko,
  GetDate(),
  @BZd_WalutaDok
 )
 SET @IdParam = SCOPE_IDENTITY()
 --DECLARE @OpisDok NVARCHAR(1024)
 --SET @OpisDok = @BZd_Opis + ' ' + @VaN_Kategoria
 EXEC [CDN].[RejestrOperacjiDodaj]
   @ObiektTyp = 1001, -- OptimaObjectType_ZdarzenieKB
   @ObiektSubTyp = @BZd_Kierunek,
   @ObiektID = @IdParam,
   @ObiektNazwa = @BZd_NumerPelny,
   @OperacjaTyp = 1, -- OptimaOperationType_Dodanie
   @Opis = '' --@OpisDok
END
