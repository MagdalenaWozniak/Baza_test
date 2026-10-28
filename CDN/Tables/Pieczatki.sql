CREATE TABLE [CDN].[Pieczatki] (
    [PC_PCID]           INT            IDENTITY (1, 1) NOT NULL,
    [PC_DataOd]         DATETIME       NOT NULL,
    [PC_DataDo]         DATETIME       NOT NULL,
    [PC_Aktualna]       AS             (case when [PC_DataDo]=CONVERT([datetime],'2999-12-31',(120)) then (1) else (0) end),
    [PC_Nazwa1]         NVARCHAR (50)  NULL,
    [PC_Nazwa2]         NVARCHAR (50)  NULL,
    [PC_Nazwa3]         NVARCHAR (512) NULL,
    [PC_NipKraj]        VARCHAR (2)    NULL,
    [PC_NipE]           NVARCHAR (20)  NULL,
    [PC_Regon]          NVARCHAR (20)  NULL,
    [PC_Kraj]           NVARCHAR (40)  NULL,
    [PC_KrajISO]        NVARCHAR (2)   NULL,
    [PC_Wojewodztwo]    NVARCHAR (40)  NULL,
    [PC_Powiat]         NVARCHAR (40)  NULL,
    [PC_Gmina]          NVARCHAR (40)  NULL,
    [PC_KodGminy]       VARCHAR (7)    NULL,
    [PC_Miasto]         NVARCHAR (40)  NULL,
    [PC_Ulica]          NVARCHAR (40)  NULL,
    [PC_NrDomu]         NVARCHAR (10)  NULL,
    [PC_NrLokalu]       NVARCHAR (10)  NULL,
    [PC_KodP]           VARCHAR (10)   NULL,
    [PC_Poczta]         NVARCHAR (40)  NULL,
    [PC_UlicaNrDomLok]  AS             (case when isnull([PC_Ulica],'')<>'' then case when isnull([PC_NrLokalu],'')<>'' then ((([PC_Ulica]+' ')+isnull([PC_NrDomu],''))+'/')+[PC_NrLokalu] else ([PC_Ulica]+' ')+isnull([PC_NrDomu],'') end else case when isnull([PC_NrLokalu],'')<>'' then (isnull([PC_NrDomu],'')+'/')+[PC_NrLokalu] else isnull([PC_NrDomu],'') end end),
    [PC_Telefon]        VARCHAR (20)   NULL,
    [PC_Email]          VARCHAR (127)  NULL,
    [PC_URL]            VARCHAR (254)  NULL,
    [PC_Opis]           NVARCHAR (50)  NULL,
    [PC_KRS_Sad]        NVARCHAR (100) NULL,
    [PC_KRS_Numer]      NVARCHAR (10)  NULL,
    [PC_KRS_KapitalZak] NVARCHAR (20)  NULL,
    [PC_KRS_KapitalWpl] NVARCHAR (20)  NULL,
    [PC_ILNGLNWlasny]   VARCHAR (13)   NULL,
    [PC_ILNGLNCentrali] VARCHAR (13)   NULL,
    [PC_PUESC]          NVARCHAR (50)  NULL,
    [PC_BDO]            NVARCHAR (20)  NULL,
    [PC_AktDok]         TINYINT        NULL,
    [PC_TS_Export]      DATETIME       NULL,
    [PC_ImportAppId]    VARCHAR (5)    NULL,
    [PC_ImportRowId]    VARCHAR (36)   NULL,
    [PC_OpeZalId]       INT            NULL,
    [PC_StaZalId]       INT            NULL,
    [PC_TS_Zal]         DATETIME       NOT NULL,
    [PC_OpeModId]       INT            NULL,
    [PC_StaModId]       INT            NULL,
    [PC_TS_Mod]         DATETIME       NOT NULL,
    [PC_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_PC_OpeModKod] DEFAULT ('') NOT NULL,
    [PC_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_PC_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [PC_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_PC_OpeZalKod] DEFAULT ('') NOT NULL,
    [PC_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_PC_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [PC_Primary] PRIMARY KEY CLUSTERED ([PC_PCID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [PCChron]
    ON [CDN].[Pieczatki]([PC_DataOd] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PCGUID]
    ON [CDN].[Pieczatki]([PC_ImportRowId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Pieczatki_Insert_Trigger
  ON CDN.Pieczatki
  FOR INSERT
AS
 Set NoCount On
 IF (SELECT COUNT(*) FROM inserted) > 1
 Begin
  RAISERROR('##OPT32352##', 16, 1) -- RaisError ('Nie można równocześnie dodawać wielu pieczątek firmy.', 16,1)
  RollBack Tran
  Return
 End
 If Exists (Select * From inserted WHERE inserted.PC_DataDo < inserted.PC_DataOd)
 Begin
  RAISERROR('##OPT32353##', 16, 1) -- RaisError ('Niepoprawny zakres dat pieczątki firmy: Data "DO" nie może być wcześniejsza niż data "DO".', 16,1)
  RollBack Tran
  Return
 End
 If Exists (Select * From inserted WHERE inserted.PC_DataOd > GETDATE())
 Begin
  RAISERROR('##OPT32354##', 16, 1) -- RaisError ('Niepoprawny zakres dat pieczątki firmy: Data "OD" nie może być późniejsza niż data bieżąca.', 16,1)
  RollBack Tran
  Return
 End
 If Exists (Select * From inserted WHERE inserted.PC_DataDo > GETDATE() - 1 AND YEAR(inserted.PC_DataDo) < 2999)
 Begin
  RAISERROR('##OPT32355##', 16, 1) -- RaisError ('Niepoprawny zakres dat pieczątki: Data "DO" musi być wcześniejsza niż data bieżąca.', 16,1)
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
 SELECT TOP 1 @id = inserted.PC_PCID, @dataOd = inserted.PC_DataOd, @dataDo = inserted.PC_DataDo,
   @OpeID = PC_OpeZalId, @StaID = PC_StaZalId, @OpeKod = PC_OpeZalKod, @OpeNazwisko = PC_OpeZalNazwisko,
   @AktDok = PC_AktDok
  FROM inserted
 If Exists (Select * from cdn.Pieczatki WHERE PC_PCID<>@id AND @dataOd<=PC_DataOd AND @dataDo>=PC_DataDo)
 Begin
  RAISERROR('##OPT32356##', 16, 1) -- RaisError ('W podanym okresie zawiera się inna pieczątka firmy.', 16,1)
  RollBack Tran
  Return
 End
 DECLARE @dataStr VARCHAR(64)
 DECLARE @NewID INT
 SELECT @NewID = 0
 DECLARE @NewDataOd DATETIME,
   @NewDataDo DATETIME,
   @Data DATETIME
 IF @dataOd > CONVERT(DATETIME, '1900-01-01', 120) AND @dataDo = CONVERT(DATETIME, '2999-12-31', 120)
 BEGIN
  DECLARE @actID INT
  DECLARE @dataOdAct DATETIME
  SELECT TOP 1 @actID = PC_PCID, @dataOdAct = PC_DataOd FROM cdn.Pieczatki WHERE PC_PCID<>@id AND PC_DataDo = CONVERT(DATETIME, '2999-12-31', 120) ORDER BY PC_DataDo ASC
  IF @actID IS NOT NULL
  BEGIN
   UPDATE cdn.Pieczatki SET PC_DataDo = @dataOd - 1 WHERE PC_PCID = @actID
   SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@actID, @dataOdAct, @dataOd - 1)
   EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 5000, -- OptimaObjectType_Pieczatka
    @ObiektSubTyp = 0,
    @ObiektID = @actID,
    @ObiektNazwa = @dataStr,
    @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
    @Opis = ''
  END
 END
 ELSE IF @dataOd = CONVERT(DATETIME, '1900-01-01', 120) AND @dataDo < CONVERT(DATETIME, '2999-12-31', 120)
 BEGIN
  DECLARE @nextID INT
  SELECT TOP 1 @nextID = PC_PCID, @Data = PC_DataDo FROM cdn.Pieczatki WHERE PC_PCID<>@id AND @dataDo BETWEEN PC_DataOd AND PC_DataDo ORDER BY PC_DataDo ASC
  IF @nextID IS NOT NULL
  BEGIN
   UPDATE cdn.Pieczatki SET PC_DataOd = @dataDo + 1 WHERE PC_PCID = @nextID
   SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@nextID, @dataDo + 1, @Data)
   EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 5000, -- OptimaObjectType_Pieczatka
    @ObiektSubTyp = 0,
    @ObiektID = @nextID,
    @ObiektNazwa = @dataStr,
    @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
    @Opis = ''
  END
 END
 ELSE IF @dataOd > CONVERT(DATETIME, '1900-01-01', 120) AND @dataDo < CONVERT(DATETIME, '2999-12-31', 120)
 BEGIN
  DECLARE @prevID2 INT
  DECLARE @prevDataOd2 DATETIME
  DECLARE @prevDataDo2 DATETIME
  SELECT TOP 1 @prevID2 = PC_PCID, @prevDataOd2 = PC_DataOd, @prevDataDo2 = PC_DataDo FROM cdn.Pieczatki WHERE PC_PCID<>@id AND @dataOd BETWEEN PC_DataOd AND PC_DataDo ORDER BY PC_DataDo DESC
  DECLARE @nextID2 INT
  DECLARE @nextDataDo2 DATETIME
  SELECT TOP 1 @nextID2 = PC_PCID, @nextDataDo2 = PC_DataDo FROM cdn.Pieczatki WHERE PC_PCID<>@id AND @dataDo BETWEEN PC_DataOd AND PC_DataDo ORDER BY PC_DataDo ASC
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
     INSERT INTO cdn.Pieczatki
     (PC_DataOd, PC_DataDo, PC_Nazwa1, PC_Nazwa2, PC_Nazwa3, PC_NipKraj, PC_NipE, PC_Regon,
      PC_Kraj, PC_KrajISO, PC_Wojewodztwo, PC_Powiat, PC_Gmina, PC_KodGminy, PC_Miasto, PC_Ulica, PC_NrDomu, PC_NrLokalu, PC_KodP, PC_Poczta,
      PC_Telefon, PC_Email, PC_URL, PC_Opis,
      PC_KRS_Sad, PC_KRS_Numer, PC_KRS_KapitalZak, PC_KRS_KapitalWpl, PC_ILNGLNWlasny, PC_ILNGLNCentrali, PC_PUESC, PC_BDO,
     PC_ImportRowId,
     PC_OpeZalId, PC_StaZalId, PC_TS_Zal, PC_OpeModId, PC_StaModId, PC_TS_Mod, PC_OpeZalKod, PC_OpeZalNazwisko, PC_OpeModKod, PC_OpeModNazwisko)
     SELECT @overDataOd, @dataOd-1, PC_Nazwa1, PC_Nazwa2, PC_Nazwa3, PC_NipKraj, PC_NipE, PC_Regon,
      PC_Kraj, PC_KrajISO, PC_Wojewodztwo, PC_Powiat, PC_Gmina, PC_KodGminy, PC_Miasto, PC_Ulica, PC_NrDomu, PC_NrLokalu, PC_KodP, PC_Poczta,
      PC_Telefon, PC_Email, PC_URL, PC_Opis,
      PC_KRS_Sad, PC_KRS_Numer, PC_KRS_KapitalZak, PC_KRS_KapitalWpl, PC_ILNGLNWlasny, PC_ILNGLNCentrali, PC_PUESC, PC_BDO,
     NewId(),
     @OpeID, @StaID, @dtNow, @OpeID, @StaID, @dtNow, @OpeKod, @OpeNazwisko, @OpeKod, @OpeNazwisko
     FROM cdn.Pieczatki WHERE PC_PCID = @prevID2
     SELECT @NewID = SCOPE_IDENTITY(), @NewDataOd = @overDataOd, @NewDataDo = @dataOd-1
     SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@NewID, @NewDataOd, @NewDataDo)
     EXEC [CDN].[RejestrOperacjiDodaj]
      @ObiektTyp = 5000, -- OptimaObjectType_Pieczatka
      @ObiektSubTyp = 0,
      @ObiektID = @NewID,
      @ObiektNazwa = @dataStr,
      @OperacjaTyp = 1, -- OptimaOperationType_Dodanie
      @Opis = ''
      -- Skopiowanie logo z zawężanej pieczątki do pieczątki automatycznie dodanej
     IF EXISTS (SELECT * FROM cdn.DaneBinarne WHERE DAB_Typ = 13 AND DAB_TwAID = @overID)
     BEGIN
      DECLARE @newPcID INT
      SELECT @newPcID = SCOPE_IDENTITY()
      ALTER TABLE cdn.DaneBinarne DISABLE TRIGGER ALL
      INSERT INTO cdn.DaneBinarne
      (DAB_MagazynDanych, DAB_MagazynDanychId, DAB_Typ, DAB_Flaga, DAB_TwAID, DAB_Wartosc, DAB_Rozmiar, DAB_NazwaPliku, DAB_Nazwa, DAB_Rozszerzenie, DAB_Sciezka, DAB_Wersja, DAB_IBard24Id, DAB_IBard24LinkPrywatny,
       DAB_OpeZalID, DAB_StaZalId, DAB_TS_Zal, DAB_OpeModID, DAB_StaModId, DAB_TS_Mod, DAB_OpeModKod, DAB_OpeModNazwisko, DAB_OpeZalKod, DAB_OpeZalNazwisko,
       DAB_GUID, DAB_eSklepZalVerID, DAB_eSklepZalID, DAB_eSklepJezykID, DAB_eSklepID)
      SELECT
       DAB_MagazynDanych, DAB_MagazynDanychId, DAB_Typ, DAB_Flaga, @newPcID, DAB_Wartosc, DAB_Rozmiar, DAB_NazwaPliku, DAB_Nazwa, DAB_Rozszerzenie, DAB_Sciezka, DAB_Wersja, DAB_IBard24Id, DAB_IBard24LinkPrywatny,
       DAB_OpeZalID, DAB_StaZalId, DAB_TS_Zal, DAB_OpeModID, DAB_StaModId, DAB_TS_Mod, DAB_OpeModKod, DAB_OpeModNazwisko, DAB_OpeZalKod, DAB_OpeZalNazwisko,
       DAB_GUID, DAB_eSklepZalVerID, DAB_eSklepZalID, DAB_eSklepJezykID, DAB_eSklepID
      FROM cdn.DaneBinarne WHERE DAB_Typ = 13 AND DAB_TwAID = @overID
      ALTER TABLE cdn.DaneBinarne ENABLE TRIGGER ALL
     END
     UPDATE cdn.Pieczatki SET PC_DataOd = @dataDo + 1 WHERE PC_PCID = @nextID2
     SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@nextID2, @dataDo + 1, @nextDataDo2)
     EXEC [CDN].[RejestrOperacjiDodaj]
      @ObiektTyp = 5000, -- OptimaObjectType_Pieczatka
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
     UPDATE cdn.Pieczatki SET PC_DataOd = @dataDo + 1 WHERE PC_PCID = @overID
     SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@overID, @dataDo + 1, @prevDataDo2)
     EXEC [CDN].[RejestrOperacjiDodaj]
      @ObiektTyp = 5000, -- OptimaObjectType_Pieczatka
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
     UPDATE cdn.Pieczatki SET PC_DataDo = @dataOd - 1 WHERE PC_PCID = @overID
     SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@overID, @overDataOd, @dataOd - 1)
     EXEC [CDN].[RejestrOperacjiDodaj]
      @ObiektTyp = 5000, -- OptimaObjectType_Pieczatka
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
    UPDATE cdn.Pieczatki SET PC_DataDo = @dataOd - 1 WHERE PC_PCID = @prevID2
    SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@prevID2, @prevDataOd2, @dataOd - 1)
    EXEC [CDN].[RejestrOperacjiDodaj]
     @ObiektTyp = 5000, -- OptimaObjectType_Pieczatka
     @ObiektSubTyp = 0,
     @ObiektID = @prevID2,
     @ObiektNazwa = @dataStr,
     @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
     @Opis = ''
    UPDATE cdn.Pieczatki SET PC_DataOd = @dataDo + 1 WHERE PC_PCID = @nextID2
    SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@nextID2, @dataDo + 1, @nextDataDo2)
    EXEC [CDN].[RejestrOperacjiDodaj]
     @ObiektTyp = 5000, -- OptimaObjectType_Pieczatka
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
   UPDATE cdn.Pieczatki SET PC_DataDo = @dataOd - 1 WHERE PC_PCID = @prevID2
   SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@prevID2, @prevDataOd2, @dataOd - 1)
   EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 5000, -- OptimaObjectType_Pieczatka
    @ObiektSubTyp = 0,
    @ObiektID = @prevID2,
    @ObiektNazwa = @dataStr,
    @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
    @Opis = ''
  END
  ELSE IF @prevID2 IS NULL AND @nextID2 IS NOT NULL
  BEGIN
   -- Dodajemy pieczątkę zahaczającą z lewej strony; np. mamy (2017-07-01, 2017-07-31) i dodajemy (2017-06-01, 2017-06-31) - na istniejącej przesuwamy datę Od
   UPDATE cdn.Pieczatki SET PC_DataOd = @dataDo + 1 WHERE PC_PCID = @nextID2
   SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@nextID2, @dataDo + 1, @nextDataDo2)
   EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 5000, -- OptimaObjectType_Pieczatka
    @ObiektSubTyp = 0,
    @ObiektID = @nextID2,
    @ObiektNazwa = @dataStr,
    @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
    @Opis = ''
  END
 END
 If Not Update (PC_TS_Export) And Exists (Select * From inserted Where PC_TS_Export Is Not Null)
   Update CDN.Pieczatki Set PC_TS_Export = Null Where PC_PCID In (Select PC_PCID From inserted Where PC_TS_Export Is Not Null)
 -- Ustawianie unikalnego identyfikatora
 If Exists (Select * From inserted Where PC_ImportRowId Is Null Or PC_ImportRowId = '')
   Update CDN.Pieczatki Set PC_ImportRowId = NewId()
   Where PC_PCId In (Select PC_PCId From inserted Where PC_ImportRowId Is Null Or PC_ImportRowId = '')
 EXEC cdn.AktualnaPieczatka2CdnFirmaDanePieczatki
  IF @AktDok = 1
  BEGIN
  ALTER TABLE cdn.TraNag DISABLE TRIGGER ALL
  UPDATE cdn.TraNag SET TrN_PCID = @id WHERE TrN_DataWys BETWEEN @dataOd AND @dataDo
  IF @NewID <> 0
   UPDATE cdn.TraNag SET TrN_PCID = @NewID WHERE TrN_DataWys BETWEEN @NewDataOd AND @NewDataDo
  ALTER TABLE cdn.TraNag ENABLE TRIGGER ALL
  END
 Set NoCount On

