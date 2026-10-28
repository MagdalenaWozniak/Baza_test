CREATE TABLE [CDN].[Producenci] (
    [Prd_PrdId]          INT            IDENTITY (1, 1) NOT NULL,
    [Prd_Kod]            VARCHAR (40)   NOT NULL,
    [Prd_Nazwa]          NVARCHAR (250) NOT NULL,
    [Prd_URL]            VARCHAR (250)  NULL,
    [Prd_Logo]           INT            NULL,
    [Prd_OpeZalId]       INT            NULL,
    [Prd_StaZalId]       INT            NULL,
    [Prd_TS_Zal]         DATETIME       NOT NULL,
    [Prd_OpeModId]       INT            NULL,
    [Prd_StaModId]       INT            NULL,
    [Prd_TS_Mod]         DATETIME       NOT NULL,
    [Prd_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_Prd_OpeModKod] DEFAULT ('') NOT NULL,
    [Prd_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_Prd_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [Prd_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_Prd_OpeZalKod] DEFAULT ('') NOT NULL,
    [Prd_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_Prd_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [Prd_Primary] PRIMARY KEY CLUSTERED ([Prd_PrdId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PrdKod]
    ON [CDN].[Producenci]([Prd_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PrdNazwa]
    ON [CDN].[Producenci]([Prd_Nazwa] ASC, [Prd_PrdId] ASC) WITH (FILLFACTOR = 100);

