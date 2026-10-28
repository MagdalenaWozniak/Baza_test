CREATE PROCEDURE cdn.CdnFirmaDanePieczatki2AktualnaPieczatka(@DodajPierwszyWpis TINYINT, @OpeID INT, @StaID INT, @OpeKod VARCHAR(20), @OpeNazwisko NVARCHAR(50))
AS
BEGIN
 IF @DodajPierwszyWpis <> 0 AND EXISTS (SELECT * FROM cdn.Pieczatki)
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
  @Miasto   NVARCHAR(40),
  @Ulica   NVARCHAR(40),
  @NrDomu   NVARCHAR(10),
  @NrLokalu  NVARCHAR(10),
  @KodP   VARCHAR(10),
  @Poczta   NVARCHAR(40),
  @Telefon  VARCHAR(20),
  @Email   VARCHAR(127),
  @URL   VARCHAR(254),
  @KRS_Sad  NVARCHAR(100),
  @KRS_Numer  NVARCHAR(10),
  @KRS_KapitalZak NVARCHAR(20),
  @KRS_KapitalWpl NVARCHAR(20),
  @Opis   NVARCHAR(50),
  @ILNGLNWlasny VARCHAR(13),
  @ILNGLNCentrali VARCHAR(13),
  @PUESC   NVARCHAR(50),
  @BDO   NVARCHAR(20)
 DECLARE @dtNow DATETIME
 SELECT @dtNow = GETDATE()
 SELECT @Nazwa1 = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1156
 SELECT @Nazwa2 = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1157
 SELECT @Nazwa3 = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2166
 SELECT @NipKraj = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1167
 SELECT @NipE = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1101
 SELECT @Regon = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1118
 SELECT @Kraj = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1145
 SELECT @KrajISO = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1169
 SELECT @Wojewodztwo = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1146
 SELECT @Powiat = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1147
 SELECT @Gmina = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1148
 SELECT @KodGminy = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1168
 SELECT @Miasto = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1152
 SELECT @Ulica = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1149
 SELECT @NrDomu = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1150
 SELECT @NrLokalu = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1151
 SELECT @KodP = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1153
 SELECT @Poczta = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1154
 SELECT @Telefon = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1155
 SELECT @Email = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2221
 SELECT @URL = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 3087
 SELECT @KRS_Sad = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1171
 SELECT @KRS_Numer = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1172
 SELECT @KRS_KapitalZak = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1173
 SELECT @KRS_KapitalWpl = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1174
 SELECT @Opis = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1158
 SELECT @ILNGLNWlasny = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1165
 SELECT @ILNGLNCentrali = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1166
 SELECT @PUESC = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 3080
 SELECT @BDO = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 1881
 DECLARE @dataOd DATETIME
 DECLARE @dataDo DATETIME
 DECLARE @dataStr VARCHAR(64)
 DECLARE @pcID INT
 SELECT @pcID = PC_PCID FROM cdn.Pieczatki WHERE PC_DataDo = CONVERT(DATETIME, '2999-12-31 00:00:00', 120)
 IF @pcID Is Null
 BEGIN
  SET IDENTITY_INSERT cdn.Pieczatki ON
  ALTER TABLE [CDN].[Pieczatki] DISABLE TRIGGER ALL
  INSERT INTO [CDN].[Pieczatki]
   (PC_PCID,
   PC_DataOd, PC_DataDo,
   PC_Nazwa1, PC_Nazwa2, PC_Nazwa3,
   PC_NipKraj, PC_NipE, PC_Regon,
   PC_Kraj, PC_KrajISO, PC_Wojewodztwo, PC_Powiat, PC_Gmina, PC_KodGminy, PC_Miasto, PC_Ulica, PC_NrDomu, PC_NrLokalu, PC_KodP, PC_Poczta,
   PC_Telefon, PC_Email, PC_URL,
   PC_KRS_Sad, PC_KRS_Numer, PC_KRS_KapitalZak, PC_KRS_KapitalWpl, PC_Opis, PC_ILNGLNWlasny, PC_ILNGLNCentrali, PC_PUESC, PC_BDO,
   PC_ImportRowId,
   PC_OpeZalId, PC_StaZalId, PC_TS_Zal, PC_OpeModId, PC_StaModId, PC_TS_Mod, PC_OpeZalKod, PC_OpeZalNazwisko, PC_OpeModKod, PC_OpeModNazwisko)
   VALUES(
   1,
   CONVERT(DATETIME, '1900-01-01 00:00:00', 120), CONVERT(DATETIME, '2999-12-31 00:00:00', 120),
   @Nazwa1, @Nazwa2, @Nazwa3,
   @NipKraj, @NipE, @Regon,
   @Kraj, @KrajISO, @Wojewodztwo, @Powiat, @Gmina, @KodGminy, @Miasto, @Ulica, @NrDomu, @NrLokalu, @KodP, @Poczta,
   @Telefon, @Email, @URL,
   @KRS_Sad, @KRS_Numer, @KRS_KapitalZak, @KRS_KapitalWpl, @Opis, @ILNGLNWlasny, @ILNGLNCentrali, @PUESC, @BDO,
   NewId(),
   @OpeID, @StaID, @dtNow, @OpeID, @StaID, @dtNow, @OpeKod, @OpeNazwisko, @OpeKod, @OpeNazwisko)
  ALTER TABLE [CDN].[Pieczatki] ENABLE TRIGGER ALL
  SET IDENTITY_INSERT cdn.Pieczatki OFF
  UPDATE cdn.DaneBinarne SET DAB_TwAID = 1 WHERE DAB_Typ = 13
  SELECT @dataOd = CONVERT(DATETIME, '1900-01-01 00:00:00', 120)
  SELECT @dataDo = CONVERT(DATETIME, '2999-12-31 00:00:00', 120)
  SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(1, @dataOd, @dataDo)
  EXEC [CDN].[RejestrOperacjiDodaj]
   @ObiektTyp = 5000, -- OptimaObjectType_Pieczatka
   @ObiektSubTyp = 0,
   @ObiektID = 1,
   @ObiektNazwa = @dataStr,
   @OperacjaTyp = 1, -- OptimaOperationType_Dodanie
   @Opis = ''
  ALTER TABLE cdn.TraNag DISABLE TRIGGER ALL
  UPDATE cdn.TraNag SET TrN_PCID = 1
  ALTER TABLE cdn.TraNag ENABLE TRIGGER ALL
 END
 ELSE
 BEGIN
  ALTER TABLE cdn.Pieczatki DISABLE TRIGGER ALL
  UPDATE cdn.Pieczatki
   SET
   PC_Nazwa1 = @Nazwa1,
   PC_Nazwa2 = @Nazwa2,
   PC_Nazwa3 = @Nazwa3,
   PC_NipKraj = @NipKraj,
   PC_NipE = @NipE,
   PC_Regon = @Regon,
   PC_Kraj = @Kraj,
   PC_KrajISO = @KrajISO,
   PC_Wojewodztwo = @Wojewodztwo,
   PC_Powiat = @Powiat,
   PC_Gmina = @Gmina,
   PC_KodGminy = @KodGminy,
   PC_Miasto = @Miasto,
   PC_Ulica = @Ulica,
   PC_NrDomu = @NrDomu,
   PC_NrLokalu = @NrLokalu,
   PC_KodP = @KodP,
   PC_Poczta = @Poczta,
   PC_Telefon = @Telefon,
   PC_Email = @Email,
   PC_URL = @URL,
   PC_KRS_Sad = @KRS_Sad,
   PC_KRS_Numer = @KRS_Numer,
   PC_KRS_KapitalZak = @KRS_KapitalZak,
   PC_KRS_KapitalWpl = @KRS_KapitalWpl,
   PC_Opis = @Opis,
   PC_ILNGLNWlasny = @ILNGLNWlasny,
   PC_ILNGLNCentrali = @ILNGLNCentrali,
   PC_PUESC = @PUESC,
   PC_BDO = @BDO,
   PC_OpeModId = @OpeID,
   PC_StaModId = @StaID,
   PC_TS_Mod = @dtNow,
   PC_OpeModKod = @OpeKod,
   PC_OpeModNazwisko = @OpeNazwisko
  WHERE PC_PCID = @pcID
  ALTER TABLE cdn.Pieczatki ENABLE TRIGGER ALL
  SELECT @dataOd = PC_DataOd, @dataDo = PC_DataOd FROM cdn.Pieczatki WHERE PC_PCID = @pcID
  SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@pcID, @dataOd, @dataDo)
  EXEC [CDN].[RejestrOperacjiDodaj]
   @ObiektTyp = 5000, -- OptimaObjectType_Pieczatka
   @ObiektSubTyp = 0,
   @ObiektID = 1,
   @ObiektNazwa = @dataStr,
   @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
   @Opis = ''
 END
END
