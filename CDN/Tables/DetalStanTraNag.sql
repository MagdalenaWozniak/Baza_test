CREATE TABLE [CDN].[DetalStanTraNag] (
    [DSTrN_DSTrNID]            INT             IDENTITY (1, 1) NOT NULL,
    [DSTrN_StanDetalID]        INT             NOT NULL,
    [DSTrN_FaId]               INT             NOT NULL,
    [DSTrN_ZwrId]              INT             NULL,
    [DSTrN_TypDokumentu]       INT             NOT NULL,
    [DSTrN_NumerNr]            INT             NOT NULL,
    [DSTrN_NumerString]        VARCHAR (31)    NOT NULL,
    [DSTrN_NumerPelny]         AS              ([CDN].[DETALNUMERPELNY]([DSTRN_NUMERNR],[DSTRN_NUMERSTRING])),
    [DSTrN_Bufor]              SMALLINT        NOT NULL,
    [DSTrN_Opis]               NVARCHAR (1024) CONSTRAINT [DF_DSTrN_Opis] DEFAULT ('') NOT NULL,
    [DSTrN_Anulowany]          INT             NOT NULL,
    [DSTrN_DataDok]            DATETIME        NOT NULL,
    [DSTrN_Fiskalna]           TINYINT         NOT NULL,
    [DSTrN_FiskalnaErr]        INT             NULL,
    [DSTrN_PodID]              INT             NULL,
    [DSTrN_OdbID]              INT             NULL,
    [DSTrN_RazemBrutto]        DECIMAL (15, 2) NOT NULL,
    [DSTrN_Rabat]              DECIMAL (5, 2)  NOT NULL,
    [DSTrN_Waluta]             VARCHAR (3)     NOT NULL,
    [DSTrN_OsobaOdbierajaca]   NVARCHAR (40)   NULL,
    [DSTrN_StanSynchronizacji] INT             NULL,
    [DSTrN_OpeID]              INT             NOT NULL,
    [DSTrN_ZmianaId]           INT             NOT NULL,
    [DSTrN_Korekta]            TINYINT         NULL,
    [DSTrN_PARodzajKor]        INT             CONSTRAINT [DF_DSTrN_PARodzajKor] DEFAULT ((0)) NOT NULL,
    [DSTrN_TS_Zal]             DATETIME        NOT NULL,
    CONSTRAINT [DSTrN_Primary] PRIMARY KEY CLUSTERED ([DSTrN_DSTrNID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DSTrNIDOperator] FOREIGN KEY ([DSTrN_OpeID]) REFERENCES [CDN].[DetalStanOperatorzy] ([DSOpe_DSOpeID]),
    CONSTRAINT [FK_DSTrNIDPodmiot] FOREIGN KEY ([DSTrN_PodID]) REFERENCES [CDN].[DetalStanKontrahenci] ([DSKnt_DSKntId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DSTrNIDPodmiot]
    ON [CDN].[DetalStanTraNag]([DSTrN_PodID] ASC, [DSTrN_DSTrNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DSTrNIDOdbiorca]
    ON [CDN].[DetalStanTraNag]([DSTrN_OdbID] ASC, [DSTrN_DSTrNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DSTrNIDOperator]
    ON [CDN].[DetalStanTraNag]([DSTrN_OpeID] ASC, [DSTrN_DSTrNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DSTrNNumer]
    ON [CDN].[DetalStanTraNag]([DSTrN_NumerString] ASC, [DSTrN_NumerNr] ASC, [DSTrN_Anulowany] ASC) WITH (FILLFACTOR = 100);

