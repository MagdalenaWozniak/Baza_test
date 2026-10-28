CREATE TABLE [CDN].[DetalZapisyKB] (
    [DZKB_DZKBID]             INT             IDENTITY (1, 1) NOT NULL,
    [DZKB_DSZKBID]            INT             NOT NULL,
    [DZKB_StanDetalID]        INT             NOT NULL,
    [DZKB_DSFPlId]            INT             NOT NULL,
    [DZKB_TypDokumentu]       INT             NOT NULL,
    [DZKB_NumerNr]            INT             NOT NULL,
    [DZKB_NumerString]        VARCHAR (31)    NOT NULL,
    [DZKB_NumerPelny]         VARCHAR (50)    NOT NULL,
    [DZKB_DataDok]            DATETIME        NOT NULL,
    [DZKB_PodID]              INT             NULL,
    [DZKB_RazemBrutto]        DECIMAL (15, 2) NOT NULL,
    [DZKB_StanSynchronizacji] INT             NULL,
    [DZKB_OpeID]              INT             NOT NULL,
    [DZKB_Opis]               NVARCHAR (254)  NOT NULL,
    [DZKB_OptimaId]           INT             NULL,
    [DZKB_TS_Export]          DATETIME        NULL,
    [DZKB_DDfID]              INT             CONSTRAINT [DF_DZKB_DDfID] DEFAULT ((0)) NOT NULL,
    [DZKB_Typ]                INT             CONSTRAINT [DF_DZKB_Typ] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [DZKB_Primary] PRIMARY KEY CLUSTERED ([DZKB_DZKBID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DZKBIDPodmiot]
    ON [CDN].[DetalZapisyKB]([DZKB_PodID] ASC, [DZKB_DZKBID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DZKBIDOperator]
    ON [CDN].[DetalZapisyKB]([DZKB_DZKBID] ASC, [DZKB_OpeID] ASC) WITH (FILLFACTOR = 100);

