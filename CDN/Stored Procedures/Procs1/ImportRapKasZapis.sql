CREATE PROCEDURE CDN.ImportRapKasZapis
@IdParam int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@BZp_ImportRowId nvarchar(36),
@DDf_Symbol nvarchar(5),
@DDf_ImportRowID nvarchar(36),
@BZp_DataDok nvarchar(10),
@BZp_NumerPelny nvarchar(30),
@rejestr nvarchar(10),
@BZp_NumerNr int,
@BZp_NumerObcy nvarchar(256),
@BZp_BRpLp int,
@BZp_Typ smallint,
@BZp_Kwota decimal(15,2),
@BZp_Waluta nvarchar(3),
@BZp_WalutaDok nvarchar(3),
@WKu_Symbol nvarchar(5),
@BZp_KursL decimal(15,4),
@BZp_KursM decimal(5,0),
@BZp_DataKur nvarchar(10),
@BZp_KwotaSys decimal(15,2),
@BZp_Kierunek smallint,
@BZp_Rozliczono smallint,
@BZp_Wynagrodzenie smallint,
@Pod_TypOpis nvarchar(30),
@Pod_Kod nvarchar(20),
@Pod_ImportRowId nvarchar(36),
@Pod_NIP nvarchar(20),
@BZp_Nazwa1 nvarchar(50),
@BZp_Nazwa2 nvarchar(50),
@BZp_Nazwa3 nvarchar(250),
@BZp_Kraj nvarchar(40),
@BZp_Wojewodztwo nvarchar(40),
@BZp_Powiat nvarchar(40),
@BZp_Gmina nvarchar(40),
@BZp_Ulica nvarchar(40),
@BZp_NrDomu nvarchar(10),
@BZp_NrLokalu nvarchar(10),
@BZp_Miasto nvarchar(40),
@BZp_KodPocztowy nvarchar(10),
@BZp_Poczta nvarchar(40),
@BZp_Adres2 nvarchar(40),
@BNa_Numer nvarchar(10),
@BNa_ImportRowId nvarchar(36),
@BZp_RachunekNr nvarchar(51),
@BZp_IBAN smallint,
@KKr_Nazwa nvarchar(20),
@BZp_KartaNr nvarchar(16),
@BZp_KartaDW nvarchar(10),
@Kat_KodSzczegol nvarchar(20),
@Kat_ImportRowId nvarchar(36),
@BZp_Opis nvarchar(254),
@BZp_KontoPrzeciwstawne nvarchar(50),
@Zak_Symbol nvarchar(30),
@Zak_ImportRowId nvarchar(36),
@BZp_SplitPay tinyint,
@BZp_SplitPayZapisVAT tinyint,
@ZrdId nvarchar(5),
@OpeId int,
@IdZap int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
  IF EXISTS(SELECT * FROM cdn.BnkZapisy WHERE BZp_ImportRowId = @BZp_ImportRowId)
  BEGIN
    --SET @Warnings = 'Zapis ' + IsNull(@BZp_NumerPelny, '') + ' już istnieje w bazie docelowej. Zapis nie został zaimportowany.\'
 SET @Warnings = '##OPT33186##%%nrDok%%=' + IsNull(@BZp_NumerPelny, '') + '##\'
    SELECT @IdZap = BZp_BZpID FROM cdn.BnkZapisy WHERE BZp_ImportRowId = @BZp_ImportRowId
    RETURN
  END
    DECLARE @BraId  int,
  @DDfId   int,
  @schemat  nvarchar(50),
  @PodId   int,
  @PodTyp   int,
  @WKuId   int,
  @sqltxt   NVARCHAR (1000),
  @TmpSrvName  SYSNAME,
  @Error   nvarchar(256),
  @KatId   int,
  @BNaId   int,
  @KKrId   int,
  @DDfErr   nvarchar(50),
    @DDfKonfiguracja int
 SET @Warnings = ''
 SELECT @BraId = BRp_BRaId
 FROM CDN.BnkRaporty
 WHERE BRp_BRpId = @IdParam
 SET @DDfId = CDN.GetDDfIDFromRowIDOrSymbol(@DDf_ImportRowId, @DDf_Symbol);
 SELECT @schemat = DDf_Numeracja
 FROM CDN.DokDefinicje
 WHERE @DDfId = DDf_DDfId
 IF(@schemat IS NULL or @DDfId is NULL )
    BEGIN
 IF @BZp_Kierunek = 1 -- KP
  SET @DDfKonfiguracja = [CDN].[Konfiguracja] (1, '1727', 0, 0);
 ELSE -- KW
  SET @DDfKonfiguracja = [CDN].[Konfiguracja] (1, '1730', 0, 0);
    SELECT @DDfId = DDf_DDfId, @schemat = DDf_Numeracja
    FROM CDN.DokDefinicje
    WHERE DDf_DDfID = @DDfKonfiguracja
    IF(@schemat IS NULL or @DDfId is NULL )
    BEGIN
  --SET @DDfErr = 'Brak definicji dokumentu ' + @DDf_Symbol + ' w bazie.'
  RAISERROR('##OPT33057##%%symbol%%=%s##', 16, 1, @DDf_Symbol) --RAISERROR(@DDfErr, 16, 1)
  RETURN
 END
    END
 IF CDN.GetNumerPelny(@schemat, convert(datetime, @BZp_DataDok, 120), @rejestr, @DDf_Symbol, @BZp_NumerNr, CDN.GetPrymityw(@BZp_NumerPelny, @schemat, '@magazyn'), CDN.GetPrymityw(@BZp_NumerPelny, @schemat, '@rok_obr')) <> @BZp_NumerPelny
  RAISERROR('##OPT33043##', 16, 1) --RAISERROR('Numer dokumentu nie jest zgodny ze schematem numeracji.', 16, 1)
 IF(@Kat_ImportRowId is not NULL OR @Kat_KodSzczegol is not NULL)
 BEGIN
  SET @KatId = NULL
  SELECT @KatId = Kat_KatId
  FROM CDN.Kategorie
  WHERE Kat_ImportRowId = @Kat_ImportRowId
  IF(@KatId is NULL)
  BEGIN
   SELECT @KatId = Kat_KatId
   FROM CDN.Kategorie
   WHERE Kat_KodSzczegol = @Kat_KodSzczegol
   IF(@KatId is NULL)
    --SET @Warnings = 'Brak kategorii ' + IsNull(@Kat_KodSzczegol, '') + ' w bazie docelowej. Kategoria nie została zaimportowana.\'
    SET @Warnings = '##OPT33150##%%kategoria%%=' + IsNull(@Kat_KodSzczegol, '') + '##\'
  END
 END
 DECLARE @notUsed INT
 EXEC CDN.GetPodmiotDlaPracyRozproszonej @Pod_TypOpis, @Pod_Kod, @Pod_ImportRowId, @Pod_NIP, 1, @PodID OUTPUT, @PodTyp OUTPUT, @notUsed OUTPUT, @Warnings OUTPUT
 DECLARE @PlatnikTyp int
 DECLARE @PlatnikID int
 DECLARE @PodmiotRachunekLp int
 SET @PodmiotRachunekLp = 0
 IF @Pod_TypOpis Is Not Null
 BEGIN
  EXEC CDN.GetPlatnikDlaPracyRozproszonej @Pod_TypOpis, @Pod_Kod, @Pod_ImportRowId, @Pod_NIP, @BZp_RachunekNr,
   1,
   @PlatnikTyp OUTPUT, @PlatnikID OUTPUT, @PodmiotRachunekLp OUTPUT, @Warnings OUTPUT
   IF @PodmiotRachunekLp Is Null
    SELECT @PodmiotRachunekLp = 0
 END
 IF IsNull(@BZp_KontoPrzeciwstawne, '') = ''
 BEGIN
  IF @PodTyp = 1
   SELECT @BZp_KontoPrzeciwstawne = CASE WHEN @BZp_Kierunek = 1 THEN Knt_KontoDost ELSE Knt_KontoOdb END FROM CDN.Kontrahenci WHERE Knt_KntId = @PodId
  ELSE IF @PodTyp = 3
   SELECT @BZp_KontoPrzeciwstawne = PRE_KontoKsiegowe FROM cdn.PracEtaty WHERE PRE_PraId = @PodId
 END
 EXECUTE @WKuId = CDN.GetTypKursuWaluty @Wku_Symbol, @ConfigDBName, @ServerName
 IF((@BNa_ImportRowId is not NULL AND @BNa_ImportRowId <> '') OR (@BNa_Numer is not NULL AND @BNa_Numer <> ''))
 BEGIN
  IF(@BNa_ImportRowId is NULL OR  @BNa_ImportRowId = '')
   SELECT @BNaId = BNa_BNaId
   FROM CDN.BnkNazwy
   WHERE BNa_Numer = @BNa_Numer
  ELSE
   SELECT @BNaId = BNa_BNaId
   FROM CDN.BnkNazwy
   WHERE BNa_ImportRowId = @BNa_ImportRowId
 END
 Set @Error = 'Brak kursu waluty ' + @WKu_Symbol + '.'
 IF @WKuId IS NULL
 RAISERROR('##OPT33059##', 16, 1, @WKu_Symbol) --RAISERROR(@Error, 16, 1)
 IF(@KKr_Nazwa is not NULL)
 BEGIN
  SELECT @KKrId = KKr_KKrId
  FROM CDN.KartyKredytowe
  WHERE KKr_Nazwa = @KKr_Nazwa
 END
 IF(@BZp_Nazwa1 is NULL)
  BEGIN
   SET @BZp_Nazwa1 = ''
   SELECT @BZp_Nazwa1 = Knt_Nazwa1
   FROM CDN.Kontrahenci
   WHERE Knt_KntId = @PodId AND @PodTyp = 1
  END
 IF(@BZp_Nazwa2 is NULL)
 BEGIN
  SET @BZp_Nazwa2 = ''
  SELECT @BZp_Nazwa2 = Knt_Nazwa2
  FROM CDN.Kontrahenci
  WHERE Knt_KntId = @PodId AND @PodTyp = 1
 END
 IF(@BZp_Nazwa3 is NULL)
 BEGIN
  SET @BZp_Nazwa3 = ''
  SELECT @BZp_Nazwa3 = Knt_Nazwa3
  FROM CDN.Kontrahenci
  WHERE Knt_KntId = @PodId AND @PodTyp = 1
 END
 IF @BZp_Wynagrodzenie IS NULL
  SET @BZp_Wynagrodzenie = 0;
  DECLARE @Zak_Id int
  EXEC CDN.GetZakladDlaPracyRozproszonej @Zak_Symbol, @Zak_ImportRowId, 3, @Zak_ID OUTPUT, @Warnings OUTPUT
  SELECT @BZp_SplitPay = IsNull(@BZp_SplitPay, 0)
  SELECT @BZp_SplitPayZapisVAT = IsNull(@BZp_SplitPayZapisVAT, 0)
 INSERT INTO CDN.BnkZapisy
 (
 BZp_RelTyp,
 BZp_RelID,
 BZp_BRpID,
 BZp_BRpLP,
 BZp_BRaID,
 BZp_Typ,
 BZp_KartaNr,
 BZp_KartaDW,
 BZp_DDfID,
 BZp_KatId,
 BZp_BNaId,
 BZp_KKrId,
 BZp_NumerNr,
 BZp_NumerString,
 BZp_NumerObcy,
 BZp_PodmiotTyp,
 BZp_PodmiotID,
 BZp_PodmiotRachunekLp,
 BZp_RachunekNr,
 BZp_IBAN,
 BZp_Wynagrodzenie,
 BZp_Nazwa1,
 BZp_Nazwa2,
 BZp_Nazwa3,
 BZp_Kraj,
 BZp_Wojewodztwo,
 BZp_Powiat,
 BZp_Gmina,
 BZp_Ulica,
 BZp_NrDomu,
 BZp_NrLokalu,
 BZp_Miasto,
 BZp_KodPocztowy,
 BZp_Poczta,
 BZp_Adres2,
 BZp_DataDok,
 BZp_KwotaSys,
 BZp_KwotaRozSys,
 BZp_KwotaRozSysMW,
 BZp_Kwota,
 BZp_KwotaRoz,
 BZp_KwotaRozMW,
 BZp_Waluta,
 BZp_KursNumer,
 BZp_KursL,
 BZp_KursM,
 BZp_Kierunek,
 BZp_Rozliczono,
 BZp_RozliczonoMW,
 BZp_Rozliczono2,
 BZp_Rozliczono2MW,
 BZp_Opis,
 BZp_ZapisAutomatyczny,
 BZp_AutoOffLine,
 BZp_KontoPrzeciwstawne,
 BZp_MagazynWalut,
 BZp_WgKursuMW,
 BZp_ZakID,
 BZp_SplitPay,
 BZp_SplitPayZapisVAT,
 BZp_TS_Export,
 BZp_ImportAppId,
 BZp_ImportRowId,
 BZp_OpeZalId,
 BZp_OpeZalKod,
 BZp_OpeZalNazwisko,
 BZp_StaZalId,
 BZp_TS_Zal,
 BZp_OpeModId,
 BZp_OpeModKod,
 BZp_OpeModNazwisko,
 BZp_StaModId,
 BZp_TS_Mod,
 BZp_WalutaDok,
 BZp_DataKur
 )
 VALUES
 (
 NULL,
 NULL,
 @IdParam,
 @BZp_BRpLp,
 @BRaID,
 @BZp_Typ,
 @BZp_KartaNr,
 convert(datetime, @BZp_KartaDW, 120),
 @DDfId,
 @KatId,
 @BNaId,
 @KKrId,
 @BZp_NumerNr,
 CDN.GetDokNumString(@schemat, @BZp_NumerPelny),
 @BZp_NumerObcy,
 @PodTyp,
 @PodId,
 @PodmiotRachunekLp,
 @BZp_RachunekNr,
 @BZp_IBAN,
 @BZp_Wynagrodzenie,
 @BZp_Nazwa1,
 @BZp_Nazwa2,
 @BZp_Nazwa3,
 @BZp_Kraj,
 @BZp_Wojewodztwo,
 @BZp_Powiat,
 @BZp_Gmina,
 @BZp_Ulica,
 @BZp_NrDomu,
 @BZp_NrLokalu,
 @BZp_Miasto,
 @BZp_KodPocztowy,
 @BZp_Poczta,
 @BZp_Adres2,
 convert(datetime, @BZp_DataDok, 120),
 @BZp_KwotaSys,
 0,
 0, -- BZp_KwotaRozSysMW
 @BZp_Kwota,
 0,
 0, -- BZp_KwotaRozMW
 @BZp_Waluta,
 @WKuId,
 case when @BZp_KursL=0 then 1 else @BZp_KursL end,
 case when @BZp_KursM=0 then 1 else @BZp_KursM end,
 @BZp_Kierunek,
 ISNULL(@BZp_Rozliczono,1), --@BZp_Rozliczono
 0, -- BZp_RozliczonoMW
 ISNULL(@BZp_Rozliczono,1), --@BZp_Rozliczono
 0, -- BZp_RozliczonoMW2
 @BZp_Opis,
 0,
 0,
 @BZp_KontoPrzeciwstawne,
 0, -- BZp_MagazynWalut
 0, -- BZp_WgKursuMW,
 @Zak_Id,
 @BZp_SplitPay,
 @BZp_SplitPayZapisVAT,
 NULL,
 @ZrdId,
 @BZp_ImportRowId,
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
 @BZp_WalutaDok,
 convert(datetime, @BZp_DataKur, 120)
 )
 SET @IdZap = SCOPE_IDENTITY()
 DECLARE @NumerDok NVARCHAR(256)
 SET @NumerDok = (SELECT BZp_NumerPelny FROM cdn.BnkZapisy WHERE BZp_BZpID = @IdZap)
 EXEC [CDN].[RejestrOperacjiDodaj]
   @ObiektTyp = 1000, -- OptimaObjectType_ZapisKB
   @ObiektSubTyp = @BZp_Kierunek,
   @ObiektID = @IdZap,
   @ObiektNazwa = @NumerDok,
   @OperacjaTyp = 1, -- OptimaOperationType_Dodanie
   @Opis = '' --@BZp_Opis
END
