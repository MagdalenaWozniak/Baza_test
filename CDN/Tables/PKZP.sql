CREATE TABLE [CDN].[PKZP] (
    [KZP_KzpId]          INT            IDENTITY (1, 1) NOT NULL,
    [KZP_PraId]          INT            NOT NULL,
    [KZP_Opis]           NVARCHAR (512) NOT NULL,
    [KZP_OkresOd]        DATETIME       NOT NULL,
    [KZP_OkresDo]        DATETIME       NOT NULL,
    [KZP_OpeZalId]       INT            NULL,
    [KZP_StaZalId]       INT            NULL,
    [KZP_TS_Zal]         DATETIME       NOT NULL,
    [KZP_OpeModId]       INT            NULL,
    [KZP_StaModId]       INT            NULL,
    [KZP_TS_Mod]         DATETIME       NOT NULL,
    [KZP_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_KZP_OpeModKod] DEFAULT ('') NOT NULL,
    [KZP_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_KZP_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [KZP_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_KZP_OpeZalKod] DEFAULT ('') NOT NULL,
    [KZP_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_KZP_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [KZP_Primary] PRIMARY KEY CLUSTERED ([KZP_KzpId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_KZPPraLink] FOREIGN KEY ([KZP_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [KZPPraLink]
    ON [CDN].[PKZP]([KZP_PraId] ASC) WITH (FILLFACTOR = 100);

