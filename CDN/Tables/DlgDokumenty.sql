CREATE TABLE [CDN].[DlgDokumenty] (
    [DLD_DLDId]            INT             IDENTITY (1, 1) NOT NULL,
    [DLD_DLEId]            INT             NOT NULL,
    [DLD_Rozliczac]        INT             NOT NULL,
    [DLD_Typ]              INT             NOT NULL,
    [DLD_DokumentTyp]      INT             NOT NULL,
    [DLD_DokumentId]       INT             NOT NULL,
    [DLD_KwotaRozliczenia] DECIMAL (15, 2) NOT NULL,
    [DLD_Opis]             NVARCHAR (255)  NOT NULL,
    CONSTRAINT [DLD_Primary] PRIMARY KEY CLUSTERED ([DLD_DLDId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DlgDokumentyDlgElem] FOREIGN KEY ([DLD_DLEId]) REFERENCES [CDN].[DlgElem] ([DLE_DLEId]) ON DELETE CASCADE
);

