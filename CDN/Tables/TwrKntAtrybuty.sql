CREATE TABLE [CDN].[TwrKntAtrybuty] (
    [TKA_TKAId]      INT            IDENTITY (1, 1) NOT NULL,
    [TKA_TwAId]      INT            NULL,
    [TKA_PodmiotTyp] SMALLINT       NULL,
    [TKA_PodmiotId]  INT            NULL,
    [TKA_WartoscTxt] NVARCHAR (100) NOT NULL,
    CONSTRAINT [TKA_Primary] PRIMARY KEY CLUSTERED ([TKA_TKAId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TKAPodmiot] FOREIGN KEY ([TKA_PodmiotId], [TKA_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp]) ON DELETE CASCADE,
    CONSTRAINT [FK_TKATwrAtrybut] FOREIGN KEY ([TKA_TwAId]) REFERENCES [CDN].[TwrAtrybuty] ([TwA_TwAId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [TKAPodmiot]
    ON [CDN].[TwrKntAtrybuty]([TKA_PodmiotId] ASC, [TKA_PodmiotTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TKATwrAtrybut]
    ON [CDN].[TwrKntAtrybuty]([TKA_TwAId] ASC) WITH (FILLFACTOR = 100);

