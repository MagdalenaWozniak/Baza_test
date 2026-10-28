CREATE TABLE [CDN].[TwrZasoby] (
    [TwZ_TwZId]     INT             IDENTITY (1, 1) NOT NULL,
    [TwZ_TrSIdDost] INT             NULL,
    [TwZ_TwrId]     INT             NOT NULL,
    [TwZ_MagId]     INT             NOT NULL,
    [TwZ_Data]      DATETIME        NULL,
    [TwZ_Ilosc]     DECIMAL (15, 4) NOT NULL,
    [TwZ_Quan]      DECIMAL (15, 4) NOT NULL,
    [TwZ_Wartosc]   DECIMAL (15, 2) NOT NULL,
    [TwZ_Cena]      DECIMAL (17, 4) NOT NULL,
    CONSTRAINT [TwZ_Primary] PRIMARY KEY CLUSTERED ([TwZ_TwZId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TwZMagazyn] FOREIGN KEY ([TwZ_MagId]) REFERENCES [CDN].[Magazyny] ([Mag_MagId]),
    CONSTRAINT [FK_TwZTowar] FOREIGN KEY ([TwZ_TwrId]) REFERENCES [CDN].[Towary] ([Twr_TwrId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwZTowar]
    ON [CDN].[TwrZasoby]([TwZ_TwrId] ASC, [TwZ_MagId] ASC, [TwZ_Data] ASC, [TwZ_TrSIdDost] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwZMagazyn]
    ON [CDN].[TwrZasoby]([TwZ_MagId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwZTraSElem]
    ON [CDN].[TwrZasoby]([TwZ_TrSIdDost] ASC, [TwZ_MagId] ASC, [TwZ_TwrId] ASC) WITH (FILLFACTOR = 100);