GO
CREATE TRIGGER CDN.Pieczatki_Delete_Trigger
  ON CDN.Pieczatki
  FOR DELETE
AS
SET NOCOUNT ON
-- Sprawdzenie, czy nie została skasowana kasa gotówkowa
 IF (SELECT COUNT(*) FROM deleted) > 1
 Begin
  RAISERROR('##OPT32349##', 16, 1) -- RaisError ('Nie można równocześnie usuwać wielu pieczątek firmy.', 16,1)
  RollBack Tran
  Return
 End
 DECLARE @cntLast INT
 SELECT @cntLast = COUNT(*) FROM cdn.Pieczatki WHERE PC_PCID NOT IN (SELECT deleted.PC_PCID FROM deleted)
 IF @cntLast = 0
   BEGIN
  RAISERROR('##OPT32350##', 16, 1) -- RAISERROR('Nie można usunąć pieczątki. Do poprawnego działania programu wymagany jest co najmniej jeden wpis z danymi firmy.', 16, 1)
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
   END
 IF EXISTS (SELECT * FROM cdn.TraNag WHERE TrN_PCID IN (SELECT deleted.PC_PCID FROM deleted))
 BEGIN
  RAISERROR('##OPT32351##', 16, 1) -- RAISERROR('Nie można usunąć pieczątki firmy powiązanej z dokumentem handlowo-magazynowym.', 16, 1)
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 END
 DECLARE @id INT
 DECLARE @dataOd DATETIME
 DECLARE @dataDo DATETIME
 SELECT TOP 1 @id = deleted.PC_PCID, @dataOd = deleted.PC_DataOd, @dataDo = deleted.PC_DataDo FROM deleted
 DECLARE @dataStr VARCHAR(64)
 DECLARE @dataOdUpd DATETIME
 DECLARE @dataDoUpd DATETIME
 DECLARE @prevID INT
 SELECT TOP 1 @prevID = PC_PCID, @dataOdUpd = PC_DataOd FROM cdn.Pieczatki WHERE PC_PCID<>@id AND PC_DataDo < @dataOd ORDER BY PC_DataDo DESC
 IF @prevID IS NOT NULL
 BEGIN
  UPDATE cdn.Pieczatki SET PC_DataDo = @dataDo WHERE PC_PCID = @prevID
  SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@prevID, @dataOdUpd, @dataDo)
  EXEC [CDN].[RejestrOperacjiDodaj]
   @ObiektTyp = 5000, -- OptimaObjectType_Pieczatka
   @ObiektSubTyp = 0,
   @ObiektID = @prevID,
   @ObiektNazwa = @dataStr,
   @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
   @Opis = ''
 END
 ELSE
 BEGIN
  DECLARE @nextID INT
  SELECT TOP 1 @nextID = PC_PCID, @dataDoUpd = PC_DataDo FROM cdn.Pieczatki WHERE PC_PCID<>@id AND PC_DataOd > @dataDo ORDER BY PC_DataOd ASC
  IF @nextID IS NOT NULL
  BEGIN
   UPDATE cdn.Pieczatki SET PC_DataOd = @dataOd WHERE PC_PCID = @nextID
   SELECT @dataStr = cdn.PieczatkaNazwaDlaLogowania(@nextID, @dataOd, @dataDoUpd)
   EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 5000, -- OptimaObjectType_Pieczatka
    @ObiektSubTyp = 0,
    @ObiektID = @nextID,
    @ObiektNazwa = @dataStr,
    @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
    @Opis = ''
  END
 END
 DELETE cdn.DaneBinarne WHERE DAB_Typ = 13 AND DAB_TwAID = @id
 EXEC cdn.AktualnaPieczatka2CdnFirmaDanePieczatki
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Pieczatki_Update_Trigger
  ON CDN.Pieczatki
  FOR UPDATE
