CREATE TABLE [CDN].[CRMDokumenty] (
    [CRD_CRDId]           INT            IDENTITY (1, 1) NOT NULL,
    [CRD_CRKId]           INT            NOT NULL,
    [CRD_RodzajDokumentu] TINYINT        NOT NULL,
    [CRD_TypDokumentu]    SMALLINT       NULL,
    [CRD_DokumentId]      INT            NULL,
    [CRD_SciezkaDostepu]  NVARCHAR (512) NULL,
    [CRD_PolozeniePliku]  INT            NULL,
    [CRD_IBardId]         BIGINT         NULL,
    CONSTRAINT [CRD_Primary] PRIMARY KEY CLUSTERED ([CRD_CRDId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CRDCRMKontakty] FOREIGN KEY ([CRD_CRKId]) REFERENCES [CDN].[CRMKontakty] ([CRK_CRKId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [CRDDokument]
    ON [CDN].[CRMDokumenty]([CRD_DokumentId] ASC, [CRD_TypDokumentu] ASC, [CRD_RodzajDokumentu] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [CRDCRMKontakty]
    ON [CDN].[CRMDokumenty]([CRD_CRKId] ASC, [CRD_CRDId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.CRMDokumenty_InsertUpdateHandler
  ON CDN.CRMDokumenty
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
    IF EXISTS (SELECT * FROM inserted WHERE inserted.CRD_TypDokumentu=1 AND inserted.CRD_RodzajDokumentu=1)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.TraNag ON
                    inserted.CRD_DokumentId = CDN.TraNag.TrN_TrNID
              WHERE CDN.TraNag.TrN_TrNID IS NULL AND (inserted.CRD_TypDokumentu=1 AND inserted.CRD_RodzajDokumentu=1)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=TraNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
SET NOCOUNT OFF
