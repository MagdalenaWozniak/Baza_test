CREATE TABLE [CDN].[RejestracjaZgodZrodlo] (
    [RZZ_RZZId]          INT            IDENTITY (1, 1) NOT NULL,
    [RZZ_Nazwa]          NVARCHAR (255) NOT NULL,
    [RZZ_Nieaktywny]     TINYINT        NOT NULL,
    [RZZ_OpeZalId]       INT            NULL,
    [RZZ_StaZalId]       INT            NULL,
    [RZZ_TS_Zal]         DATETIME       NOT NULL,
    [RZZ_OpeModId]       INT            NULL,
    [RZZ_StaModId]       INT            NULL,
    [RZZ_TS_Mod]         DATETIME       NOT NULL,
    [RZZ_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_RZZ_OpeModKod] DEFAULT ('') NOT NULL,
    [RZZ_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_RZZ_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [RZZ_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_RZZ_OpeZalKod] DEFAULT ('') NOT NULL,
    [RZZ_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_RZZ_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [RZZ_Primary] PRIMARY KEY CLUSTERED ([RZZ_RZZId] ASC) WITH (FILLFACTOR = 100)
);

