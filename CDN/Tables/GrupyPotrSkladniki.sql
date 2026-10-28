CREATE TABLE [CDN].[GrupyPotrSkladniki] (
    [GPS_GpsId]       INT           IDENTITY (1, 1) NOT NULL,
    [GPS_GprId]       INT           NOT NULL,
    [GPS_ParentSTS]   INT           NOT NULL,
    [GPS_ParentNazwa] NVARCHAR (40) NOT NULL,
    [GPS_ParentId]    INT           NOT NULL,
    [GPS_Rodzaj]      TINYINT       NULL,
    [GPS_Priorytet]   INT           NOT NULL,
    CONSTRAINT [GPS_Primary] PRIMARY KEY CLUSTERED ([GPS_GpsId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_GPSGprLink] FOREIGN KEY ([GPS_GprId]) REFERENCES [CDN].[GrupyPotracen] ([GPR_GprId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [GPSGprLink]
    ON [CDN].[GrupyPotrSkladniki]([GPS_GprId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [GPSRodzaj]
    ON [CDN].[GrupyPotrSkladniki]([GPS_Rodzaj] ASC, [GPS_GprId] ASC) WITH (FILLFACTOR = 100);

