CREATE TABLE [CDN].[DetalFormyPlatnosci] (
    [DFPl_DFPlId]     INT           IDENTITY (1, 1) NOT NULL,
    [DFPl_DStaId]     INT           NOT NULL,
    [DFPl_FPlId]      INT           NOT NULL,
    [DFPl_Nazwa]      NVARCHAR (20) NOT NULL,
    [DFPl_NazwaDetal] NVARCHAR (20) NOT NULL,
    [DFPl_Domyslna]   TINYINT       CONSTRAINT [DF_DFPl_Domyslna] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [DFPl_Primary] PRIMARY KEY CLUSTERED ([DFPl_DFPlId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DFplStanowiskoDetal]
    ON [CDN].[DetalFormyPlatnosci]([DFPl_DStaId] ASC, [DFPl_FPlId] ASC) WITH (FILLFACTOR = 100);

