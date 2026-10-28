CREATE TABLE [CDN].[IGaleriaKategorie] (
    [IGK_IGKId]    INT          NOT NULL,
    [IGK_ParentId] INT          NOT NULL,
    [IGK_Nazwa]    VARCHAR (50) NOT NULL,
    [IGK_Aktywna]  TINYINT      NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IGKategorieId]
    ON [CDN].[IGaleriaKategorie]([IGK_IGKId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IGKategorieNazwa]
    ON [CDN].[IGaleriaKategorie]([IGK_Nazwa] ASC, [IGK_IGKId] ASC) WITH (FILLFACTOR = 100);

