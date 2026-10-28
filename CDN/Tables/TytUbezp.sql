CREATE TABLE [CDN].[TytUbezp] (
    [TYU_TyuId]          INT            IDENTITY (1, 1) NOT NULL,
    [TYU_TyUb4]          INT            NOT NULL,
    [TYU_Poziom]         INT            NOT NULL,
    [TYU_Wybieralny]     INT            NOT NULL,
    [TYU_Pracownik]      TINYINT        NULL,
    [TYU_Wlasciciel]     TINYINT        NULL,
    [TYU_Wspolpracownik] TINYINT        NULL,
    [TYU_Zleceniobiorca] TINYINT        NULL,
    [TYU_Uczen]          TINYINT        NULL,
    [TYU_Opis]           NVARCHAR (510) NULL,
    [TYU_CheckBox]       NVARCHAR (4)   NULL,
    [TYU_Umowa]          TINYINT        NOT NULL,
    [TYU_ZjeId]          NVARCHAR (128) CONSTRAINT [DF_TYU_ZjeId] DEFAULT ('') NOT NULL,
    CONSTRAINT [TYU_Primary] PRIMARY KEY CLUSTERED ([TYU_TyuId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [TYUZjeLink]
    ON [CDN].[TytUbezp]([TYU_ZjeId] ASC) WITH (FILLFACTOR = 100);

