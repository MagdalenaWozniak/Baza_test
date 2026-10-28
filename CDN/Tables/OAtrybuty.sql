CREATE TABLE [CDN].[OAtrybuty] (
    [OAT_OatId]          INT            IDENTITY (1, 1) NOT NULL,
    [OAT_PrcId]          INT            NOT NULL,
    [OAT_AtkId]          INT            NULL,
    [OAT_Wartosc]        NVARCHAR (101) NOT NULL,
    [OAT_NazwaKlasy]     NVARCHAR (41)  NOT NULL,
    [OAT_OkresOd]        DATETIME       NOT NULL,
    [OAT_OkresDo]        DATETIME       NOT NULL,
    [OAT_OpeZalId]       INT            NULL,
    [OAT_StaZalId]       INT            NULL,
    [OAT_TS_Zal]         DATETIME       CONSTRAINT [DF_OAT_TS_Zal] DEFAULT (getdate()) NOT NULL,
    [OAT_OpeModId]       INT            NULL,
    [OAT_StaModId]       INT            NULL,
    [OAT_TS_Mod]         DATETIME       CONSTRAINT [DF_OAT_TS_Mod] DEFAULT (getdate()) NOT NULL,
    [OAT_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_OAT_OpeModKod] DEFAULT ('') NOT NULL,
    [OAT_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_OAT_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [OAT_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_OAT_OpeZalKod] DEFAULT ('') NOT NULL,
    [OAT_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_OAT_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [OAT_Primary] PRIMARY KEY CLUSTERED ([OAT_OatId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_OATAtkId] FOREIGN KEY ([OAT_AtkId]) REFERENCES [CDN].[OAtrybutyKlasy] ([ATK_AtkId]),
    CONSTRAINT [FK_OATPrcId] FOREIGN KEY ([OAT_PrcId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [OATPrcId]
    ON [CDN].[OAtrybuty]([OAT_PrcId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [OATPrcIdAtkId]
    ON [CDN].[OAtrybuty]([OAT_PrcId] ASC, [OAT_AtkId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [OATAtkId]
    ON [CDN].[OAtrybuty]([OAT_AtkId] ASC) WITH (FILLFACTOR = 100);

