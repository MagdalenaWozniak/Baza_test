CREATE TABLE [CDN].[KwotyDodatkowe] (
    [Kdd_KddID]       INT             IDENTITY (1, 1) NOT NULL,
    [Kdd_PrzekrojTyp] INT             NOT NULL,
    [Kdd_DokumentTyp] INT             NOT NULL,
    [Kdd_DokumentID]  INT             NOT NULL,
    [Kdd_KatID]       INT             NULL,
    [Kdd_Opis]        NVARCHAR (50)   NULL,
    [Kdd_Kat2ID]      INT             NULL,
    [Kdd_Opis2]       NVARCHAR (50)   NULL,
    [Kdd_Kwota]       DECIMAL (15, 2) NOT NULL,
    [Kdd_KwotaWal]    DECIMAL (15, 2) NOT NULL,
    [Kdd_Segment1]    NVARCHAR (50)   NOT NULL,
    [Kdd_Segment2]    NVARCHAR (50)   NOT NULL,
    [Kdd_Wartosc1]    TINYINT         NOT NULL,
    [Kdd_Wartosc2]    TINYINT         NOT NULL,
    [Kdd_Waluta]      VARCHAR (3)     NOT NULL,
    [Kdd_KursNumer]   INT             NOT NULL,
    [Kdd_KursL]       DECIMAL (15, 4) NOT NULL,
    [Kdd_KursM]       DECIMAL (5)     NOT NULL,
    [Kdd_DataKur]     DATETIME        NOT NULL,
    [Kdd_Rozrachunki] INT             NULL,
    [Kdd_Lp]          INT             CONSTRAINT [DF_Kdd_Lp] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [Kdd_Primary] PRIMARY KEY CLUSTERED ([Kdd_KddID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_KddKategoria] FOREIGN KEY ([Kdd_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_KddKategoria2] FOREIGN KEY ([Kdd_Kat2ID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID])
);


GO
CREATE NONCLUSTERED INDEX [KddDokument]
    ON [CDN].[KwotyDodatkowe]([Kdd_DokumentID] ASC, [Kdd_DokumentTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KddKategoria]
    ON [CDN].[KwotyDodatkowe]([Kdd_KatID] ASC, [Kdd_DokumentTyp] ASC, [Kdd_DokumentID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.KwotyDodatkowe_InsertUpdateHandler
  ON CDN.KwotyDodatkowe
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
    IF EXISTS (SELECT * FROM inserted WHERE inserted.KDD_DokumentTyp=1)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.TraNag ON
                    inserted.Kdd_DokumentID = CDN.TraNag.TrN_TrNID
              WHERE CDN.TraNag.TrN_TrNID IS NULL AND (inserted.KDD_DokumentTyp=1)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=TraNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.KDD_DokumentTyp=2)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.VatNag ON
                    inserted.Kdd_DokumentID = CDN.VatNag.VaN_VaNID
              WHERE CDN.VatNag.VaN_VaNID IS NULL AND (inserted.KDD_DokumentTyp=2)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=VatNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.KDD_DokumentTyp=3)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.AutoRozlicz ON
                    inserted.Kdd_DokumentID = CDN.AutoRozlicz.AuR_AuRID
              WHERE CDN.AutoRozlicz.AuR_AuRID IS NULL AND (inserted.KDD_DokumentTyp=3)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=AutoRozlicz##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.KDD_DokumentTyp=4)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.RemanentNag ON
                    inserted.Kdd_DokumentID = CDN.RemanentNag.ReN_ReNID
              WHERE CDN.RemanentNag.ReN_ReNID IS NULL AND (inserted.KDD_DokumentTyp=4)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=RemanentNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.KDD_DokumentTyp=5)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.WyplatyNag ON
                    inserted.Kdd_DokumentID = CDN.WyplatyNag.WyN_WyNId
              WHERE CDN.WyplatyNag.WyN_WyNId IS NULL AND (inserted.KDD_DokumentTyp=5)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=WyplatyNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.KDD_DokumentTyp=6)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.DeklNag ON
                    inserted.Kdd_DokumentID = CDN.DeklNag.DkN_DkNID
              WHERE CDN.DeklNag.DkN_DkNID IS NULL AND (inserted.KDD_DokumentTyp=6)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=DeklNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.KDD_DokumentTyp=8)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.Wyplaty ON
                    inserted.Kdd_DokumentID = CDN.Wyplaty.WPL_WplId
              WHERE CDN.Wyplaty.WPL_WplId IS NULL AND (inserted.KDD_DokumentTyp=8)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=Wyplaty##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.KDD_DokumentTyp=9)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.BnkRaporty ON
                    inserted.Kdd_DokumentID = CDN.BnkRaporty.BRp_BRpID
              WHERE CDN.BnkRaporty.BRp_BRpID IS NULL AND (inserted.KDD_DokumentTyp=9)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=BnkRaporty##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.KDD_DokumentTyp=10)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.ListyPlac ON
                    inserted.Kdd_DokumentID = CDN.ListyPlac.LPL_LplId
              WHERE CDN.ListyPlac.LPL_LplId IS NULL AND (inserted.KDD_DokumentTyp=10)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=ListyPlac##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.KDD_DokumentTyp=11)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.NotyOdsNag ON
                    inserted.Kdd_DokumentID = CDN.NotyOdsNag.NON_NONId
              WHERE CDN.NotyOdsNag.NON_NONId IS NULL AND (inserted.KDD_DokumentTyp=11)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=NotyOdsNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.KDD_DokumentTyp=12)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.EwidDodNag ON
                    inserted.Kdd_DokumentID = CDN.EwidDodNag.EDN_EDNID
              WHERE CDN.EwidDodNag.EDN_EDNID IS NULL AND (inserted.KDD_DokumentTyp=12)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=EwidDodNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.KDD_DokumentTyp=13)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.BnkRozKwoty ON
                    inserted.Kdd_DokumentID = CDN.BnkRozKwoty.BRK_BRKID
              WHERE CDN.BnkRozKwoty.BRK_BRKID IS NULL AND (inserted.KDD_DokumentTyp=13)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=BnkRozKwoty##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.KDD_DokumentTyp=14)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.BnkZapisy ON
                    inserted.Kdd_DokumentID = CDN.BnkZapisy.BZp_BZpId
              WHERE CDN.BnkZapisy.BZp_BZpId IS NULL AND (inserted.KDD_DokumentTyp=14)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=BnkZapisy##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
SET NOCOUNT OFF
