CREATE TABLE [CDN].[SenditPaczki] (
    [SPA_SPAID]                 INT             IDENTITY (1, 1) NOT NULL,
    [SPA_LP]                    INT             NOT NULL,
    [SPA_SZLID]                 INT             NOT NULL,
    [SPA_SposobPakowania]       NVARCHAR (254)  NOT NULL,
    [SPA_SposobPakowaniaKey]    NVARCHAR (254)  NOT NULL,
    [SPA_KwotaUbezpieczenia]    DECIMAL (15, 2) NOT NULL,
    [SPA_NumerListu]            NVARCHAR (254)  NOT NULL,
    [SPA_URL]                   NVARCHAR (254)  NOT NULL,
    [SPA_Zawartosc]             NVARCHAR (254)  CONSTRAINT [DF_SPA_Zawartosc] DEFAULT ('') NOT NULL,
    [SPA_Waga]                  DECIMAL (15, 2) NOT NULL,
    [SPA_Wysokosc]              DECIMAL (15, 2) NOT NULL,
    [SPA_Szerokosc]             DECIMAL (15, 2) NOT NULL,
    [SPA_Dlugosc]               DECIMAL (15, 2) NOT NULL,
    [SPA_Gabaryt]               TINYINT         CONSTRAINT [DF_SPA_Gabaryt] DEFAULT ((0)) NOT NULL,
    [SPA_Ostroznie]             TINYINT         CONSTRAINT [DF_SPA_Ostroznie] DEFAULT ((0)) NOT NULL,
    [SPA_Niestandardowa]        TINYINT         CONSTRAINT [DF_SPA_Niestandardowa] DEFAULT ((0)) NOT NULL,
    [SPA_DeklarowanaWartosc]    DECIMAL (15, 2) CONSTRAINT [DF_SPA_DeklarowanaWartosc] DEFAULT ((0)) NOT NULL,
    [SPA_IdentyfikatorUKuriera] NVARCHAR (64)   CONSTRAINT [DF_SPA_IdentyfikatorUKuriera] DEFAULT ('') NOT NULL,
    CONSTRAINT [SPA_Primary] PRIMARY KEY CLUSTERED ([SPA_SPAID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SPASenditZleceniePrzesylki] FOREIGN KEY ([SPA_SZLID]) REFERENCES [CDN].[SenditZleceniePrzesylki] ([SZL_SZLID]) ON DELETE CASCADE
);

