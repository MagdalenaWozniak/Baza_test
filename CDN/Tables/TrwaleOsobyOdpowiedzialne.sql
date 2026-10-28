CREATE TABLE [CDN].[TrwaleOsobyOdpowiedzialne] (
    [SrOO_SrOOID]          INT            IDENTITY (1, 1) NOT NULL,
    [SrOO_SrTID]           INT            NOT NULL,
    [SrOO_DataOd]          DATETIME       NULL,
    [SrOO_DataDo]          DATETIME       NULL,
    [SrOO_PrcID]           INT            NULL,
    [SrOO_PrcImieNazwisko] NVARCHAR (255) NOT NULL,
    CONSTRAINT [SrOOPrimary] PRIMARY KEY CLUSTERED ([SrOO_SrOOID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SrOOSrT] FOREIGN KEY ([SrOO_SrTID]) REFERENCES [CDN].[Trwale] ([SrT_SrTID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrOOSrT]
    ON [CDN].[TrwaleOsobyOdpowiedzialne]([SrOO_SrTID] ASC, [SrOO_DataOd] ASC) WITH (FILLFACTOR = 100);

