CREATE TABLE [CDN].[AnkAnkietyAnkieterzy] (
    [AnkAaA_AnkAaAId]   INT      IDENTITY (1, 1) NOT NULL,
    [AnkAaA_AnkAnNId]   INT      NOT NULL,
    [AnkAaA_Lp]         INT      NOT NULL,
    [AnkAaA_PodmiotTyp] SMALLINT NOT NULL,
    [AnkAaA_PodID]      INT      NOT NULL,
    CONSTRAINT [AnkAaA_Primary] PRIMARY KEY CLUSTERED ([AnkAaA_AnkAaAId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AnkAaA_AnkAnN] FOREIGN KEY ([AnkAaA_AnkAnNId]) REFERENCES [CDN].[AnkAnkietyNag] ([AnkAnN_AnkAnNId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AnkAaA_Lp_UniqueIx]
    ON [CDN].[AnkAnkietyAnkieterzy]([AnkAaA_AnkAnNId] ASC, [AnkAaA_Lp] ASC) WITH (FILLFACTOR = 100);

