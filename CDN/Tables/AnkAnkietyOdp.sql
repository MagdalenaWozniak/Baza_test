CREATE TABLE [CDN].[AnkAnkietyOdp] (
    [AnkAnO_AnkAnOId] INT             IDENTITY (1, 1) NOT NULL,
    [AnkAnO_AnkAnPId] INT             NOT NULL,
    [AnkAnO_Lp]       INT             NOT NULL,
    [AnkAnO_Mode]     TINYINT         NOT NULL,
    [AnkAnO_Punkty]   DECIMAL (15, 2) NOT NULL,
    [AnkAnO_Wartosc]  NVARCHAR (MAX)  NOT NULL,
    [AnkAnO_AnkSpOId] INT             NULL,
    CONSTRAINT [AnkAnO_Primary] PRIMARY KEY CLUSTERED ([AnkAnO_AnkAnOId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AnkAnO_AnkAnP] FOREIGN KEY ([AnkAnO_AnkAnPId]) REFERENCES [CDN].[AnkAnkietyPyt] ([AnkAnP_AnkAnPId]) ON DELETE CASCADE
);

