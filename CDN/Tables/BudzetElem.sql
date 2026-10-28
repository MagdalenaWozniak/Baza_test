CREATE TABLE [CDN].[BudzetElem] (
    [BuE_BuEId]           INT             IDENTITY (1, 1) NOT NULL,
    [BuE_BuNId]           INT             NOT NULL,
    [BuE_Miesiac]         INT             NOT NULL,
    [BuE_Kwota]           DECIMAL (15, 2) NOT NULL,
    [BuE_KwotaPoprzednia] DECIMAL (15, 2) NOT NULL,
    [BuE_OpeZalID]        INT             NULL,
    [BuE_StaZalId]        INT             NULL,
    [BuE_TS_Zal]          DATETIME        NOT NULL,
    [BuE_OpeModID]        INT             NULL,
    [BuE_StaModId]        INT             NULL,
    [BuE_TS_Mod]          DATETIME        NOT NULL,
    [BuE_OpeModKod]       VARCHAR (20)    CONSTRAINT [DF_BuE_OpeModKod] DEFAULT ('') NOT NULL,
    [BuE_OpeModNazwisko]  NVARCHAR (50)   CONSTRAINT [DF_BuE_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [BuE_OpeZalKod]       VARCHAR (20)    CONSTRAINT [DF_BuE_OpeZalKod] DEFAULT ('') NOT NULL,
    [BuE_OpeZalNazwisko]  NVARCHAR (50)   CONSTRAINT [DF_BuE_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [BuE_Primary] PRIMARY KEY CLUSTERED ([BuE_BuEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_BuEBuNID] FOREIGN KEY ([BuE_BuNId]) REFERENCES [CDN].[BudzetNag] ([BuN_BuNId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [BuEBuNID]
    ON [CDN].[BudzetElem]([BuE_BuNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BuERokMiesiac]
    ON [CDN].[BudzetElem]([BuE_Miesiac] ASC) WITH (FILLFACTOR = 100);

