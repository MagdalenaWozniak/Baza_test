CREATE TABLE [CDN].[DetalStanZmiany] (
    [DSZ_DSZID]                     INT             IDENTITY (1, 1) NOT NULL,
    [DSZ_StanDetalID]               INT             NOT NULL,
    [DSZ_NumerNr]                   INT             NOT NULL,
    [DSZ_NumerPelny]                VARCHAR (30)    NOT NULL,
    [DSZ_OpeIdOtw]                  INT             NOT NULL,
    [DSZ_OpeIdZamk]                 INT             NOT NULL,
    [DSZ_Bufor]                     SMALLINT        NOT NULL,
    [DSZ_DataOtw]                   DATETIME        NOT NULL,
    [DSZ_DataZamk]                  DATETIME        NOT NULL,
    [DSZ_IloscAnulowanychParagonow] INT             NOT NULL,
    [DSZ_StanKasy]                  DECIMAL (15, 2) NOT NULL,
    [DSZ_KPOtw]                     DECIMAL (15, 2) NOT NULL,
    [DSZ_KWZamk]                    DECIMAL (15, 2) NOT NULL,
    [DSZ_KwotaZPrzeniesienia]       DECIMAL (15, 2) NOT NULL,
    CONSTRAINT [DSZ_Primary] PRIMARY KEY CLUSTERED ([DSZ_DSZID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DSZIDOperatorZam]
    ON [CDN].[DetalStanZmiany]([DSZ_OpeIdZamk] ASC, [DSZ_DSZID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DSZIDOperatorOtw]
    ON [CDN].[DetalStanZmiany]([DSZ_OpeIdOtw] ASC, [DSZ_DSZID] ASC) WITH (FILLFACTOR = 100);

