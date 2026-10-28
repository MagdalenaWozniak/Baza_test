CREATE TABLE [CDN].[ProdSkladniki] (
    [PdS_PdSId]          INT             IDENTITY (1, 1) NOT NULL,
    [PdS_PdRId]          INT             NOT NULL,
    [PdS_ProdId]         INT             NOT NULL,
    [PdS_TwrId]          INT             NULL,
    [PdS_MagId]          INT             NULL,
    [PdS_Ilosc]          DECIMAL (15, 4) NOT NULL,
    [PdS_Jm]             NVARCHAR (20)   NOT NULL,
    [PdS_JMCalkowite]    TINYINT         NOT NULL,
    [PdS_JMPrzelicznikL] DECIMAL (15, 2) NOT NULL,
    [PdS_JMPrzelicznikM] DECIMAL (7)     NOT NULL,
    [PdS_IloscJM]        DECIMAL (15, 4) NOT NULL,
    [PdS_Lp]             INT             NULL,
    CONSTRAINT [PdS_Primary] PRIMARY KEY CLUSTERED ([PdS_PdSId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PdSMagazyn] FOREIGN KEY ([PdS_MagId]) REFERENCES [CDN].[Magazyny] ([Mag_MagId]),
    CONSTRAINT [FK_PdSReceptura] FOREIGN KEY ([PdS_PdRId]) REFERENCES [CDN].[ProdReceptury] ([PdR_PdRId]) ON DELETE CASCADE,
    CONSTRAINT [FK_PdSTowar] FOREIGN KEY ([PdS_TwrId]) REFERENCES [CDN].[Towary] ([Twr_TwrId])
);


GO
CREATE NONCLUSTERED INDEX [PdSTowar]
    ON [CDN].[ProdSkladniki]([PdS_TwrId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PdSReceptura]
    ON [CDN].[ProdSkladniki]([PdS_PdRId] ASC, [PdS_PdSId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PdSMagazyn]
    ON [CDN].[ProdSkladniki]([PdS_MagId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PdSProdukt]
    ON [CDN].[ProdSkladniki]([PdS_ProdId] ASC) WITH (FILLFACTOR = 100);


GO
Create Trigger CDN.ProdSkladniki_InsertUpdate_Trigger
  On CDN.ProdSkladniki
  For Insert, Update
As
Set NoCount On
-- Sprawdzanie ProdId z nagłówkiem
If Exists (Select * From inserted Join CDN.ProdReceptury On PdR_PdRId = PdS_PdRId
           Where PdR_TwrId <> PdS_ProdId)
  Update CDN.ProdSkladniki Set PdS_ProdId = PdR_TwrId
    From CDN.ProdReceptury Join CDN.ProdSkladniki On PdR_PdRId = PdS_PdRId
    Where PdS_PdSId In (Select PdS_PdSId From inserted Join CDN.ProdReceptury On PdR_PdRId = PdS_PdRId
                        Where PdR_TwrId <> PdS_ProdId)
Set NoCount Off
