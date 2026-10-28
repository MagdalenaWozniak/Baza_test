CREATE TABLE [CDN].[RegulyRcp] (
    [RRG_RrgId]          INT            IDENTITY (1, 1) NOT NULL,
    [RRG_Opis]           NVARCHAR (200) NOT NULL,
    [RRG_IloscMinZrodlo] INT            NOT NULL,
    [RRG_Akcja]          TINYINT        NOT NULL,
    [RRG_MetodaModyf]    INT            NOT NULL,
    [RRG_IloscMinCel]    INT            NOT NULL,
    [RRG_ZjeId]          NVARCHAR (128) CONSTRAINT [DF_RRG_ZjeId] DEFAULT ('') NOT NULL,
    CONSTRAINT [RRG_Primary] PRIMARY KEY CLUSTERED ([RRG_RrgId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [RRGZjeLink]
    ON [CDN].[RegulyRcp]([RRG_ZjeId] ASC) WITH (FILLFACTOR = 100);

