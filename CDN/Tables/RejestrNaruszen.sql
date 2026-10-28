CREATE TABLE [CDN].[RejestrNaruszen] (
    [RUN_RUNID]               INT            IDENTITY (1, 1) NOT NULL,
    [RUN_Lp]                  AS             ([CDN].[RejestrNaruszenLp]([RUN_RUNID])),
    [RUN_PodID]               INT            NOT NULL,
    [RUN_PodmiotTyp]          SMALLINT       NOT NULL,
    [RUN_Akronim]             NVARCHAR (50)  NOT NULL,
    [RUN_ImieNazwisko]        NVARCHAR (50)  NOT NULL,
    [RUN_OsobaID]             INT            NULL,
    [RUN_DataNaruszenia]      DATETIME       NOT NULL,
    [RUN_MiejsceNaruszenia]   NVARCHAR (200) NOT NULL,
    [RUN_Zgloszone]           INT            NOT NULL,
    [RUN_DataZgloszenia]      DATETIME       NULL,
    [RUN_MiejsceZgloszenia]   NVARCHAR (200) NOT NULL,
    [RUN_LiczbaRekordow]      INT            NOT NULL,
    [RUN_PrzyczynaOpoznienia] NVARCHAR (MAX) NOT NULL,
    [RUN_CharakterNaruszenia] NVARCHAR (MAX) NOT NULL,
    [RUN_KategoriaDanych]     NVARCHAR (MAX) NOT NULL,
    [RUN_Konsekwencje]        NVARCHAR (MAX) NOT NULL,
    [RUN_PodjeteSrodki]       NVARCHAR (MAX) NOT NULL,
    [RUN_OpeZalID]            INT            NULL,
    [RUN_OpeModID]            INT            NULL,
    [RUN_StaZalID]            INT            NULL,
    [RUN_StaModID]            INT            NULL,
    [RUN_TS_Zal]              DATETIME       NOT NULL,
    [RUN_TS_Mod]              DATETIME       NOT NULL,
    [RUN_OpeModKod]           VARCHAR (20)   NOT NULL,
    [RUN_OpeZalKod]           VARCHAR (20)   NOT NULL,
    [RUN_OpeModNazwisko]      NVARCHAR (50)  NOT NULL,
    [RUN_OpeZalNazwisko]      NVARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_RUN_RUNID] PRIMARY KEY CLUSTERED ([RUN_RUNID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_RUNPodmiot] FOREIGN KEY ([RUN_PodID], [RUN_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp]),
    CONSTRAINT [FK_RUNPrzedstawiciel] FOREIGN KEY ([RUN_OsobaID]) REFERENCES [CDN].[KntOsoby] ([KnO_KnOId])
);


GO
CREATE NONCLUSTERED INDEX [RUN_ImieNazwisko]
    ON [CDN].[RejestrNaruszen]([RUN_ImieNazwisko] ASC) WITH (FILLFACTOR = 100);

