CREATE TABLE [CDN].[Katalogi] (
    [Ktl_KtlId]          INT            IDENTITY (1, 1) NOT NULL,
    [Ktl_SSID]           INT            NULL,
    [Ktl_Symbol]         VARCHAR (20)   NOT NULL,
    [Ktl_Nazwa]          NVARCHAR (50)  NOT NULL,
    [Ktl_Numeracja]      NVARCHAR (5)   NULL,
    [Ktl_IBard24]        NVARCHAR (255) NOT NULL,
    [Ktl_Domyslny]       TINYINT        CONSTRAINT [DF_Ktl_Domyslny] DEFAULT ((0)) NOT NULL,
    [Ktl_OpeZalID]       INT            NULL,
    [Ktl_StaZalId]       INT            NULL,
    [Ktl_TS_Zal]         DATETIME       NOT NULL,
    [Ktl_OpeModID]       INT            NULL,
    [Ktl_StaModId]       INT            NULL,
    [Ktl_TS_Mod]         DATETIME       NOT NULL,
    [Ktl_IBard24Id]      BIGINT         NULL,
    [Ktl_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_Ktl_OpeModKod] DEFAULT ('') NOT NULL,
    [Ktl_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_Ktl_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [Ktl_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_Ktl_OpeZalKod] DEFAULT ('') NOT NULL,
    [Ktl_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_Ktl_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [Ktl_Primary] PRIMARY KEY CLUSTERED ([Ktl_KtlId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KtlSymbol]
    ON [CDN].[Katalogi]([Ktl_Symbol] ASC) WITH (FILLFACTOR = 100);

