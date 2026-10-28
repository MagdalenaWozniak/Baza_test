CREATE TABLE [CDN].[AnkSzablonOdpElem] (
    [AnkSoE_AnkSoEId] INT             IDENTITY (1, 1) NOT NULL,
    [AnkSoE_AnkSoNId] INT             NOT NULL,
    [AnkSoE_Lp]       INT             NOT NULL,
    [AnkSoE_Mode]     TINYINT         NOT NULL,
    [AnkSoE_Punkty]   DECIMAL (15, 2) NOT NULL,
    [AnkSoE_Wartosc]  NVARCHAR (MAX)  NOT NULL,
    CONSTRAINT [AnkSoE_Primary] PRIMARY KEY CLUSTERED ([AnkSoE_AnkSoEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AnkSoe_AnkSon] FOREIGN KEY ([AnkSoE_AnkSoNId]) REFERENCES [CDN].[AnkSzablonOdpNag] ([AnkSoN_AnkSoNId]) ON DELETE CASCADE
);