AS
 Set NoCount On
 If Update (PC_DataOD) Or Update (PC_DataDo)
 Begin
  If Exists (Select * From inserted WHERE inserted.PC_DataDo < inserted.PC_DataOd)
  Begin
   RAISERROR('##OPT32353##', 16, 1) -- RaisError ('Niepoprawny zakres dat pieczątki firmy: Data "DO"  nie może być wcześniejsza niż data "DO".', 16,1)
   RollBack Tran
   Return
  End
  If Exists (Select * From inserted WHERE inserted.PC_DataOd > GETDATE())
  Begin
   RAISERROR('##OPT32354##', 16, 1) -- RaisError ('Niepoprawny zakres dat pieczątki firmy: Data "OD" nie może być późniejsza niż data bieżąca.', 16,1)
   RollBack Tran
   Return
  End
  If Exists (Select * From inserted WHERE inserted.PC_DataDo > GETDATE() - 1 AND YEAR(inserted.PC_DataDo) < 2999)
  Begin
   RAISERROR('##OPT32355##', 16, 1) -- RaisError ('Niepoprawny zakres dat pieczątki: Data "DO" musi być wcześniejsza niż data bieżąca.', 16,1)
   RollBack Tran
   Return
  End
 End
 EXEC cdn.AktualnaPieczatka2CdnFirmaDanePieczatki
  Set NoCount On
