CREATE TABLE [CDN].[OpisKadry] (
    [OPK_OpkId]        INT             IDENTITY (1, 1) NOT NULL,
    [OPK_RodzajZrodla] INT             NOT NULL,
    [OPK_ZrodloId]     INT             NOT NULL,
    [OPK_PraId]        INT             NULL,
    [OPK_DzlId]        INT             NOT NULL,
    [OPK_PrjId]        INT             NOT NULL,
    [OPK_Procent]      DECIMAL (15, 4) NOT NULL,
    CONSTRAINT [OPK_Primary] PRIMARY KEY CLUSTERED ([OPK_OpkId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_OPKDzlId] FOREIGN KEY ([OPK_DzlId]) REFERENCES [CDN].[Dzialy] ([DZL_DzlId]),
    CONSTRAINT [FK_OPKPraLink] FOREIGN KEY ([OPK_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [OPKPraLink]
    ON [CDN].[OpisKadry]([OPK_PraId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [OPKDzlId]
    ON [CDN].[OpisKadry]([OPK_DzlId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [OPKPrjLink]
    ON [CDN].[OpisKadry]([OPK_PrjId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [OPKUnikalny]
    ON [CDN].[OpisKadry]([OPK_RodzajZrodla] ASC, [OPK_ZrodloId] ASC, [OPK_DzlId] ASC, [OPK_PrjId] ASC) WITH (FILLFACTOR = 100);

