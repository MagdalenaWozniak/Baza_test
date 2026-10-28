CREATE TABLE [CDN].[DetalStanPlatnosciDokumentu] (
    [DSPlD_DSPlDId]        INT             IDENTITY (1, 1) NOT NULL,
    [DSPlD_DSTrNId]        INT             NOT NULL,
    [DSPlD_DSFPlId]        INT             NOT NULL,
    [DSPlD_Kwota]          DECIMAL (15, 2) NOT NULL,
    [DSPlD_KwotaZaplacona] DECIMAL (15, 2) NOT NULL,
    [DSPlD_DataPlatnosci]  DATETIME        NOT NULL,
    [DSPlD_Termin]         DATETIME        NOT NULL,
    CONSTRAINT [DSPlD_Primary] PRIMARY KEY CLUSTERED ([DSPlD_DSPlDId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DSTraNag] FOREIGN KEY ([DSPlD_DSTrNId]) REFERENCES [CDN].[DetalStanTraNag] ([DSTrN_DSTrNID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DSTraNag]
    ON [CDN].[DetalStanPlatnosciDokumentu]([DSPlD_DSTrNId] ASC, [DSPlD_DSPlDId] ASC) WITH (FILLFACTOR = 100);

