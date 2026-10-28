CREATE TABLE [CDN].[TwrPrzeceny] (
    [TPC_TwrID]    INT             NOT NULL,
    [TPC_TwCNumer] INT             NOT NULL,
    [TPC_Data]     DATETIME        NOT NULL,
    [TPC_Wartosc]  DECIMAL (17, 4) NOT NULL,
    [TPC_Waluta]   VARCHAR (3)     NOT NULL,
    CONSTRAINT [FK_TPCTowar] FOREIGN KEY ([TPC_TwrID]) REFERENCES [CDN].[Towary] ([Twr_TwrId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TPCTowar]
    ON [CDN].[TwrPrzeceny]([TPC_TwrID] ASC, [TPC_TwCNumer] ASC, [TPC_Data] ASC) WITH (FILLFACTOR = 100);

