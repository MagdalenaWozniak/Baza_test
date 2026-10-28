CREATE TABLE [CDN].[DokNagProcesEtapy] (
    [DnPr_DnPrID]      INT      IDENTITY (1, 1) NOT NULL,
    [DnPr_DoNID]       INT      NULL,
    [DnPr_Typ]         INT      NULL,
    [DnPr_Lp]          INT      NOT NULL,
    [DnPr_PoprzedniLp] INT      NOT NULL,
    [DnPr_Poziom]      SMALLINT NOT NULL,
    CONSTRAINT [DnPr_Primary] PRIMARY KEY CLUSTERED ([DnPr_DnPrID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DnPrDokNag] FOREIGN KEY ([DnPr_DoNID]) REFERENCES [CDN].[DokNag] ([DoN_DoNID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DnPrLp]
    ON [CDN].[DokNagProcesEtapy]([DnPr_DoNID] ASC, [DnPr_Lp] ASC, [DnPr_Poziom] ASC, [DnPr_DnPrID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DnPrDokNag]
    ON [CDN].[DokNagProcesEtapy]([DnPr_DoNID] ASC, [DnPr_DnPrID] ASC) WITH (FILLFACTOR = 100);


GO
Create Trigger CDN.DokNagProcesEtapy_Delete_Trigger
  On CDN.DokNagProcesEtapy
  For Delete
As
Set NoCount On
-- Skasowanie relacji do DokNagEtapy
  DELETE CDN.DokNagEtapy
  FROM CDN.DokNagEtapy JOIN deleted ON DnE_DnPrID=deleted.DnPr_DnPrID
-- Skasowanie relacji do DokNagEtapyKolejne
  DELETE CDN.DokNagEtapyKolejne
  FROM CDN.DokNagEtapyKolejne JOIN deleted ON DnEK_DnPrID=deleted.DnPr_DnPrID
Set NoCount Off
