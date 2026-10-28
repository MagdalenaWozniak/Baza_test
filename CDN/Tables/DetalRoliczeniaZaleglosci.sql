CREATE TABLE [CDN].[DetalRoliczeniaZaleglosci] (
    [DRZ_DRZId]              INT             IDENTITY (1, 1) NOT NULL,
    [DRZ_DSDRZId]            INT             CONSTRAINT [DF_DRZ_DSDRZId] DEFAULT ((0)) NOT NULL,
    [DRZ_BZdId]              INT             NOT NULL,
    [DRZ_DSZKBID]            INT             NOT NULL,
    [DRZ_StanDetalID]        INT             NOT NULL,
    [DRZ_Kwota]              DECIMAL (15, 2) NOT NULL,
    [DRZ_StanSynchronizacji] INT             NULL,
    [DRZ_TS_Export]          DATETIME        NULL,
    CONSTRAINT [DRZ_Primary] PRIMARY KEY CLUSTERED ([DRZ_DRZId] ASC) WITH (FILLFACTOR = 100)
);

