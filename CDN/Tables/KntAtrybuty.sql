CREATE TABLE [CDN].[KntAtrybuty] (
    [KnA_KnAId]            INT             IDENTITY (1, 1) NOT NULL,
    [KnA_DeAId]            INT             NOT NULL,
    [KnA_PodmiotTyp]       SMALLINT        NULL,
    [KnA_PodmiotId]        INT             NULL,
    [KnA_WartoscTxt]       NVARCHAR (1024) NOT NULL,
    [KnA_CzyKopiowac]      TINYINT         NOT NULL,
    [KnA_CzyKod]           TINYINT         NOT NULL,
    [KnA_CzyPrzenosic]     TINYINT         NOT NULL,
    [KnA_CzyDrukowac]      TINYINT         NOT NULL,
    [KnA_CzyKopiowacDoVAT] TINYINT         NOT NULL,
    CONSTRAINT [KnA_Primary] PRIMARY KEY CLUSTERED ([KnA_KnAId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_KnADefAtrybut] FOREIGN KEY ([KnA_DeAId]) REFERENCES [CDN].[DefAtrybuty] ([DeA_DeAId]) ON DELETE CASCADE,
    CONSTRAINT [FK_KnAPodmiot] FOREIGN KEY ([KnA_PodmiotId], [KnA_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [KnAPodmiot]
    ON [CDN].[KntAtrybuty]([KnA_PodmiotId] ASC, [KnA_PodmiotTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KnADefAtrybut]
    ON [CDN].[KntAtrybuty]([KnA_DeAId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KnADefAtrybutPodmiot]
    ON [CDN].[KntAtrybuty]([KnA_DeAId] ASC, [KnA_PodmiotId] ASC, [KnA_PodmiotTyp] ASC) WITH (FILLFACTOR = 100);

