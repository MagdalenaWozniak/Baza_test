CREATE TABLE [CDN].[ZestawieniaKonta] (
    [ZKa_ZKaId]        INT           IDENTITY (1, 1) NOT NULL,
    [ZKa_OObId]        INT           NOT NULL,
    [ZKa_ZKNId]        INT           NOT NULL,
    [ZKa_ZKPId]        INT           NOT NULL,
    [ZKa_AccId]        INT           NOT NULL,
    [ZKa_Funkcja]      NVARCHAR (50) NOT NULL,
    [ZKa_FunkcjaNorma] NVARCHAR (50) NOT NULL,
    CONSTRAINT [ZKa_Primary] PRIMARY KEY CLUSTERED ([ZKa_ZKaId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccZestawienie] FOREIGN KEY ([ZKa_AccId]) REFERENCES [CDN].[Konta] ([Acc_AccId]) ON DELETE CASCADE,
    CONSTRAINT [FK_ZKaZestawienie] FOREIGN KEY ([ZKa_ZKPId]) REFERENCES [CDN].[ZestKsiPoz] ([ZKP_ZKPId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [ZKaZestawienie]
    ON [CDN].[ZestawieniaKonta]([ZKa_OObId] ASC, [ZKa_ZKNId] ASC, [ZKa_ZKPId] ASC, [ZKa_AccId] ASC, [ZKa_FunkcjaNorma] ASC) WITH (FILLFACTOR = 100);

