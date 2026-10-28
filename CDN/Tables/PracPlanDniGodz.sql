CREATE TABLE [CDN].[PracPlanDniGodz] (
    [PGL_PglId]      INT             IDENTITY (1, 1) NOT NULL,
    [PGL_PplId]      INT             NOT NULL,
    [PGL_Lp]         INT             NOT NULL,
    [PGL_OdGodziny]  DATETIME        NOT NULL,
    [PGL_DoGodziny]  DATETIME        NOT NULL,
    [PGL_Strefa]     INT             NOT NULL,
    [PGL_DzlId]      INT             NOT NULL,
    [PGL_PrjId]      INT             NOT NULL,
    [PGL_UwagiPlanu] NVARCHAR (1024) CONSTRAINT [DF_PGL_UwagiPlanu] DEFAULT ('') NOT NULL,
    CONSTRAINT [PGL_Primary] PRIMARY KEY CLUSTERED ([PGL_PglId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PGLPplLink] FOREIGN KEY ([PGL_PplId]) REFERENCES [CDN].[PracPlanDni] ([PPL_PplId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [PGLLp]
    ON [CDN].[PracPlanDniGodz]([PGL_Lp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PGLPplLink]
    ON [CDN].[PracPlanDniGodz]([PGL_PplId] ASC) WITH (FILLFACTOR = 100);

