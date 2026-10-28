CREATE TABLE [CDN].[KntPromocje] (
    [KPR_Id]       INT             IDENTITY (1, 1) NOT NULL,
    [KPR_PrmId]    INT             NULL,
    [KPR_KntTyp]   SMALLINT        NULL,
    [KPR_KntFirma] INT             NULL,
    [KPR_KntNumer] INT             NULL,
    [KPR_KntLp]    SMALLINT        NULL,
    [KPR_KngTyp]   SMALLINT        NULL,
    [KPR_KngFirma] INT             NULL,
    [KPR_KngNumer] INT             NULL,
    [KPR_KngLp]    SMALLINT        NULL,
    [KPR_Typ]      INT             NULL,
    [KPR_Wartosc]  DECIMAL (15, 4) NULL,
    CONSTRAINT [XL_KPR_Primary] PRIMARY KEY CLUSTERED ([KPR_Id] ASC) WITH (FILLFACTOR = 80, PAD_INDEX = ON),
    CONSTRAINT [FK_KprPrm] FOREIGN KEY ([KPR_PrmId]) REFERENCES [CDN].[PrmKarty] ([PRM_Id]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [KprPrm]
    ON [CDN].[KntPromocje]([KPR_PrmId] ASC) WITH (FILLFACTOR = 80, PAD_INDEX = ON);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KprKontrahent]
    ON [CDN].[KntPromocje]([KPR_KntTyp] ASC, [KPR_KntNumer] ASC, [KPR_KngTyp] ASC, [KPR_KngNumer] ASC, [KPR_PrmId] ASC) WITH (FILLFACTOR = 80, PAD_INDEX = ON);

