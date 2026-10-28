CREATE TABLE [CDN].[AutoEwid] (
    [AuE_AuEID]          INT            IDENTITY (1, 1) NOT NULL,
    [AuE_Rejestracja]    VARCHAR (20)   NOT NULL,
    [AuE_Marka]          NVARCHAR (20)  NOT NULL,
    [AuE_KlasaPoj]       TINYINT        NOT NULL,
    [AuE_Pojemnosc]      SMALLINT       NOT NULL,
    [AuE_Pracownik]      TINYINT        NOT NULL,
    [AuE_Limit]          SMALLINT       NOT NULL,
    [AuE_PrcId]          INT            NULL,
    [AuE_PrcNazwisko]    NVARCHAR (100) NOT NULL,
    [AuE_PrcAdres]       NVARCHAR (100) NOT NULL,
    [AuE_Opis]           NVARCHAR (254) NOT NULL,
    [AuE_Nieaktywny]     TINYINT        CONSTRAINT [DF_AuE_Nieaktywny] DEFAULT ((0)) NOT NULL,
    [AuE_OpeZalID]       INT            NULL,
    [AuE_StaZalId]       INT            NULL,
    [AuE_TS_Zal]         DATETIME       NOT NULL,
    [AuE_OpeModID]       INT            NULL,
    [AuE_StaModId]       INT            NULL,
    [AuE_TS_Mod]         DATETIME       NOT NULL,
    [AuE_DataRoz]        DATETIME       NULL,
    [AuE_DataZak]        DATETIME       NULL,
    [AuE_ZakID]          INT            NULL,
    [AuE_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_AuE_OpeModKod] DEFAULT ('') NOT NULL,
    [AuE_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_AuE_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [AuE_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_AuE_OpeZalKod] DEFAULT ('') NOT NULL,
    [AuE_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_AuE_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [AuE_Primary] PRIMARY KEY CLUSTERED ([AuE_AuEID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AuEPracownik] FOREIGN KEY ([AuE_PrcId]) REFERENCES [CDN].[PracKod] ([PRA_PraId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AuERejestracja]
    ON [CDN].[AutoEwid]([AuE_Rejestracja] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [AuEPracownik]
    ON [CDN].[AutoEwid]([AuE_PrcId] ASC) WITH (FILLFACTOR = 100);

