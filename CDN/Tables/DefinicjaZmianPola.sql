CREATE TABLE [CDN].[DefinicjaZmianPola] (
    [DZP_DzpId]        INT             IDENTITY (1, 1) NOT NULL,
    [DZP_DfzId]        INT             NOT NULL,
    [DZP_Nazwa]        NVARCHAR (61)   NULL,
    [DZP_Rodzaj]       TINYINT         NOT NULL,
    [DZP_Wartosc]      DECIMAL (15, 2) NULL,
    [DZP_WartoscTekst] NVARCHAR (254)  NOT NULL,
    [DZP_Nieaktywny]   TINYINT         NOT NULL,
    [DZP_Format]       NVARCHAR (20)   NOT NULL,
    [DZP_Dodatkowe]    NVARCHAR (254)  NOT NULL,
    [DZP_Kolekcja]     NVARCHAR (128)  NOT NULL,
    [DZP_Inne]         NVARCHAR (128)  NOT NULL,
    CONSTRAINT [DZP_Primary] PRIMARY KEY CLUSTERED ([DZP_DzpId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DZPDfzLink] FOREIGN KEY ([DZP_DfzId]) REFERENCES [CDN].[DefinicjaZmian] ([DFZ_DfzId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [DZPDfzLink]
    ON [CDN].[DefinicjaZmianPola]([DZP_DfzId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DFZNazwa]
    ON [CDN].[DefinicjaZmianPola]([DZP_Nazwa] ASC, [DZP_DfzId] ASC) WITH (FILLFACTOR = 100);

