CREATE TABLE [CDN].[FormyPlatnosci] (
    [FPl_FPlId]             INT            IDENTITY (1, 1) NOT NULL,
    [FPl_Nazwa]             NVARCHAR (20)  NOT NULL,
    [FPl_Typ]               SMALLINT       NOT NULL,
    [FPl_BRaId]             INT            NULL,
    [FPl_PodmiotTyp]        SMALLINT       NULL,
    [FPl_PodmiotID]         INT            NULL,
    [FPl_Termin]            SMALLINT       NOT NULL,
    [FPl_NieAktywny]        SMALLINT       NOT NULL,
    [FPl_TS_Export]         DATETIME       NULL,
    [FPl_ImportAppId]       VARCHAR (5)    NULL,
    [FPl_ImportRowId]       VARCHAR (36)   NULL,
    [FPl_XLID]              INT            NULL,
    [FPl_Rabat]             DECIMAL (5, 2) NOT NULL,
    [FPl_TerminalPlatniczy] SMALLINT       CONSTRAINT [DF_FPl_TerminalPlatniczy] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [FPl_Primary] PRIMARY KEY CLUSTERED ([FPl_FPlId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [CK_FPl_Termin] CHECK ([FPL_TERMIN]>=(0)),
    CONSTRAINT [FK_FplRachunek] FOREIGN KEY ([FPl_BRaId]) REFERENCES [CDN].[BnkRachunki] ([BRa_BRaID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [FPlNazwa]
    ON [CDN].[FormyPlatnosci]([FPl_Nazwa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [FplRachunek]
    ON [CDN].[FormyPlatnosci]([FPl_BRaId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [FPlGUID]
    ON [CDN].[FormyPlatnosci]([FPl_ImportRowId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.FormyPlatnosci_InsertUpdateDelete_Trigger
  ON CDN.FormyPlatnosci
  FOR INSERT, UPDATE, DELETE
AS
  SET NOCOUNT ON
-- Sprawdzenie, czy rejestr jest w walucie systemowej
  IF EXISTS (SELECT * FROM inserted JOIN CDN.BnkRachunki On FPl_BRaId = BRa_BRaId
               WHERE BRa_Waluta <> '')
    BEGIN
      RAISERROR('##OPT32324##', 16, 1) -- RAISERROR('Wybrano domyślny rejestr walutowy. Rejestry walutowe należy definiować na liście rejestrów walutowych.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Sprawdzenie, czy zmieniono nazwę lub typ w formie
  IF EXISTS (SELECT * FROM deleted
             JOIN inserted ON deleted.FPl_FPlId = inserted.FPl_FPlId
             WHERE deleted.FPl_Typ<>inserted.FPl_Typ OR deleted.FPl_Nazwa<>inserted.FPl_Nazwa)
  BEGIN
  -- Sprawdzenie, czy zmieniono nazwę lub typ w formie wykorzystanej w TraNag
    IF EXISTS (SELECT * FROM deleted
               JOIN inserted ON deleted.FPl_FPlID = inserted.FPl_FPlID
               JOIN CDN.TraNag ON deleted.FPl_FPlID = CDN.TraNag.TrN_FPlId
               WHERE deleted.FPl_Typ<>inserted.FPl_Typ OR deleted.FPl_Nazwa<>inserted.FPl_Nazwa)
    BEGIN
      RAISERROR('##OPT32325##', 16, 1) -- RAISERROR('Forma płatności jest używana w nagłówkach transakcji (TraNag). Nie można zmieniać jej typu ani nazwy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  -- Sprawdzenie, czy zmieniono nazwę lub typ w formie wykorzystanej w VatNag
    IF EXISTS (SELECT * FROM deleted
               JOIN inserted ON deleted.FPl_FPlID = inserted.FPl_FPlID
               JOIN CDN.VatNag ON deleted.FPl_FPlID = CDN.VatNag.VaN_FPlId
               WHERE deleted.FPl_Typ<>inserted.FPl_Typ OR deleted.FPl_Nazwa<>inserted.FPl_Nazwa)
    BEGIN
      RAISERROR('##OPT32326##', 16, 1) -- RAISERROR('Forma płatności jest używana w nagłówkach rejestrów VAT (VatNag). Nie można zmieniać jej typu ani nazwy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  -- Sprawdzenie, czy zmieniono nazwę lub typ w formie wykorzystanej w BnkZdarzenia
    IF EXISTS (SELECT * FROM deleted
               JOIN inserted ON deleted.FPl_FPlID = inserted.FPl_FPlID
               JOIN CDN.BnkZdarzenia ON deleted.FPl_FPlID = CDN.BnkZdarzenia.BZd_FPlId
               WHERE deleted.FPl_Typ<>inserted.FPl_Typ OR deleted.FPl_Nazwa<>inserted.FPl_Nazwa)
    BEGIN
      RAISERROR('##OPT32327##', 16, 1) -- RAISERROR('Forma płatności jest używana w zdarzeniach (BnkZdarzenia). Nie można zmieniać jej typu ani nazwy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  -- Sprawdzenie, czy zmieniono nazwę lub typ w formie wykorzystanej w Kontrahenci
    IF EXISTS (SELECT * FROM deleted
               JOIN inserted ON deleted.FPl_FPlID = inserted.FPl_FPlID
               JOIN CDN.Kontrahenci ON deleted.FPl_FPlID = CDN.Kontrahenci.Knt_FPlId
               WHERE deleted.FPl_Typ<>inserted.FPl_Typ OR deleted.FPl_Nazwa<>inserted.FPl_Nazwa)
    BEGIN
      RAISERROR('##OPT32328##', 16, 1) -- RAISERROR('Forma płatności jest używana w kontrahentach (Kontrahenci). Nie można zmieniać jej typu ani nazwy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  -- Sprawdzenie, czy zmieniono nazwę lub typ w formie wykorzystanej w Detal
    IF EXISTS (SELECT * FROM deleted
               JOIN inserted ON deleted.FPl_FPlID = inserted.FPl_FPlID
               JOIN CDN.DetalFormyPlatnosci ON deleted.FPl_FPlID = CDN.DetalFormyPlatnosci.DFPl_FPlId
               WHERE deleted.FPl_Typ<>inserted.FPl_Typ OR deleted.FPl_Nazwa<>inserted.FPl_Nazwa)
    BEGIN
      RAISERROR('##OPT32329##', 16, 1) -- RAISERROR('Forma płatności jest używana w konfiguracji Detalu. Nie można zmieniać jej typu ani nazwy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  END
-- Kasowanie wskanika wyeksportowania
If Not Update (FPl_TS_Export) And Exists (Select * From inserted Where FPl_TS_Export Is Not Null)
  Update CDN.FormyPlatnosci Set FPl_TS_Export = Null Where FPl_FPlId In (Select FPl_FPlId From inserted Where FPl_TS_Export Is Not Null)
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where FPl_ImportRowId Is Null Or FPl_ImportRowId = '')
  Update CDN.FormyPlatnosci Set FPl_ImportRowId = NewId()
  Where FPl_FPlId In (Select FPl_FPlId From inserted Where FPl_ImportRowId Is Null Or FPl_ImportRowId = '')
-- Dodanie promocji dla platnosci XL
IF NOT EXISTS(SELECT * FROM CDN.Firma WHERE Fir_Numer = 1470 AND Fir_Wartosc = '4')
  BEGIN
  -- Sprawdzenie, czy jest przynajmniej jedna aktywna forma
  IF NOT EXISTS (Select * From CDN.FormyPlatnosci Where FPl_NieAktywny = 0)
    BEGIN
      RAISERROR('##OPT32330##', 16, 1) -- RAISERROR('Musi istnieć przynajmniej jedna aktywna forma płatności.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  END
  SET NOCOUNT OFF
