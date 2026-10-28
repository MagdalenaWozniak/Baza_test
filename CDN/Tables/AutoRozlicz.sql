CREATE TABLE [CDN].[AutoRozlicz] (
    [AuR_AuRID]          INT             IDENTITY (1, 1) NOT NULL,
    [AuR_AuEID]          INT             NOT NULL,
    [AuR_RokMies]        INT             NOT NULL,
    [AuR_PrzejMiesiac]   DECIMAL (15, 2) NOT NULL,
    [AuR_PrzejRok]       DECIMAL (15, 2) NOT NULL,
    [AuR_KosztMiesiac]   DECIMAL (15, 2) NOT NULL,
    [AuR_KosztRok]       DECIMAL (15, 2) NOT NULL,
    [AuR_KsiegMiesiac]   DECIMAL (15, 2) NOT NULL,
    [AuR_KsiegRok]       DECIMAL (15, 2) NOT NULL,
    [AuR_KatId]          INT             NULL,
    [AuR_Kategoria]      VARCHAR (50)    NOT NULL,
    [AuR_Rejestr]        NVARCHAR (20)   NOT NULL,
    [AuR_VaNId]          INT             NULL,
    [AuR_KPRId]          INT             NULL,
    [AuR_DekId]          INT             NULL,
    [AuR_OpeZalID]       INT             NULL,
    [AuR_StaZalId]       INT             NULL,
    [AuR_TS_Zal]         DATETIME        NOT NULL,
    [AuR_OpeModID]       INT             NULL,
    [AuR_StaModId]       INT             NULL,
    [AuR_TS_Mod]         DATETIME        NOT NULL,
    [AuR_KorektaVat]     INT             CONSTRAINT [DF_AuR_KorektaVat] DEFAULT ((1)) NOT NULL,
    [AuR_ZakID]          INT             NULL,
    [AuR_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_AuR_OpeModKod] DEFAULT ('') NOT NULL,
    [AuR_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_AuR_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [AuR_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_AuR_OpeZalKod] DEFAULT ('') NOT NULL,
    [AuR_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_AuR_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [AuR_Primary] PRIMARY KEY CLUSTERED ([AuR_AuRID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AuRAuto] FOREIGN KEY ([AuR_AuEID]) REFERENCES [CDN].[AutoEwid] ([AuE_AuEID]),
    CONSTRAINT [FK_AuRKategorie] FOREIGN KEY ([AuR_KatId]) REFERENCES [CDN].[Kategorie] ([Kat_KatID])
);


GO
CREATE NONCLUSTERED INDEX [AuRKategorie]
    ON [CDN].[AutoRozlicz]([AuR_KatId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AuRAuto]
    ON [CDN].[AutoRozlicz]([AuR_AuEID] ASC, [AuR_RokMies] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AuRRokMies]
    ON [CDN].[AutoRozlicz]([AuR_RokMies] ASC, [AuR_AuEID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [AuRVatNag]
    ON [CDN].[AutoRozlicz]([AuR_VaNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AuRKPR]
    ON [CDN].[AutoRozlicz]([AuR_KPRId] ASC, [AuR_AuRID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AuRDekrety]
    ON [CDN].[AutoRozlicz]([AuR_DekId] ASC, [AuR_AuRID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.AutoRozlicz_DeleteHandler
  ON CDN.AutoRozlicz
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS(
  SELECT * FROM CDN.KwotyDodatkowe INNER JOIN deleted ON
   deleted.AuR_AuRID = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=3)
   )
  DELETE CDN.KwotyDodatkowe
  FROM CDN.KwotyDodatkowe, deleted
  WHERE deleted.AuR_AuRID = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=3)
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.AutoRozlicz_Delete_Trigger
  ON CDN.AutoRozlicz
  FOR DELETE
AS
  SET NOCOUNT ON
-- Sprawdzenie, czy zapisy nie są zaksięgowane do KPR
  IF EXISTS (SELECT * FROM deleted
             WHERE deleted.AuR_KPRId IS NOT NULL)
    BEGIN
      RAISERROR('##OPT32023##%%1%%=ZapisyKPR##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Sprawdzenie, czy zapisy nie są zaksięgowane do dekretów
  IF EXISTS (SELECT * FROM deleted
             WHERE deleted.AuR_DekId IS NOT NULL)
    BEGIN
      RAISERROR('##OPT32023##%%1%%=Dekrety##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.AutoRozlicz_InsertUpdate_Trigger
  ON CDN.AutoRozlicz
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
--Sprawdzanie obecności wierszy w tabeli nadrzędnej ZapisyKPR
        IF EXISTS
           (  SELECT * FROM inserted LEFT OUTER JOIN CDN.ZapisyKPR ON
                    inserted.AuR_KPRID       = CDN.ZapisyKPR.KPR_KPRID
              WHERE CDN.ZapisyKPR.KPR_KPRID IS NULL
                AND inserted.AuR_KPRID IS NOT NULL
           )
        BEGIN
          RAISERROR('##OPT32024##%%1%%=ZapisyKPR##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
--Sprawdzanie obecności wierszy w tabeli nadrzędnej DekretyNag
        IF EXISTS
           (  SELECT * FROM inserted LEFT OUTER JOIN CDN.DekretyNag ON
                    inserted.AuR_DekID       = CDN.DekretyNag.DeN_DeNId
              WHERE CDN.DekretyNag.DeN_DeNId IS NULL
                AND inserted.AuR_DekID IS NOT NULL
           )
        BEGIN
          RAISERROR('##OPT32024##%%1%%=DekretyNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
-- Kontrola VatNag
        IF EXISTS
           (  SELECT * FROM inserted
                       JOIN deleted    ON inserted.AuR_AuRID   = deleted.AuR_AuRID
                       JOIN CDN.VatNag ON CDN.VatNag.VaN_VaNId = inserted.AuR_VaNId
              WHERE inserted.AuR_KPRId IS NULL AND deleted.AuR_KPRId IS NOT NULL
           )
-- Usunięcie zapisu korekcyjnego VatNag w przypadku "odksięgowania" rozliczenia
          BEGIN
            DELETE CDN.VatNag
            FROM CDN.VatNag
            JOIN inserted ON CDN.VatNag.VaN_VaNId = inserted.AuR_VaNId
            JOIN deleted  ON CDN.VatNag.VaN_VaNId = deleted.AuR_VaNId
            WHERE inserted.AuR_KPRId IS NULL AND deleted.AuR_KPRId IS NOT NULL
            UPDATE CDN.AutoRozlicz SET CDN.AutoRozlicz.AuR_VaNId = NULL
            FROM CDN.AutoRozlicz
            JOIN inserted ON CDN.AutoRozlicz.AuR_AuRId = inserted.AuR_AuRId
            JOIN deleted  ON CDN.AutoRozlicz.AuR_AuRId = deleted.AuR_AuRId
            WHERE inserted.AuR_KPRId IS NULL AND deleted.AuR_KPRId IS NOT NULL
          END
        ELSE
-- Sprawdzenie istnienia odpowiedniego zapisu w VatNag
          BEGIN
            IF EXISTS
               (  SELECT * FROM inserted LEFT OUTER JOIN CDN.VatNag ON
                        inserted.AuR_VaNId       = CDN.VatNag.VaN_VaNID
                  WHERE CDN.VatNag.VaN_VaNID IS NULL
                    AND inserted.AuR_VaNId IS NOT NULL
               )
            BEGIN
              RAISERROR('##OPT32024##%%1%%=VatNag##', 16, 1)
              ROLLBACK TRAN
              SET NOCOUNT OFF
              RETURN
            END
          END
  SET NOCOUNT OFF
