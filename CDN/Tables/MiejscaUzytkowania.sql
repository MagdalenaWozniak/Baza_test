CREATE TABLE [CDN].[MiejscaUzytkowania] (
    [MUz_MUzID]      INT            IDENTITY (1, 1) NOT NULL,
    [MUz_Nazwa]      NVARCHAR (255) NOT NULL,
    [MUz_Nieaktywne] TINYINT        CONSTRAINT [DF_MUz_Nieaktywne] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [MUzPrimary] PRIMARY KEY CLUSTERED ([MUz_MUzID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [MUzNazwa]
    ON [CDN].[MiejscaUzytkowania]([MUz_Nazwa] ASC) WITH (FILLFACTOR = 100);

