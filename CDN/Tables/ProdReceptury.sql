CREATE TABLE [CDN].[ProdReceptury] (
    [PdR_PdRId]          INT             IDENTITY (1, 1) NOT NULL,
    [PdR_TwrId]          INT             NULL,
    [PdR_Kod]            VARCHAR (20)    NOT NULL,
    [PdR_Nazwa]          NVARCHAR (50)   NOT NULL,
    [PdR_Domyslna]       TINYINT         NOT NULL,
    [PdR_Ilosc]          DECIMAL (15, 4) NOT NULL,
    [PdR_JM]             NVARCHAR (20)   NOT NULL,
    [PdR_Opis]           NVARCHAR (254)  NOT NULL,
    [PdR_OpeZalID]       INT             NULL,
    [PdR_StaZalId]       INT             NULL,
    [PdR_TS_Zal]         DATETIME        NOT NULL,
    [PdR_OpeModID]       INT             NULL,
    [PdR_StaModId]       INT             NULL,
    [PdR_TS_Mod]         DATETIME        NOT NULL,
    [PdR_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_PdR_OpeModKod] DEFAULT ('') NOT NULL,
    [PdR_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_PdR_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [PdR_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_PdR_OpeZalKod] DEFAULT ('') NOT NULL,
    [PdR_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_PdR_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [PdR_Primary] PRIMARY KEY CLUSTERED ([PdR_PdRId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PdRTwrKod] FOREIGN KEY ([PdR_TwrId]) REFERENCES [CDN].[Towary] ([Twr_TwrId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PdRTwrKod]
    ON [CDN].[ProdReceptury]([PdR_TwrId] ASC, [PdR_Kod] ASC) WITH (FILLFACTOR = 100);


GO
Create Trigger CDN.ProdReceptury_InsertUpdate_Trigger
  On CDN.ProdReceptury
  For Insert, Update
As
Set NoCount On
-- Kaskadowa aktualizacja ProdId w składnikach
If Exists (Select * From inserted Join CDN.ProdSkladniki On PdR_PdRId = PdS_PdRId
           Where PdR_TwrId <> PdS_ProdId)
  Update CDN.ProdSkladniki Set PdS_ProdId = PdR_TwrId
    From inserted Join CDN.ProdSkladniki On PdR_PdRId = PdS_PdRId
    Where PdR_TwrId <> PdS_ProdId
Set NoCount Off
