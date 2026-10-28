CREATE TABLE [CDN].[Zaliczki] (
    [Zal_ZalID]          INT             IDENTITY (1, 1) NOT NULL,
    [Zal_DokumentTyp]    SMALLINT        NOT NULL,
    [Zal_DokumentID]     INT             NOT NULL,
    [Zal_BZpId]          INT             NOT NULL,
    [Zal_Zaznaczenie]    TINYINT         NOT NULL,
    [Zal_Kwota]          DECIMAL (15, 2) NOT NULL,
    [Zal_OpeZalId]       INT             NULL,
    [Zal_StaZalId]       INT             NULL,
    [Zal_TS_Zal]         DATETIME        NOT NULL,
    [Zal_OpeModId]       INT             NULL,
    [Zal_StaModId]       INT             NULL,
    [Zal_TS_Mod]         DATETIME        NOT NULL,
    [Zal_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_Zal_OpeModKod] DEFAULT ('') NOT NULL,
    [Zal_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_Zal_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [Zal_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_Zal_OpeZalKod] DEFAULT ('') NOT NULL,
    [Zal_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_Zal_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [Zal_Primary] PRIMARY KEY CLUSTERED ([Zal_ZalID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DoRBnkZapis] FOREIGN KEY ([Zal_BZpId]) REFERENCES [CDN].[BnkZapisy] ([BZp_BZpID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [DoRBnkZapis]
    ON [CDN].[Zaliczki]([Zal_BZpId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DoRDokument]
    ON [CDN].[Zaliczki]([Zal_DokumentID] ASC, [Zal_DokumentTyp] ASC, [Zal_BZpId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Zaliczki_InsertUpdateHandler
  ON CDN.Zaliczki
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
    IF EXISTS (SELECT * FROM inserted WHERE inserted.Zal_DokumentTyp=1)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.TraNag ON
                    inserted.Zal_DokumentID = CDN.TraNag.TrN_TrNID
              WHERE CDN.TraNag.TrN_TrNID IS NULL AND (inserted.Zal_DokumentTyp=1)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=TraNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
SET NOCOUNT OFF
