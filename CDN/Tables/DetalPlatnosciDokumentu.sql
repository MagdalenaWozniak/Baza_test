CREATE TABLE [CDN].[DetalPlatnosciDokumentu] (
    [DPlD_DPlDId]             INT             IDENTITY (1, 1) NOT NULL,
    [DPlD_DSPlDId]            INT             NOT NULL,
    [DPlD_DSTrNId]            INT             NOT NULL,
    [DPlD_DSZKBID]            INT             NOT NULL,
    [DPlD_StanDetalID]        INT             NOT NULL,
    [DPlD_DSFPlId]            INT             NOT NULL,
    [DPlD_Kwota]              DECIMAL (15, 2) NOT NULL,
    [DPlD_KwotaZaplacona]     DECIMAL (15, 2) NOT NULL,
    [DPlD_DataPlatnosci]      DATETIME        NOT NULL,
    [DPlD_Gotowka]            TINYINT         NULL,
    [DPlD_Termin]             DATETIME        NOT NULL,
    [DPlD_StanSynchronizacji] INT             NULL,
    [DPlD_TS_Export]          DATETIME        NULL,
    CONSTRAINT [DPlD_Primary] PRIMARY KEY CLUSTERED ([DPlD_DPlDId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DPlDTraNagDS] FOREIGN KEY ([DPlD_DSTrNId], [DPlD_StanDetalID]) REFERENCES [CDN].[DetalTraNag] ([DTrN_DSTrNID], [DTrN_StanDetalID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DPlDTraNagDS]
    ON [CDN].[DetalPlatnosciDokumentu]([DPlD_DSTrNId] ASC, [DPlD_DSZKBID] ASC, [DPlD_StanDetalID] ASC, [DPlD_DSPlDId] ASC) WITH (FILLFACTOR = 100);

