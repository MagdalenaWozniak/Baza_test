CREATE PROCEDURE [CDN].[ImportDokInnePlat]
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
@BZd_DataKur nvarchar(10),
@BZd_WalutaDok nvarchar(10),
@BZd_PodmiotTypOpis nvarchar(10),
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
 @BRa_BRaId             INT,
 @DomyslnaKasa        nvarchar(20),
 @DomyslnyBank       nvarchar(20),
 @BZd_DokumentTyp       INT,
 @BZd_DokumentId        INT,
 @TrN_BlokadaPlatnosci  INT,
 @BZd_NumerPelny         nvarchar(30),
 @BZd_NumerObcy          nvarchar(256),
 @BZd_Numer           nvarchar(30),
 @BZd_PodmiotTyp         SmallInt,
 @BZd_PodmiotID          Int,
 @BZd_PodmiotRachunekLp  Int,
 @BZd_DDfID              Int,
 @BZd_KatID              Int,
 @BZd_FPlId              Int,
 @FPl_Typ    SMALLINT,
 @BZd_DataDok            datetime,
 @BZd_Stan               SmallInt,
 @BZd_Opis               nvarchar(254),
 @BZD_StaId              int,
 @BZd_OpeId              int,
 @BZd_TS_Zal             datetime,
 @Termin   datetime,
 @TmpSrvName    nvarchar(20),
 @sqltxt     nvarchar(1000),
 @WKuId     int,
 @DKur   datetime,
 @BNaId   int,
 @RachunekNr  nvarchar(51),
 @IBAN   smallint,
 @Zwloka   smallint,
 @KontoPrzeciwstawne nvarchar(50),
 @DataReal  datetime,
 @ZrdBNaId  int,
 @EdnTyp   smallint,
 @EDN_Kategoria nvarchar(50)
 SET @DKur = convert(datetime, @BZd_DataKur, 120)
 SET @Termin = CONVERT(datetime, @BZd_Termin, 120)
 SELECT
 @EdnTyp       = EDN_Typ,
 @BZd_NumerPelny        = EDN_NumerPelny,
 @BZd_NumerObcy         = EDN_NumerObcy,
 @BZd_PodmiotTyp        = EDN_PodmiotTyp,
 @BZd_PodmiotID         = EDN_PodId,
 @Bzd_DDFId             = EDN_DDfId,
 @BZd_KatID             = CASE WHEN ISNULL(EDN_KatId, 0) = 0 THEN NULL ELSE EDN_KatId END,
