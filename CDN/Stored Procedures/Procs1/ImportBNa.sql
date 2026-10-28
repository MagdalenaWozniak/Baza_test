CREATE PROCEDURE CDN.ImportBNa
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@BNa_ImportRowId nvarchar(36),
@BNa_Numer nvarchar(10),
@BNa_Iban smallint,
@BNa_Zagraniczny smallint,
@BNa_Centrala nvarchar(3),
@BNa_Akronim nvarchar(20),
@BNa_Nazwa1 nvarchar(50),
@BNa_Nazwa2 nvarchar(50),
@BNa_Kraj nvarchar(40),
@BNa_Wojewodztwo nvarchar(40),
@BNa_Powiat nvarchar(40),
@BNa_Gmina nvarchar(40),
@BNa_KodPocztowy nvarchar(10),
@BNa_Poczta nvarchar(40),
@BNa_Miasto nvarchar(40),
@BNa_Ulica nvarchar(40),
@BNa_NrDomu nvarchar(10),
@BNa_NrLokalu nvarchar(10),
@BNa_Adres2 nvarchar(40),
@BNa_Modem nvarchar(20),
@BNa_Telefon nvarchar(20),
@BNa_Fax nvarchar(20),
@BNa_URL nvarchar(254),
@BNa_UID nvarchar(30),
@BNa_PWD nvarchar(30),
@Kat_KodSzczegol nvarchar(20),
@Kat_ImportRowId nvarchar(36),
@BNa_Format nvarchar(50),
@BNa_FormatSplitPay nvarchar(50),
@BNa_FormatUS nvarchar(50),
@BNa_FormatZUS nvarchar(50),
@BNa_FormatImp nvarchar(50),
@BNa_CzasRealizacji smallint,
--@BNa_OddzialBRE smallint,
--@BNa_KlientBRE int,
@BNa_Swift nvarchar(20),
--@BNa_FormatZUS smallint,
--@BNa_OpcjaE1 smallint,
--@BNa_OpcjaE2 smallint,
--@BNa_OpcjaPKOSA smallint,
@BNa_NieRozliczac tinyint,
@BNa_Email nvarchar(40),
@BNa_Nieaktywny tinyint,
@ZrdId nvarchar(5),
@OpeId int,
@SlowId int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 DECLARE @OperationType INT
 SET @OperationType = 0
 DECLARE @KatId int,
      @FormatId int,
   @FormatSplitPayID int,
      @FormatUSId int,
      @FormatZUSId int,
      @FormatImpId int,
      @TmpAkr nvarchar(20)
  SET @Warnings = ''
  IF @Kat_ImportRowId is not NULL OR @Kat_KodSzczegol is not NULL
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
  SET @FormatId = NULL
  SELECT @FormatId = BFN_BFNId FROM CDN.BnkFormatyNag WHERE BFN_Nazwa = @BNa_Format
  IF(@FormatId is NULL) SET @FormatId = 0
  SET @FormatSplitPayID = NULL
  IF IsNull(@BNa_FormatSplitPay, '') <> ''
 SELECT @FormatSplitPayID = BFN_BFNId FROM CDN.BnkFormatyNag WHERE BFN_Nazwa = @BNa_FormatSplitPay
  IF(@FormatSplitPayID is NULL) SET @FormatSplitPayID = 0
  SET @FormatUSId = NULL
  SELECT @FormatUSId = BFN_BFNId FROM CDN.BnkFormatyNag WHERE BFN_Nazwa = @BNa_FormatUS
  IF(@FormatUSId is NULL) SET @FormatUSId = 0
  SET @FormatZUSId = NULL
  SELECT @FormatZUSId = BFN_BFNId FROM CDN.BnkFormatyNag WHERE BFN_Nazwa = @BNa_FormatZUS
  IF(@FormatZUSId is NULL) SET @FormatZUSId = 0
  SET @FormatImpId = NULL
  SELECT @FormatImpId = BFN_BFNId FROM CDN.BnkFormatyNag WHERE BFN_Nazwa = @BNa_FormatImp
  IF(@FormatImpId is NULL) SET @FormatImpId = 0
  IF(SELECT Fir_Wartosc
    FROM CDN.Firma
    WHERE Fir_Numer = 2) = 1
  BEGIN
      SET @TmpAkr = @BNa_Akronim
      SET @TmpAkr = REPLACE(REPLACE(REPLACE(REPLACE(@TmpAkr, ',', '.'), ' ', '.'), '-', '.'), '''', '.')
      IF CHARINDEX('.', @TmpAkr) <> 0
  --SET @Warnings = @Warnings + 'Akronim zawiera znaki specjalne.\'
  SET @Warnings = @Warnings + '##OPT33152##\'
  END
  IF((SELECT count(*)
    FROM CDN.BnkNazwy
    WHERE ((IsNull(@BNa_ImportRowId, '') <> '' AND  BNa_ImportRowId = @BNa_ImportRowId) OR BNa_Akronim = @BNa_Akronim)
        OR (IsNull(@BNa_ImportRowId, '') = '' AND BNa_Akronim = @BNa_Akronim))=0)
  BEGIN
    INSERT INTO CDN.BnkNazwy
    (
    BNa_ImportRowId,
    BNa_Numer,
    BNa_Iban,
    BNa_Zagraniczny,
    BNa_Centrala,
    BNa_Akronim,
    BNa_Nazwa1,
    BNa_Nazwa2,
    BNa_Kraj,
    BNa_Wojewodztwo,
    BNa_Powiat,
    BNa_Gmina,
    BNa_KodPocztowy,
    BNa_Poczta,
    BNa_Miasto,
    BNa_Ulica,
    BNa_NrDomu,
    BNa_NrLokalu,
    BNa_Adres2,
    BNa_Modem,
    BNa_Telefon,
    BNa_Fax,
    BNa_EMail,
    BNa_URL,
    BNa_UID,
    BNa_PWD,
    BNa_Format,
 BNa_FormatSplitPay,
    BNa_FormatUS,
    BNa_FormatZUS,
    BNa_FormatImp,
    BNa_CzasRealizacji,
--    BNa_OddzialBRE,
--    BNa_KlientBRE,
    BNa_Swift,
--    BNa_FormatZUS,
--    BNa_OpcjaE1,
--    BNa_OpcjaE2,
--    BNa_OpcjaPKOSA,
    BNa_TS_Mod,
    BNa_TS_Zal,
    BNa_NieRozliczac,
    BNa_KatId,
    BNa_Nieaktywny,
    BNa_OpeModID,
 BNa_OpeModKod,
 BNa_OpeModNazwisko,
    BNa_OpeZalID,
 BNa_OpeZalKod,
 BNa_OpeZalNazwisko,
    BNa_TS_Export,
    BNa_ImportAppId
    )
    VALUES
    (
    @BNa_ImportRowId,
    @BNa_Numer,
    @BNa_Iban,
    @BNa_Zagraniczny,
    @BNa_Centrala,
    @BNa_Akronim,
    @BNa_Nazwa1,
    @BNa_Nazwa2,
    @BNa_Kraj,
    @BNa_Wojewodztwo,
    @BNa_Powiat,
    @BNa_Gmina,
    @BNa_KodPocztowy,
    @BNa_Poczta,
    @BNa_Miasto,
    @BNa_Ulica,
    @BNa_NrDomu,
    @BNa_NrLokalu,
    @BNa_Adres2,
    @BNa_Modem,
    @BNa_Telefon,
    @BNa_Fax,
    ISNULL(@BNa_Email,''),
    @BNa_URL,
    @BNa_UID,
    @BNa_PWD,
    @FormatId,
 @FormatSplitPayID,
    @FormatUSId,
    @FormatZUSId,
    @FormatImpId,
    @BNa_CzasRealizacji,
--    @BNa_OddzialBRE,
--    @BNa_KlientBRE,
    @BNa_Swift,
--    @BNa_FormatZUS,
--    @BNa_OpcjaE1,
--    @BNa_OpcjaE2,
--    @BNa_OpcjaPKOSA,
    GETDATE(),
    GETDATE(),
    @BNa_NieRozliczac,
    @KatId,
    @BNa_Nieaktywny,
    @OpeId,
 @OpeModKod,
 @OpeModNazwisko,
    @OpeId,
 @OpeModKod,
 @OpeModNazwisko,
    GETDATE(),
    @ZrdId
    )
 SELECT @SlowID = SCOPE_IDENTITY()
 SET @OperationType = 1 -- OptimaOperationType_Dodanie
  END
  ELSE
  BEGIN
    IF(@OnlyNew <> 1)
    BEGIN
   SELECT @SlowID = BNa_BNaID FROM CDN.BnkNazwy WHERE (IsNull(@BNa_ImportRowId, '') <> '' AND BNa_ImportRowId = @BNa_ImportRowId) OR (IsNull(@BNa_ImportRowId, '') = '' AND BNa_Akronim = @BNa_Akronim)
      UPDATE CDN.BnkNazwy
      SET
      BNa_ImportRowId = @BNa_ImportRowId,
      BNa_Numer = @BNa_Numer,
      BNa_Iban = @BNa_Iban,
      BNa_Zagraniczny = @BNa_Zagraniczny,
      BNa_Centrala = @BNa_Centrala,
      BNa_Akronim = @BNa_Akronim,
      BNa_Nazwa1 = @BNa_Nazwa1,
      BNa_Nazwa2 = @BNa_Nazwa2,
      BNa_Kraj = @BNa_Kraj,
      BNa_Wojewodztwo = @BNa_Wojewodztwo,
      BNa_Powiat = @BNa_Powiat,
      BNa_Gmina = @BNa_Gmina,
      BNa_KodPocztowy = @BNa_KodPocztowy,
      BNa_Poczta = @BNa_Poczta,
      BNa_Miasto = @BNa_Miasto,
      BNa_Ulica = @BNa_Ulica,
      BNa_NrDomu = @BNa_NrDomu,
      BNa_NrLokalu = @BNa_NrLokalu,
      BNa_Adres2 = @BNa_Adres2,
      BNa_Modem = @BNa_Modem,
      BNa_Telefon = @BNa_Telefon,
      BNa_Fax = @BNa_Fax,
      BNa_URL = @BNa_URL,
      BNa_UID = @BNa_UID,
      BNa_PWD = @BNa_PWD,
      BNa_Format = @FormatId,
   BNa_FormatSplitPay = @FormatSplitPayID,
      BNa_FormatUS = @FormatUSId,
      BNa_FormatZUS = @FormatZUSId,
      BNa_FormatImp = @FormatImpId,
      BNa_CzasRealizacji = @BNa_CzasRealizacji,
--      BNa_OddzialBRE = @BNa_OddzialBRE,
--      BNa_KlientBRE = @BNa_KlientBRE,
      BNa_Swift = @BNa_Swift,
--      BNa_FormatZUS = @BNa_FormatZUS,
--      BNa_OpcjaE1 = @BNa_OpcjaE1,
--      BNa_OpcjaE2 = @BNa_OpcjaE2,
--      BNa_OpcjaPKOSA = @BNa_OpcjaPKOSA,
      BNa_TS_MOD = GETDATE(),
      BNa_NieRozliczac = @BNa_NieRozliczac,
      BNa_KatId = @KatId,
      BNa_Email = CASE WHEN LEN(ISNULL(@BNa_Email,'')) = 0 THEN BNa_Email ELSE @BNa_Email END,
      BNa_Nieaktywny = @BNa_Nieaktywny,
      BNa_OpeModId = @OpeId,
   BNa_OpeModKod = @OpeModKod,
   BNa_OpeModNazwisko = @OpeModNazwisko
      WHERE BNa_BNaID = @SlowID
   SET @OperationType = 2 -- OptimaOperationType_Modyfikacja
    END
    ELSE
  RAISERROR('##OPT33041##', 16, 1) --RAISERROR('Taki zapis już istnieje. Element nie został dodany', 16, 1)
  END
 IF @OperationType <> 0
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 1102, -- OptimaObjectType_Bank
    @ObiektSubTyp = 0,
    @ObiektID = @SlowID,
    @ObiektNazwa = @BNa_Numer,
    @OperacjaTyp = @OperationType,
    @Opis = '' --@BNa_Nazwa1
END
