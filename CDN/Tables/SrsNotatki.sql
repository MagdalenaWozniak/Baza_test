CREATE TABLE [CDN].[SrsNotatki] (
    [SrN_SrNId]        INT             IDENTITY (1, 1) NOT NULL,
    [SrN_SrZId]        INT             NOT NULL,
    [SrN_Lp]           INT             NOT NULL,
    [SrN_Tresc]        NVARCHAR (1024) NOT NULL,
    [SrN_SerwisantTyp] INT             NULL,
    [SrN_SerwisantId]  INT             NULL,
    [SrN_DataDok]      DATETIME        NOT NULL,
    CONSTRAINT [SrN_Primary] PRIMARY KEY CLUSTERED ([SrN_SrNId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SrNZlecenia] FOREIGN KEY ([SrN_SrZId]) REFERENCES [CDN].[SrsZlecenia] ([SrZ_SrZId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrNZlecenia]
    ON [CDN].[SrsNotatki]([SrN_SrZId] ASC, [SrN_Lp] ASC, [SrN_SrNId] ASC) WITH (FILLFACTOR = 100);

