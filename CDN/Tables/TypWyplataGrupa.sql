CREATE TABLE [CDN].[TypWyplataGrupa] (
    [TWY_TwyId]          INT           IDENTITY (1, 1) NOT NULL,
    [TWY_Nazwa]          NVARCHAR (40) NOT NULL,
    [TWY_Nieaktywna]     TINYINT       NOT NULL,
    [TWY_OpeZalId]       INT           NULL,
    [TWY_StaZalId]       INT           NULL,
    [TWY_TS_Zal]         DATETIME      NOT NULL,
    [TWY_OpeModId]       INT           NULL,
    [TWY_StaModId]       INT           NULL,
    [TWY_TS_Mod]         DATETIME      NOT NULL,
    [TWY_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_TWY_OpeModKod] DEFAULT ('') NOT NULL,
    [TWY_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_TWY_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [TWY_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_TWY_OpeZalKod] DEFAULT ('') NOT NULL,
    [TWY_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_TWY_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [TWY_Primary] PRIMARY KEY CLUSTERED ([TWY_TwyId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TWYNazwa]
    ON [CDN].[TypWyplataGrupa]([TWY_Nazwa] ASC) WITH (FILLFACTOR = 100);

