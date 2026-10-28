CREATE TABLE [CDN].[KalendDniGodz] (
    [KDG_KdgId]     INT      IDENTITY (1, 1) NOT NULL,
    [KDG_KadId]     INT      NOT NULL,
    [KDG_Lp]        INT      NOT NULL,
    [KDG_OdGodziny] DATETIME NOT NULL,
    [KDG_DoGodziny] DATETIME NOT NULL,
    [KDG_Strefa]    INT      NOT NULL,
    [KDG_DzlId]     INT      NULL,
    [KDG_PrjId]     INT      NULL,
    CONSTRAINT [KDG_Primary] PRIMARY KEY CLUSTERED ([KDG_KdgId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [KDGLp]
    ON [CDN].[KalendDniGodz]([KDG_Lp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PDGKadLink]
    ON [CDN].[KalendDniGodz]([KDG_KadId] ASC) WITH (FILLFACTOR = 100);

