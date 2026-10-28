CREATE TABLE [CDN].[AnkSlownikPytanOdp] (
    [AnkSpO_AnkSpoId] INT             IDENTITY (1, 1) NOT NULL,
    [AnkSpO_AnkSpId]  INT             NOT NULL,
    [AnkSpO_AnkSoNId] INT             NULL,
    [AnkSpO_AnkSoEId] INT             NULL,
    [AnkSpO_Lp]       INT             NOT NULL,
    [AnkSpO_Mode]     TINYINT         NOT NULL,
    [AnkSpO_Punkty]   DECIMAL (15, 2) NOT NULL,
    [AnkSpO_Wartosc]  NVARCHAR (MAX)  NOT NULL,
    CONSTRAINT [AnkSpO_Primary] PRIMARY KEY CLUSTERED ([AnkSpO_AnkSpoId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AnkSpO_AnkSp] FOREIGN KEY ([AnkSpO_AnkSpId]) REFERENCES [CDN].[AnkSlownikPytan] ([AnkSp_AnkSpId]) ON DELETE CASCADE
);

