CREATE TABLE [CDN].[PieczatkiJS] (
    [PCJS_PCJSID]         INT            IDENTITY (1, 1) NOT NULL,
    [PCJS_DataOd]         DATETIME       NOT NULL,
    [PCJS_DataDo]         DATETIME       NOT NULL,
    [PCJS_Aktualna]       AS             (case when [PCJS_DataDo]=CONVERT([datetime],'2999-12-31',(120)) then (1) else (0) end),
    [PCJS_Nazwa1]         NVARCHAR (50)  NULL,
    [PCJS_Nazwa2]         NVARCHAR (50)  NULL,
    [PCJS_Nazwa3]         NVARCHAR (512) NULL,
    [PCJS_NipKraj]        VARCHAR (2)    NULL,
    [PCJS_NipE]           NVARCHAR (20)  NULL,
    [PCJS_Regon]          NVARCHAR (20)  NULL,
    [PCJS_Kraj]           NVARCHAR (40)  NULL,
    [PCJS_KrajISO]        NVARCHAR (2)   NULL,
    [PCJS_Wojewodztwo]    NVARCHAR (40)  NULL,
    [PCJS_Powiat]         NVARCHAR (40)  NULL,
    [PCJS_Gmina]          NVARCHAR (40)  NULL,
    [PCJS_KodGminy]       VARCHAR (7)    NULL,
    [PCJS_Miasto]         NVARCHAR (40)  NULL,
    [PCJS_Ulica]          NVARCHAR (40)  NULL,
    [PCJS_NrDomu]         NVARCHAR (10)  NULL,
    [PCJS_NrLokalu]       NVARCHAR (10)  NULL,
    [PCJS_KodP]           VARCHAR (10)   NULL,
    [PCJS_Poczta]         NVARCHAR (40)  NULL,
    [PCJS_UlicaNrDomLok]  AS             (case when isnull([PCJS_Ulica],'')<>'' then case when isnull([PCJS_NrLokalu],'')<>'' then ((([PCJS_Ulica]+' ')+isnull([PCJS_NrDomu],''))+'/')+[PCJS_NrLokalu] else ([PCJS_Ulica]+' ')+isnull([PCJS_NrDomu],'') end else case when isnull([PCJS_NrLokalu],'')<>'' then (isnull([PCJS_NrDomu],'')+'/')+[PCJS_NrLokalu] else isnull([PCJS_NrDomu],'') end end),
    [PCJS_Telefon]        VARCHAR (20)   NULL,
    [PCJS_Email]          VARCHAR (127)  NULL,
    [PCJS_URL]            VARCHAR (254)  NULL,
    [PCJS_AktDok]         TINYINT        NULL,
    [PCJS_TS_Export]      DATETIME       NULL,
    [PCJS_ImportAppId]    VARCHAR (5)    NULL,
    [PCJS_ImportRowId]    VARCHAR (36)   NULL,
    [PCJS_OpeZalId]       INT            NULL,
    [PCJS_StaZalId]       INT            NULL,
    [PCJS_TS_Zal]         DATETIME       NOT NULL,
    [PCJS_OpeModId]       INT            NULL,
    [PCJS_StaModId]       INT            NULL,
    [PCJS_TS_Mod]         DATETIME       NOT NULL,
    [PCJS_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_PCJS_OpeModKod] DEFAULT ('') NOT NULL,
    [PCJS_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_PCJS_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [PCJS_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_PCJS_OpeZalKod] DEFAULT ('') NOT NULL,
    [PCJS_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_PCJS_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [PCJS_Primary] PRIMARY KEY CLUSTERED ([PCJS_PCJSID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [PCJSChron]
    ON [CDN].[PieczatkiJS]([PCJS_DataOd] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PCJSGUID]
    ON [CDN].[PieczatkiJS]([PCJS_ImportRowId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.PieczatkiJS_Update_Trigger
  ON CDN.PieczatkiJS
  FOR UPDATE
AS
 Set NoCount On
 If Update (PCJS_DataOD) Or Update (PCJS_DataDo)
 Begin
  If Exists (Select * From inserted WHERE inserted.PCJS_DataDo < inserted.PCJS_DataOd)
  Begin
   RAISERROR('##OPT32360##', 16, 1) -- RaisError ('Niepoprawny zakres dat pieczątki firmy - jednostki samorządowej: Data "DO" nie może być wcześniejsza niż data "DO".', 16,1)
   RollBack Tran
   Return
  End
  If Exists (Select * From inserted WHERE inserted.PCJS_DataOd > GETDATE())
  Begin
   RAISERROR('##OPT32361##', 16, 1) -- RaisError ('Niepoprawny zakres dat pieczątki firmy - jednostki samorządowej: Data "OD" nie może być późniejsza niż data bieżąca.', 16,1)
   RollBack Tran
   Return
  End
  If Exists (Select * From inserted WHERE inserted.PCJS_DataDo > GETDATE() - 1 AND YEAR(inserted.PCJS_DataDo) < 2999)
  Begin
   RAISERROR('##OPT32362##', 16, 1) -- RaisError ('Niepoprawny zakres dat pieczątki: Data "DO" musi być wcześniejsza niż data bieżąca.', 16,1)
   RollBack Tran
   Return
  End
 End
  -- Aktualizacja danych w cdn.Firma na podstawie zmienionej pieczątki aktualnej
 IF EXISTS (SELECT * FROM inserted WHERE inserted.PCJS_DataDo = CONVERT(DATETIME, '2999-12-31 00:00:00.000', 120))
 BEGIN
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
   @URL   VARCHAR(254)
  SELECT @Nazwa1 = PCJS_Nazwa1, @Nazwa2 = PCJS_Nazwa2, @Nazwa3 = PCJS_Nazwa3, @NipKraj = PCJS_NipKraj, @NipE = PCJS_NipE, @Regon = PCJS_Regon,
   @Kraj = PCJS_Kraj, @KrajISO = PCJS_KrajISO, @Wojewodztwo = PCJS_Wojewodztwo, @Powiat = PCJS_Powiat, @Gmina = PCJS_Gmina, @KodGminy = PCJS_KodGminy, @Ulica = PCJS_Ulica, @NrDomu = PCJS_NrDomu, @NrLokalu = PCJS_NrLokalu, @Miasto = PCJS_Miasto, @KodP = PCJS_KodP, @Poczta = PCJS_Poczta,
   @Telefon = PCJS_Telefon, @Email = PCJS_Email, @URL = PCJS_URL
  FROM inserted WHERE inserted.PCJS_DataDo = CONVERT(DATETIME, '2999-12-31 00:00:00.000', 120)
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@Nazwa1, '') WHERE Fir_Numer = 2247
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@Nazwa2, '') WHERE Fir_Numer = 2248
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@Nazwa3, '') WHERE Fir_Numer = 2248
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@NipKraj, '') WHERE Fir_Numer = 2250
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@NipE, '') WHERE Fir_Numer = 2251
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@Regon, '') WHERE Fir_Numer = 2252
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@Kraj, '') WHERE Fir_Numer = 2253
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@KrajISO, '') WHERE Fir_Numer = 2254
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@Wojewodztwo, '') WHERE Fir_Numer = 2255
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@Powiat, '') WHERE Fir_Numer = 2256
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@Gmina, '') WHERE Fir_Numer = 2257
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@KodGminy, '') WHERE Fir_Numer = 2258
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@Ulica, '') WHERE Fir_Numer = 2259
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@NrDomu, '') WHERE Fir_Numer = 2260
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@NrLokalu, '') WHERE Fir_Numer = 2261
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@Miasto, '') WHERE Fir_Numer = 2262
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@KodP, '') WHERE Fir_Numer = 2263
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@Poczta, '') WHERE Fir_Numer = 2264
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@Telefon, '') WHERE Fir_Numer = 2264
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@Email, '') WHERE Fir_Numer = 2266
  UPDATE cdn.Firma SET Fir_Wartosc = IsNull(@URL, '') WHERE Fir_Numer = 3088
 END
  Set NoCount On

