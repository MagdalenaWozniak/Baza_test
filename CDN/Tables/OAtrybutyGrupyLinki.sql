CREATE TABLE [CDN].[OAtrybutyGrupyLinki] (
    [AGL_AglId]      INT           IDENTITY (1, 1) NOT NULL,
    [AGL_AtgId]      INT           NOT NULL,
    [AGL_AtkId]      INT           NOT NULL,
    [AGL_Lp]         INT           NOT NULL,
    [AGL_NazwaKlasy] NVARCHAR (41) NOT NULL,
    CONSTRAINT [AGL_Primary] PRIMARY KEY CLUSTERED ([AGL_AglId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AGLAtgId] FOREIGN KEY ([AGL_AtgId]) REFERENCES [CDN].[OAtrybutyGrupy] ([ATG_AtgId]) ON DELETE CASCADE,
    CONSTRAINT [FK_AGLAtkId] FOREIGN KEY ([AGL_AtkId]) REFERENCES [CDN].[OAtrybutyKlasy] ([ATK_AtkId])
);


GO
CREATE NONCLUSTERED INDEX [AGLAtkId]
    ON [CDN].[OAtrybutyGrupyLinki]([AGL_AtkId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [AGLAtgId]
    ON [CDN].[OAtrybutyGrupyLinki]([AGL_AtgId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AGLAtkIdAtgId]
    ON [CDN].[OAtrybutyGrupyLinki]([AGL_AtgId] ASC, [AGL_AtkId] ASC) WITH (FILLFACTOR = 100);

