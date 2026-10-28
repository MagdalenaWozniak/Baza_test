CREATE TABLE [CDN].[AnkWzorzecAnkietyAnkietowani] (
    [AnkWaA_AnkWaAId]      INT            IDENTITY (1, 1) NOT NULL,
    [AnkWaA_AnkWaNId]      INT            NOT NULL,
    [AnkWaA_Lp]            INT            NOT NULL,
    [AnkWaA_PodmiotTyp]    SMALLINT       NOT NULL,
    [AnkWaA_PodID]         INT            NOT NULL,
    [AnkWaA_OsobaId]       INT            NULL,
    [AnkWaA_OsobaNazwisko] NVARCHAR (40)  NOT NULL,
    [AnkWaA_OsobaTelefon]  VARCHAR (40)   NOT NULL,
    [AnkWaA_KntKod]        VARCHAR (20)   NOT NULL,
    [AnkWaA_KntNazwa]      NVARCHAR (352) NOT NULL,
    CONSTRAINT [AnkWaA_Primary] PRIMARY KEY CLUSTERED ([AnkWaA_AnkWaAId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AnkWaA_AnkWaN] FOREIGN KEY ([AnkWaA_AnkWaNId]) REFERENCES [CDN].[AnkWzorzecAnkietyNag] ([AnkWaN_AnkWaNId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AnkWaA_Lp_UniqueIx]
    ON [CDN].[AnkWzorzecAnkietyAnkietowani]([AnkWaA_AnkWaNId] ASC, [AnkWaA_Lp] ASC) WITH (FILLFACTOR = 100);