GO
CREATE TRIGGER CDN.PieczatkiJS_Delete_Trigger
  ON CDN.PieczatkiJS
  FOR DELETE
AS
SET NOCOUNT ON
-- Sprawdzenie, czy nie została skasowana kasa gotówkowa
 IF (SELECT COUNT(*) FROM deleted) > 1
 Begin
  RAISERROR('##OPT32357##', 16, 1) -- RaisError ('Nie można równocześnie usuwać wielu pieczątek firmy - jednostki samorządowej.', 16,1)
  RollBack Tran
  Return
 End
 IF EXISTS (SELECT * FROM cdn.TraNag WHERE TrN_PCJSID IN (SELECT deleted.PCJS_PCJSID FROM deleted))
 BEGIN
  RAISERROR('##OPT32358##', 16, 1) -- RAISERROR('Nie można usunąć pieczątki firmy - jednostki samorządowej powiązanej z dokumentem handlowo-magazynowym.', 16, 1)
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 END
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.PieczatkiJS_Insert_Trigger
  ON CDN.PieczatkiJS
  FOR INSERT
AS
 Set NoCount On
 IF (SELECT COUNT(*) FROM inserted) > 1
 Begin
  RAISERROR('##OPT32359##', 16, 1) -- RaisError ('Nie można równocześnie dodawać wielu pieczątek firmy - jednostki samorządowej.', 16,1)
  RollBack Tran
  Return
 End
 If Exists (Select * From inserted WHERE inserted.PCJS_DataDo < inserted.PCJS_DataOd)
 Begin
  RAISERROR('##OPT32360##', 16, 1) -- RaisError ('Niepoprawny zakres dat pieczątki firmy - jednostki samorządowej: Data "DO" nie może być wcześniejsza niż data "DO".', 16,1)
  RollBack Tran
  Return
 End
 If Exists (Select * From inserted WHERE inserted.PCJS_DataOd > GETDATE())
 Begin
  RAISERROR('##OPT32361##', 16, 1) -- RaisError ('Niepoprawny zakres dat pieczątki firmy - jednostki samorządowej: Data "OD" nie może być późniejsza niż data bieżąca.', 16,1)
  RollBack Tran
  Return
 End
 If Exists (Select * From inserted WHERE inserted.PCJS_DataDo > GETDATE() - 1 AND YEAR(inserted.PCJS_DataDo) < 2999)
 Begin
  RAISERROR('##OPT32362##', 16, 1) -- RaisError ('Niepoprawny zakres dat pieczątki firmy - jednostki samorządowej: Data "DO" musi być wcześniejsza niż data bieżąca.', 16,1)
  RollBack Tran
  Return
 End
 DECLARE @id INT,
   @dataOd DATETIME,
   @dataDo DATETIME,
   @OpeID INT,
   @StaID INT,
   @OpeKod VARCHAR(20),
   @OpeNazwisko NVARCHAR(50),
   @AktDok TINYINT
 SELECT TOP 1 @id = inserted.PCJS_PCJSID, @dataOd = inserted.PCJS_DataOd, @dataDo = inserted.PCJS_DataDo,
   @OpeID = PCJS_OpeZalId, @StaID = PCJS_StaZalId, @OpeKod = PCJS_OpeZalKod, @OpeNazwisko = PCJS_OpeZalNazwisko,
   @AktDok = PCJS_AktDok
  FROM inserted
 If Exists (Select * from cdn.PieczatkiJS WHERE PCJS_PCJSID<>@id AND @dataOd<=PCJS_DataOd AND @dataDo>=PCJS_DataDo)
 Begin
  RAISERROR('##OPT32362##', 16, 1) -- RaisError ('W podanym okresie zawiera się inna pieczątka firmy - jednostki samorządowej.', 16,1)
  RollBack Tran
  Return
 End
 DECLARE @dataStr VARCHAR(64)
 DECLARE @NewID INT
 SELECT @NewID = 0
 DECLARE @NewDataOd DATETIME,
   @NewDataDo DATETIME,
   @Data DATETIME
 IF @dataOd > CONVERT(DATETIME, '2017-01-01', 120) AND @dataDo = CONVERT(DATETIME, '2999-12-31', 120)
 BEGIN
     -- Trzeba wyeliminować zachodzenie na siebie okresów, np. mamy p1(2018-06-01, 2018-06-30) i dodajemy p2(2018-06-15, +oo) - w p1 trzeba przesunąć datę do z 06-30 na 06-14.
  DECLARE @actID INT
  DECLARE @dataOdAct DATETIME
  -- Nie szukamy tu, jak w zwykłej pieczątce pieczątki do +oo, bo tekiej może tu nie być. Ważne jest tylko sprawdzenie czy nie ma takiej, która datą do zachodzi na dodawaną pieczątkę.
  --SELECT TOP 1 @actID = PCJS_PCJSID, @dataOdAct = PCJS_DataOd FROM cdn.PieczatkiJS WHERE PCJS_PCJSID<>@id AND PCJS_DataDo = CONVERT(DATETIME, '2999-12-31', 120) ORDER BY PCJS_DataDo ASC
  SELECT TOP 1 @actID = PCJS_PCJSID, @dataOdAct = PCJS_DataOd FROM cdn.PieczatkiJS WHERE PCJS_PCJSID<>@id AND PCJS_DataDo > @dataOd ORDER BY PCJS_DataDo ASC
  IF @actID IS NOT NULL
  BEGIN
   UPDATE cdn.PieczatkiJS SET PCJS_DataDo = @dataOd - 1 WHERE PCJS_PCJSID = @actID
   SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@actID, @dataOdAct, @dataOd - 1)
   EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 5001, -- OptimaObjectType_PieczatkaJS
    @ObiektSubTyp = 0,
    @ObiektID = @actID,
    @ObiektNazwa = @dataStr,
    @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
    @Opis = ''
  END
 END
 ELSE IF @dataOd = CONVERT(DATETIME, '2017-01-01', 120) AND @dataDo < CONVERT(DATETIME, '2999-12-31', 120)
 BEGIN
  DECLARE @nextID INT
  SELECT TOP 1 @nextID = PCJS_PCJSID, @Data = PCJS_DataDo FROM cdn.PieczatkiJS WHERE PCJS_PCJSID<>@id AND @dataDo BETWEEN PCJS_DataOd AND PCJS_DataDo ORDER BY PCJS_DataDo ASC
  IF @nextID IS NOT NULL
  BEGIN
   UPDATE cdn.PieczatkiJS SET PCJS_DataOd = @dataDo + 1 WHERE PCJS_PCJSID = @nextID
   SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@nextID, @dataDo + 1, @Data)
   EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 5001, -- OptimaObjectType_PieczatkaJS
    @ObiektSubTyp = 0,
    @ObiektID = @nextID,
    @ObiektNazwa = @dataStr,
    @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
    @Opis = ''
  END
 END
 ELSE IF @dataOd > CONVERT(DATETIME, '2017-01-01', 120) AND @dataDo < CONVERT(DATETIME, '2999-12-31', 120)
 BEGIN
  DECLARE @prevID2 INT
  DECLARE @prevDataOd2 DATETIME
  DECLARE @prevDataDo2 DATETIME
  SELECT TOP 1 @prevID2 = PCJS_PCJSID, @prevDataOd2 = PCJS_DataOd, @prevDataDo2 = PCJS_DataDo FROM cdn.PieczatkiJS WHERE PCJS_PCJSID<>@id AND @dataOd BETWEEN PCJS_DataOd AND PCJS_DataDo ORDER BY PCJS_DataDo DESC
  DECLARE @nextID2 INT
  DECLARE @nextDataDo2 DATETIME
  SELECT TOP 1 @nextID2 = PCJS_PCJSID, @nextDataDo2 = PCJS_DataDo FROM cdn.PieczatkiJS WHERE PCJS_PCJSID<>@id AND @dataDo BETWEEN PCJS_DataOd AND PCJS_DataDo ORDER BY PCJS_DataDo ASC
  IF @prevID2 IS NOT NULL AND @nextID2 IS NOT NULL
  BEGIN
   -- zakres dat dodawanej pieczątki zawiera się w jednej lub dwóch istniejących pieczątkach (w więcej nie może, bo zawierałby w całości jakąś istniejącą pieczątkę)
   IF @prevID2 = @nextID2
   BEGIN
    -- zakres dat dodawanej pieczątki zawiera się w jednej istniejącej pieczątce
    DECLARE @overID INT
    SET @overID = @prevID2 -- = @nextID2
    DECLARE @overDataOd DATETIME
    SET @overDataOd = @prevDataOd2
    DECLARE @overDataDo DATETIME
    SET @overDataDo = @nextDataDo2
    IF @dataOd > @overDataOd AND @dataDo < @overDataDo
    BEGIN
     -- np. mamy pieczątkę (1.1.2018, 31.12.2018) i dodajemy (1.6.2018, 30.06.2018)
     -- Dodajemy pieczątkę z lewej strony, a na istniejącej zmieniamy datę Od
     DECLARE @dtNow DATETIME
     SELECT @dtNow = GETDATE()
     INSERT INTO cdn.PieczatkiJS
     (PCJS_DataOd, PCJS_DataDo, PCJS_Nazwa1, PCJS_Nazwa2, PCJS_Nazwa3, PCJS_NipKraj, PCJS_NipE, PCJS_Regon,
      PCJS_Kraj, PCJS_KrajISO, PCJS_Wojewodztwo, PCJS_Powiat, PCJS_Gmina, PCJS_KodGminy, PCJS_Miasto, PCJS_Ulica, PCJS_NrDomu, PCJS_NrLokalu, PCJS_KodP, PCJS_Poczta,
      PCJS_Telefon, PCJS_Email, PCJS_URL,
     PCJS_ImportRowId,
     PCJS_OpeZalId, PCJS_StaZalId, PCJS_TS_Zal, PCJS_OpeModId, PCJS_StaModId, PCJS_TS_Mod, PCJS_OpeZalKod, PCJS_OpeZalNazwisko, PCJS_OpeModKod, PCJS_OpeModNazwisko)
     SELECT @overDataOd, @dataOd-1, PCJS_Nazwa1, PCJS_Nazwa2, PCJS_Nazwa3, PCJS_NipKraj, PCJS_NipE, PCJS_Regon,
      PCJS_Kraj, PCJS_KrajISO, PCJS_Wojewodztwo, PCJS_Powiat, PCJS_Gmina, PCJS_KodGminy, PCJS_Miasto, PCJS_Ulica, PCJS_NrDomu, PCJS_NrLokalu, PCJS_KodP, PCJS_Poczta,
      PCJS_Telefon, PCJS_Email, PCJS_URL,
     NewId(),
     @OpeID, @StaID, @dtNow, @OpeID, @StaID, @dtNow, @OpeKod, @OpeNazwisko, @OpeKod, @OpeNazwisko
     FROM cdn.PieczatkiJS WHERE PCJS_PCJSID = @prevID2
     SELECT @NewID = SCOPE_IDENTITY(), @NewDataOd = @overDataOd, @NewDataDo = @dataOd-1
     SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@NewID, @NewDataOd, @NewDataDo)
     EXEC [CDN].[RejestrOperacjiDodaj]
      @ObiektTyp = 5001, -- OptimaObjectType_PieczatkaJS
      @ObiektSubTyp = 0,
      @ObiektID = @NewID,
      @ObiektNazwa = @dataStr,
      @OperacjaTyp = 1, -- OptimaOperationType_Dodanie
      @Opis = ''
     UPDATE cdn.PieczatkiJS SET PCJS_DataOd = @dataDo + 1 WHERE PCJS_PCJSID = @nextID2
     SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@nextID2, @dataDo + 1, @nextDataDo2)
     EXEC [CDN].[RejestrOperacjiDodaj]
      @ObiektTyp = 5001, -- OptimaObjectType_PieczatkaJS
      @ObiektSubTyp = 0,
      @ObiektID = @nextID2,
      @ObiektNazwa = @dataStr,
      @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
      @Opis = ''
    END
    ELSE IF @dataOd = @overDataOd AND @dataDo < @overDataDo
    BEGIN
     -- np. mamy pieczątkę (1.1.2018, 31.12.2018) i dodajemy (1.1.2018, 30.04.2018)
     -- przesuwamy tylko datę Od na istniejącej pieczątce
     UPDATE cdn.PieczatkiJS SET PCJS_DataOd = @dataDo + 1 WHERE PCJS_PCJSID = @overID
     SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@overID, @dataDo + 1, @prevDataDo2)
     EXEC [CDN].[RejestrOperacjiDodaj]
      @ObiektTyp = 5001, -- OptimaObjectType_PieczatkaJS
      @ObiektSubTyp = 0,
      @ObiektID = @overID,
      @ObiektNazwa = @dataStr,
      @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
      @Opis = ''
    END
    ELSE IF @dataOd > @overDataOd AND @dataDo = @overDataDo
    BEGIN
     -- np. mamy pieczątkę (1.1.2018, 31.12.2018) i dodajemy (1.6.2018, 31.12.2018)
     -- przesuwamy tylko datę Do na istniejącej pieczątce
     UPDATE cdn.PieczatkiJS SET PCJS_DataDo = @dataOd - 1 WHERE PCJS_PCJSID = @overID
     SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@overID, @overDataOd, @dataOd - 1)
     EXEC [CDN].[RejestrOperacjiDodaj]
      @ObiektTyp = 5001, -- OptimaObjectType_PieczatkaJS
      @ObiektSubTyp = 0,
      @ObiektID = @overID,
      @ObiektNazwa = @dataStr,
      @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
      @Opis = ''
    END
   END
   ELSE
   BEGIN
    -- zakres dat dodawanej pieczątki zawiera się w dwóch istniejących pieczątkach
    -- w tym przypadku wystarczy tylko przesunąć daty na obu
    UPDATE cdn.PieczatkiJS SET PCJS_DataDo = @dataOd - 1 WHERE PCJS_PCJSID = @prevID2
    SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@prevID2, @prevDataOd2, @dataOd - 1)
    EXEC [CDN].[RejestrOperacjiDodaj]
     @ObiektTyp = 5001, -- OptimaObjectType_PieczatkaJS
     @ObiektSubTyp = 0,
     @ObiektID = @prevID2,
     @ObiektNazwa = @dataStr,
     @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
     @Opis = ''
    UPDATE cdn.PieczatkiJS SET PCJS_DataOd = @dataDo + 1 WHERE PCJS_PCJSID = @nextID2
    SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@nextID2, @dataDo + 1, @nextDataDo2)
    EXEC [CDN].[RejestrOperacjiDodaj]
     @ObiektTyp = 5001, -- OptimaObjectType_PieczatkaJS
     @ObiektSubTyp = 0,
     @ObiektID = @nextID2,
     @ObiektNazwa = @dataStr,
     @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
     @Opis = ''
   END
  END
  ELSE IF @prevID2 IS NOT NULL AND @nextID2 IS NULL
  BEGIN
   -- Dodajemy pieczątkę zahaczającą z prawej strony; np. mamy (2017-07-01, 2017-07-31) i dodajemy (2017-07-15, 2017-08-31) - na istniejącej przesuwamy datę Do
   UPDATE cdn.PieczatkiJS SET PCJS_DataDo = @dataOd - 1 WHERE PCJS_PCJSID = @prevID2
   SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@prevID2, @prevDataOd2, @dataOd - 1)
   EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 5001, -- OptimaObjectType_PieczatkaJS
    @ObiektSubTyp = 0,
    @ObiektID = @prevID2,
    @ObiektNazwa = @dataStr,
    @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
    @Opis = ''
  END
  ELSE IF @prevID2 IS NULL AND @nextID2 IS NOT NULL
  BEGIN
   -- Dodajemy pieczątkę zahaczającą z lewej strony; np. mamy (2017-07-01, 2017-07-31) i dodajemy (2017-06-01, 2017-06-31) - na istniejącej przesuwamy datę Od
   UPDATE cdn.PieczatkiJS SET PCJS_DataOd = @dataDo + 1 WHERE PCJS_PCJSID = @nextID2
   SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@nextID2, @dataDo + 1, @nextDataDo2)
   EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 5001, -- OptimaObjectType_PieczatkaJS
    @ObiektSubTyp = 0,
    @ObiektID = @nextID2,
    @ObiektNazwa = @dataStr,
    @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
    @Opis = ''
  END
 END
 If Not Update (PCJS_TS_Export) And Exists (Select * From inserted Where PCJS_TS_Export Is Not Null)
   Update CDN.PieczatkiJS Set PCJS_TS_Export = Null Where PCJS_PCJSID In (Select PCJS_PCJSID From inserted Where PCJS_TS_Export Is Not Null)
 -- Ustawianie unikalnego identyfikatora
 If Exists (Select * From inserted Where PCJS_ImportRowId Is Null Or PCJS_ImportRowId = '')
   Update CDN.PieczatkiJS Set PCJS_ImportRowId = NewId()
   Where PCJS_PCJSId In (Select PCJS_PCJSId From inserted Where PCJS_ImportRowId Is Null Or PCJS_ImportRowId = '')
  IF @AktDok = 1
  BEGIN
  ALTER TABLE cdn.TraNag DISABLE TRIGGER ALL
  UPDATE cdn.TraNag SET TrN_PCJSID = @id WHERE TrN_DataWys BETWEEN @dataOd AND @dataDo
  IF @NewID <> 0
   UPDATE cdn.TraNag SET TrN_PCJSID = @NewID WHERE TrN_DataWys BETWEEN @NewDataOd AND @NewDataDo
  ALTER TABLE cdn.TraNag ENABLE TRIGGER ALL
  END
 Set NoCount On
