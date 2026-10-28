CREATE TABLE [CDN].[DokAtrybuty] (
    [DAt_DAtId]          INT             IDENTITY (1, 1) NOT NULL,
    [DAt_Kod]            VARCHAR (20)    NULL,
    [DAt_DeAId]          INT             NOT NULL,
    [DAt_WartoscTxt]     NVARCHAR (1024) NOT NULL,
    [DAt_TrNId]          INT             NULL,
    [DAt_CRKId]          INT             NULL,
    [DAt_SrZId]          INT             NULL,
    [DAt_VaNID]          INT             NULL,
    [DAt_DoNID]          INT             NULL,
    [DAt_OfdID]          INT             NULL,
    [DAt_DokumentTyp]    INT             NULL,
    [DAt_DokumentId]     INT             NULL,
    [DAt_WartoscDecimal] AS              (case when len([DAT_WARTOSCTXT])<(15) AND isnumeric(replace([DAT_WARTOSCTXT],',','.')+'E0')=(1) AND NOT ltrim(rtrim([DAT_WARTOSCTXT])) like '[-.,+]' AND NOT [DAT_WARTOSCTXT] like ('%'+char((13)))+'%' then CONVERT([decimal](18,4),ltrim(rtrim(replace(replace([DAT_WARTOSCTXT],char((9)),''),',','.'))),(0)) else (-99999999) end),
    [DAt_TypJPK]         TINYINT         NULL,
    CONSTRAINT [DAt_Primary] PRIMARY KEY CLUSTERED ([DAt_DAtId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DAtCRMKey] FOREIGN KEY ([DAt_CRKId]) REFERENCES [CDN].[CRMKontakty] ([CRK_CRKId]) ON DELETE CASCADE,
    CONSTRAINT [FK_DAtDefAtrybut] FOREIGN KEY ([DAt_DeAId]) REFERENCES [CDN].[DefAtrybuty] ([DeA_DeAId]) ON DELETE CASCADE,
    CONSTRAINT [FK_DAtOfertyDok] FOREIGN KEY ([DAt_OfdID]) REFERENCES [CDN].[OfertyDok] ([OfD_OfDId]) ON DELETE CASCADE,
    CONSTRAINT [FK_DAtSrSZlecenia] FOREIGN KEY ([DAt_SrZId]) REFERENCES [CDN].[SrsZlecenia] ([SrZ_SrZId]) ON DELETE CASCADE,
    CONSTRAINT [FK_DAtVatNag] FOREIGN KEY ([DAt_VaNID]) REFERENCES [CDN].[VatNag] ([VaN_VaNID]) ON DELETE CASCADE,
    CONSTRAINT [FK_DTaTraNag] FOREIGN KEY ([DAt_TrNId]) REFERENCES [CDN].[TraNag] ([TrN_TrNID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [DAtCRMKey]
    ON [CDN].[DokAtrybuty]([DAt_CRKId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DAtDefAtrybut]
    ON [CDN].[DokAtrybuty]([DAt_DeAId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DTaTraNag]
    ON [CDN].[DokAtrybuty]([DAt_TrNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DAtVatNag]
    ON [CDN].[DokAtrybuty]([DAt_VaNID] ASC)
    INCLUDE([DAt_DAtId], [DAt_DeAId], [DAt_WartoscTxt]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DAtSrSZlecenia]
    ON [CDN].[DokAtrybuty]([DAt_SrZId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DAtDokNag]
    ON [CDN].[DokAtrybuty]([DAt_DoNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DAtOfertyDok]
    ON [CDN].[DokAtrybuty]([DAt_OfdID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DAtAtrybutyTraNag]
    ON [CDN].[DokAtrybuty]([DAt_DeAId] ASC, [DAt_TrNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DAtDokument]
    ON [CDN].[DokAtrybuty]([DAt_DokumentTyp] ASC, [DAt_DokumentId] ASC) WITH (FILLFACTOR = 100);

