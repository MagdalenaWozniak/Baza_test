CREATE TABLE [CDN].[DziennikZakazy] (
    [DzZ_DzZId]         INT     IDENTITY (1, 1) NOT NULL,
    [DzZ_DziId]         INT     NOT NULL,
    [DzZ_OpeId]         INT     NOT NULL,
    [DzZ_Dodawanie]     TINYINT NOT NULL,
    [DzZ_Podglad]       TINYINT NOT NULL,
    [DzZ_ZmianaWlas]    TINYINT NOT NULL,
    [DzZ_ZmianaInne]    TINYINT NOT NULL,
    [DzZ_KasowanieWlas] TINYINT NOT NULL,
    [DzZ_KasowanieInne] TINYINT NOT NULL,
    CONSTRAINT [DzZ_Primary] PRIMARY KEY CLUSTERED ([DzZ_DzZId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DzZDziennik] FOREIGN KEY ([DzZ_DziId]) REFERENCES [CDN].[Dzienniki] ([Dzi_DziId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DzZDziennik]
    ON [CDN].[DziennikZakazy]([DzZ_DziId] ASC, [DzZ_OpeId] ASC) WITH (FILLFACTOR = 100);

