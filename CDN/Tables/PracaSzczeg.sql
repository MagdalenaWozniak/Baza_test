CREATE TABLE [CDN].[PracaSzczeg] (
    [SZP_SZPId]      INT            IDENTITY (1, 1) NOT NULL,
    [SZP_Szczeg2]    INT            NOT NULL,
    [SZP_Poziom]     INT            NOT NULL,
    [SZP_Wybieralny] INT            NOT NULL,
    [SZP_Opis]       NVARCHAR (510) NOT NULL,
    [SZP_ZjeId]      NVARCHAR (128) CONSTRAINT [DF_SZP_ZjeId] DEFAULT ('') NOT NULL,
    CONSTRAINT [SZP_Primary] PRIMARY KEY CLUSTERED ([SZP_SZPId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [SZPZjeLink]
    ON [CDN].[PracaSzczeg]([SZP_ZjeId] ASC) WITH (FILLFACTOR = 100);

