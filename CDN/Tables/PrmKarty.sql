CREATE TABLE [CDN].[PrmKarty] (
    [PRM_Id]               INT           CONSTRAINT [DF_PRM_Id] DEFAULT ((0)) NOT NULL,
    [PRM_Akronim]          VARCHAR (200) NULL,
    [PRM_DataOd]           INT           NULL,
    [PRM_DataDo]           INT           NULL,
    [PRM_Typ]              INT           NULL,
    [PRM_Priorytet]        INT           NULL,
    [PRM_Stan]             INT           NULL,
    [PRM_Aktywna]          INT           NULL,
    [PRM_SposobStosowania] SMALLINT      NULL,
    [PRM_PominPozostale]   SMALLINT      NULL,
    [PRM_Uwagi]            VARCHAR (512) NULL,
    [PRM_Dokument]         SMALLINT      NULL,
    [PRM_LastMod]          INT           NULL,
    [PRM_PriorytetLp]      INT           NULL,
    [PRM_Cykliczna]        INT           CONSTRAINT [DF_PRM_Cykliczna] DEFAULT ((0)) NULL,
    CONSTRAINT [XL_PRM_Primary] PRIMARY KEY CLUSTERED ([PRM_Id] ASC) WITH (FILLFACTOR = 80, PAD_INDEX = ON)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PrmAkronim]
    ON [CDN].[PrmKarty]([PRM_Akronim] ASC) WITH (FILLFACTOR = 80, PAD_INDEX = ON);


GO
CREATE NONCLUSTERED INDEX [PrmDataOd]
    ON [CDN].[PrmKarty]([PRM_DataOd] ASC, [PRM_DataDo] ASC) WITH (FILLFACTOR = 80, PAD_INDEX = ON);


GO
CREATE NONCLUSTERED INDEX [PrmPriorytet]
    ON [CDN].[PrmKarty]([PRM_Priorytet] ASC) WITH (FILLFACTOR = 80, PAD_INDEX = ON);

