CREATE TABLE [CDN].[UrzRachunki] (
    [URa_URaId]       INT           IDENTITY (1, 1) NOT NULL,
    [URa_UrzId]       INT           NOT NULL,
    [URa_Lp]          SMALLINT      NOT NULL,
    [URa_BNaId]       INT           NULL,
    [URa_RachunekNr]  NVARCHAR (51) NOT NULL,
    [URa_IBAN]        SMALLINT      NOT NULL,
    [URa_PraID]       INT           NULL,
    [URa_RachunekNr0] AS            (CONVERT([nvarchar](51),replace(replace([URA_RACHUNEKNR],'-',''),' ',''),(0))),
    CONSTRAINT [URa_Primary] PRIMARY KEY CLUSTERED ([URa_URaId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_URaBank] FOREIGN KEY ([URa_BNaId]) REFERENCES [CDN].[BnkNazwy] ([BNa_BNaId]),
    CONSTRAINT [FK_URaPracownik] FOREIGN KEY ([URa_PraID]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE,
    CONSTRAINT [FK_URaUrzad] FOREIGN KEY ([URa_UrzId]) REFERENCES [CDN].[Urzedy] ([Urz_UrzId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [URaUrzad]
    ON [CDN].[UrzRachunki]([URa_UrzId] ASC, [URa_Lp] ASC, [URa_PraID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [URaBank]
    ON [CDN].[UrzRachunki]([URa_BNaId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [URaRachunekNr0]
    ON [CDN].[UrzRachunki]([URa_RachunekNr0] ASC) WITH (FILLFACTOR = 100);

