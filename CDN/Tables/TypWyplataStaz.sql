CREATE TABLE [CDN].[TypWyplataStaz] (
    [TWS_TwsId]   INT             IDENTITY (1, 1) NOT NULL,
    [TWS_TwpId]   INT             NOT NULL,
    [TWS_Staz]    INT             NOT NULL,
    [TWS_Procent] DECIMAL (15, 2) NOT NULL,
    CONSTRAINT [TWS_Primary] PRIMARY KEY CLUSTERED ([TWS_TwsId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TWSTwpLink] FOREIGN KEY ([TWS_TwpId]) REFERENCES [CDN].[TypWyplata] ([TWP_TwpId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [TWSTwpLink]
    ON [CDN].[TypWyplataStaz]([TWS_TwpId] ASC) WITH (FILLFACTOR = 100);

