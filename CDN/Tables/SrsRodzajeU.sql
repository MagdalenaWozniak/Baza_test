CREATE TABLE [CDN].[SrsRodzajeU] (
    [SrR_SrRId]          INT           IDENTITY (1, 1) NOT NULL,
    [SrR_Kod]            VARCHAR (20)  NOT NULL,
    [SrR_Nazwa]          NVARCHAR (50) NOT NULL,
    [SrR_Nieaktywny]     TINYINT       NOT NULL,
    [SrR_OpeZalId]       INT           NULL,
    [SrR_StaZalId]       INT           NULL,
    [SrR_TS_Zal]         DATETIME      NOT NULL,
    [SrR_OpeModId]       INT           NULL,
    [SrR_StaModId]       INT           NULL,
    [SrR_TS_Mod]         DATETIME      NOT NULL,
    [SrR_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_SrR_OpeModKod] DEFAULT ('') NOT NULL,
    [SrR_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_SrR_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [SrR_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_SrR_OpeZalKod] DEFAULT ('') NOT NULL,
    [SrR_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_SrR_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [SrR_Primary] PRIMARY KEY CLUSTERED ([SrR_SrRId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrUKod]
    ON [CDN].[SrsRodzajeU]([SrR_Kod] ASC) WITH (FILLFACTOR = 100);

