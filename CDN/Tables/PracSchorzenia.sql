CREATE TABLE [CDN].[PracSchorzenia] (
    [PRS_PrsId]          INT           IDENTITY (1, 1) NOT NULL,
    [PRS_PraId]          INT           NOT NULL,
    [PRS_DkmId]          INT           NOT NULL,
    [PRS_DataOd]         DATETIME      NOT NULL,
    [PRS_DataDo]         DATETIME      NOT NULL,
    [PRS_OpeZalId]       INT           NULL,
    [PRS_StaZalId]       INT           NULL,
    [PRS_TS_Zal]         DATETIME      NOT NULL,
    [PRS_OpeModId]       INT           NULL,
    [PRS_StaModId]       INT           NULL,
    [PRS_TS_Mod]         DATETIME      NOT NULL,
    [PRS_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_PRS_OpeModKod] DEFAULT ('') NOT NULL,
    [PRS_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_PRS_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [PRS_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_PRS_OpeZalKod] DEFAULT ('') NOT NULL,
    [PRS_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_PRS_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [PRS_Primary] PRIMARY KEY CLUSTERED ([PRS_PrsId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PRSDkmId] FOREIGN KEY ([PRS_DkmId]) REFERENCES [CDN].[DaneKadMod] ([DKM_DkmId]),
    CONSTRAINT [FK_PRSPraLink] FOREIGN KEY ([PRS_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [PRSPraLink]
    ON [CDN].[PracSchorzenia]([PRS_PraId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PRSDkmId]
    ON [CDN].[PracSchorzenia]([PRS_DkmId] ASC, [PRS_PraId] ASC) WITH (FILLFACTOR = 100);

