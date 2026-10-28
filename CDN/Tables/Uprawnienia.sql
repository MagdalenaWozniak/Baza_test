CREATE TABLE [CDN].[Uprawnienia] (
    [UPR_UprId]          INT            IDENTITY (1, 1) NOT NULL,
    [UPR_PraId]          INT            NOT NULL,
    [UPR_DkmId]          INT            NULL,
    [UPR_Rodzaj]         TINYINT        NOT NULL,
    [UPR_Nazwa]          NVARCHAR (250) NOT NULL,
    [UPR_WymagLubMowa]   TINYINT        NOT NULL,
    [UPR_UkonLubPismo]   TINYINT        NOT NULL,
    [UPR_StMowa]         NVARCHAR (30)  NOT NULL,
    [UPR_StPismo]        NVARCHAR (30)  NOT NULL,
    [UPR_KursOd]         DATETIME       NULL,
    [UPR_KursDo]         DATETIME       NULL,
    [UPR_KursTermin]     DATETIME       NULL,
    [UPR_Opis]           NVARCHAR (512) NOT NULL,
    [UPR_Przypomnienie]  TINYINT        NOT NULL,
    [UPR_Zrodlo]         TINYINT        CONSTRAINT [DF_UPR_Zrodlo] DEFAULT ((0)) NOT NULL,
    [UPR_OpeZalId]       INT            NULL,
    [UPR_StaZalId]       INT            NULL,
    [UPR_TS_Zal]         DATETIME       NOT NULL,
    [UPR_OpeModId]       INT            NULL,
    [UPR_StaModId]       INT            NULL,
    [UPR_TS_Mod]         DATETIME       NOT NULL,
    [UPR_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_UPR_OpeModKod] DEFAULT ('') NOT NULL,
    [UPR_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_UPR_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [UPR_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_UPR_OpeZalKod] DEFAULT ('') NOT NULL,
    [UPR_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_UPR_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [UPR_Primary] PRIMARY KEY CLUSTERED ([UPR_UprId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_UPRDkmLink] FOREIGN KEY ([UPR_DkmId]) REFERENCES [CDN].[DaneKadMod] ([DKM_DkmId]),
    CONSTRAINT [FK_UPRPraLink] FOREIGN KEY ([UPR_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [UPRPraLink]
    ON [CDN].[Uprawnienia]([UPR_PraId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [UPRDkmLink]
    ON [CDN].[Uprawnienia]([UPR_DkmId] ASC) WITH (FILLFACTOR = 100);

