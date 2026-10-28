CREATE TABLE [CDN].[IGaleriaAtrybuty] (
    [IGA_IGAId]          INT            NOT NULL,
    [IGA_IGKId]          INT            NOT NULL,
    [IGA_Nazwa]          NVARCHAR (100) NOT NULL,
    [IGA_Typ]            INT            NOT NULL,
    [IGA_Jednostka]      NVARCHAR (30)  NOT NULL,
    [IGA_Aktywny]        TINYINT        NOT NULL,
    [IGA_DowolnaWartosc] TINYINT        NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IGAtrybutyId]
    ON [CDN].[IGaleriaAtrybuty]([IGA_IGAId] ASC, [IGA_IGKId] ASC) WITH (FILLFACTOR = 100);

