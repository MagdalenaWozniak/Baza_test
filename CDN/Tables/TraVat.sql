CREATE TABLE [CDN].[TraVat] (
    [TrV_TrVID]        INT             IDENTITY (1, 1) NOT NULL,
    [TrV_TrNID]        INT             NOT NULL,
    [TrV_TrNidFinalna] INT             NULL,
    [TrV_Stawka]       DECIMAL (5, 2)  NOT NULL,
    [TrV_Flaga]        SMALLINT        NOT NULL,
    [TrV_Zrodlowa]     DECIMAL (5, 2)  NOT NULL,
    [TrV_Netto]        DECIMAL (15, 2) NOT NULL,
    [TrV_VAT]          DECIMAL (15, 2) NOT NULL,
    [TrV_NettoWal]     DECIMAL (15, 2) NOT NULL,
    [TrV_VATWal]       DECIMAL (15, 2) NOT NULL,
    [TrV_Typ]          TINYINT         NOT NULL,
    CONSTRAINT [TrV_Primary] PRIMARY KEY CLUSTERED ([TrV_TrVID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_VaTTraNag] FOREIGN KEY ([TrV_TrNID]) REFERENCES [CDN].[TraNag] ([TrN_TrNID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [VaTTraNag]
    ON [CDN].[TraVat]([TrV_TrNID] ASC) WITH (FILLFACTOR = 100);

