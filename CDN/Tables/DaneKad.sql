CREATE TABLE [CDN].[DaneKad] (
    [DKD_DkdId]      INT            IDENTITY (1, 1) NOT NULL,
    [DKD_Kod]        INT            NOT NULL,
    [DKD_Rodzaj]     TINYINT        NOT NULL,
    [DKD_Poziom]     INT            NOT NULL,
    [DKD_Wybieralny] INT            NOT NULL,
    [DKD_Opis]       NVARCHAR (254) NOT NULL,
    [DKD_ZjeId]      NVARCHAR (128) CONSTRAINT [DF_DKD_ZjeId] DEFAULT ('') NOT NULL,
    CONSTRAINT [DKD_Primary] PRIMARY KEY CLUSTERED ([DKD_DkdId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [DKDZjeLink]
    ON [CDN].[DaneKad]([DKD_ZjeId] ASC) WITH (FILLFACTOR = 100);

