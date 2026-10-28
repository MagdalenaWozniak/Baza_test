CREATE TABLE [CDN].[Zaklady] (
    [Zak_ZakID]          INT            IDENTITY (1, 1) NOT NULL,
    [Zak_Symbol]         NVARCHAR (30)  NOT NULL,
    [Zak_NazwaFirmy]     NVARCHAR (250) NULL,
    [Zak_NipKraj]        VARCHAR (2)    NULL,
    [Zak_NipE]           NVARCHAR (20)  NULL,
    [Zak_Regon]          VARCHAR (20)   NULL,
    [Zak_NazwaZakladu]   NVARCHAR (250) NULL,
    [Zak_Ulica]          NVARCHAR (40)  NULL,
    [Zak_NrDomu]         NVARCHAR (10)  NULL,
    [Zak_NrLokalu]       NVARCHAR (10)  NULL,
    [Zak_Miejscowosc]    NVARCHAR (40)  NULL,
    [Zak_Poczta]         NVARCHAR (40)  NULL,
    [Zak_KodPocztowy]    VARCHAR (10)   NULL,
    [Zak_Nieaktywny]     TINYINT        NOT NULL,
    [Zak_Domyslny]       TINYINT        NOT NULL,
    [Zak_Pierwszy]       TINYINT        NOT NULL,
    [Zak_TS_Export]      DATETIME       NULL,
    [Zak_ImportAppId]    VARCHAR (5)    NULL,
    [Zak_ImportRowId]    VARCHAR (36)   NULL,
    [Zak_OpeZalID]       INT            NULL,
    [Zak_StaZalId]       INT            NULL,
    [Zak_TS_Zal]         DATETIME       NOT NULL,
    [Zak_OpeModID]       INT            NULL,
    [Zak_StaModId]       INT            NULL,
    [Zak_TS_Mod]         DATETIME       NOT NULL,
    [Zak_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_Zak_OpeModKod] DEFAULT ('') NOT NULL,
    [Zak_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_Zak_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [Zak_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_Zak_OpeZalKod] DEFAULT ('') NOT NULL,
    [Zak_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_Zak_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_Zak_ZakID] PRIMARY KEY CLUSTERED ([Zak_ZakID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ZakSymbol]
    ON [CDN].[Zaklady]([Zak_Symbol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ZakGUID]
    ON [CDN].[Zaklady]([Zak_ImportRowId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER [CDN].[Zaklady_Delete_Trigger]
  ON [CDN].[Zaklady]
  FOR DELETE
AS
SET NOCOUNT ON
-- Sprawdzanie, czy nie skasowano kontrahenta o Id=1 (nieokreślony)
IF EXISTS (SELECT * FROM deleted WHERE deleted.Zak_Domyslny = 1)
  BEGIN
    RAISERROR('##OPT32048##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.PracEtaty
IF EXISTS (SELECT * FROM CDN.PracEtaty, deleted WHERE Zak_ZakID = PRE_ZakId)
  BEGIN
    RAISERROR('##OPT32049##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.BnkRozKwoty
IF EXISTS (SELECT * FROM CDN.BnkRozKwoty, deleted WHERE Zak_ZakID = BRK_ZakID)
  BEGIN
    RAISERROR('##OPT32049##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.BnkRozKwotyMW
IF EXISTS (SELECT * FROM CDN.BnkRozKwotyMW, deleted WHERE Zak_ZakID = BRKMW_ZakID)
  BEGIN
    RAISERROR('##OPT32049##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.VatNag
IF EXISTS (SELECT * FROM CDN.VatNag, deleted WHERE Zak_ZakID = VaN_ZakID)
  BEGIN
    RAISERROR('##OPT32049##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.EwidDodNag
IF EXISTS (SELECT * FROM CDN.EwidDodNag, deleted WHERE Zak_ZakID = EDN_ZakID)
  BEGIN
    RAISERROR('##OPT32049##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.AutoEwid
IF EXISTS (SELECT * FROM CDN.AutoEwid, deleted WHERE Zak_ZakID = AuE_ZakID)
  BEGIN
    RAISERROR('##OPT32049##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.AutoRozlicz
IF EXISTS (SELECT * FROM CDN.AutoRozlicz, deleted WHERE Zak_ZakID = AuR_ZakID)
  BEGIN
    RAISERROR('##OPT32049##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.RemanentNag
IF EXISTS (SELECT * FROM CDN.RemanentNag, deleted WHERE Zak_ZakID = ReN_ZakID)
  BEGIN
    RAISERROR('##OPT32049##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.ZapisyKPR
IF EXISTS (SELECT * FROM CDN.ZapisyKPR, deleted WHERE Zak_ZakID = KPR_ZakID)
  BEGIN
    RAISERROR('##OPT32049##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.ListyPlac
IF EXISTS (SELECT * FROM CDN.ListyPlac, deleted WHERE Zak_ZakID = LPL_ZakId)
  BEGIN
    RAISERROR('##OPT32049##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.BnkZapisy
IF EXISTS (SELECT * FROM CDN.BnkZapisy, deleted WHERE Zak_ZakID = BZp_ZakID)
  BEGIN
    RAISERROR('##OPT32049##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.Trwale
IF EXISTS (SELECT * FROM CDN.Trwale , deleted WHERE Zak_ZakID = SrT_ZakID)
  BEGIN
    RAISERROR('##OPT32049##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.TrwaleHist
IF EXISTS (SELECT * FROM CDN.TrwaleHist, deleted WHERE Zak_ZakID = SrH_ZakID)
  BEGIN
    RAISERROR('##OPT32049##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.WyplatyNag
IF EXISTS (SELECT * FROM CDN.WyplatyNag, deleted WHERE Zak_ZakID = WyN_ZakID)
  BEGIN
    RAISERROR('##OPT32049##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Zaklady_InsertUpdate_Trigger
  ON CDN.Zaklady
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
-- Kasowanie wskanika wyeksportowania
If Not Update (Zak_TS_Export) And Exists (Select * From inserted Where Zak_TS_Export Is Not Null)
  Update CDN.Zaklady Set Zak_TS_Export = Null Where Zak_ZakId In (Select Zak_ZakId From inserted Where Zak_TS_Export Is Not Null)
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where Zak_ImportRowId Is Null Or Zak_ImportRowId = '')
  Update CDN.Zaklady Set Zak_ImportRowId = NewId()
  Where Zak_ZakId In (Select Zak_ZakId From inserted Where Zak_ImportRowId Is Null Or Zak_ImportRowId = '')
  SET NOCOUNT OFF
