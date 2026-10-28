CREATE TABLE [CDN].[TraElemKwotyCelne] (
    [TKC_TKCId]             INT             IDENTITY (1, 1) NOT NULL,
    [TKC_KCeId]             INT             NOT NULL,
    [TKC_TrEId]             INT             NOT NULL,
    [TKC_Nazwa]             NVARCHAR (100)  NOT NULL,
    [TKC_Wartosc]           DECIMAL (15, 2) NOT NULL,
    [TKC_WartoscPLN]        DECIMAL (15, 2) NOT NULL,
    [TKC_WplywNaWartoscVAT] SMALLINT        NOT NULL,
    [TKC_WplywNaPlatnosc]   SMALLINT        NOT NULL,
    CONSTRAINT [TKC_Primary] PRIMARY KEY CLUSTERED ([TKC_TKCId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TKCTraElem] FOREIGN KEY ([TKC_TrEId]) REFERENCES [CDN].[TraElem] ([TrE_TrEID]) ON DELETE CASCADE
);

