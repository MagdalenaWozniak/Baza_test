CREATE TABLE [CDN].[AkordyHistWartosci] (
    [AHW_AhwId]   INT             IDENTITY (1, 1) NOT NULL,
    [AHW_AkhId]   INT             NOT NULL,
    [AHW_Ilosc]   DECIMAL (15, 4) NOT NULL,
    [AHW_Czas]    DATETIME        NULL,
    [AHW_Miesiac] SMALLINT        NOT NULL,
    [AHW_Rok]     INT             NOT NULL,
    [AHW_Kwota]   DECIMAL (15, 2) NOT NULL,
    [AHW_Udzial]  DECIMAL (15, 4) NOT NULL,
    [AHW_Zmiana]  INT             NOT NULL,
    CONSTRAINT [AHW_Primary] PRIMARY KEY CLUSTERED ([AHW_AhwId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AHWAkhLink] FOREIGN KEY ([AHW_AkhId]) REFERENCES [CDN].[AkordyHist] ([AKH_AkhId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [AHWAkhLink]
    ON [CDN].[AkordyHistWartosci]([AHW_AkhId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AHWWartosci]
    ON [CDN].[AkordyHistWartosci]([AHW_AkhId] ASC, [AHW_Miesiac] ASC, [AHW_Rok] ASC) WITH (FILLFACTOR = 100);

