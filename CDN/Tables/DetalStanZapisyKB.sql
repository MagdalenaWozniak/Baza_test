CREATE TABLE [CDN].[DetalStanZapisyKB] (
    [DSZKB_DSZKBID]            INT             IDENTITY (1, 1) NOT NULL,
    [DSZKB_StanDetalID]        INT             NOT NULL,
    [DSZKB_DSFPlId]            INT             NOT NULL,
    [DSZKB_TypDokumentu]       INT             NOT NULL,
    [DSZKB_NumerNr]            INT             NOT NULL,
    [DSZKB_NumerString]        VARCHAR (31)    NOT NULL,
    [DSZKB_NumerPelny]         AS              ([CDN].[DETALNUMERPELNY]([DSZKB_NUMERNR],[DSZKB_NUMERSTRING])),
    [DSZKB_Bufor]              SMALLINT        NOT NULL,
    [DSZKB_DataDok]            DATETIME        NOT NULL,
    [DSZKB_PodID]              INT             NULL,
    [DSZKB_RazemBrutto]        DECIMAL (15, 2) NOT NULL,
    [DSZKB_StanSynchronizacji] INT             NULL,
    [DSZKB_OpeID]              INT             NOT NULL,
    [DSZKB_Opis]               NVARCHAR (254)  NULL,
    [DSZKB_ZmianaId]           INT             NOT NULL,
    CONSTRAINT [DSZKB_Primary] PRIMARY KEY CLUSTERED ([DSZKB_DSZKBID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DSZKBIDPodmiot]
    ON [CDN].[DetalStanZapisyKB]([DSZKB_PodID] ASC, [DSZKB_DSZKBID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DSZKBIDOperator]
    ON [CDN].[DetalStanZapisyKB]([DSZKB_DSZKBID] ASC, [DSZKB_OpeID] ASC) WITH (FILLFACTOR = 100);

