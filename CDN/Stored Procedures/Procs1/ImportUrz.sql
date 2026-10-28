CREATE PROCEDURE CDN.ImportUrz
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@Urz_ImportRowId nvarchar(36),
@Urz_Akronim nvarchar(20),
@Urz_TypUrzedu smallint,
@Urz_Nazwa1 nvarchar(50),
@Urz_Nazwa2 nvarchar(50),
@Urz_Kraj nvarchar(40),
@Urz_Wojewodztwo nvarchar(40),
@Urz_Powiat nvarchar(40),
@Urz_Gmina nvarchar(40),
@Urz_KodPocztowy nvarchar(10),
@Urz_Poczta nvarchar(40),
@Urz_Miasto nvarchar(40),
@Urz_Ulica nvarchar(40),
@Urz_NrDomu nvarchar(10),
@Urz_NrLokalu nvarchar(10),
@Urz_Adres2 nvarchar(40),
@Urz_Telefon nvarchar(20),
@Urz_Fax nvarchar(20),
@Urz_URL nvarchar(254),
@Urz_NieRozliczac tinyint,
@Urz_Kod nvarchar(40),
@Urz_Email nvarchar(40),
@Kat_KodSzczegol nvarchar(20),
@Kat_ImportRowId nvarchar(36),
@Urz_Nieaktywny tinyint,
@ZrdId nvarchar(5),
@OpeId int,
@SlowId int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 DECLARE @KatId int,
   @TmpAkr nvarchar(20)
 DECLARE @OperationType INT
 SET @OperationType = 0
 SET @Warnings = ''
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
 IF(SELECT Fir_Wartosc
  FROM CDN.Firma
  WHERE Fir_Numer = 2) = 1
 BEGIN
   SET @TmpAkr = @Urz_Akronim
   SET @TmpAkr = REPLACE(REPLACE(REPLACE(REPLACE(@TmpAkr, ',', '.'), ' ', '.'), '-', '.'), '''', '.')
   IF CHARINDEX('.', @TmpAkr) <> 0
    --SET @Warnings = @Warnings + 'Akronim zawiera znaki specjalne.\'
    SET @Warnings = @Warnings + '##OPT33152##\'
 END
 IF((SELECT count(*)
  FROM CDN.Urzedy
  WHERE ((IsNull(@Urz_ImportRowId, '') <> '' AND Urz_ImportRowId = @Urz_ImportRowId) OR Urz_TypUrzedu = @Urz_TypUrzedu AND Urz_Akronim = @Urz_Akronim)
    OR (IsNull(@Urz_ImportRowId, '') = '' AND Urz_TypUrzedu = @Urz_TypUrzedu AND Urz_Akronim = @Urz_Akronim)) = 0)
 BEGIN
  INSERT INTO CDN.Urzedy
  (
  Urz_ImportRowId,
  Urz_Akronim,
  Urz_TypUrzedu,
  Urz_Nazwa1,
  Urz_Nazwa2,
  Urz_Kraj,
  Urz_Wojewodztwo,
  Urz_Powiat,
  Urz_Gmina,
  Urz_KodPocztowy,
  Urz_Poczta,
  Urz_Miasto,
  Urz_Ulica,
  Urz_NrDomu,
  Urz_NrLokalu,
  Urz_Adres2,
  Urz_Telefon,
  Urz_Fax,
  Urz_EMail,
  Urz_URL,
  Urz_TS_Mod,
  Urz_TS_Zal,
  Urz_Standardowy,
  Urz_NieRozliczac,
  Urz_KatId,
  Urz_Kod,
  Urz_Nieaktywny,
  Urz_OpeModId,
  Urz_OpeModKod,
  Urz_OpeModNazwisko,
  Urz_OpeZalId,
  Urz_OpeZalKod,
  Urz_OpeZalNazwisko,
  Urz_TS_Export,
  Urz_ImportAppId
  )
  VALUES
  (
  @Urz_ImportRowId,
  @Urz_Akronim,
  @Urz_TypUrzedu,
  @Urz_Nazwa1,
  @Urz_Nazwa2,
  @Urz_Kraj,
  @Urz_Wojewodztwo,
  @Urz_Powiat,
  @Urz_Gmina,
  @Urz_KodPocztowy,
  @Urz_Poczta,
  @Urz_Miasto,
  @Urz_Ulica,
  @Urz_NrDomu,
  @Urz_NrLokalu,
  @Urz_Adres2,
  @Urz_Telefon,
  @Urz_Fax,
  ISNULL(@Urz_Email,''),
  @Urz_URL,
  GETDATE(),
  GETDATE(),
  CASE @Urz_TypUrzedu WHEN 2 THEN 1 ELSE 0 END,
  @Urz_NieRozliczac,
  @KatId,
  @Urz_Kod,
  IsNull(@Urz_Nieaktywny, 0),
  @OpeId,
  @OpeModKod,
  @OpeModNazwisko,
  @OpeId,
  @OpeModKod,
  @OpeModNazwisko,
  GETDATE(),
  @ZrdId
  )
  SET @SlowId = SCOPE_IDENTITY()
  SET @OperationType = 1 -- OptimaOperationType_Dodanie
 END ELSE IF( @OnlyNew <> 1)
 BEGIN
  UPDATE CDN.Urzedy
  SET
  Urz_ImportRowId = @Urz_ImportRowId,
  Urz_Akronim = @Urz_Akronim,
  Urz_TypUrzedu = @Urz_TypUrzedu,
  Urz_Nazwa1 = @Urz_Nazwa1,
  Urz_Nazwa2 = @Urz_Nazwa2,
  Urz_Kraj = @Urz_Kraj,
  Urz_Wojewodztwo = @Urz_Wojewodztwo,
  Urz_Powiat = @Urz_Powiat,
  Urz_Gmina = @Urz_Gmina,
  Urz_KodPocztowy = @Urz_KodPocztowy,
  Urz_Poczta = @Urz_Poczta,
  Urz_Miasto = @Urz_Miasto,
  Urz_Ulica = @Urz_Ulica,
  Urz_NrDomu = @Urz_NrDomu,
  Urz_NrLokalu = @Urz_NrLokalu,
  Urz_Adres2 = @Urz_Adres2,
  Urz_Telefon = @Urz_Telefon,
  Urz_Fax = @Urz_Fax,
  Urz_URL = @Urz_URL,
  Urz_TS_Mod = GETDATE(),
  Urz_NieRozliczac = @Urz_NieRozliczac,
  Urz_KatId = IsNull(@KatId, Urz_KatId),
  Urz_Kod = @Urz_Kod,
  Urz_Nieaktywny = IsNull(@Urz_Nieaktywny, Urz_Nieaktywny),
  Urz_Email = CASE WHEN ISNULL(LEN(@Urz_Email),'') = 0 THEN Urz_Email ELSE @Urz_Email END,
  Urz_OpeModId = @OpeId,
  Urz_OpeModKod = @OpeModKod,
  Urz_OpeModNazwisko = @OpeModNazwisko
  WHERE ((IsNull(@Urz_ImportRowId, '') <> '' AND Urz_ImportRowId = @Urz_ImportRowId) OR Urz_TypUrzedu = @Urz_TypUrzedu AND Urz_Akronim = @Urz_Akronim)
    OR (IsNull(@Urz_ImportRowId, '') = '' AND Urz_TypUrzedu = @Urz_TypUrzedu AND Urz_Akronim = @Urz_Akronim)
  SELECT @SlowId = Urz_UrzId
  FROM CDN.Urzedy
  WHERE Urz_ImportRowId = @Urz_ImportRowId
  SET @OperationType = 2 -- OptimaOperationType_Modyfikacja
 END
 ELSE
  RAISERROR('##OPT33041##', 16, 1) --RAISERROR('Taki zapis już istnieje. Element nie został dodany', 16, 1)
 IF @OperationType <> 0
 BEGIN
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 1105, -- OptimaObjectType_Urzad
    @ObiektSubTyp = 0,
    @ObiektID = @SlowID,
    @ObiektNazwa = @Urz_Akronim,
    @OperacjaTyp = @OperationType,
    @Opis = '' -- @Urz_Nazwa1
  IF NOT EXISTS (SELECT * FROM cdn.UrzRachunki WHERE URa_UrzId = @SlowId AND URa_Lp = -1 AND URa_PraID Is NULL)
   EXEC CDN.DodajRachunekPodatkowyFirmy @SlowId
 END
END
