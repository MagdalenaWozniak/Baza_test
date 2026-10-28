CREATE PROCEDURE CDN.ImportPracSchemPlatn
@DokId int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@FPl_Nazwa nvarchar(20),
@FPl_ImportRowId nvarchar(36),
@SPL_LiczbaPorz int,
@SPL_IBAN tinyint,
@SPL_RachunekNr nvarchar(51),
--@BNa_Akronim nvarchar(30),
--@BNa_ImportRowId nvarchar(36),
@SPL_Procent decimal(14, 2),
@SPL_Kwota decimal(14, 2),
@SPL_Reszta tinyint,
@BNa_Numer nvarchar(20),
@BNa_ImportRowId nvarchar(36),
@Odbiorca_Typ int,
@Odbiorca_ImportRowId nvarchar(36),
@Odbiorca_Kod nvarchar(20),
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 DECLARE @FPlId int,
   @BNaId int,
   @TypPlat int,
   @OdbID int,
   @KodImportowanego nvarchar(20)
 IF(@FPl_ImportRowId is NULL OR @FPl_ImportRowId = '')
  SELECT @FPlId = FPl_FPlId, @TypPlat = Fpl_Typ
  FROM CDN.FormyPlatnosci
  WHERE FPl_Nazwa = @FPl_Nazwa
 ELSE
  SELECT @FPlId = FPl_FPlId, @TypPlat = Fpl_Typ
  FROM CDN.FormyPlatnosci
  WHERE FPl_ImportRowId = @FPl_ImportRowId
 SELECT @BNaId = BNa_BNaId
 FROM CDN.BnkNazwy
 WHERE BNa_ImportRowId = @BNa_ImportRowId
 IF @BNaId is NULL
  SELECT @BNaId = BNa_BNaId
  FROM CDN.BnkNazwy
  WHERE BNa_Numer = @BNa_Numer
 IF(@TypPlat = 2)
 BEGIN
  IF(@BNaId is NULL OR @SPL_RachunekNr = '')
   RAISERROR('##OPT24129##', 16, 1) --RAISERROR('Dla formy płatności "przelew" wymagane jest uzupełnienie pola bank oraz numer rachunku.', 16, 1)
 END
 SET @OdbID = null;
 IF @Odbiorca_Typ IS NULL
  SET @Odbiorca_Typ = 3
 IF @Odbiorca_Typ = 1 -- kontrahent
 BEGIN
  SELECT @OdbID = Knt_KntID FROM CDN.Kontrahenci WHERE ISNULL(@Odbiorca_ImportRowId,'') <> '' AND @Odbiorca_ImportRowId = Knt_ImportRowID
  IF @OdbID IS NULL
   SELECT @OdbID = Knt_KntID FROM CDN.Kontrahenci WHERE Knt_Kod = @Odbiorca_Kod
  IF @OdbID IS NULL
   SET @Odbiorca_Typ = 3 -- podstawimy samego siebie jako odbiorcę.
 END
 ELSE IF @Odbiorca_Typ = 3 -- pracownik
 BEGIN
  SELECT @OdbID = Pra_PraID FROM CDN.PracKod WHERE ISNULL(@Odbiorca_ImportRowId,'') <> '' AND @Odbiorca_ImportRowId = Pra_ImportRowID
  IF @OdbID IS NULL
   SELECT @OdbID = Pra_PraID FROM CDN.PracKod WHERE Pra_Kod = @Odbiorca_Kod
  IF @OdbID IS NOT NULL
   SELECT @OdbID = PRE_PREID FROM CDN.PracEtaty WHERE PRE_PraID = @OdbID AND PRE_DataDo=Convert(datetime,'2999-12-31',121)
 END
 IF @OdbID IS NULL
 BEGIN
  SET @OdbID = @DokID;
  SELECT @KodImportowanego = Pra_Kod FROM CDN.PracKod WHERE Pra_PraID = @DokID
  --SET @Warnings = 'Brak odbiorcy płatności [' + ISNULL(@Odbiorca_Kod, '') + '] w bazie docelowej. Jako odbiorca został podstawiony [' + @KodImportowanego + ']\'
  SET @Warnings = '##OPT33160##%%odbiorca%%=' + IsNull(@Odbiorca_Kod, '') + '%%podstawiony%%=' + @KodImportowanego + '##\'
 END
 INSERT INTO CDN.SchematPlatnosci
 (
 SPL_PodmiotId,
 SPL_PodmiotTyp,
 SPL_OdbPodmiotId,
 SPL_OdbPodmiotTyp,
 SPL_FplId,
 SPL_BnaId,
 SPL_Rodzaj,
 SPL_Kwota,
 SPL_Procent,
 SPL_RachunekNr,
 SPL_IBAN,
 SPL_LiczbaPorz,
 SPL_Reszta,
 SPL_OpeZalID,
 SPL_StaZalId,
 SPL_TS_Zal,
 SPL_OpeModID,
 SPL_StaModId,
 SPL_TS_Mod
 )
 VALUES
 (
 @DokId,
 3,
 @OdbID,
 @Odbiorca_Typ,
 @FPlId,
 @BNaId,
 0,
 @SPL_Kwota,
 @SPL_Procent,
 @SPL_RachunekNr,
 @SPL_IBAN,
 @SPL_LiczbaPorz,
 @SPL_Reszta,
 NULL,
 NULL,
 GETDATE(),
 NULL,
 NULL,
 GETDATE()
 )
END
