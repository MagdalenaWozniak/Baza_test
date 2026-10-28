CREATE TABLE [CDN].[PrzWyrej] (
    [PWR_PwrId]      INT            IDENTITY (1, 1) NOT NULL,
    [PWR_PrzWyrej3]  INT            NOT NULL,
    [PWR_Poziom]     INT            NOT NULL,
    [PWR_Wybieralny] INT            NOT NULL,
    [PWR_Opis]       NVARCHAR (510) NOT NULL,
    [PWR_ZjeId]      NVARCHAR (128) CONSTRAINT [DF_PWR_ZjeId] DEFAULT ('') NOT NULL,
    CONSTRAINT [PWR_Primary] PRIMARY KEY CLUSTERED ([PWR_PwrId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [PWRZjeLink]
    ON [CDN].[PrzWyrej]([PWR_ZjeId] ASC) WITH (FILLFACTOR = 100);

