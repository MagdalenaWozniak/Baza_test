CREATE TABLE [CDN].[BnkRachunki] (
    [BRa_BRaID]                 INT             IDENTITY (1, 1) NOT NULL,
    [BRa_Akronim]               VARCHAR (20)    NOT NULL,
    [BRa_Symbol]                VARCHAR (5)     NOT NULL,
    [BRa_DDfID]                 INT             NULL,
    [BRa_Nazwa]                 NVARCHAR (50)   NOT NULL,
    [BRa_BNaID]                 INT             NULL,
    [BRa_RachunekNr]            NVARCHAR (51)   NOT NULL,
    [BRa_IBAN]                  SMALLINT        NOT NULL,
    [BRa_KKrID]                 INT             NULL,
    [BRa_KartaDW]               DATETIME        NULL,
    [BRa_Waluta]                VARCHAR (3)     NOT NULL,
    [BRa_KursSprzedazyNr]       INT             NOT NULL,
    [BRa_KursZakupuNr]          INT             NOT NULL,
    [BRa_KursNumer]             INT             NOT NULL,
    [BRa_KursL]                 DECIMAL (15, 4) NOT NULL,
    [BRa_KursM]                 DECIMAL (5)     NOT NULL,
    [BRa_SaldoBO]               DECIMAL (15, 2) NOT NULL,
    [BRa_SaldoBOSys]            DECIMAL (15, 2) NOT NULL,
    [BRa_BRpOkres]              SMALLINT        NOT NULL,
    [BRa_Typ]                   INT             NOT NULL,
    [BRa_LimitKredytu]          DECIMAL (15, 2) NOT NULL,
    [BRa_OprocRachunku]         DECIMAL (7, 3)  NOT NULL,
    [BRa_OprocKredytu]          DECIMAL (7, 3)  NOT NULL,
    [BRa_OprocKarne]            DECIMAL (7, 3)  NOT NULL,
    [BRa_KaraZaPrzekr]          DECIMAL (15, 2) NULL,
    [BRa_NumeryObce]            SMALLINT        NOT NULL,
    [BRa_KontoPrzeciwstawne]    NVARCHAR (50)   NOT NULL,
    [BRa_Nieaktywny]            SMALLINT        NOT NULL,
    [BRa_MagazynWalut]          SMALLINT        NOT NULL,
    [BRa_KursHistorycznyMW]     SMALLINT        NOT NULL,
    [BRa_RozKur2SumaMW]         SMALLINT        NOT NULL,
    [BRa_TS_Export]             DATETIME        NULL,
    [BRa_ImportAppId]           VARCHAR (5)     NULL,
    [BRa_ImportRowId]           VARCHAR (36)    NULL,
    [BRa_OpeZalId]              INT             NULL,
    [BRa_StaZalId]              INT             NULL,
    [BRa_TS_Zal]                DATETIME        NOT NULL,
    [BRa_OpeModId]              INT             NULL,
    [BRa_StaModId]              INT             NULL,
    [BRa_TS_Mod]                DATETIME        NOT NULL,
    [BRa_GIDTyp]                SMALLINT        NULL,
    [BRa_GIDFirma]              INT             NULL,
    [BRa_GIDNumer]              INT             NULL,
    [BRa_GIDLp]                 SMALLINT        NULL,
    [BRa_PrzelewySEPA]          TINYINT         CONSTRAINT [DF_BRa_PrzelewySEPA] DEFAULT ((0)) NOT NULL,
    [BRa_OpeModKod]             VARCHAR (20)    CONSTRAINT [DF_BRa_OpeModKod] DEFAULT ('') NOT NULL,
    [BRa_OpeModNazwisko]        NVARCHAR (50)   CONSTRAINT [DF_BRa_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [BRa_OpeZalKod]             VARCHAR (20)    CONSTRAINT [DF_BRa_OpeZalKod] DEFAULT ('') NOT NULL,
    [BRa_OpeZalNazwisko]        NVARCHAR (50)   CONSTRAINT [DF_BRa_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [BRa_SplitPay]              TINYINT         CONSTRAINT [DF_BRa_SplitPay] DEFAULT ((0)) NOT NULL,
    [BRa_CDCIdentyfikatorFirmy] NVARCHAR (32)   NULL,
    CONSTRAINT [BRa_Primary] PRIMARY KEY CLUSTERED ([BRa_BRaID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_BRaDokDefinicja] FOREIGN KEY ([BRa_DDfID]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID]),
    CONSTRAINT [FK_BRaKartaTyp] FOREIGN KEY ([BRa_KKrID]) REFERENCES [CDN].[KartyKredytowe] ([KKr_KKrId]),
    CONSTRAINT [FK_BRaNumer] FOREIGN KEY ([BRa_BNaID]) REFERENCES [CDN].[BnkNazwy] ([BNa_BNaId])
);


GO
CREATE NONCLUSTERED INDEX [BRaDokDefinicja]
    ON [CDN].[BnkRachunki]([BRa_DDfID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BRaAkronim]
    ON [CDN].[BnkRachunki]([BRa_Akronim] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BRaSymbol]
    ON [CDN].[BnkRachunki]([BRa_Symbol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BRaNumer]
    ON [CDN].[BnkRachunki]([BRa_BNaID] ASC, [BRa_RachunekNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRaKartaTyp]
    ON [CDN].[BnkRachunki]([BRa_KKrID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BRaGUID]
    ON [CDN].[BnkRachunki]([BRa_ImportRowId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRaGID]
    ON [CDN].[BnkRachunki]([BRa_GIDTyp] ASC, [BRa_GIDFirma] ASC, [BRa_GIDNumer] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.BnkRachunki_InsertUpdate_Trigger
  ON CDN.BnkRachunki
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
-- Sprawdzanie duplikacji identyfikatora GID
  If Update (BRa_GIDTyp) Or Update (BRa_GIDFirma) Or Update (BRa_GIDNumer)
    Begin
      If Exists (
        Select * From inserted A, CDN.BnkRachunki B Where
          A.BRa_GIDTyp   = B.BRa_GIDTyp   And
          A.BRa_GIDFirma = B.BRa_GIDFirma And
          A.BRa_GIDNumer = B.BRa_GIDNumer And
          A.BRa_BRaId   <> B.BRa_BRaId    And
          IsNull(A.BRa_GIDTyp, 0) <> 0    And
          IsNull(A.BRa_GIDFirma, 0) <> 0  And
          IsNull(A.BRa_GIDNumer, 0) <> 0)
        Begin
          RAISERROR('##OPT32230##', 16, 1) -- RaisError ('Duplikacja identyfikatora GID', 16,1)
          RollBack Tran
          Return
        End
    End
-- Sprawdzenie, czy zmieniono walute
  IF UPDATE (BRa_Waluta)
  BEGIN
    -- Sprawdzenie, czy istnieja zapisy w BnkRaporty
    IF EXISTS (SELECT * FROM deleted D
               JOIN inserted I ON D.BRa_BRaId = I.BRa_BRaId
               JOIN CDN.BnkRaporty ON I.BRa_BRaId = BRp_BRaId
               WHERE D.BRa_Waluta<>I.BRa_Waluta)
    BEGIN
      RAISERROR('##OPT32231##', 16, 1) -- RAISERROR('Rachunek jest używany w raportach kasowo-bankowych (BnkRaporty). Nie można zmieniać jego waluty.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- Sprawdzenie, czy istnieja zapisy w BnkZdarzenia
    IF EXISTS (SELECT * FROM deleted D
               JOIN inserted I ON D.BRa_BRaId = I.BRa_BRaId
               JOIN CDN.BnkZdarzenia ON I.BRa_BRaId = BZd_BRaId
               WHERE D.BRa_Waluta<>I.BRa_Waluta)
    BEGIN
      RAISERROR('##OPT32232##', 16, 1) -- RAISERROR('Rachunek jest używany w preliminarzu (BnkZdarzenia). Nie można zmieniać jego waluty.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- Sprawdzenie, czy istnieja zapisy w FormyPlatnWaluty
    IF EXISTS (SELECT * FROM deleted D
               JOIN inserted I ON D.BRa_BRaId = I.BRa_BRaId
               JOIN CDN.FormyPlatnWaluty ON I.BRa_BRaId = FPW_BRaId
               WHERE D.BRa_Waluta<>I.BRa_Waluta)
    BEGIN
      RAISERROR('##OPT32233##', 16, 1) -- RAISERROR('Rachunek jest używany w formach płatności (FormyPlatnWaluty). Nie można zmieniać jego waluty.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- Sprawdzenie, czy istnieja zapisy w FormyPlatnosci
    IF EXISTS (SELECT * FROM inserted I
               JOIN CDN.FormyPlatnosci ON I.BRa_BRaId = FPl_BRaId
               WHERE I.BRa_Waluta<>'')
    BEGIN
      RAISERROR('##OPT32234##', 16, 1) -- RAISERROR('Rachunek jest używany w formach płatności (FormyPlatnosci). Nie można zmieniać jego waluty.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  END
-- Sprawdzenie, czy zmieniono symbol lub numerację na rachunku
  IF EXISTS (SELECT * FROM deleted
             JOIN inserted ON deleted.BRa_BRaId = inserted.BRa_BRaId
             WHERE deleted.BRa_Symbol<>inserted.BRa_Symbol OR deleted.BRa_DDfID<>inserted.BRa_DDfID)
  BEGIN
  -- Sprawdzenie, czy zmieniono symbol lub numerację w rachunku wykorzystanym w BnkRaporty
    IF EXISTS (SELECT * FROM deleted
               JOIN inserted ON deleted.BRa_BRaId = inserted.BRa_BRaId
               JOIN CDN.BnkRaporty ON deleted.BRa_BRaId = CDN.BnkRaporty.BRp_BRaId
               WHERE deleted.BRa_Symbol<>inserted.BRa_Symbol OR deleted.BRa_DDfID<>inserted.BRa_DDfID)
    BEGIN
      RAISERROR('##OPT32235##', 16, 1) -- RAISERROR('Rachunek jest używany w raportach kasowo-bankowych (BnkRaporty). Nie można zmieniać jego symbolu ani numeracji.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  END
-- Sprawdzenie, czy zmieniono typ w rachunku wykorzystanym w BnkZapisy
  IF EXISTS (SELECT * FROM deleted
             JOIN inserted ON deleted.BRa_BRaId = inserted.BRa_BRaId
             JOIN CDN.BnkZapisy ON deleted.BRa_BRaId = CDN.BnkZapisy.BZp_BRaId
             WHERE deleted.BRa_Typ<>inserted.BRa_Typ)
  BEGIN
    RAISERROR('##OPT32236##', 16, 1) -- RAISERROR('Rachunek jest używany w zapisach kasowo-bankowych (BnkZapisy). Nie można zmieniać jego typu.',16,1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzanie ustawień związanych ze Split payment
 IF UPDATE (BRa_Typ) OR UPDATE (BRa_SplitPay)
 BEGIN
 IF EXISTS (SELECT * FROM inserted WHERE inserted.BRa_SplitPay <> 0 AND inserted.BRa_Typ <> 2)
  BEGIN
   RAISERROR('##OPT32237##', 16, 1) -- RAISERROR('Parametr Rachunek VAT dla split payment może być zaznaczony tylko dla rejestrów bankowych.', 16, 1)
   ROLLBACK TRAN
   SET NOCOUNT OFF
   RETURN
  END
 END
 IF UPDATE (BRa_Waluta) OR UPDATE (BRa_SplitPay)
 BEGIN
  IF EXISTS (SELECT * FROM inserted WHERE inserted.BRa_SplitPay <> 0 AND inserted.BRa_Waluta <> '')
  BEGIN
   RAISERROR('##OPT32238##', 16, 1) -- RAISERROR('Parametr Rachunek VAT dla split payment może być zaznaczony tylko dla rejestrów w walucie systemowej.', 16, 1)
   ROLLBACK TRAN
   SET NOCOUNT OFF
   RETURN
  END
 END
 IF EXISTS (SELECT * FROM inserted WHERE inserted.BRa_SplitPay <> 0 AND
      (EXISTS(SELECT * FROM cdn.FormyPlatnWaluty WHERE FPW_BRaId = inserted.BRa_BRaID) OR EXISTS(SELECT * FROM cdn.FormyPlatnosci WHERE FPl_BRaID = inserted.BRa_BRaID)))
    BEGIN
  RAISERROR('##OPT32239##', 16, 1) -- RAISERROR('Rachunek jest używany w formach płatności. Nie można go oznaczyć jako Rachunek VAT dla split payment.', 16, 1)
        ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
    END
-- Sprawdzenie, czy zmieniono saldo BO na rachunku
IF EXISTS (SELECT * FROM deleted
             JOIN inserted ON deleted.BRa_BRaId = inserted.BRa_BRaId
             WHERE deleted.BRa_SaldoBO<>inserted.BRa_SaldoBO Or deleted.BRa_SaldoBOSys<>inserted.BRa_SaldoBOSys)
BEGIN
 DECLARE @Raport INT
 DECLARE @Rachunek INT
 DECLARE @Zamkniety SMALLINT
 DECLARE @ZmianaWZamknietym TINYINT
 SELECT @ZmianaWZamknietym = 0
 DECLARE @SaldoBO DECIMAL(15,2), @SaldoBOSys DECIMAL(15,2)
  DECLARE CursorInserted CURSOR LOCAL FAST_FORWARD FOR
    SELECT inserted.BRa_BRaID, inserted.BRa_SaldoBO, inserted.BRa_SaldoBOSys
          FROM inserted
  OPEN CursorInserted
  WHILE 1=1
  BEGIN
    FETCH NEXT FROM CursorInserted INTO @Rachunek, @SaldoBO, @SaldoBOSys
    IF @@FETCH_STATUS <> 0 BREAK
    -- Zmiana salda na rachunku - sprawdzenie czy nie występuje zamknięty raport i ewentualna zmiana salda w 1st raporcie
    SELECT TOP 1 @Raport=BRp_BRpID, @Zamkniety=BRp_Zamkniety FROM CDN.BnkRaporty
    WHERE BRp_BRaID=@Rachunek ORDER BY BRp_BRaID, BRp_DataDok
    IF @Zamkniety is not null
    -- Jest jakiś podpięty raport; sprawdzamy go...
    BEGIN
      IF @Zamkniety=1
      -- Nie można zmienić salda BO rachunku
      BEGIN
        SELECT @ZmianaWZamknietym = 1
        BREAK
        /*
        RAISERROR('Nie można zmienić salda BO w rachunku, w którym istnieje zamknięty raport.', 16, 1)
        ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
        */
      END
      ELSE
        -- Trzeba zmienić saldo BO raportu
      BEGIN
        UPDATE CDN.BnkRaporty SET BRp_SaldoBO=@SaldoBO, BRp_SaldoBOSys=@SaldoBOSys WHERE BRp_BRpID=@Raport AND (BRp_SaldoBO<>@SaldoBO Or BRp_SaldoBOSys<>@SaldoBOSys)
        IF @@ERROR <> 0
        BEGIN
    RAISERROR('##OPT32240##', 16, 1) -- RAISERROR('Błąd aktualizacji salda początkowego pierwszego raportu.', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
      END
    END
  END
  CLOSE CursorInserted;
  IF @ZmianaWZamknietym = 1
  BEGIN
    EXEC cdn.PrzeliczAgregatyBRp
  END
END
-- Kasowanie wskanika wyeksportowania
If Not Update (BRa_TS_Export) And Exists (Select * From inserted Where BRa_TS_Export Is Not Null)
  Update CDN.BnkRachunki Set BRa_TS_Export = Null Where BRa_BRaId In (Select BRa_BRaId From inserted Where BRa_TS_Export Is Not Null)
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where BRa_ImportRowId Is Null Or BRa_ImportRowId = '')
  Update CDN.BnkRachunki Set BRa_ImportRowId = NewId()
  Where BRa_BRaId In (Select BRa_BRaId From inserted Where BRa_ImportRowId Is Null Or BRa_ImportRowId = '')
--Sprawdzenie, czy seria nie zostala wybrana w detalu
       IF EXISTS  (select Bra_Symbol from inserted where Bra_Symbol in
                          (select DSta_Seria from cdn.detalstanowiska))
        BEGIN
     RAISERROR('##OPT32241##', 16, 1) -- RAISERROR('Symbol rejestru zarezerwowany dla stanowiska Detalu. ', 16, 1)
              ROLLBACK TRAN
              SET NOCOUNT OFF
              RETURN
        END
SET NOCOUNT OFF