-- @BZd_DataDok           = EDN_DataDok, ustawiana później w zależności od konfiguracji
 @BZd_Termin            = EDN_Termin,
 @BZd_Stan              = 1,                  -- 0 (bufor)
 @BZd_Opis              = 'Dok.: ' + EDN_NumerPelny,
 @BZd_OpeId      = EDN_OpeModId,
 @BZd_StaId      = EDN_StaModId,
 @BZd_TS_Zal            = EDN_TS_Mod,
 @EDN_Kategoria     = EDN_Kategoria
 FROM cdn.EwidDodNag   WHERE EDN_EDNId = @DokId
 DECLARE @dateType int;
 IF @EdnTyp = 101 -- dla rejestru przychodów
  SELECT @dateType = Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = 2164
 ELSE   --  dla rejestru rozchodów
   SELECT @dateType = Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = 1765
 -- wybranie odpowiedniej daty zdarzenia w preliminarzu, w zależności od konfiguracji
 IF @EdnTyp = 101 -- dla rejestru przychodów
 BEGIN
 -- 1 - data wystawienia
 -- 2 - data sprzedaży
  IF @dateType=1
   SELECT @BZd_DataDok = EDN_DataWys FROM CDN.EwidDodNag WHERE EDN_EDNID=@DokId
  ELSE IF @dateType=2
  SELECT @BZd_DataDok = EDN_DataOpe FROM CDN.EwidDodNag WHERE EDN_EDNID=@DokId
  ELSE
   SELECT @BZd_DataDok = EDN_DataDok FROM CDN.EwidDodNag WHERE EDN_EDNID=@DokId
 END
 IF @EdnTyp = 102 -- dla rejestru rozchodów
 BEGIN
 -- 1 - data wystawienia
 -- 2 - data zapisu
 -- 3 - data operacji
  IF @dateType=2
  SELECT @BZd_DataDok = EDN_DataDok FROM CDN.EwidDodNag WHERE EDN_EDNID=@DokId
  ELSE IF @dateType=3
  SELECT @BZd_DataDok = EDN_DataOpe FROM CDN.EwidDodNag WHERE EDN_EDNID=@DokId
  ELSE
  SELECT @BZd_DataDok = EDN_DataWys FROM CDN.EwidDodNag WHERE EDN_EDNID=@DokId
 END
 DECLARE @KatID Int
 SET @KatID = NULL
 IF(@Kat_ImportRowId is not NULL OR @Kat_KodSzczegol is not NULL)
 BEGIN
   SELECT @KatID = Kat_KatId
   FROM CDN.Kategorie
   WHERE Kat_ImportRowId = @Kat_ImportRowId
   IF(@KatID is NULL)
   BEGIN
     SELECT @KatID = Kat_KatId
     FROM CDN.Kategorie
     WHERE Kat_KodSzczegol = @Kat_KodSzczegol
   END
 END
 IF @KatID Is Not Null
  SET @BZd_KatID = @KatID
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
  SELECT @Kat_ElixirO1 = Kat_ElixirO1, @Kat_ElixirO2 = Kat_ElixirO2, @Kat_ElixirO3 = Kat_ElixirO3, @Kat_ElixirO4 = Kat_ElixirO4
  FROM CDN.Kategorie WHERE Kat_KatID = @BZd_KatID
  SET @Bzd_Numer = CASE WHEN ISNULL(@Bzd_NumerObcy, '') = '' THEN @Bzd_NumerPelny ELSE @Bzd_NumerObcy END
  IF (@BZd_ElixirO1 Is Null OR @BZd_ElixirO1 = '') AND @Kat_ElixirO1 Is Not Null AND @Kat_ElixirO1 <> ''
  BEGIN
    SET @BZd_ElixirO1 = @Kat_ElixirO1
    -- makra rozwijamy tylko w przypadku pobierania linii opisu z kategorii
  SET @BZd_ElixirO1 = REPLACE( @BZd_ElixirO1, '@DATA', CONVERT(nvarchar(10), @BZd_DataDok, 120) );
  SET @BZd_ElixirO1 = REPLACE( @BZd_ElixirO1, '@DOC',  @Bzd_Numer  );
  END
  IF (@BZd_ElixirO2 Is Null OR @BZd_ElixirO2 = '') AND @Kat_ElixirO2 Is Not Null AND @Kat_ElixirO2 <> ''
  BEGIN
    SET @BZd_ElixirO2 = @Kat_ElixirO2
    -- makra rozwijamy tylko w przypadku pobierania linii opisu z kategorii
  SET @BZd_ElixirO2 = REPLACE( @BZd_ElixirO2, '@DATA', CONVERT(nvarchar(10), @BZd_DataDok, 120) );
  SET @BZd_ElixirO2 = REPLACE( @BZd_ElixirO2, '@DOC',  @Bzd_Numer  );
  END
  IF (@BZd_ElixirO3 Is Null OR @BZd_ElixirO3 = '') AND @Kat_ElixirO3 Is Not Null AND @Kat_ElixirO3 <> ''
  BEGIN
    SET @BZd_ElixirO3 = @Kat_ElixirO3
    -- makra rozwijamy tylko w przypadku pobierania linii opisu z kategorii
  SET @BZd_ElixirO3 = REPLACE( @BZd_ElixirO3, '@DATA', CONVERT(nvarchar(10), @BZd_DataDok, 120) );
  SET @BZd_ElixirO3 = REPLACE( @BZd_ElixirO3, '@DOC',  @Bzd_Numer  );
  END
  IF (@BZd_ElixirO4 Is Null OR @BZd_ElixirO4 = '') AND @Kat_ElixirO4 Is Not Null AND @Kat_ElixirO4 <> ''
  BEGIN
    SET @BZd_ElixirO4 = @Kat_ElixirO4
    -- makra rozwijamy tylko w przypadku pobierania linii opisu z kategorii
  SET @BZd_ElixirO4 = REPLACE( @BZd_ElixirO4, '@DATA', CONVERT(nvarchar(10), @BZd_DataDok, 120) );
  SET @BZd_ElixirO4 = REPLACE( @BZd_ElixirO4, '@DOC',  @Bzd_Numer  );
  END
 END
 SET @BZd_ElixirO1 = ISNULL(@BZd_ElixirO1,'')
 SET @BZd_ElixirO2 = ISNULL(@BZd_ElixirO2,'')
 SET @BZd_ElixirO3 = ISNULL(@BZd_ElixirO3,'')
 SET @BZd_ElixirO4 = ISNULL(@BZd_ElixirO4,'')
 SET @BZd_SplitPay = ISNULL(@BZd_SplitPay, 0)
 SET @BZd_SplitPayKwotaVAT = ISNULL(@BZd_SplitPayKwotaVAT, 0)
 SET @BZd_SplitPayNipE = ISNULL(@BZd_SplitPayNipE, '')
 SET @BZd_SplitPayNrDok = ISNULL(@BZd_SplitPayNrDok, '')
 SELECT
 @BZD_OpeId =  TrN_OpeModId
 FROM cdn.TraNag
 WHERE TrN_TrNId = @DokId
 IF(@Fpl_Nazwa is NULL OR @Fpl_Nazwa = '') SET @Fpl_Nazwa = 'gotówka'
 SELECT @BZd_FplId = Fpl_FplId, @FPl_Typ = FPl_Typ
 FROM CDN.FormyPlatnosci
 WHERE Fpl_ImportRowId = @Fpl_ImportRowId
 IF @BZd_FplId is NULL
  SELECT @BZd_FplId = Fpl_FplId, @FPl_Typ = FPl_Typ
  FROM CDN.FormyPlatnosci
  WHERE Fpl_Nazwa = @Fpl_Nazwa
 IF @BZd_FPlId is NULL
  RAISERROR('##OPT33045##', 16, 1) --RAISERROR('Nie znaleziono odpowiedniej formy płatności.', 16, 1)
 SET @BRa_BraId = NULL
 -- jeśli dokument walutowy, to pobieramy rejestr domyślny z FormyPlatnWaluty
 IF ISNULL(@BZd_Waluta,'') <> '' AND UPPER(ISNULL(@BZd_Waluta,'')) <> 'PLN'
 SELECT @BRa_BraId = FPW_BRaId
 FROM cdn.FormyPlatnWaluty
 JOIN cdn.BnkRachunki ON FPW_BRaId = BRa_BraId
 WHERE FPW_FPlId = @BZd_FPlId
 IF @BRa_BraId IS NULL
 SELECT @BRa_BraId = FPl_BRaId
 FROM cdn.FormyPlatnosci
 JOIN cdn.BnkRachunki ON FPl_BRaId = BRa_BraId
 WHERE Fpl_FplId = @BZd_FplId
 IF @BRa_BraId IS NULL
 BEGIN
  EXEC CDN.DomyslnaKasaBankOperatora @ServerName, @ConfigDBName, @OpeId, @DomyslnaKasa OUTPUT, @DomyslnyBank OUTPUT
  SELECT @BRa_BraId = BRa_BRaId
  FROM CDN.BnkRachunki
  WHERE Bra_Akronim=(CASE @FPl_Typ WHEN 2 THEN @DomyslnyBank ELSE @DomyslnaKasa END)
 END
 IF @BRa_BraId IS NULL
 BEGIN
  IF @Fpl_Typ = 2
   RAISERROR('##OPT33046##', 16, 1) --RAISERROR( 'Bank domyślny [-brak-] dla zalogowanego operatora nie istnieje.', 16, 1)
  ELSE
   RAISERROR('##OPT33047##', 16, 1) --RAISERROR( 'Kasa domyślna [-brak-] dla zalogowanego operatora nie istnieje.', 16, 1)
 END
 DECLARE @PlatnikTyp int
 DECLARE @PlatnikID int
 DECLARE @PlatnikRachunekLp int
 IF @BZd_PodmiotTypOpis Is Not Null
 BEGIN
  EXEC CDN.GetPlatnikDlaPracyRozproszonej @BZd_PodmiotTypOpis, @BZd_PodmiotKod, @BZd_PodmiotImportRowID, @BZd_PodmiotNIP, @BZd_PodmiotRachunekNr0,
    2,
  @PlatnikTyp OUTPUT, @PlatnikID OUTPUT, @PlatnikRachunekLp OUTPUT, @Warnings OUTPUT
  IF(@PlatnikID is NULL) -- jeśli nie ma podmiotu w bazie
  BEGIN
   SET @PlatnikTyp = @BZd_PodmiotTyp
   SET @PlatnikID = @BZd_PodmiotID
   SET @PlatnikRachunekLp = @BZd_PodmiotRachunekLp
  END
 END
 ELSE
 BEGIN
   SET @PlatnikTyp = @BZd_PodmiotTyp
   SET @PlatnikID = @BZd_PodmiotID
   SET @PlatnikRachunekLp = @BZd_PodmiotRachunekLp
 END
 IF @PlatnikRachunekLp Is Null
 BEGIN
  IF @BZd_PodmiotTyp = 5
   SET @PlatnikRachunekLp = 1
  Else
   SET @PlatnikRachunekLp = 0
 END
 If @PlatnikTyp = 1
 Begin
  Select
  @BNaId = Knt_BNaId,
  @RachunekNr = Knt_RachunekNr,
  @IBAN = Knt_IBAN,
  @Zwloka = Knt_MaxZwloka
  --@KontoPrzeciwstawne = IsNull(@KontoPrzeciwstawne, Case @BZd_Kierunek When 1 Then Knt_KontoOdb Else Knt_KontoDost End)
  From CDN.Kontrahenci Where Knt_KntId = @PlatnikID
 End
 Else If @PlatnikTyp = 3
 Begin
  Select Top 1
  @BNaId = SPL_BNaId,
  @RachunekNr = SPL_RachunekNr,
  @IBAN = SPL_IBAN,
  @Zwloka = 0
  From CDN.PracEtaty
  Join CDN.SchematPlatnosci On SPL_PodmiotId = PRE_PREId
  Where PRE_PRAId = @PlatnikID And PRE_DataDo = Convert(DateTime, '2999-12-31', 120) AND SPL_PodmiotTyp = 3
  Order By SPL_LiczbaPorz
 End
 Else If @PlatnikTyp = 5
 Begin
  Select
  @BNaId = URa_BNaId,
  @RachunekNr = URa_RachunekNr,
  @IBAN = URa_IBAN,
  @Zwloka = 0
  From CDN.Urzrachunki
  Where URa_UrzId = @PlatnikID And URa_Lp = 1
 End
 Else If @PlatnikTyp = 2
 BEGIN
  SELECT
  @BNaId = BNa_BNaId,
  @RachunekNr = '',
  @IBAN = 1,
  @Zwloka = 0
  FROM CDN.BnkNazwy
  WHERE BNa_BNaId = @PlatnikID
 END
  IF((@BZd_PodmiotTyp = 1 OR @BZd_PodmiotTyp = 3 OR @BZd_PodmiotTyp = 5) AND @PlatnikID is Not NULL AND @PlatnikRachunekLp IS NOT NULL)
  BEGIN
    -- Zmienne @BNaID, @RachunekNr i @IBAN zostały pobrane wyżej jako rachunki domyślne z karty podmiotu. Jednak w przypadku kontrahenta, pracownika i urzedu,
    -- zdarzenie mogło mieć przypisany nr rachunku inny niż domyślny na karcie - na podstawie tego numeru znaleźliśmy @PlatnikRachunekLp i teraz musimy
    -- uzgodnić BZd_BNaID, BZd_RachunekNr i BZd_IBAN ze znalezionym @PlatnikRachunekLp.
    IF(@BZd_PodmiotTyp = 1 OR @BZd_PodmiotTyp = 3)
      SELECT @RachunekNr = SPl_RachunekNr, @BNaID = SPl_BNaID, @IBAN = SPl_IBAN FROM cdn.SchematPlatnosci WHERE SPl_SPlID = @PlatnikRachunekLp
    ELSE
      SELECT @RachunekNr = URa_RachunekNr, @BNaID = URa_BNaID, @IBAN = URa_IBAN FROM cdn.UrzRachunki WHERE URa_Lp = @PlatnikRachunekLp
    IF @BZd_PodmiotRachunekNr0 Is Not Null
      SET @RachunekNr = @BZd_PodmiotRachunekNr0
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
 EXECUTE @WKuId = CDN.GetTypKursuWaluty @Wku_Symbol, @ConfigDBName, @ServerName
 IF @WKuId is null
 RAISERROR('##OPT33048##', 16, 1) --RAISERROR('Brak kursu waluty w płatności', 16, 1)
 IF @BZd_FPlId is NULL
 RAISERROR('##OPT33045##', 16, 1) --RAISERROR('Nie znaleziono odpowiedniej formy płatności.', 16, 1)
 -- 102 to rejestr kosztów
 IF @EdnTyp = 102 OR @BZd_NumerObcy is NULL OR @BZd_NumerObcy = '' -- było @EdnTyp = 2, czyli nigdy sie nie wykonywało
  SET @BZd_NumerObcy = @BZd_NumerPelny;
 IF @BZd_PrzelewSEPA <> 0 AND cdn.CzyMoznaUstawicSEPA(@BRa_BraId) = 0
 BEGIN
 --SET @Warnings = @Warnings + 'Rejestr przelewu nie spełnia warunków SEPA. Rejestr nie zostanie ustawiony jako przelew SEPA.\'
 SET @Warnings = @Warnings + '##OPT33185##\'
 SET @BZd_PrzelewSEPA = 0
 END
 DECLARE @Rozliczono INT
 SELECT @Rozliczono = CDN.StatusRozliczeniaPR(@BZd_Rozliczono, @PlatnikTyp, @PlatnikID, @BZd_DataDok)
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
 BZd_SplitPay,
 BZd_SplitPayKwotaVAT,
 BZd_SplitPayNipE,
 BZd_SplitPayNrDok,
 BZd_Opis,
 BZd_KontoPrzeciwstawne,
 BZd_NieNaliczajOdsetek,
 BZd_PrzelewSEPA,
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
 12,
 @DokId,
 @BRa_BraId,
 @BZd_DDfID,
 12,
 @DokId,
 @BZd_NumerPelny,
 @BZd_NumerObcy,
 @PlatnikTyp,
 @PlatnikID,
 @PlatnikRachunekLp,
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
 @BZd_SplitPay,
 @BZd_SplitPayKwotaVAT,
 @BZd_SplitPayNipE,
 @BZd_SplitPayNrDok,
 @BZd_Opis + ' ' + @EDN_Kategoria,
 @BZd_KontoPrzeciwstawne,
 @BZd_NieNaliczajOdsetek,
 @BZd_PrzelewSEPA,
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
 EXEC [CDN].[RejestrOperacjiDodaj]
   @ObiektTyp = 1001, -- OptimaObjectType_ZdarzenieKB
   @ObiektSubTyp = @BZd_Kierunek,
   @ObiektID = @IdParam,
   @ObiektNazwa = @BZd_NumerPelny,
   @OperacjaTyp = 1, -- OptimaOperationType_Dodanie
   @Opis = '' -- @OpisDok
END
