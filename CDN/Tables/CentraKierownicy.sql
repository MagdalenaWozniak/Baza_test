CREATE TABLE [CDN].[CentraKierownicy] (
    [CNK_CnkId]          INT           IDENTITY (1, 1) NOT NULL,
    [CNK_CntId]          INT           NOT NULL,
    [CNK_PraId]          INT           NOT NULL,
    [CNK_Rodzaj]         SMALLINT      NOT NULL,
    [CNK_Kod]            VARCHAR (40)  NOT NULL,
    [CNK_OkresOd]        DATETIME      NULL,
    [CNK_OkresDo]        DATETIME      NULL,
    [CNK_OpeZalId]       INT           NULL,
    [CNK_StaZalId]       INT           NULL,
    [CNK_TS_Zal]         DATETIME      NOT NULL,
    [CNK_OpeModId]       INT           NULL,
    [CNK_StaModId]       INT           NULL,
    [CNK_TS_Mod]         DATETIME      NOT NULL,
    [CNK_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_CNK_OpeModKod] DEFAULT ('') NOT NULL,
    [CNK_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_CNK_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [CNK_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_CNK_OpeZalKod] DEFAULT ('') NOT NULL,
    [CNK_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_CNK_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [CNK_Primary] PRIMARY KEY CLUSTERED ([CNK_CnkId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CNKCentra] FOREIGN KEY ([CNK_CntId]) REFERENCES [CDN].[Centra] ([CNT_CntId]) ON DELETE CASCADE,
    CONSTRAINT [FK_CNKPraLink] FOREIGN KEY ([CNK_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [CNKPraLink]
    ON [CDN].[CentraKierownicy]([CNK_PraId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [CNKCentra]
    ON [CDN].[CentraKierownicy]([CNK_CntId] ASC) WITH (FILLFACTOR = 100);

