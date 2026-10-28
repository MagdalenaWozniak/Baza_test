CREATE TABLE [CDN].[PracPlanDni] (
    [PPL_PplId]          INT           IDENTITY (1, 1) NOT NULL,
    [PPL_PraId]          INT           NOT NULL,
    [PPL_Data]           DATETIME      NOT NULL,
    [PPL_TypDnia]        INT           NOT NULL,
    [PPL_OpeZalId]       INT           NULL,
    [PPL_StaZalId]       INT           NULL,
    [PPL_TS_Zal]         DATETIME      NOT NULL,
    [PPL_OpeModId]       INT           NULL,
    [PPL_StaModId]       INT           NULL,
    [PPL_TS_Mod]         DATETIME      NOT NULL,
    [PPL_Zrodlo]         TINYINT       CONSTRAINT [DF_PPL_Zrodlo] DEFAULT ((0)) NOT NULL,
    [PPL_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_PPL_OpeModKod] DEFAULT ('') NOT NULL,
    [PPL_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_PPL_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [PPL_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_PPL_OpeZalKod] DEFAULT ('') NOT NULL,
    [PPL_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_PPL_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [PPL_OdwId]          INT           NULL,
    CONSTRAINT [PPL_Primary] PRIMARY KEY CLUSTERED ([PPL_PplId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PPLData] FOREIGN KEY ([PPL_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE,
    CONSTRAINT [FK_PPLOdwLink] FOREIGN KEY ([PPL_OdwId]) REFERENCES [CDN].[OpisyDniWolne] ([ODW_OdwId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PPLData]
    ON [CDN].[PracPlanDni]([PPL_PraId] ASC, [PPL_Data] ASC) WITH (FILLFACTOR = 100);

