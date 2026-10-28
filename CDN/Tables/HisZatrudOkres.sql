CREATE TABLE [CDN].[HisZatrudOkres] (
    [HZO_HzoId]          INT           IDENTITY (1, 1) NOT NULL,
    [HZO_HztId]          INT           NOT NULL,
    [HZO_DkmId]          INT           NOT NULL,
    [HZO_OkresOd]        DATETIME      NOT NULL,
    [HZO_OkresDo]        DATETIME      NOT NULL,
    [HZO_OpeZalId]       INT           NULL,
    [HZO_StaZalId]       INT           NULL,
    [HZO_TS_Zal]         DATETIME      NOT NULL,
    [HZO_OpeModId]       INT           NULL,
    [HZO_StaModId]       INT           NULL,
    [HZO_TS_Mod]         DATETIME      NOT NULL,
    [HZO_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_HZO_OpeModKod] DEFAULT ('') NOT NULL,
    [HZO_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_HZO_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [HZO_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_HZO_OpeZalKod] DEFAULT ('') NOT NULL,
    [HZO_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_HZO_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [HZO_Primary] PRIMARY KEY CLUSTERED ([HZO_HzoId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HZODkmId] FOREIGN KEY ([HZO_DkmId]) REFERENCES [CDN].[DaneKadMod] ([DKM_DkmId]),
    CONSTRAINT [FK_HZOHztLink] FOREIGN KEY ([HZO_HztId]) REFERENCES [CDN].[HisZatrud] ([HZT_HztId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [HZOHztLink]
    ON [CDN].[HisZatrudOkres]([HZO_HztId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [HZODkmId]
    ON [CDN].[HisZatrudOkres]([HZO_DkmId] ASC) WITH (FILLFACTOR = 100);

