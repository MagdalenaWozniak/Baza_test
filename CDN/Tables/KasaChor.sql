CREATE TABLE [CDN].[KasaChor] (
    [KCH_KchId]      INT            IDENTITY (1, 1) NOT NULL,
    [KCH_Kod]        VARCHAR (3)    NOT NULL,
    [KCH_Poziom]     INT            NOT NULL,
    [KCH_Wybieralny] INT            NOT NULL,
    [KCH_Opis]       NVARCHAR (254) NOT NULL,
    [KCH_ZjeId]      NVARCHAR (128) CONSTRAINT [DF_KCH_ZjeId] DEFAULT ('') NOT NULL,
    CONSTRAINT [KCH_Primary] PRIMARY KEY CLUSTERED ([KCH_KchId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [KCHZjeLink]
    ON [CDN].[KasaChor]([KCH_ZjeId] ASC) WITH (FILLFACTOR = 100);

