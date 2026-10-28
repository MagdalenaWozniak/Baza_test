CREATE TABLE [CDN].[BnkZdarzeniaAutoryzacje] (
    [BZdA_BZdAID]           INT            IDENTITY (1, 1) NOT NULL,
    [BZdA_BZdID]            INT            NOT NULL,
    [BZdA_OpeID]            INT            NOT NULL,
    [BZdA_LoginUzytkownika] NVARCHAR (256) NOT NULL,
    [BZdA_Data]             DATETIME       NOT NULL,
    [BZdA_TypAutoryzacji]   TINYINT        NOT NULL,
    CONSTRAINT [BZdA_Primary] PRIMARY KEY CLUSTERED ([BZdA_BZdAID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_BZdABZd] FOREIGN KEY ([BZdA_BZdID]) REFERENCES [CDN].[BnkZdarzenia] ([BZd_BZdID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZdAOperatorTypAutoryzacji]
    ON [CDN].[BnkZdarzeniaAutoryzacje]([BZdA_BZdID] ASC, [BZdA_OpeID] ASC, [BZdA_TypAutoryzacji] ASC) WITH (FILLFACTOR = 100);

