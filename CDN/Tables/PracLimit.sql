CREATE TABLE [CDN].[PracLimit] (
    [PLN_PlnId]                 INT             IDENTITY (1, 1) NOT NULL,
    [PLN_PraId]                 INT             NOT NULL,
    [PLN_LnbId]                 INT             NOT NULL,
    [PLN_ParentId]              INT             NULL,
    [PLN_LimitDodatkowy]        TINYINT         NOT NULL,
    [PLN_LimitDodatkowyDni]     INT             NOT NULL,
    [PLN_Rok]                   INT             NOT NULL,
    [PLN_OkresOd]               DATETIME        NOT NULL,
    [PLN_WaznyOd]               DATETIME        NOT NULL,
    [PLN_OkresDo]               DATETIME        NOT NULL,
    [PLN_PrzeniesienieF]        DECIMAL (15, 4) NOT NULL,
    [PLN_PrzeniesienieCzas]     DATETIME        NOT NULL,
    [PLN_KorektaPomniejszajaca] TINYINT         NOT NULL,
    [PLN_KorektaRecznaF]        DECIMAL (15, 4) NOT NULL,
    [PLN_KorektaRecznaCzas]     DATETIME        NOT NULL,
    [PLN_ProporcjonalnyF]       DECIMAL (15, 4) NOT NULL,
    [PLN_ProporcjonalnyCzas]    DATETIME        NOT NULL,
    [PLN_NalezneF]              DECIMAL (15, 4) NOT NULL,
    [PLN_NalezneCzas]           DATETIME        NOT NULL,
    [PLN_NalezneLacznieF]       DECIMAL (15, 4) NOT NULL,
    [PLN_NalezneLacznieCzas]    DATETIME        NOT NULL,
    [PLN_WykorzystaneF]         DECIMAL (15, 4) NOT NULL,
    [PLN_WykorzystaneCzas]      DATETIME        NOT NULL,
    [PLN_NaZadanie]             INT             NOT NULL,
    [PLN_Nazwa]                 NVARCHAR (50)   NOT NULL,
    [PLN_PozostaloF]            DECIMAL (15, 4) NOT NULL,
    [PLN_PozostaloCzas]         DATETIME        NOT NULL,
    [PLN_Opis]                  NVARCHAR (200)  NOT NULL,
    [PLN_OpeZalId]              INT             NULL,
    [PLN_StaZalId]              INT             NULL,
    [PLN_TS_Zal]                DATETIME        NOT NULL,
    [PLN_OpeModId]              INT             NULL,
    [PLN_StaModId]              INT             NULL,
    [PLN_TS_Mod]                DATETIME        NOT NULL,
    [PLN_PlanowanyF]            DECIMAL (15, 4) CONSTRAINT [DF_PLN_PlanowanyF] DEFAULT ((0.0000)) NOT NULL,
    [PLN_PlanowanyCzas]         DATETIME        CONSTRAINT [DF_PLN_PlanowanyCzas] DEFAULT ((-2)) NOT NULL,
    [PLN_EkwiwalentF]           DECIMAL (15, 4) CONSTRAINT [DF_PLN_EkwiwalentF] DEFAULT ((0.0000)) NOT NULL,
    [PLN_EkwiwalentCzas]        DATETIME        CONSTRAINT [DF_PLN_EkwiwalentCzas] DEFAULT ((-2)) NOT NULL,
    [PLN_KorektaOkres]          TINYINT         CONSTRAINT [DF_PLN_KorektaOkres] DEFAULT ((0)) NOT NULL,
    [PLN_Zakonczony]            TINYINT         CONSTRAINT [DF_PLN_Zakonczony] DEFAULT ((0)) NOT NULL,
    [PLN_Miesiac30]             TINYINT         CONSTRAINT [DF_PLN_Miesiac30] DEFAULT ((0)) NOT NULL,
    [PLN_PierwszaPraca]         TINYINT         CONSTRAINT [DF_PLN_PierwszaPraca] DEFAULT ((0)) NOT NULL,
    [PLN_LicznikMies]           TINYINT         CONSTRAINT [DF_PLN_LicznikMies] DEFAULT ((0)) NOT NULL,
    [PLN_OpeModKod]             VARCHAR (20)    CONSTRAINT [DF_PLN_OpeModKod] DEFAULT ('') NOT NULL,
    [PLN_OpeModNazwisko]        NVARCHAR (50)   CONSTRAINT [DF_PLN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [PLN_OpeZalKod]             VARCHAR (20)    CONSTRAINT [DF_PLN_OpeZalKod] DEFAULT ('') NOT NULL,
    [PLN_OpeZalNazwisko]        NVARCHAR (50)   CONSTRAINT [DF_PLN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [PLN_NaZadaniePoprzedni]    INT             NOT NULL,
    CONSTRAINT [PLN_Primary] PRIMARY KEY CLUSTERED ([PLN_PlnId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PLNLnbLink] FOREIGN KEY ([PLN_LnbId]) REFERENCES [CDN].[LimitNieobec] ([LNB_LnbId]),
    CONSTRAINT [FK_PLNPraLink] FOREIGN KEY ([PLN_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [PLNLnbOkrNazwa]
    ON [CDN].[PracLimit]([PLN_Nazwa] ASC, [PLN_OkresOd] ASC, [PLN_WaznyOd] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PLNPraLink]
    ON [CDN].[PracLimit]([PLN_PraId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PLNLnbLink]
    ON [CDN].[PracLimit]([PLN_LnbId] ASC) WITH (FILLFACTOR = 100);

