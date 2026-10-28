CREATE TABLE [CDN].[BRpAgregaty] (
    [BAg_BAgId]        INT             IDENTITY (1, 1) NOT NULL,
    [BAg_BRpId]        INT             NULL,
    [BAg_Typ]          SMALLINT        NULL,
    [BAg_SaldoBOSys]   DECIMAL (15, 2) NULL,
    [BAg_PrzychodySys] DECIMAL (15, 2) NULL,
    [BAg_RozchodySys]  DECIMAL (15, 2) NULL,
    CONSTRAINT [BAg_Primary] PRIMARY KEY CLUSTERED ([BAg_BAgId] ASC) WITH (FILLFACTOR = 80, PAD_INDEX = ON),
    CONSTRAINT [FK_BAgRaport] FOREIGN KEY ([BAg_BRpId]) REFERENCES [CDN].[BnkRaporty] ([BRp_BRpID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [BAgAgregat]
    ON [CDN].[BRpAgregaty]([BAg_BRpId] ASC, [BAg_Typ] ASC) WITH (FILLFACTOR = 80, PAD_INDEX = ON);

