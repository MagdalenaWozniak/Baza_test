CREATE TABLE [CDN].[GrupyKontNag] (
    [GKN_GKNID]          INT           IDENTITY (1, 1) NOT NULL,
    [GKN_OObId]          INT           NULL,
    [GKN_Symbol]         VARCHAR (20)  NOT NULL,
    [GKN_NieAktywny]     TINYINT       CONSTRAINT [DF_GKN_NieAktywny] DEFAULT ((0)) NULL,
    [GKN_OpeZalId]       INT           NULL,
    [GKN_StaZalId]       INT           NULL,
    [GKN_TS_Zal]         DATETIME      NOT NULL,
    [GKN_OpeModID]       INT           NULL,
    [GKN_StaModId]       INT           NULL,
    [GKN_TS_Mod]         DATETIME      NOT NULL,
    [GKN_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_GKN_OpeModKod] DEFAULT ('') NOT NULL,
    [GKN_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_GKN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [GKN_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_GKN_OpeZalKod] DEFAULT ('') NOT NULL,
    [GKN_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_GKN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [GKN_Primary] PRIMARY KEY CLUSTERED ([GKN_GKNID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_GKNOkrObr] FOREIGN KEY ([GKN_OObId]) REFERENCES [CDN].[OkresyObrach] ([OOb_OObID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [GKNSymbol]
    ON [CDN].[GrupyKontNag]([GKN_Symbol] ASC, [GKN_OObId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [GKNOkrObr]
    ON [CDN].[GrupyKontNag]([GKN_OObId] ASC) WITH (FILLFACTOR = 100);

