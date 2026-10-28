CREATE TABLE [CDN].[TwrPromocje] (
    [TPR_Id]         INT             IDENTITY (1, 1) NOT NULL,
    [TPR_PrmId]      INT             NULL,
    [TPR_TwrTyp]     SMALLINT        NULL,
    [TPR_TwrFirma]   INT             NULL,
    [TPR_TwrNumer]   INT             NULL,
    [TPR_TwrLp]      SMALLINT        NULL,
    [TPR_TwgTyp]     SMALLINT        NULL,
    [TPR_TwgFirma]   INT             NULL,
    [TPR_TwgNumer]   INT             NULL,
    [TPR_TwgLp]      SMALLINT        NULL,
    [TPR_Typ]        INT             NULL,
    [TPR_Wartosc]    DECIMAL (15, 4) NULL,
    [TPR_Prog]       DECIMAL (15, 4) NULL,
    [TPR_Waluta]     VARCHAR (3)     NULL,
    [TPR_FlagaNB]    VARCHAR (1)     NULL,
    [TPR_Notatki]    VARCHAR (200)   NULL,
    [TPR_ZstID]      INT             NULL,
    [TPR_LP]         INT             NULL,
    [TPR_RodzajCeny] INT             NULL,
    CONSTRAINT [TPR_Primary] PRIMARY KEY CLUSTERED ([TPR_Id] ASC) WITH (FILLFACTOR = 80, PAD_INDEX = ON),
    CONSTRAINT [FK_TprPrm] FOREIGN KEY ([TPR_PrmId]) REFERENCES [CDN].[PrmKarty] ([PRM_Id]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [TprPrm]
    ON [CDN].[TwrPromocje]([TPR_PrmId] ASC, [TPR_ZstID] ASC, [TPR_LP] ASC) WITH (FILLFACTOR = 80, PAD_INDEX = ON);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TprTowar]
    ON [CDN].[TwrPromocje]([TPR_TwrTyp] ASC, [TPR_TwrNumer] ASC, [TPR_TwgTyp] ASC, [TPR_TwgNumer] ASC, [TPR_Typ] ASC, [TPR_ZstID] ASC, [TPR_Prog] ASC, [TPR_PrmId] ASC) WITH (FILLFACTOR = 80, PAD_INDEX = ON);

