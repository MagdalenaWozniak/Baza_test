CREATE TABLE [CDN].[Zaniechania] (
    [ZAN_ZanId]          INT             IDENTITY (1, 1) NOT NULL,
    [ZAN_PraId]          INT             NOT NULL,
    [ZAN_Nazwa]          NVARCHAR (40)   NOT NULL,
    [ZAN_Sposob]         INT             NOT NULL,
    [ZAN_KwotaZan]       DECIMAL (15, 2) NOT NULL,
    [ZAN_KwotaRoz]       DECIMAL (15, 2) NOT NULL,
    [ZAN_KwotaTemp]      DECIMAL (15, 2) NOT NULL,
    [ZAN_Data]           DATETIME        NOT NULL,
    [ZAN_OpeZalId]       INT             NULL,
    [ZAN_StaZalId]       INT             NULL,
    [ZAN_TS_Zal]         DATETIME        NOT NULL,
    [ZAN_OpeModId]       INT             NULL,
    [ZAN_StaModId]       INT             NULL,
    [ZAN_TS_Mod]         DATETIME        NOT NULL,
    [ZAN_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_ZAN_OpeModKod] DEFAULT ('') NOT NULL,
    [ZAN_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_ZAN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [ZAN_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_ZAN_OpeZalKod] DEFAULT ('') NOT NULL,
    [ZAN_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_ZAN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [ZAN_Primary] PRIMARY KEY CLUSTERED ([ZAN_ZanId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ZANPraLink] FOREIGN KEY ([ZAN_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [ZANPraLink]
    ON [CDN].[Zaniechania]([ZAN_PraId] ASC, [ZAN_Data] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [ZANTwpLink]
    ON [CDN].[Zaniechania]([ZAN_Sposob] ASC) WITH (FILLFACTOR = 100);

