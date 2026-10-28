CREATE TABLE [CDN].[TwrIlosci] (
    [TwI_TwIId]      INT             IDENTITY (1, 1) NOT NULL,
    [TwI_TwrId]      INT             NOT NULL,
    [TwI_MagId]      INT             NULL,
    [TwI_Data]       DATETIME        NULL,
    [TwI_Ilosc]      DECIMAL (15, 4) NOT NULL,
    [TwI_Wartosc]    DECIMAL (15, 2) NOT NULL,
    [TwI_Braki]      DECIMAL (15, 4) NOT NULL,
    [TwI_Rezerwacje] DECIMAL (15, 4) NOT NULL,
    [TwI_Zamowienia] DECIMAL (15, 4) NOT NULL,
    CONSTRAINT [TwI_Primary] PRIMARY KEY CLUSTERED ([TwI_TwIId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TwIMagazyn] FOREIGN KEY ([TwI_MagId]) REFERENCES [CDN].[Magazyny] ([Mag_MagId]) ON DELETE CASCADE,
    CONSTRAINT [FK_TwITowar] FOREIGN KEY ([TwI_TwrId]) REFERENCES [CDN].[Towary] ([Twr_TwrId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwITowar]
    ON [CDN].[TwrIlosci]([TwI_TwrId] ASC, [TwI_MagId] ASC, [TwI_Data] DESC)
    INCLUDE([TwI_Ilosc], [TwI_Wartosc], [TwI_Braki], [TwI_Rezerwacje], [TwI_Zamowienia]) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [TwIMagazyn]
    ON [CDN].[TwrIlosci]([TwI_MagId] ASC) WITH (FILLFACTOR = 100);

