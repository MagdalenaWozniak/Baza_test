CREATE TABLE [CDN].[DetalOperator] (
    [DOpe_DOpeId] INT IDENTITY (1, 1) NOT NULL,
    [DOpe_DStaId] INT NOT NULL,
    [DOpe_OpeId]  INT NOT NULL,
    CONSTRAINT [DOpe_Primary] PRIMARY KEY CLUSTERED ([DOpe_DOpeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DOpeStanowiskoDetal] FOREIGN KEY ([DOpe_DStaId]) REFERENCES [CDN].[DetalStanowiska] ([DSta_DStaId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DOpeStanowiskoDetal]
    ON [CDN].[DetalOperator]([DOpe_DStaId] ASC, [DOpe_OpeId] ASC) WITH (FILLFACTOR = 100);

