CREATE TABLE [CDN].[KatalogZakazy] (
    [KtZ_KtZId]         INT     IDENTITY (1, 1) NOT NULL,
    [KtZ_KtlId]         INT     NOT NULL,
    [KtZ_OpeId]         INT     NOT NULL,
    [KtZ_Dodawanie]     TINYINT NOT NULL,
    [KtZ_Podglad]       TINYINT NOT NULL,
    [KtZ_ZmianaWlas]    TINYINT NOT NULL,
    [KtZ_ZmianaInne]    TINYINT NOT NULL,
    [KtZ_KasowanieWlas] TINYINT NOT NULL,
    [KtZ_KasowanieInne] TINYINT NOT NULL,
    CONSTRAINT [KtZ_Primary] PRIMARY KEY CLUSTERED ([KtZ_KtZId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KtZKatalog]
    ON [CDN].[KatalogZakazy]([KtZ_KtlId] ASC, [KtZ_OpeId] ASC) WITH (FILLFACTOR = 100);

