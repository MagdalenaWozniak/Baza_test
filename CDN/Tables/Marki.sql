CREATE TABLE [CDN].[Marki] (
    [Mrk_MrkId]          INT           IDENTITY (1, 1) NOT NULL,
    [Mrk_PrdId]          INT           NULL,
    [Mrk_Nazwa]          VARCHAR (250) NOT NULL,
    [Mrk_Logo]           INT           NULL,
    [Mrk_OpeZalId]       INT           NULL,
    [Mrk_StaZalId]       INT           NULL,
    [Mrk_TS_Zal]         DATETIME      NOT NULL,
    [Mrk_OpeModId]       INT           NULL,
    [Mrk_StaModId]       INT           NULL,
    [Mrk_TS_Mod]         DATETIME      NOT NULL,
    [Mrk_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_Mrk_OpeModKod] DEFAULT ('') NOT NULL,
    [Mrk_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_Mrk_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [Mrk_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_Mrk_OpeZalKod] DEFAULT ('') NOT NULL,
    [Mrk_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_Mrk_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [Mrk_Primary] PRIMARY KEY CLUSTERED ([Mrk_MrkId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_MrkProducenci] FOREIGN KEY ([Mrk_PrdId]) REFERENCES [CDN].[Producenci] ([Prd_PrdId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [MrkNazwa]
    ON [CDN].[Marki]([Mrk_Nazwa] ASC, [Mrk_MrkId] ASC) WITH (FILLFACTOR = 100);

