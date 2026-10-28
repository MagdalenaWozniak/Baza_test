CREATE TABLE [CDN].[BnkZdarzeniaPodpisy] (
    [BZdP_BZdPID]          INT            IDENTITY (1, 1) NOT NULL,
    [BZdP_BZdID]           INT            NOT NULL,
    [BZdP_OpeID]           INT            NOT NULL,
    [BZdP_Data]            DATETIME       NOT NULL,
    [BZdP_CertyfikatNazwa] NVARCHAR (256) NOT NULL,
    [BZdP_Podpis]          NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [BZdP_Primary] PRIMARY KEY CLUSTERED ([BZdP_BZdPID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_BZdPBZd] FOREIGN KEY ([BZdP_BZdID]) REFERENCES [CDN].[BnkZdarzenia] ([BZd_BZdID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZdPOperator]
    ON [CDN].[BnkZdarzeniaPodpisy]([BZdP_BZdID] ASC, [BZdP_OpeID] ASC) WITH (FILLFACTOR = 100);

