CREATE TABLE [CDN].[DetalStanTowary] (
    [DSTwr_DSTwrId]     INT             IDENTITY (1, 1) NOT NULL,
    [DSTwr_StanDetalID] INT             NOT NULL,
    [DSTwr_OptimaId]    INT             NOT NULL,
    [DSTwr_Kod]         VARCHAR (50)    NOT NULL,
    [DSTwr_NumerKat]    NVARCHAR (40)   NOT NULL,
    [DSTwr_SWW]         VARCHAR (20)    NOT NULL,
    [DSTwr_EAN]         VARCHAR (40)    NOT NULL,
    [DSTwr_Nazwa]       NVARCHAR (255)  NOT NULL,
    [DSTwr_Opis]        NVARCHAR (254)  NOT NULL,
    [DSTwr_JM]          NVARCHAR (20)   NOT NULL,
    [DSTwr_JMCalkowite] TINYINT         NOT NULL,
    [DSTwr_Kaucja]      TINYINT         NOT NULL,
    [DSTwr_Cena]        DECIMAL (15, 2) NOT NULL,
    [DSTwr_Waluta]      VARCHAR (3)     NOT NULL,
    [DSTwr_SONId]       INT             NOT NULL,
    [DSTwr_Stawka]      DECIMAL (5, 2)  NOT NULL,
    [DSTwr_Flaga]       SMALLINT        NOT NULL,
    [DSTwr_NieAktywny]  TINYINT         NOT NULL,
    [DSTwr_Typ]         TINYINT         NOT NULL,
    [DSTwr_KntId]       INT             NULL,
    [DSTwr_TS_Mod]      DATETIME        NOT NULL,
    CONSTRAINT [DSTwr_Primary] PRIMARY KEY CLUSTERED ([DSTwr_DSTwrId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DelalStanDSTwr_OptimaID]
    ON [CDN].[DetalStanTowary]([DSTwr_OptimaId] ASC, [DSTwr_StanDetalID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwrDSON]
    ON [CDN].[DetalStanTowary]([DSTwr_SONId] ASC) WITH (FILLFACTOR = 100);

