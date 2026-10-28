CREATE TABLE [CDN].[NotyOdsElem] (
    [NOE_NOEId]        INT             IDENTITY (1, 1) NOT NULL,
    [NOE_NONId]        INT             NOT NULL,
    [NOE_BZdId]        INT             NULL,
    [NOE_BRKId]        INT             NULL,
    [NOE_Numer]        NVARCHAR (30)   NOT NULL,
    [NOE_Opis]         NVARCHAR (254)  NOT NULL,
    [NOE_DataDok]      DATETIME        NOT NULL,
    [NOE_DataOd]       DATETIME        NOT NULL,
    [NOE_DataDo]       DATETIME        NOT NULL,
    [NOE_Podstawa]     DECIMAL (15, 2) NOT NULL,
    [NOE_OdsetkiStopa] DECIMAL (7, 2)  NOT NULL,
    [NOE_OdsetkiKwota] DECIMAL (15, 2) NOT NULL,
    CONSTRAINT [NOE_Primary] PRIMARY KEY CLUSTERED ([NOE_NOEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_NOENaglowek] FOREIGN KEY ([NOE_NONId]) REFERENCES [CDN].[NotyOdsNag] ([NON_NONId]) ON DELETE CASCADE,
    CONSTRAINT [FK_NOERozliczenie] FOREIGN KEY ([NOE_BRKId]) REFERENCES [CDN].[BnkRozKwoty] ([BRK_BRKID]),
    CONSTRAINT [FK_NOEZdarzenie] FOREIGN KEY ([NOE_BZdId]) REFERENCES [CDN].[BnkZdarzenia] ([BZd_BZdID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [NOENaglowek]
    ON [CDN].[NotyOdsElem]([NOE_NONId] ASC, [NOE_NOEId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [NOEZdarzenie]
    ON [CDN].[NotyOdsElem]([NOE_BZdId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [NOERozliczenie]
    ON [CDN].[NotyOdsElem]([NOE_BRKId] ASC) WITH (FILLFACTOR = 100);

