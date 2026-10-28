CREATE TABLE [CDN].[PrzeszacWalutElem] (
    [PWE_PWEId]    INT             IDENTITY (1, 1) NOT NULL,
    [PWE_PWNId]    INT             NOT NULL,
    [PWE_AccWnId]  INT             NULL,
    [PWE_AccMaId]  INT             NULL,
    [PWE_KontoWn]  VARCHAR (50)    NULL,
    [PWE_KontoMa]  VARCHAR (50)    NULL,
    [PWE_Kwota]    DECIMAL (15, 2) NOT NULL,
    [PWE_SaldoWal] DECIMAL (15, 2) NOT NULL,
    [PWE_SaldoSys] DECIMAL (15, 2) NOT NULL,
    CONSTRAINT [PWE_Primary] PRIMARY KEY CLUSTERED ([PWE_PWEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PWEKontoMa] FOREIGN KEY ([PWE_AccMaId]) REFERENCES [CDN].[Konta] ([Acc_AccId]),
    CONSTRAINT [FK_PWEKontoWn] FOREIGN KEY ([PWE_AccWnId]) REFERENCES [CDN].[Konta] ([Acc_AccId]),
    CONSTRAINT [FK_PWEPWNID] FOREIGN KEY ([PWE_PWNId]) REFERENCES [CDN].[PrzeszacWalutNag] ([PWN_PWNID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [PWEPWNID]
    ON [CDN].[PrzeszacWalutElem]([PWE_PWNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PWEKonto]
    ON [CDN].[PrzeszacWalutElem]([PWE_AccWnId] ASC, [PWE_KontoWn] ASC, [PWE_AccMaId] ASC, [PWE_KontoMa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PWEKwota]
    ON [CDN].[PrzeszacWalutElem]([PWE_Kwota] ASC, [PWE_SaldoWal] ASC, [PWE_SaldoSys] ASC) WITH (FILLFACTOR = 100);

