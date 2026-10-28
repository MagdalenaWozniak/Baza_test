CREATE TABLE [CDN].[PanstwaTrzecie] (
    [PaT_PaTID]        INT            IDENTITY (1, 1) NOT NULL,
    [PaT_RUCID]        INT            NOT NULL,
    [PaT_Kraj]         NVARCHAR (255) NOT NULL,
    [PaT_Uzasadnienie] NVARCHAR (MAX) NOT NULL,
    [PaT_Szczegoly]    NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_PaT_PaTID] PRIMARY KEY CLUSTERED ([PaT_PaTID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PaTRUC] FOREIGN KEY ([PaT_RUCID]) REFERENCES [CDN].[RejestrCzynnosci] ([RUC_RUCID]) ON DELETE CASCADE
);

