CREATE TABLE [CDN].[KsiRozrachunki] (
    [KRo_KRoId]           INT             IDENTITY (1, 1) NOT NULL,
    [KRo_OObId]           INT             NULL,
    [KRo_Typ]             SMALLINT        NOT NULL,
    [KRo_Dokument]        VARCHAR (256)   NULL,
    [KRo_NrDziennika]     NVARCHAR (30)   NULL,
    [KRo_Dziennik]        NVARCHAR (30)   NULL,
    [KRo_NumerDziennika]  INT             NULL,
    [KRo_NrKsiegi]        NVARCHAR (30)   NULL,
    [KRo_IdentKsieg]      VARCHAR (50)    NULL,
    [KRo_DataDokumentu]   DATETIME        NULL,
    [KRo_TerminPlatnosci] DATETIME        NULL,
    [KRo_DataRozliczenia] DATETIME        NULL,
    [KRo_DataRoz]         DATETIME        NULL,
    [KRo_KwotaDok]        DECIMAL (15, 2) NULL,
    [KRo_Kwota]           DECIMAL (15, 2) NULL,
    [KRo_Konto]           NVARCHAR (50)   NULL,
    [KRo_SumRozliczen]    DECIMAL (15, 2) NULL,
    [KRo_KontoIdx]        NVARCHAR (50)   NULL,
    [KRo_KontoPrzeciw]    NVARCHAR (50)   NULL,
    [KRo_DeEId]           INT             NULL,
    [KRo_Bufor]           TINYINT         NULL,
    [KRo_Storno]          TINYINT         NULL,
    [KRo_BOEId]           INT             NULL,
    [KRo_Opis]            NVARCHAR (50)   NULL,
    [KRo_RozliczenieId]   INT             NULL,
    [KRo_Strona]          INT             NULL,
    [KRo_KwotaDokWal]     DECIMAL (15, 2) NULL,
    [KRo_KwotaWal]        DECIMAL (15, 2) NULL,
    [KRo_SumRozliczenWal] DECIMAL (15, 2) NULL,
    [KRo_Waluta]          VARCHAR (3)     NULL,
    [KRo_ParentId]        INT             NULL,
    [KRo_BRKID]           INT             NULL,
    [KRo_DataOperacji]    DATETIME        NULL,
    CONSTRAINT [KRo_Primary] PRIMARY KEY CLUSTERED ([KRo_KRoId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [KRoBRKID]
    ON [CDN].[KsiRozrachunki]([KRo_BRKID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KroDekretyElem]
    ON [CDN].[KsiRozrachunki]([KRo_Typ] ASC, [KRo_DeEId] ASC, [KRo_Strona] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KRoBOElem]
    ON [CDN].[KsiRozrachunki]([KRo_Typ] ASC, [KRo_BOEId] ASC, [KRo_Strona] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KRoRozliczenie]
    ON [CDN].[KsiRozrachunki]([KRo_RozliczenieId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KRoKonto]
    ON [CDN].[KsiRozrachunki]([KRo_Konto] ASC, [KRo_KontoIdx] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [KRoDataDokumentu]
    ON [CDN].[KsiRozrachunki]([KRo_DataDokumentu] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KRoTerminPlatnosci]
    ON [CDN].[KsiRozrachunki]([KRo_TerminPlatnosci] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KRoDataRozliczenia]
    ON [CDN].[KsiRozrachunki]([KRo_DataRozliczenia] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KRoBufor]
    ON [CDN].[KsiRozrachunki]([KRo_Bufor] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KRoDokument]
    ON [CDN].[KsiRozrachunki]([KRo_Dokument] ASC, [KRo_IdentKsieg] ASC, [KRo_Opis] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [KroKwota]
    ON [CDN].[KsiRozrachunki]([KRo_Kwota] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KRo_DETA]
    ON [CDN].[KsiRozrachunki]([KRo_RozliczenieId] ASC, [KRo_Typ] ASC, [KRo_DeEId] ASC, [KRo_KRoId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KRoDeEId]
    ON [CDN].[KsiRozrachunki]([KRo_DeEId] ASC)
    INCLUDE([KRo_KRoId], [KRo_OObId], [KRo_Typ], [KRo_Dokument], [KRo_NrDziennika], [KRo_Dziennik], [KRo_NumerDziennika], [KRo_NrKsiegi], [KRo_IdentKsieg], [KRo_DataDokumentu], [KRo_TerminPlatnosci], [KRo_DataRozliczenia], [KRo_DataRoz], [KRo_Kwota], [KRo_Konto], [KRo_SumRozliczen], [KRo_KontoIdx], [KRo_KontoPrzeciw], [KRo_Bufor], [KRo_Storno], [KRo_BOEId], [KRo_Opis], [KRo_RozliczenieId], [KRo_Strona], [KRo_KwotaDokWal], [KRo_KwotaWal], [KRo_SumRozliczenWal], [KRo_Waluta]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KRoBoEId]
    ON [CDN].[KsiRozrachunki]([KRo_BOEId] ASC)
    INCLUDE([KRo_KRoId], [KRo_OObId], [KRo_Typ], [KRo_Dokument], [KRo_NrDziennika], [KRo_Dziennik], [KRo_NumerDziennika], [KRo_NrKsiegi], [KRo_IdentKsieg], [KRo_DataDokumentu], [KRo_TerminPlatnosci], [KRo_DataRozliczenia], [KRo_DataRoz], [KRo_Kwota], [KRo_Konto], [KRo_SumRozliczen], [KRo_KontoIdx], [KRo_KontoPrzeciw], [KRo_Bufor], [KRo_Storno], [KRo_DeEId], [KRo_Opis], [KRo_RozliczenieId], [KRo_Strona], [KRo_KwotaDokWal], [KRo_KwotaWal], [KRo_SumRozliczenWal], [KRo_Waluta]) WITH (FILLFACTOR = 100);

