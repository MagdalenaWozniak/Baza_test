CREATE TABLE [CDN].[DzialZakazy] (
    [DZA_DzaId]            INT     IDENTITY (1, 1) NOT NULL,
    [DZA_DzlId]            INT     NOT NULL,
    [DZA_OpeId]            INT     NOT NULL,
    [DZA_Edycja]           TINYINT NOT NULL,
    [DZA_Podglad]          TINYINT NOT NULL,
    [DZA_Usuwanie]         TINYINT NOT NULL,
    [DZA_WyplatyInsDel]    TINYINT NOT NULL,
    [DZA_WyplatyView]      TINYINT NOT NULL,
    [DZA_WyplatyEdit]      TINYINT NOT NULL,
    [DZA_DeklaracjeInsDel] TINYINT NOT NULL,
    [DZA_DeklaracjeView]   TINYINT NOT NULL,
    [DZA_DeklaracjeEdit]   TINYINT NOT NULL,
    [DZA_PracIns]          TINYINT NOT NULL,
    [DZA_PracDel]          TINYINT NOT NULL,
    [DZA_PracEdit]         TINYINT NOT NULL,
    [DZA_PracView]         TINYINT NOT NULL,
    [DZA_PracEtat]         TINYINT NOT NULL,
    [DZA_PracUmowy]        TINYINT NOT NULL,
    [DZA_PracDodatki]      TINYINT NOT NULL,
    [DZA_RptKadry]         TINYINT NOT NULL,
    [DZA_RptPlace]         TINYINT NOT NULL,
    [DZA_PracPlace]        TINYINT NOT NULL,
    [DZA_PracKadry]        TINYINT NOT NULL,
    [DZA_ListyPlac]        TINYINT NOT NULL,
    CONSTRAINT [DZA_Primary] PRIMARY KEY CLUSTERED ([DZA_DzaId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DZADzialy] FOREIGN KEY ([DZA_DzlId]) REFERENCES [CDN].[Dzialy] ([DZL_DzlId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DZADzialy]
    ON [CDN].[DzialZakazy]([DZA_DzlId] ASC, [DZA_OpeId] ASC) WITH (FILLFACTOR = 100);

