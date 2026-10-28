CREATE TABLE [CDN].[ZestawyRegulElem] (
    [ZRE_ZreId]          INT     IDENTITY (1, 1) NOT NULL,
    [ZRE_Lp]             INT     NOT NULL,
    [ZRE_ZrgId]          INT     NULL,
    [ZRE_RrgId]          INT     NULL,
    [ZRE_IloscMinZrodlo] INT     NOT NULL,
    [ZRE_Akcja]          INT     NOT NULL,
    [ZRE_MetodaModyf]    TINYINT NOT NULL,
    [ZRE_IloscMinCel]    INT     NOT NULL,
    CONSTRAINT [ZRE_Primary] PRIMARY KEY CLUSTERED ([ZRE_ZreId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_FREForId] FOREIGN KEY ([ZRE_ZrgId]) REFERENCES [CDN].[ZestawyRegul] ([ZRG_ZrgId]) ON DELETE CASCADE,
    CONSTRAINT [FK_FRERrgId] FOREIGN KEY ([ZRE_RrgId]) REFERENCES [CDN].[RegulyRcp] ([RRG_RrgId])
);


GO
CREATE NONCLUSTERED INDEX [FREForId]
    ON [CDN].[ZestawyRegulElem]([ZRE_ZrgId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [FRERrgId]
    ON [CDN].[ZestawyRegulElem]([ZRE_RrgId] ASC) WITH (FILLFACTOR = 100);

