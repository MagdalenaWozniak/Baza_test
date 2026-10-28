CREATE PROCEDURE cdn.DodajPierwszyWpisHistoriiPieczatkiJSFirmy(@OpeID INT, @StaID INT, @OpeKod VARCHAR(20), @OpeNazwisko NVARCHAR(50))
AS
BEGIN
 IF EXISTS (SELECT * FROM cdn.PieczatkiJS)
  RETURN
 DECLARE
  @Nazwa1   NVARCHAR(50),
  @Nazwa2   NVARCHAR(50),
  @Nazwa3   NVARCHAR(512),
  @NipKraj  VARCHAR(2),
  @NipE     NVARCHAR(20),
  @Regon     NVARCHAR(20),
  @Kraj     NVARCHAR(40),
  @KrajISO    NVARCHAR(2),
  @Wojewodztwo NVARCHAR(40),
  @Powiat   NVARCHAR(40),
  @Gmina   NVARCHAR(40),
  @KodGminy  VARCHAR(7),
  @Ulica   NVARCHAR(40),
  @NrDomu   NVARCHAR(10),
  @NrLokalu  NVARCHAR(10),
  @Miasto   NVARCHAR(40),
  @KodP VARCHAR(10),
  @Poczta   NVARCHAR(40),
  @Telefon  VARCHAR(20),
  @Email   VARCHAR(127),
  @URL   VARCHAR(254)
 DECLARE @dtNow DATETIME
 SELECT @dtNow = GETDATE()
 DECLARE @JSPodlega INT
 IF EXISTS(SELECT * FROM cdn.Firma WHERE Fir_Numer = 2246)
  SELECT @JSPodlega = IsNull(CONVERT(INT, Fir_Wartosc), 0) FROM cdn.Firma WHERE Fir_Numer = 2246
 ELSE
  SELECT @JSPodlega = 0
 IF @JSPodlega = 0
  RETURN
 SELECT @Nazwa1 = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2247
 SELECT @Nazwa2 = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2248
 SELECT @Nazwa3 = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2249
 SELECT @NipKraj = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2250
 SELECT @NipE = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2251
 SELECT @Regon = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2252
 SELECT @Kraj = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2253
 SELECT @KrajISO = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2254
 SELECT @Wojewodztwo = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2255
 SELECT @Powiat = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2256
 SELECT @Gmina = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2257
 SELECT @KodGminy = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2258
 SELECT @Miasto = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2262
 SELECT @Ulica = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2259
 SELECT @NrDomu = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2260
 SELECT @NrLokalu = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2261
 SELECT @KodP = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2263
 SELECT @Poczta = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2264
 SELECT @Telefon = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2265
 SELECT @Email = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2266
 SELECT @URL = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 3088
 DECLARE @DaneJSUzupelnione TINYINT
 IF IsNull(@Nazwa1, '') <> '' OR IsNull(@Nazwa2, '') <> '' OR IsNull(@Nazwa3, '') <> '' OR IsNull(@NipKraj, '') <> '' OR IsNull(@NipE, '') <> '' OR IsNull(@Regon, '') <> ''
  OR IsNull(@Wojewodztwo, '') <> '' OR IsNull(@Powiat, '') <> '' OR IsNull(@Gmina, '') <> '' OR IsNull(@KodGminy, '') <> '' OR IsNull(@Miasto, '') <> '' OR IsNull(@Ulica, '') <> '' OR IsNull(@NrDomu, '') <> '' OR IsNull(@NrLokalu, '') <> '' OR IsNull(@KodP, '') <> '' OR IsNull(@Poczta, '') <> ''
  OR IsNull(@Telefon, '') <> '' OR IsNull(@Email, '') <> '' OR IsNull(@URL, '') <> ''
  SELECT @DaneJSUzupelnione = 1
 ELSE
  SELECT @DaneJSUzupelnione = 0
 IF @DaneJSUzupelnione = 1
 BEGIN
  SET IDENTITY_INSERT cdn.PieczatkiJS ON
  ALTER TABLE [CDN].[PieczatkiJS] DISABLE TRIGGER ALL
  INSERT INTO [CDN].[PieczatkiJS]
   (PCJS_PCJSID,
   PCJS_DataOd, PCJS_DataDo,
   PCJS_Nazwa1, PCJS_Nazwa2, PCJS_Nazwa3,
   PCJS_NipKraj, PCJS_NipE, PCJS_Regon,
   PCJS_Kraj, PCJS_KrajISO, PCJS_Wojewodztwo, PCJS_Powiat, PCJS_Gmina, PCJS_KodGminy, PCJS_Ulica, PCJS_NrDomu, PCJS_NrLokalu, PCJS_Miasto, PCJS_KodP, PCJS_Poczta,
   PCJS_Telefon, PCJS_Email, PCJS_URL,
   PCJS_ImportRowId,
   PCJS_OpeZalId, PCJS_StaZalId, PCJS_TS_Zal, PCJS_OpeModId, PCJS_StaModId, PCJS_TS_Mod, PCJS_OpeZalKod, PCJS_OpeZalNazwisko, PCJS_OpeModKod, PCJS_OpeModNazwisko)
   VALUES(
   1,
   CONVERT(DATETIME, '2017-01-01 00:00:00', 120), CONVERT(DATETIME, '2999-12-31 00:00:00', 120),
   @Nazwa1, @Nazwa2, @Nazwa3,
   @NipKraj, @NipE, @Regon,
   @Kraj, @KrajISO, @Wojewodztwo, @Powiat, @Gmina, @KodGminy, @Ulica, @NrDomu, @NrLokalu, @Miasto, @KodP, @Poczta,
   @Telefon, @Email, @URL,
   NewId(),
   @OpeID, @StaID, @dtNow, @OpeID, @StaID, @dtNow, @OpeKod, @OpeNazwisko, @OpeKod, @OpeNazwisko)
  ALTER TABLE [CDN].[PieczatkiJS] ENABLE TRIGGER ALL
  SET IDENTITY_INSERT cdn.PieczatkiJS OFF
  DECLARE @dataOd DATETIME
  DECLARE @dataDo DATETIME
  SELECT @dataOd = CONVERT(DATETIME, '2017-01-01 00:00:00', 120)
  SELECT @dataDo = CONVERT(DATETIME, '2999-12-31 00:00:00', 120)
  DECLARE @dataStr VARCHAR(64)
  SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(1, @dataOd, @dataDo)
  EXEC [CDN].[RejestrOperacjiDodaj]
   @ObiektTyp = 5001, -- OptimaObjectType_PieczatkaJS
   @ObiektSubTyp = 0,
   @ObiektID = 1,
   @ObiektNazwa = @dataStr,
   @OperacjaTyp = 1, -- OptimaOperationType_Dodanie
   @Opis = ''
  IF @JSPodlega <> 0
  BEGIN
   ALTER TABLE cdn.TraNag DISABLE TRIGGER ALL
   UPDATE cdn.TraNag SET TrN_PCJSID = 1 WHERE TrN_DataWys >= CONVERT(DATETIME, '2017-01-01 00:00:00', 120)
   ALTER TABLE cdn.TraNag ENABLE TRIGGER ALL
  END
 END
END
