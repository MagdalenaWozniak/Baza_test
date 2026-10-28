CREATE TABLE [CDN].[DanePlac] (
    [DPL_DplId]      INT            IDENTITY (1, 1) NOT NULL,
    [DPL_Kod]        INT            NOT NULL,
    [DPL_Rodzaj]     TINYINT        NOT NULL,
    [DPL_Poziom]     INT            NOT NULL,
    [DPL_Wybieralny] INT            NOT NULL,
    [DPL_Opis]       NVARCHAR (254) NOT NULL,
    [DPL_ZjeId]      NVARCHAR (128) CONSTRAINT [DF_DPL_ZjeId] DEFAULT ('') NOT NULL,
    CONSTRAINT [DPL_Primary] PRIMARY KEY CLUSTERED ([DPL_DplId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [DPLZjeLink]
    ON [CDN].[DanePlac]([DPL_ZjeId] ASC) WITH (FILLFACTOR = 100);

