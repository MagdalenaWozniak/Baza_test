CREATE TABLE [CDN].[DetalRaporty] (
    [DRap_DRapId]    INT      IDENTITY (1, 1) NOT NULL,
    [DRap_DStaId]    INT      NOT NULL,
    [DRap_DSRapId]   INT      NOT NULL,
    [DRap_TS_Export] DATETIME NULL,
    CONSTRAINT [DRap_Primary] PRIMARY KEY CLUSTERED ([DRap_DRapId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DFplStanowiskoDetal]
    ON [CDN].[DetalRaporty]([DRap_DStaId] ASC, [DRap_DSRapId] ASC) WITH (FILLFACTOR = 100);

