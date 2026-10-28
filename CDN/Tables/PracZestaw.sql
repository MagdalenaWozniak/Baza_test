CREATE TABLE [CDN].[PracZestaw] (
    [PZE_PzeId]          INT           IDENTITY (1, 1) NOT NULL,
    [PZE_PraId]          INT           NOT NULL,
    [PZE_Tryb]           TINYINT       NULL,
    [PZE_ParentId]       INT           NULL,
    [PZE_OkresOd]        DATETIME      NOT NULL,
    [PZE_OkresDo]        DATETIME      NOT NULL,
    [PZE_Ilosc]          INT           NOT NULL,
    [PZE_Czas]           DATETIME      NOT NULL,
    [PZE_CzasNoc]        DATETIME      NOT NULL,
    [PZE_CzasWolne]      DATETIME      NOT NULL,
    [PZE_CzasSW]         DATETIME      NOT NULL,
    [PZE_Nadgodziny50]   DATETIME      NOT NULL,
    [PZE_Nadgodziny100]  DATETIME      NOT NULL,
    [PZE_NadgodzinySW]   DATETIME      NOT NULL,
    [PZE_OpeZalId]       INT           NULL,
    [PZE_StaZalId]       INT           NULL,
    [PZE_TS_Zal]         DATETIME      NOT NULL,
    [PZE_OpeModId]       INT           NULL,
    [PZE_StaModId]       INT           NULL,
    [PZE_TS_Mod]         DATETIME      NOT NULL,
    [PZE_Zrodlo]         TINYINT       CONSTRAINT [DF_PZE_Zrodlo] DEFAULT ((0)) NOT NULL,
    [PZE_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_PZE_OpeModKod] DEFAULT ('') NOT NULL,
    [PZE_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_PZE_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [PZE_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_PZE_OpeZalKod] DEFAULT ('') NOT NULL,
    [PZE_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_PZE_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [PZE_Primary] PRIMARY KEY CLUSTERED ([PZE_PzeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PZEPraLink] FOREIGN KEY ([PZE_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [PZEPraLink]
    ON [CDN].[PracZestaw]([PZE_PraId] ASC, [PZE_OkresOd] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KeyParentId]
    ON [CDN].[PracZestaw]([PZE_ParentId] ASC) WITH (FILLFACTOR = 100);

