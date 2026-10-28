CREATE TABLE [CDN].[WymiaryWartosci] (
    [WyW_WyWID]        INT             IDENTITY (1, 1) NOT NULL,
    [WyW_WyyId]        INT             NULL,
    [WyW_SourceType]   INT             NULL,
    [WyW_SRCGUID]      NVARCHAR (255)  NULL,
    [WyW_GUID]         NVARCHAR (255)  NULL,
    [WyW_Wartosc]      NVARCHAR (255)  NULL,
    [WyW_DokumentTyp]  INT             NULL,
    [WyW_DokumentId]   INT             NULL,
    [WyW_SlownikId]    INT             NULL,
    [WyW_LpPozycji]    INT             NULL,
    [WyW_KwotaPozycji] DECIMAL (15, 4) NULL,
    [WyW_Procent]      DECIMAL (15, 4) NULL,
    [WyW_Kwota]        DECIMAL (15, 4) NULL,
    CONSTRAINT [WyW_Primary] PRIMARY KEY CLUSTERED ([WyW_WyWID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [WyWWyyId]
    ON [CDN].[WymiaryWartosci]([WyW_WyyId] ASC)
    INCLUDE([WyW_GUID], [WyW_Wartosc], [WyW_DokumentTyp], [WyW_DokumentId], [WyW_SlownikId]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WyWGUID]
    ON [CDN].[WymiaryWartosci]([WyW_GUID] ASC)
    INCLUDE([WyW_Wartosc], [WyW_DokumentTyp], [WyW_DokumentId], [WyW_SlownikId]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WyWDokument]
    ON [CDN].[WymiaryWartosci]([WyW_DokumentTyp] ASC, [WyW_DokumentId] ASC)
    INCLUDE([WyW_GUID], [WyW_Wartosc], [WyW_SlownikId]) WITH (FILLFACTOR = 100);

