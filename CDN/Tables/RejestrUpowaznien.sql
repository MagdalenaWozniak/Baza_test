CREATE TABLE [CDN].[RejestrUpowaznien] (
    [RUP_RUPID]          INT            IDENTITY (1, 1) NOT NULL,
    [RUP_Lp]             AS             ([CDN].[RejestrUpowaznienLp]([RUP_RUPID])),
    [RUP_PodID]          INT            NOT NULL,
    [RUP_PodmiotTyp]     SMALLINT       NOT NULL,
    [RUP_ImieNazwisko]   NVARCHAR (50)  NOT NULL,
    [RUP_OsobaID]        INT            NULL,
    [RUP_DataNadania]    DATETIME       NOT NULL,
    [RUP_DataUstania]    DATETIME       NULL,
    [RUP_Opis]           NVARCHAR (MAX) NOT NULL,
    [RUP_OpeZalID]       INT            NULL,
    [RUP_OpeModID]       INT            NULL,
    [RUP_StaZalID]       INT            NULL,
    [RUP_StaModID]       INT            NULL,
    [RUP_TS_Zal]         DATETIME       NOT NULL,
    [RUP_TS_Mod]         DATETIME       NOT NULL,
    [RUP_OpeModKod]      VARCHAR (20)   NOT NULL,
    [RUP_OpeZalKod]      VARCHAR (20)   NOT NULL,
    [RUP_OpeModNazwisko] NVARCHAR (50)  NOT NULL,
    [RUP_OpeZalNazwisko] NVARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_RUP_RUPID] PRIMARY KEY CLUSTERED ([RUP_RUPID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_RUPPodmiot] FOREIGN KEY ([RUP_PodID], [RUP_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp]),
    CONSTRAINT [FK_RUPPrzedstawiciel] FOREIGN KEY ([RUP_OsobaID]) REFERENCES [CDN].[KntOsoby] ([KnO_KnOId])
);


GO
CREATE NONCLUSTERED INDEX [RUP_ImieNazwisko]
    ON [CDN].[RejestrUpowaznien]([RUP_ImieNazwisko] ASC) WITH (FILLFACTOR = 100);

