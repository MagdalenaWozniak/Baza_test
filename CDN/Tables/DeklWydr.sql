CREATE TABLE [CDN].[DeklWydr] (
    [DkW_DkWID]      INT            IDENTITY (1, 1) NOT NULL,
    [DkW_DkNID]      INT            NOT NULL,
    [DkW_Rubryka]    INT            NOT NULL,
    [DkW_SubRubryka] SMALLINT       NOT NULL,
    [DkW_Wartosc]    NVARCHAR (MAX) NOT NULL,
    [DkW_Opis]       NVARCHAR (254) NOT NULL,
    CONSTRAINT [DkW_Primary] PRIMARY KEY CLUSTERED ([DkW_DkWID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DkWDeklNag] FOREIGN KEY ([DkW_DkNID]) REFERENCES [CDN].[DeklNag] ([DkN_DkNID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DkWDeklNag]
    ON [CDN].[DeklWydr]([DkW_DkNID] ASC, [DkW_Rubryka] ASC, [DkW_SubRubryka] ASC) WITH (FILLFACTOR = 100);

