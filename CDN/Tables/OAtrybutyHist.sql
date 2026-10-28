CREATE TABLE [CDN].[OAtrybutyHist] (
    [ATH_AthId]       INT            IDENTITY (1, 1) NOT NULL,
    [ATH_PrcId]       INT            NOT NULL,
    [ATH_AtkId]       INT            NULL,
    [ATH_OatId]       INT            NOT NULL,
    [ATH_Wartosc]     NVARCHAR (101) NOT NULL,
    [ATH_DataOd]      DATETIME       NOT NULL,
    [ATH_DataDo]      DATETIME       NOT NULL,
    [ATH_ImportRowId] NVARCHAR (36)  CONSTRAINT [DF_ATH_ImportRowId] DEFAULT (newid()) NULL,
    CONSTRAINT [ATH_Primary] PRIMARY KEY CLUSTERED ([ATH_AthId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ATHOatId] FOREIGN KEY ([ATH_OatId]) REFERENCES [CDN].[OAtrybuty] ([OAT_OatId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [ATHOatId]
    ON [CDN].[OAtrybutyHist]([ATH_OatId] ASC) WITH (FILLFACTOR = 100);


GO
Create Trigger CDN.OAtrybutyHist_InsertUpdate_Trigger
  On CDN.OAtrybutyHist
  For Insert, Update
As
Set NoCount On
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where ATH_ImportRowId Is Null Or ATH_ImportRowId = '')
  Update CDN.OAtrybutyHist Set ATH_ImportRowId = NewId()
  Where ATH_AthId In (Select ATH_AthId From inserted Where ATH_ImportRowId Is Null Or ATH_ImportRowId = '')
Set NoCount Off
