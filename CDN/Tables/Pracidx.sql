CREATE TABLE [CDN].[Pracidx] (
    [PRI_PriId]        INT            NOT NULL,
    [PRI_Typ]          INT            NOT NULL,
    [PRI_DzlId]        INT            CONSTRAINT [DF_PRI_DzlId] DEFAULT ((3)) NULL,
    [PRI_PraId]        INT            NOT NULL,
    [PRI_Kod]          VARCHAR (20)   NOT NULL,
    [PRI_Nazwisko]     NVARCHAR (40)  NULL,
    [PRI_Imie1]        NVARCHAR (30)  NULL,
    [PRI_Pesel]        NVARCHAR (11)  NULL,
    [PRI_DataOd]       DATETIME       NULL,
    [PRI_DataDo]       DATETIME       NULL,
    [PRI_AdresDzialu]  NVARCHAR (512) NOT NULL,
    [PRI_AdresCentrum] NVARCHAR (512) CONSTRAINT [DF_PRI_AdresCentrum] DEFAULT ('') NOT NULL,
    [PRI_CntId]        INT            CONSTRAINT [DF_PRI_CntId] DEFAULT ((3)) NULL,
    [PRI_Opis]         NVARCHAR (128) NOT NULL,
    [PRI_Archiwalny]   TINYINT        NOT NULL,
    [PRI_ParentId]     INT            NULL,
    [PRI_Nadrzedny]    TINYINT        NOT NULL,
    CONSTRAINT [PRI_Primary] PRIMARY KEY CLUSTERED ([PRI_PriId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PRIDzlLink] FOREIGN KEY ([PRI_DzlId]) REFERENCES [CDN].[Dzialy] ([DZL_DzlId]),
    CONSTRAINT [FK_PriPraId] FOREIGN KEY ([PRI_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [PriPraId]
    ON [CDN].[Pracidx]([PRI_PraId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PRIKod]
    ON [CDN].[Pracidx]([PRI_Kod] ASC, [PRI_PriId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PRINazwisko]
    ON [CDN].[Pracidx]([PRI_Nazwisko] ASC, [PRI_Imie1] ASC, [PRI_PriId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PRIDzlLink]
    ON [CDN].[Pracidx]([PRI_DzlId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PRI_EP_Idx]
    ON [CDN].[Pracidx]([PRI_Archiwalny] ASC, [PRI_Typ] ASC, [PRI_PraId] ASC, [PRI_PriId] ASC) WITH (FILLFACTOR = 100);

