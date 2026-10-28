CREATE TABLE [CDN].[DaneKadStr] (
    [DKT_DktId]      INT            IDENTITY (1, 1) NOT NULL,
    [DKT_Kod]        NVARCHAR (32)  NOT NULL,
    [DKT_Rodzaj]     TINYINT        NOT NULL,
    [DKT_Poziom]     INT            NOT NULL,
    [DKT_Wybieralny] INT            NOT NULL,
    [DKT_Opis]       NVARCHAR (254) NOT NULL,
    [DKT_ZjeId]      NVARCHAR (128) CONSTRAINT [DF_DKT_ZjeId] DEFAULT ('') NOT NULL,
    CONSTRAINT [DKT_Primary] PRIMARY KEY CLUSTERED ([DKT_DktId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [DKTZjeLink]
    ON [CDN].[DaneKadStr]([DKT_ZjeId] ASC) WITH (FILLFACTOR = 100);

