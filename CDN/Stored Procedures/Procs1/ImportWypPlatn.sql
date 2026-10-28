create procedure cdn.ImportWypPlatn
@BZd_DokumentID int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@BZd_ImportRowID nvarchar(36),
@BZd_PodmiotTypOpis nvarchar(20),
@BZd_PodmiotKod nvarchar(20),
@BZd_PodmiotImportRowID nvarchar(36),
@BZd_PodmiotNIP nvarchar(20),
@BZd_PodmiotRachunekNr0 nvarchar(51),
@DDf_ImportRowID nvarchar(36),
@DDf_Symbol nvarchar(5),
@DDf_Numeracja nvarchar(50),
@BZd_NumerPelny nvarchar(30),
@BZd_NumerObcy nvarchar(256),
@BZd_Kierunek smallint,
@BZd_Kwota decimal(15,2),
@BZd_KwotaSys decimal(15,2),
@BZd_WalutaDok nvarchar(10),
@BZd_Waluta nvarchar(3),
@WKu_Symbol nvarchar(5),
@BZd_KursL decimal(15,4),
@BZd_KursM decimal(5,0),
@BZd_DataKur nvarchar(10),
@BZd_DataDok nvarchar(10),
@BZd_Termin nvarchar(10),
@BZd_DataReal nvarchar(10),
@BZd_Zwloka int,
@FPl_ImportRowID nvarchar(36),
@FPl_Nazwa nvarchar(20),
@BNa_ImportRowID nvarchar(36),
@BNa_Numer nvarchar(10),
@BZd_RachunekNr nvarchar(51),
@BZd_IBAN int,
@BZd_Rozliczono tinyint,
@BZd_NieNaliczajOdsetek tinyint,
@BZd_PrzelewSEPA tinyint,
@BZd_KontoPrzeciwstawne nvarchar(50),
@Kat_ImportRowID nvarchar(36),
@Kat_KodSzczegol nvarchar(20),
@BZd_ElixirO1 nvarchar(35),
@BZd_ElixirO2 nvarchar(35),
@BZd_ElixirO3 nvarchar(35),
@BZd_ElixirO4 nvarchar(35),
@BZd_Opis nvarchar(254),
@BZd_KomornikZajecieWynagr tinyint,
@ZrdID nvarchar(5),
@OpeID int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT as
 begin
  DECLARE
   @DokTyp int
  SET @DokTyp = 8
  DECLARE
   @PodmiotTyp   smallint,
   @PodmiotID   Int,
   @PodmiotRachunekLp Int
  IF @BZd_PodmiotTypOpis Is Not Null
  BEGIN
   EXEC CDN.GetPlatnikDlaPracyRozproszonej @BZd_PodmiotTypOpis, @BZd_PodmiotKod, @BZd_PodmiotImportRowID, @BZd_PodmiotNIP, @BZd_PodmiotRachunekNr0,
    2,
    @PodmiotTyp OUTPUT, @PodmiotID OUTPUT, @PodmiotRachunekLp OUTPUT, @Warnings OUTPUT
   IF(@PodmiotID Is NULL)
   BEGIN
    RAISERROR('##OPT33112##', 16, 1) --RAISERROR('Płatność wypłaty nie została zaimportowana. Brak zgodnego podmiotu w bazie docelowej.', 16, 1)
    RETURN
   END
  END
  IF @PodmiotRachunekLp Is Null
   SET @PodmiotRachunekLp = 0
  DECLARE @DDfID INT
  SET @DDfID = NULL
  IF(@DDf_ImportRowID Is Not NULL)
   SELECT @DDfID = DDf_DDfId FROM CDN.DokDefinicje WHERE DDf_ImportRowID = @DDf_ImportRowID AND DDf_Numeracja = @DDf_Numeracja
  IF @DDfID is NULL
   SELECT @DDfID = DDf_DDfID FROM CDN.DokDefinicje WHERE DDf_Symbol = @DDf_Symbol AND DDf_Numeracja = @DDf_Numeracja
  IF @DDfID is NULL
  BEGIN
   -- SET @Warnings = 'Brak definicji dokumentu o zadanym symbolu i zgodnym schemacie numeracji ' + IsNull(@DDf_Symbol, '') + ' w bazie docelowej.\'
   RAISERROR('##OPT33114##', 16, 1) --RAISERROR('Brak zgodnego schematu numeracji w bazie dla płatności wypłaty.', 16, 1)
   RETURN
  END
  DECLARE
   @WKuID  int,
   @DataKur datetime
  SET @DataKur = convert(datetime, @BZd_DataKur, 120)
  EXECUTE @WKuId = CDN.GetTypKursuWaluty @Wku_Symbol, @ConfigDBName, @ServerName
  IF @WKuId Is Null
  BEGIN
   RAISERROR('##OPT33048##', 16, 1) --RAISERROR('Brak kursu waluty w płatności', 16, 1)
   RETURN
  END
  DECLARE @DataDok datetime,
    @Termin  datetime,
    @DataReal datetime
  SET @DataDok = CONVERT(datetime, @BZd_DataDok, 120)
  SET @Termin = CONVERT(datetime, @BZd_Termin, 120)
  SET @DataReal = CONVERT(datetime, @BZd_DataReal, 120)
  DECLARE
  @FPlID  Int,
  @FPlTyp  SMALLINT
  SELECT @FPlID = Fpl_FplId, @FPlTyp = Fpl_Typ FROM CDN.FormyPlatnosci WHERE Fpl_ImportRowId = @Fpl_ImportRowID
  IF @FPlID is NULL
   SELECT @FPlID = Fpl_FplId, @FPlTyp = Fpl_Typ FROM CDN.FormyPlatnosci WHERE Fpl_Nazwa = @Fpl_Nazwa
  IF @FPlID is NULL
  BEGIN
   RAISERROR('##OPT33115##', 16, 1) --RAISERROR('Nie znaleziono odpowiedniej formy płatności dla płatności wypłaty.', 16, 1)
   RETURN
  END
  DECLARE
  @BRaID   int,
  @DomyslnaKasa nvarchar(20),
  @DomyslnyBank nvarchar(20)
  SET @BRaID = NULL
  IF ISNULL(@BZd_Waluta,'') <> '' AND UPPER(ISNULL(@BZd_Waluta,'')) <> CDN.Waluta('')
  BEGIN
   SELECT @BRaID = FPW_BRaID FROM cdn.FormyPlatnWaluty
    JOIN cdn.BnkRachunki ON FPW_BRaId = BRa_BraId
   WHERE FPW_FPlId = @FPlID AND BRa_Waluta = @BZd_Waluta
   END
   IF @BRaID IS NULL
   SELECT @BRaID = FPl_BRaID FROM cdn.FormyPlatnosci
    JOIN cdn.BnkRachunki ON FPl_BRaId = BRa_BraId
   WHERE Fpl_FplId = @FPlID
   IF @BRaID IS NULL
   BEGIN
   EXEC CDN.DomyslnaKasaBankOperatora @ServerName, @ConfigDBName, @OpeId, @DomyslnaKasa OUTPUT, @DomyslnyBank OUTPUT
   SELECT @BRaID = BRa_BRaID FROM CDN.BnkRachunki WHERE Bra_Akronim=(CASE @FPlTyp WHEN 2 THEN @DomyslnyBank ELSE @DomyslnaKasa END)
   END
   IF @BRaID IS NULL
   BEGIN
   IF @FPlTyp = 2
    RAISERROR('##OPT33046##', 16, 1) --RAISERROR( 'Bank domyślny [-brak-] dla zalogowanego operatora nie istnieje.', 16, 1)
   ELSE
    RAISERROR('##OPT33047##', 16, 1) --RAISERROR( 'Kasa domyślna [-brak-] dla zalogowanego operatora nie istnieje.', 16, 1)
  END
   DECLARE @BNaID INT
  SET @BNaID = NULL
  IF(@BNa_ImportRowID is not NULL OR @BNa_Numer is not NULL)
  BEGIN
   SELECT @BNaID = BNa_BNaID FROM CDN.BnkNazwy WHERE BNa_ImportRowId = @BNa_ImportRowId
   IF(@BNaID is NULL)
   BEGIN
    SELECT @BNaID = BNa_BNaID FROM CDN.BnkNazwy WHERE BNa_Numer = @BNa_Numer
    IF @BNaID is NULL
     --SET @Warnings = 'Brak banku ' + IsNull(@BNa_Numer, '') + ' w bazie docelowej. Bank na płatności wypłaty nie został zaimportowany.\'
     SET @Warnings = '##OPT33209##%%nrb%%=' +  IsNull(@BNa_Numer, '') + '##\';
   END
  END
  DECLARE
   @BZd_Stan smallInt
  SET @BZd_Stan = 1 -- do realizacji
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
      IF @KatID is NULL
       --SET @Warnings = 'Brak kategorii ' + IsNull(@Kat_KodSzczegol, '') + ' w bazie docelowej. Kategoria na płatności wypłaty nie została zaimportowana.\'
    SET @Warnings = '##OPT33208##%%kategoria%%=' + IsNull(@Kat_KodSzczegol, '') + '##\'
   END
   ELSE
   SELECT @KatID = Wpl_KatID FROM cdn.Wyplaty WHERE Wpl_WplID = @BZd_DokumentID
  DECLARE
   @BZD_StaZalID   int,
   @BZd_OpeZalID   int,
   @BZd_TS_Zal    datetime,
   @BZD_StaModID   int,
   @BZd_OpeModID   int,
   @BZd_TS_Mod    datetime,
   @LPl_Tryb    int
      SELECT
   @BZd_StaZalID = Wpl_StaZalID,
   @BZd_OpeZalID = Wpl_OpeZalID,
   @BZd_TS_Zal  = Wpl_TS_Zal,
   @BZd_StaModID = Wpl_StaModID,
   @BZd_OpeModID = Wpl_OpeModID,
   @BZd_TS_Mod  = Wpl_TS_Mod,
   @LPl_Tryb       = LPl_Tryb
   FROM CDN.Wyplaty JOIN cdn.PracEtaty ON PrE_PraID = Wpl_PraID AND Wpl_DataDo BETWEEN PrE_DataOd AND PrE_DataDo JOIN cdn.ListyPlac ON LPl_LPlID = Wpl_LPlID WHERE Wpl_WplID = @BZd_DokumentID
  declare @OpeZalKod varchar(20), @OpeZalNazwisko nvarchar(50)
  exec CDN.OpeKodNazwisko @BZd_OpeZalID, @OpeZalKod OUT, @OpeZalNazwisko OUT
  declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
  exec CDN.OpeKodNazwisko @BZd_OpeModID, @OpeModKod OUT, @OpeModNazwisko OUT
   DECLARE @Rozliczono INT
   IF @LPl_Tryb = 1 -- lista płac korygująca
   BEGIN
   IF @BZd_Rozliczono <> 0
   BEGIN
     DECLARE @NieRozl INT
     SET @NieRozl = 0
     IF @PodmiotTyp = 1
    Select Top 1 @NieRozl = Knt_NieRozliczac From CDN.Kontrahenci Where Knt_KntID = @PodmiotID
     ELSE IF @PodmiotTyp = 3
    Select Top 1 @NieRozl = PRE_NieRozliczac From CDN.PracEtaty Where PRE_PRAID = @PodmiotID And PRE_DataDo = Convert(DateTime, '2999-12-31', 120)
     ELSE IF @PodmiotTyp = 5
    Select Top 1 @NieRozl = Urz_NieRozliczac From CDN.Urzedy Where Urz_UrzID = @PodmiotID
     IF @NieRozl <> 0
    SET @BZd_Rozliczono = 0
   END
   SET @Rozliczono = @BZd_Rozliczono
   END
   ELSE
   SELECT @Rozliczono = CDN.StatusRozliczeniaPR(@BZd_Rozliczono, @PodmiotTyp, @PodmiotID, @DataDok)
    SET @BZd_PrzelewSEPA = IsNull(@BZd_PrzelewSEPA, 0)
    IF @BZd_PrzelewSEPA <> 0 AND cdn.CzyMoznaUstawicSEPA(@BRaID) = 0
    BEGIN
      --SET @Warnings = @Warnings + 'Rejestr przelewu nie spełnia warunków SEPA. Rejestr nie zostanie ustawiony jako przelew SEPA.\'
   SET @Warnings = @Warnings + '##OPT33185##\'
      SET @BZd_PrzelewSEPA = 0
    END
   INSERT INTO CDN.BnkZdarzenia
   (
   BZd_DokumentID,
   BZd_DokumentTyp,
   BZd_ImportRowID,
   BZd_BRaID,
   BZd_PodmiotTyp,
   BZd_PodmiotID,
   BZd_PodmiotRachunekLp,
   BZd_DDfID,
   BZd_NumerPelny,
   BZd_NumerObcy,
   BZd_Kierunek,
   BZd_Kwota,
   BZd_KwotaSys,
   BZd_WalutaDok,
   BZd_Waluta,
   BZd_KursNumer,
   BZd_KursL,
   BZd_KursM,
   BZd_DataKur,
   BZd_DataDok,
   BZd_Termin,
   BZd_DataReal,
   BZd_Zwloka,
   BZd_FPlID,
   BZd_BNaID,
   BZd_RachunekNr,
   BZd_IBAN,
   BZd_Stan,
   BZd_Rozliczono,
   BZd_Rozliczono2,
   BZd_KwotaRoz,
   BZd_KwotaRozSys,
   BZd_KatID,
   BZd_Priorytet,
   BZd_KontoPrzeciwstawne,
   BZd_NieNaliczajOdsetek,
   BZd_PrzelewSEPA,
   BZd_RelTyp,
   BZd_RelID,
   BZd_PrwTyp,
   BZd_PrwID,
   BZd_ElixirO1,
   BZd_ElixirO2,
   BZd_ElixirO3,
   BZd_ElixirO4,
   BZd_Opis,
   BZd_KomornikZajecieWynagr,
   BZd_ImportAppID,
   BZd_StaZalID,
   BZd_OpeZalID,
   BZd_OpeZalKod,
   BZd_OpeZalNazwisko,
   BZd_TS_Zal,
   BZd_StaModID,
   BZd_OpeModID,
   BZd_OpeModKod,
   BZd_OpeModNazwisko,
   BZd_TS_Mod
   )
     VALUES
     (
   @BZd_DokumentID,
   @DokTyp,
   @BZd_ImportRowID,
   @BRaID,
   @PodmiotTyp,
   @PodmiotID,
   @PodmiotRachunekLp,
   @DDfID,
   @BZd_NumerPelny,
   @BZd_NumerObcy,
   @BZd_Kierunek,
   @BZd_Kwota,
   @BZd_KwotaSys,
   @BZd_WalutaDok,
   @BZd_Waluta,
   @WKuId,
   Case when @BZd_KursL=0 then 1 else @BZd_KursL end,
   Case when @BZd_KursM=0 then 1 else @BZd_KursM end,
   @DataKur,
   @DataDok,
   @Termin,
   @DataReal,
   @BZd_Zwloka,
   @FPlID,
   @BNaID,
   @BZd_RachunekNr,
   @BZd_IBAN,
   @BZd_Stan,
   @Rozliczono,
   @Rozliczono,
   0,
   0,
   @KatID,
   2,
   @BZd_KontoPrzeciwstawne,
   @BZd_NieNaliczajOdsetek,
   @BZd_PrzelewSEPA,
   0,
   0,
   @dokTyp,
   @BZd_DokumentID,
   @BZd_ElixirO1,
   @BZd_ElixirO2,
   @BZd_ElixirO3,
   @BZd_ElixirO4,
   @BZd_Opis,
   @BZd_KomornikZajecieWynagr,
   @ZrdID,
   @BZd_StaZalID,
   @BZd_OpeZalID,
   @OpeZalKod,
   @OpeZalNazwisko,
   @BZd_TS_Zal,
   @BZd_StaModID,
   @BZd_OpeModID,
   @OpeModKod,
   @OpeModNazwisko,
   @BZd_TS_Mod
  )
  select @IdParam = SCOPE_IDENTITY()
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 1001, -- OptimaObjectType_ZdarzenieKB
    @ObiektSubTyp = @BZd_Kierunek,
    @ObiektID = @IdParam,
    @ObiektNazwa = @BZd_NumerPelny,
    @OperacjaTyp = 1, -- OptimaOperationType_Dodanie
    @Opis = ''
 end
