CREATE TABLE [CDN].[ZaniechaniaRoz] (
    [ZAR_ZarId] INT             IDENTITY (1, 1) NOT NULL,
    [ZAR_ZanId] INT             NOT NULL,
    [ZAR_WplId] INT             NOT NULL,
    [ZAR_Kwota] DECIMAL (15, 2) NOT NULL,
    [ZAR_Data]  DATETIME        NOT NULL,
    CONSTRAINT [ZAR_Primary] PRIMARY KEY CLUSTERED ([ZAR_ZarId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ZARZanId] FOREIGN KEY ([ZAR_ZanId]) REFERENCES [CDN].[Zaniechania] ([ZAN_ZanId])
);


GO
CREATE NONCLUSTERED INDEX [ZARZanId]
    ON [CDN].[ZaniechaniaRoz]([ZAR_ZanId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [ZARWplId]
    ON [CDN].[ZaniechaniaRoz]([ZAR_WplId] ASC) WITH (FILLFACTOR = 100);

