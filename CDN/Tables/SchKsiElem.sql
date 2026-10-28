CREATE TABLE [CDN].[SchKsiElem] (
    [SKE_SKEId]               INT             IDENTITY (1, 1) NOT NULL,
    [SKE_SKNId]               INT             NOT NULL,
    [SKE_Lp]                  SMALLINT        NOT NULL,
    [SKE_DataWys]             NVARCHAR (1000) NOT NULL,
    [SKE_DataOpe]             NVARCHAR (1000) NOT NULL,
    [SKE_Dokument]            VARCHAR (1000)  NOT NULL,
    [SKE_SlownikKSI]          TINYINT         NOT NULL,
    [SKE_Kategoria]           TINYINT         NOT NULL,
    [SKE_KontoWn]             NVARCHAR (2000) NOT NULL,
    [SKE_KontoMa]             NVARCHAR (2000) NOT NULL,
    [SKE_Kwota]               NVARCHAR (1000) NOT NULL,
    [SKE_Opis]                NVARCHAR (1000) NOT NULL,
    [SKE_Warunek]             NVARCHAR (2000) NOT NULL,
    [SKE_KsiegowanieWalutowe] TINYINT         NOT NULL,
    [SKE_Rozrachunki]         INT             NULL,
    CONSTRAINT [SKE_Primary] PRIMARY KEY CLUSTERED ([SKE_SKEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SKESchemat] FOREIGN KEY ([SKE_SKNId]) REFERENCES [CDN].[SchKsiNag] ([SKN_SKNId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [SKESchemat]
    ON [CDN].[SchKsiElem]([SKE_SKNId] ASC, [SKE_Lp] ASC) WITH (FILLFACTOR = 100);

