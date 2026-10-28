CREATE TABLE [CDN].[IGaleriaDefAtrWartosci] (
    [IGDW_IGDWId]  INT            NOT NULL,
    [IGDW_IGAId]   INT            NOT NULL,
    [IGDW_Wartosc] NVARCHAR (100) NOT NULL,
    [IGDW_Aktywna] TINYINT        NOT NULL
);


GO
CREATE CLUSTERED INDEX [IGaleriaDefAtrWartosci]
    ON [CDN].[IGaleriaDefAtrWartosci]([IGDW_IGAId] ASC) WITH (FILLFACTOR = 100);

