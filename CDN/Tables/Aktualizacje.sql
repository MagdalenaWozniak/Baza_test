CREATE TABLE [CDN].[Aktualizacje] (
    [Akt_Hash] CHAR (64) NOT NULL,
    CONSTRAINT [Akt_Primary] PRIMARY KEY CLUSTERED ([Akt_Hash] ASC) WITH (FILLFACTOR = 100)
);

