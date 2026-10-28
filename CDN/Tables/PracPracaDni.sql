CREATE TABLE [CDN].[PracPracaDni] (
    [PPR_PprId]          INT           IDENTITY (1, 1) NOT NULL,
    [PPR_PraId]          INT           NOT NULL,
    [PPR_Data]           DATETIME      NOT NULL,
    [PPR_OpeZalId]       INT           NULL,
    [PPR_StaZalId]       INT           NULL,
    [PPR_TS_Zal]         DATETIME      NOT NULL,
    [PPR_OpeModId]       INT           NULL,
    [PPR_StaModId]       INT           NULL,
    [PPR_TS_Mod]         DATETIME      NOT NULL,
    [PPR_Zrodlo]         TINYINT       NOT NULL,
    [PPR_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_PPR_OpeModKod] DEFAULT ('') NOT NULL,
    [PPR_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_PPR_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [PPR_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_PPR_OpeZalKod] DEFAULT ('') NOT NULL,
    [PPR_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_PPR_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [PPR_Primary] PRIMARY KEY CLUSTERED ([PPR_PprId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PPRData] FOREIGN KEY ([PPR_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PPRData]
    ON [CDN].[PracPracaDni]([PPR_PraId] ASC, [PPR_Data] ASC) WITH (FILLFACTOR = 100);

