CREATE TABLE [CDN].[SzDekElem] (
    [SDE_SDEId]       INT             IDENTITY (1, 1) NOT NULL,
    [SDE_SzDId]       INT             NOT NULL,
    [SDE_Lp]          SMALLINT        NOT NULL,
    [SDE_KatID]       INT             NULL,
    [SDE_Opis]        NVARCHAR (1000) NOT NULL,
    [SDE_Kat2ID]      INT             NULL,
    [SDE_Opis2]       NVARCHAR (50)   NULL,
    [SDE_Kategoria]   TINYINT         NOT NULL,
    [SDE_KontoWn]     VARCHAR (50)    NOT NULL,
    [SDE_KontoMa]     VARCHAR (50)    NOT NULL,
    [SDE_Rozrachunki] INT             NULL,
    CONSTRAINT [SDE_Primary] PRIMARY KEY CLUSTERED ([SDE_SDEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SDESzablonDekretacji] FOREIGN KEY ([SDE_SzDId]) REFERENCES [CDN].[SzDekNag] ([SzD_SzDId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [SDESzablonDekretacji]
    ON [CDN].[SzDekElem]([SDE_SzDId] ASC, [SDE_Lp] ASC) WITH (FILLFACTOR = 100);

