CREATE TABLE [CDN].[TrwaleHistPowiazania] (
    [SrHP_SrHPID]      INT             IDENTITY (1, 1) NOT NULL,
    [SrHP_SrHID]       INT             NULL,
    [SrHP_DokumentTyp] INT             NULL,
    [SrHP_DokumentID]  INT             NULL,
    [SrHP_DataDok]     DATETIME        NULL,
    [SrHP_Numer]       NVARCHAR (256)  NULL,
    [SrHP_Kwota]       DECIMAL (15, 2) NOT NULL,
    [SrHP_Opis]        NVARCHAR (255)  NULL,
    CONSTRAINT [SrHP_Primary] PRIMARY KEY CLUSTERED ([SrHP_SrHPID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SrHPDok] FOREIGN KEY ([SrHP_SrHID]) REFERENCES [CDN].[TrwaleHist] ([SrH_SrHID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrHPDok]
    ON [CDN].[TrwaleHistPowiazania]([SrHP_SrHID] ASC, [SrHP_DokumentID] ASC, [SrHP_DokumentTyp] ASC, [SrHP_Numer] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.TrwaleHistPowiazania_Delete_Trigger
  ON CDN.TrwaleHistPowiazania
  FOR DELETE
AS
  SET NOCOUNT ON
  UPDATE cdn.TrwaleHist
 SET
   SrH_DokumentTyp = (SELECT TOP 1 SrHP_DokumentTyp FROM cdn.TrwaleHistPowiazania WHERE SrHP_SrHID = SrH_SrHID ORDER BY SrHP_DataDok, SrHP_SrHPID),
   SrH_DokumentID = (SELECT TOP 1 SrHP_DokumentID FROM cdn.TrwaleHistPowiazania WHERE SrHP_SrHID = SrH_SrHID ORDER BY SrHP_DataDok, SrHP_SrHPID),
   SrH_Numer = (SELECT TOP 1 SrHP_Numer FROM cdn.TrwaleHistPowiazania WHERE SrHP_SrHID = SrH_SrHID ORDER BY SrHP_DataDok, SrHP_SrHPID)
 WHERE SrH_SrHID IN (SELECT deleted.SrHP_SrHID FROM deleted) AND EXISTS (SELECT * FROM cdn.TrwaleHistPowiazania WHERE SrHP_SrHID = SrH_SrHID)
  AND
  (
   IsNull(SrH_DokumentTyp, 0) <> (SELECT TOP 1 IsNull(SrHP_DokumentTyp, 0) FROM cdn.TrwaleHistPowiazania WHERE SrHP_SrHID = SrH_SrHID ORDER BY SrHP_DataDok, SrHP_SrHPID) OR
   IsNull(SrH_DokumentID, 0) <> (SELECT TOP 1 IsNull(SrHP_DokumentID, 0) FROM cdn.TrwaleHistPowiazania WHERE SrHP_SrHID = SrH_SrHID ORDER BY SrHP_DataDok, SrHP_SrHPID) OR
   IsNull(SrH_Numer, '') <> (SELECT TOP 1 IsNull(SrHP_Numer, '') FROM cdn.TrwaleHistPowiazania WHERE SrHP_SrHID = SrH_SrHID ORDER BY SrHP_DataDok, SrHP_SrHPID)
  )
 UPDATE cdn.TrwaleHist
 SET
   SrH_DokumentTyp = NULL,
   SrH_DokumentID = NULL,
   SrH_Numer = NULL
 WHERE SrH_SrHID IN (SELECT deleted.SrHP_SrHID FROM deleted) AND NOT EXISTS (SELECT * FROM cdn.TrwaleHistPowiazania WHERE SrHP_SrHID = SrH_SrHID)
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.TrwaleHistPowiazania_InsertUpdate_Trigger
  ON CDN.TrwaleHistPowiazania
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
  UPDATE cdn.TrwaleHist
 SET
   SrH_DokumentTyp = (SELECT TOP 1 SrHP_DokumentTyp FROM cdn.TrwaleHistPowiazania WHERE SrHP_SrHID = SrH_SrHID ORDER BY SrHP_DataDok, SrHP_SrHPID),
   SrH_DokumentID = (SELECT TOP 1 SrHP_DokumentID FROM cdn.TrwaleHistPowiazania WHERE SrHP_SrHID = SrH_SrHID ORDER BY SrHP_DataDok, SrHP_SrHPID),
   SrH_Numer = (SELECT TOP 1 SrHP_Numer FROM cdn.TrwaleHistPowiazania WHERE SrHP_SrHID = SrH_SrHID ORDER BY SrHP_DataDok, SrHP_SrHPID)
 WHERE SrH_SrHID IN (SELECT inserted.SrHP_SrHID FROM inserted)
 AND
  (NOT EXISTS (SELECT * FROM cdn.TrwaleHistPowiazania WHERE SrHP_SrHID = SrH_SrHID) OR
   (
    IsNull(SrH_DokumentTyp, 0) <> (SELECT TOP 1 IsNull(SrHP_DokumentTyp, 0) FROM cdn.TrwaleHistPowiazania WHERE SrHP_SrHID = SrH_SrHID ORDER BY SrHP_DataDok, SrHP_SrHPID) OR
    IsNull(SrH_DokumentID, 0) <> (SELECT TOP 1 IsNull(SrHP_DokumentID, 0) FROM cdn.TrwaleHistPowiazania WHERE SrHP_SrHID = SrH_SrHID ORDER BY SrHP_DataDok, SrHP_SrHPID) OR
    IsNull(SrH_Numer, '') <> (SELECT TOP 1 IsNull(SrHP_Numer, '') FROM cdn.TrwaleHistPowiazania WHERE SrHP_SrHID = SrH_SrHID ORDER BY SrHP_DataDok, SrHP_SrHPID)
   )
 )
  SET NOCOUNT OFF
