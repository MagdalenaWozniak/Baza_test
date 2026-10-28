CREATE TABLE [CDN].[SchematPlatnosci] (
    [SPL_SplId]          INT             IDENTITY (1, 1) NOT NULL,
    [SPL_PodmiotTyp]     SMALLINT        NULL,
    [SPL_PodmiotID]      INT             NOT NULL,
    [SPL_OdbPodmiotTyp]  SMALLINT        NULL,
    [SPL_OdbPodmiotID]   INT             NULL,
    [SPL_FplId]          INT             NULL,
    [SPL_BnaId]          INT             NULL,
    [SPL_Rodzaj]         SMALLINT        NOT NULL,
    [SPL_Kwota]          DECIMAL (14, 2) NOT NULL,
    [SPL_Procent]        DECIMAL (14, 2) NOT NULL,
    [SPL_RachunekNr]     NVARCHAR (51)   NOT NULL,
    [SPL_IBAN]           TINYINT         NOT NULL,
    [SPL_LiczbaPorz]     INT             NOT NULL,
    [SPL_Reszta]         TINYINT         NOT NULL,
    [SPL_Opis]           NVARCHAR (50)   NULL,
    [SPL_OpeZalID]       INT             NULL,
    [SPL_StaZalId]       INT             NULL,
    [SPL_TS_Zal]         DATETIME        NOT NULL,
    [SPL_OpeModID]       INT             NULL,
    [SPL_StaModId]       INT             NULL,
    [SPL_TS_Mod]         DATETIME        NOT NULL,
    [SPL_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_SPL_OpeModKod] DEFAULT ('') NOT NULL,
    [SPL_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_SPL_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [SPL_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_SPL_OpeZalKod] DEFAULT ('') NOT NULL,
    [SPL_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_SPL_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [SPL_RachunekNr0]    AS              (CONVERT([nvarchar](51),replace(replace([SPL_RACHUNEKNR],'-',''),' ',''),(0))),
    CONSTRAINT [SPL_Primary] PRIMARY KEY CLUSTERED ([SPL_SplId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SPLBnaLink] FOREIGN KEY ([SPL_BnaId]) REFERENCES [CDN].[BnkNazwy] ([BNa_BNaId]),
    CONSTRAINT [FK_SPLFplLink] FOREIGN KEY ([SPL_FplId]) REFERENCES [CDN].[FormyPlatnosci] ([FPl_FPlId])
);


GO
CREATE NONCLUSTERED INDEX [SPLFplLink]
    ON [CDN].[SchematPlatnosci]([SPL_FplId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SPLBnaLink]
    ON [CDN].[SchematPlatnosci]([SPL_BnaId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SPLLiczbaPorz]
    ON [CDN].[SchematPlatnosci]([SPL_LiczbaPorz] ASC, [SPL_PodmiotTyp] ASC, [SPL_PodmiotID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SplRachunekNr0]
    ON [CDN].[SchematPlatnosci]([SPL_RachunekNr0] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.SchematPlatnosci_Delete_Trigger
  ON CDN.SchematPlatnosci
  FOR DELETE
AS
SET NOCOUNT ON
UPDATE cdn.Kontrahenci SET Knt_RachunekNr = '', Knt_BNaID = NULL WHERE Knt_KntID In (SELECT deleted.SPl_PodmiotID FROM deleted WHERE deleted.SPl_PodmiotTyp=1 AND deleted.SPl_Reszta=1 AND deleted.SPL_RachunekNr = Knt_RachunekNr)
SET NOCOUNT OFF
