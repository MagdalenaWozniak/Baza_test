CREATE TABLE [CDN].[DokNagEtapyHistoria] (
    [DnEH_DnEHID]      INT             IDENTITY (1, 1) NOT NULL,
    [DnEH_DoNID]       INT             NOT NULL,
    [DnEH_Typ]         INT             NOT NULL,
    [DnEH_SymbolPrzed] VARCHAR (20)    NOT NULL,
    [DnEH_SymbolPo]    VARCHAR (20)    NOT NULL,
    [DnEH_OpeID]       INT             NOT NULL,
    [DnEH_OpeKod]      VARCHAR (20)    NULL,
    [DnEH_DataZmiany]  DATETIME        NOT NULL,
    [DnEH_Komentarz]   NVARCHAR (1024) NULL,
    CONSTRAINT [DnEH_Primary] PRIMARY KEY CLUSTERED ([DnEH_DnEHID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DnEHDokumenty] FOREIGN KEY ([DnEH_DoNID]) REFERENCES [CDN].[DokNag] ([DoN_DoNID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DnEHDokumenty]
    ON [CDN].[DokNagEtapyHistoria]([DnEH_DoNID] ASC, [DnEH_Typ] ASC, [DnEH_DnEHID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DnEKDataZmiany]
    ON [CDN].[DokNagEtapyHistoria]([DnEH_DoNID] ASC, [DnEH_DataZmiany] ASC) WITH (FILLFACTOR = 100);

