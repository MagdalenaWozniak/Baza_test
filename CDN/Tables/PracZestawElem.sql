CREATE TABLE [CDN].[PracZestawElem] (
    [PZD_PzdId]         INT      IDENTITY (1, 1) NOT NULL,
    [PZD_PzeId]         INT      NOT NULL,
    [PZD_Ilosc]         INT      NOT NULL,
    [PZD_Czas]          DATETIME NOT NULL,
    [PZD_CzasNoc]       DATETIME NOT NULL,
    [PZD_CzasWolne]     DATETIME NOT NULL,
    [PZD_CzasSW]        DATETIME NOT NULL,
    [PZD_Nadgodziny50]  DATETIME NOT NULL,
    [PZD_Nadgodziny100] DATETIME NOT NULL,
    [PZD_NadgodzinySW]  DATETIME NOT NULL,
    [PZD_DstId]         INT      NOT NULL,
    [PZD_PrjId]         INT      NULL,
    [PZD_DzlId]         INT      NULL,
    CONSTRAINT [PZD_Primary] PRIMARY KEY CLUSTERED ([PZD_PzdId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PZDPzeLink] FOREIGN KEY ([PZD_PzeId]) REFERENCES [CDN].[PracZestaw] ([PZE_PzeId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [PZDPzeLink]
    ON [CDN].[PracZestawElem]([PZD_PzeId] ASC) WITH (FILLFACTOR = 100);

