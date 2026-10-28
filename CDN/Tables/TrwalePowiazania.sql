CREATE TABLE [CDN].[TrwalePowiazania] (
    [SrTP_SrtPID]      INT             IDENTITY (1, 1) NOT NULL,
    [SrTP_SrTID]       INT             NULL,
    [SrTP_DokumentTyp] INT             NULL,
    [SrTP_DokumentID]  INT             NULL,
    [SrTP_DataDok]     DATETIME        NULL,
    [SrTP_Numer]       NVARCHAR (256)  NULL,
    [SrTP_Kwota]       DECIMAL (15, 2) NOT NULL,
    [SrTP_Opis]        NVARCHAR (255)  NULL,
    CONSTRAINT [SrTP_Primary] PRIMARY KEY CLUSTERED ([SrTP_SrtPID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SrTPDok] FOREIGN KEY ([SrTP_SrTID]) REFERENCES [CDN].[Trwale] ([SrT_SrTID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrTPDok]
    ON [CDN].[TrwalePowiazania]([SrTP_SrTID] ASC, [SrTP_DokumentID] ASC, [SrTP_DokumentTyp] ASC, [SrTP_Numer] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.TrwalePowiazania_DeleteHandler
  ON CDN.TrwalePowiazania
  FOR DELETE
AS
  SET NOCOUNT ON
    -- Usunięcie liknów do dokumentów OT w cdn.TrwaleHist
    UPDATE cdn.TrwaleHist
    SET SrH_DokumentTyp = NULL, SrH_DokumentID = NULL
    WHERE
    SrH_SrHID IN (SELECT h.SrH_SrHID FROM deleted d JOIN cdn.TrwaleHist h ON h.SrH_SrTID = d.SrTP_SrTID
                  AND h.SrH_DokumentTyp = d.SrTP_DokumentTyp AND h.SrH_DokumentID = d.SrTP_DokumentID
                  WHERE h.SrH_TypDokumentu = 4)
  SET NOCOUNT OFF
