CREATE TABLE [CDN].[SzDekNag] (
    [SzD_SzDId]          INT           IDENTITY (1, 1) NOT NULL,
    [SzD_Typ]            SMALLINT      NOT NULL,
    [SzD_PodTyp]         INT           NOT NULL,
    [SzD_Symbol]         VARCHAR (20)  NOT NULL,
    [SzD_Nazwa]          NVARCHAR (50) NOT NULL,
    [SzD_NieAktywny]     TINYINT       NOT NULL,
    [SzD_OpeZalID]       INT           NULL,
    [SzD_StaZalId]       INT           NULL,
    [SzD_TS_Zal]         DATETIME      NOT NULL,
    [SzD_OpeModID]       INT           NULL,
    [SzD_StaModId]       INT           NULL,
    [SzD_TS_Mod]         DATETIME      NOT NULL,
    [SzD_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_SzD_OpeModKod] DEFAULT ('') NOT NULL,
    [SzD_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_SzD_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [SzD_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_SzD_OpeZalKod] DEFAULT ('') NOT NULL,
    [SzD_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_SzD_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [SzD_Primary] PRIMARY KEY CLUSTERED ([SzD_SzDId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SzDSymbol]
    ON [CDN].[SzDekNag]([SzD_Typ] ASC, [SzD_Symbol] ASC) WITH (FILLFACTOR = 100);

