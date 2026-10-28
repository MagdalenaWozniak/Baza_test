CREATE PROCEDURE CDN.ImportKntRach
@SlowId int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@FPl_Nazwa nvarchar(20),
@FPl_ImportRowId nvarchar(36),
@BNa_Numer nvarchar(20),
@BNa_ImportRowId nvarchar(36),
@Spl_Opis nvarchar(50),
@Spl_Reszta tinyint,
@Spl_LiczbaPorz int,
@Spl_IBAN tinyint,
@Spl_RachunekNr nvarchar(51),
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 -- obsługa pominięcia importu, jeżeli był nr konta w sekcji <ADRES> na kontrahencie
 --IF EXISTS (SELECT * FROM CDN.SchematPlatnosci WHERE @Spl_RachunekNr = Spl_RachunekNr AND Spl_PodmiotId = @SlowId AND Spl_PodmiotTyp=1)
 --BEGIN
 -- UPDATE CDN.SchematPlatnosci SET SPL_Opis = @SPL_Opis
 -- WHERE @Spl_RachunekNr = Spl_RachunekNr AND Spl_PodmiotId = @SlowId AND Spl_PodmiotTyp=1
 -- return;
 --END
 DECLARE @KntKod NVARCHAR(20)
 SELECT @KntKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @SlowId
 IF (
  EXISTS(SELECT * FROM CDN.SchematPlatnosci WHERE SPL_PodmiotTyp = 1 AND SPL_PodmiotID = @SlowID AND
   CASE WHEN LEN(Spl_RachunekNr) >=2 AND UPPER(SUBSTRING(Spl_RachunekNr, 1, 2)) = 'PL' THEN REPLACE(REPLACE(SUBSTRING(Spl_RachunekNr, 3, LEN(Spl_RachunekNr)-2), '-', ''), ' ', '') ELSE REPLACE(REPLACE(Spl_RachunekNr, '-', ''), ' ', '') END
   =
   CASE WHEN LEN(@Spl_RachunekNr) >=2 AND UPPER(SUBSTRING(@Spl_RachunekNr, 1, 2)) = 'PL' THEN REPLACE(REPLACE(SUBSTRING(@Spl_RachunekNr, 3, LEN(@Spl_RachunekNr)-2), '-', ''), ' ', '') ELSE REPLACE(REPLACE(@Spl_RachunekNr, '-', ''), ' ', '') END)
  )
 BEGIN
  --Kontrahent %[knt] posiada już rachunek o numerze %[nrach]. Rachunek kontrahenta nie został zaimportowany.
  --SET @Warnings = '##OPT34896##%%knt%%=' + IsNull(@KntKod, '') + '%%nrach%%=' + IsNull(@Spl_RachunekNr, '') + '##\';
  RETURN
 END
 DECLARE @BNa_Id INT, @Fpl_Id INT;
 SET @BNa_Id = NULL;
 SET @Fpl_Id = NULL;
 SET @Warnings = '';
 SELECT @BNa_Id = BNa_BNaId FROM CDN.BnkNazwy WHERE BNa_ImportRowId = @BNa_ImportRowId
 IF @BNa_Id is NULL SELECT @BNa_Id = BNa_BNaId FROM CDN.BnkNazwy WHERE BNa_Numer = @BNa_Numer
 IF (@BNa_Id is NULL AND IsNull(@BNa_Numer, '') <> '')
  --SET @Warnings = 'Brak banku ' + IsNull(@BNa_Numer, '') + ' w bazie docelowej. Bank nie został zaimportowany.\'
  SET @Warnings = '##OPT33198##%%nrb%%=' +  IsNull(@BNa_Numer, '') + '##\';
 SELECT @Fpl_Id = Fpl_FplID FROM CDN.FormyPlatnosci WHERE @FPl_ImportRowId=Fpl_ImportRowId
 IF @Fpl_Id IS NULL
  SELECT @Fpl_Id = Fpl_FplID FROM CDN.FormyPlatnosci WHERE @Fpl_Nazwa = Fpl_Nazwa
 IF (@Fpl_Id is NULL)
 BEGIN
  --SET @Warnings = @Warnings + 'Brak formy platności ' + IsNull(@FPl_Nazwa, '') + ' w bazie docelowej.\'
  SET @Warnings = @Warnings + '##OPT33204##%%nazwa%%=' +  IsNull(@FPl_Nazwa, '') + '##\';
  RETURN
 END
 ELSE --(@Fpl_Id is NOT NULL)
 BEGIN
  IF IsNull(@Spl_RachunekNr, '') = ''
  BEGIN
   --SET @Warnings = @Warnings + 'Nie podano numeru rachunku.\'
   SET @Warnings = @Warnings + '##OPT33205##\';
   RETURN
  END
 END
 DECLARE @JestJuzDomyslny TINYINT
 SELECT @JestJuzDomyslny = CASE WHEN EXISTS (SELECT * FROM cdn.SchematPlatnosci WHERE SPL_PodmiotTyp = 1 AND Spl_PodmiotId = @SlowId AND SPl_Reszta = 1) THEN 1 ELSE 0 END
 IF @JestJuzDomyslny = 1
  SELECT @Spl_Reszta = 0
 IF (@Spl_Reszta > 0) -- aktualizacja tabeli Kontrahenci - dodanie wpisu o domyślnym rachunku do kontrahenta
 BEGIN
  UPDATE CDN.Kontrahenci SET Knt_BNaID=@BNa_Id, Knt_RachunekNr=@Spl_RachunekNr, Knt_IBAN=@Spl_IBAN WHERE Knt_KntID=@SlowId
  EXEC CDN.RejestrOperacjiZapiszKontrahenta
   @ID = @SlowID,
   @Kod = '',
   @TypOperacji = 2
 END
 INSERT INTO CDN.SchematPlatnosci
 (
  Spl_PodmiotId,
  Spl_PodmiotTyp,
  Spl_FplID,
  Spl_BnaID,
  Spl_Rodzaj,
  Spl_Kwota,
  Spl_Procent,
  Spl_RachunekNr,
  Spl_IBAN,
  Spl_LiczbaPorz,
  Spl_Reszta,
  Spl_OpeZalID,
  Spl_OpeZalKod,
  Spl_OpeZalNazwisko,
  Spl_StaZalID,
  Spl_TS_Zal,
  Spl_OpeModId,
  Spl_OpeModKod,
  Spl_OpeModNazwisko,
  Spl_StaModId,
  Spl_TS_Mod,
  Spl_Opis,
  Spl_OdbPodmiotTyp,
  Spl_OdbPodmiotID
 )
 VALUES
 (
  @SlowId,
  1,
  @Fpl_Id,
  @BNa_Id,
  0,
  0,
  100, -- procent
  @Spl_RachunekNr,
  @Spl_IBAN,
  @Spl_LiczbaPorz,
  @Spl_Reszta,
  @OpeID,
  @OpeModKod,
  @OpeModNazwisko,
  NULL,
  GETDATE(),
  @OpeID,
  @OpeModKod,
  @OpeModNazwisko,
  NULL,
  GETDATE(),
  @Spl_Opis,
  NULL,
  NULL
 )
 SELECT @IdParam = SCOPE_IDENTITY()
