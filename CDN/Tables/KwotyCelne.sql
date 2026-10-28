CREATE TABLE [CDN].[KwotyCelne] (
    [KCe_KCeId]             INT            IDENTITY (1, 1) NOT NULL,
    [KCe_Nazwa]             NVARCHAR (100) NOT NULL,
    [KCe_Import]            SMALLINT       NOT NULL,
    [KCe_WNT]               SMALLINT       NOT NULL,
    [KCe_WplywNaWartoscVAT] SMALLINT       NOT NULL,
    [KCe_WplywNaPlatnosc]   SMALLINT       NOT NULL,
    CONSTRAINT [KCe_Primary] PRIMARY KEY CLUSTERED ([KCe_KCeId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KCeNazwa]
    ON [CDN].[KwotyCelne]([KCe_Nazwa] ASC) WITH (FILLFACTOR = 100);

