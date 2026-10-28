CREATE TABLE [CDN].[PracPracaDniGodz] (
    [PGR_PgrId]     INT             IDENTITY (1, 1) NOT NULL,
    [PGR_PprId]     INT             NOT NULL,
    [PGR_Lp]        INT             NOT NULL,
    [PGR_OdGodziny] DATETIME        NOT NULL,
    [PGR_DoGodziny] DATETIME        NOT NULL,
    [PGR_Strefa]    INT             NOT NULL,
    [PGR_DzlId]     INT             NOT NULL,
    [PGR_PrjId]     INT             NOT NULL,
    [PGR_Uwagi]     NVARCHAR (1024) NOT NULL,
    [PGR_OdbNadg]   INT             NOT NULL,
    CONSTRAINT [PGR_Primary] PRIMARY KEY CLUSTERED ([PGR_PgrId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PGRPprLink] FOREIGN KEY ([PGR_PprId]) REFERENCES [CDN].[PracPracaDni] ([PPR_PprId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [PGRLp]
    ON [CDN].[PracPracaDniGodz]([PGR_Lp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PGRPprLink]
    ON [CDN].[PracPracaDniGodz]([PGR_PprId] ASC) WITH (FILLFACTOR = 100);

