CREATE TABLE [CDN].[SerieKalNag] (
    [SLN_SlnId]          INT            IDENTITY (1, 1) NOT NULL,
    [SLN_Symbol]         VARCHAR (20)   NOT NULL,
    [SLN_Nazwa]          NVARCHAR (50)  NOT NULL,
    [SLN_Opis]           NVARCHAR (254) NOT NULL,
    [SLN_OpeZalId]       INT            NULL,
    [SLN_StaZalId]       INT            NULL,
    [SLN_TS_Zal]         DATETIME       NOT NULL,
    [SLN_OpeModId]       INT            NULL,
    [SLN_StaModId]       INT            NULL,
    [SLN_TS_Mod]         DATETIME       NOT NULL,
    [SLN_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_SLN_OpeModKod] DEFAULT ('') NOT NULL,
    [SLN_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_SLN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [SLN_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_SLN_OpeZalKod] DEFAULT ('') NOT NULL,
    [SLN_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_SLN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [SLN_Primary] PRIMARY KEY CLUSTERED ([SLN_SlnId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SlNSymbol]
    ON [CDN].[SerieKalNag]([SLN_Symbol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SlNNazwa]
    ON [CDN].[SerieKalNag]([SLN_Nazwa] ASC) WITH (FILLFACTOR = 100);

