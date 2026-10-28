CREATE TABLE [CDN].[WyposazenieOsobyOdpowiedzialne] (
    [WyOO_WyOOID]          INT            IDENTITY (1, 1) NOT NULL,
    [WyOO_WypID]           INT            NOT NULL,
    [WyOO_DataOd]          DATETIME       NULL,
    [WyOO_DataDo]          DATETIME       NULL,
    [WyOO_PrcID]           INT            NULL,
    [WyOO_PrcImieNazwisko] NVARCHAR (255) NOT NULL,
    CONSTRAINT [WyOOPrimary] PRIMARY KEY CLUSTERED ([WyOO_WyOOID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WyOOWyp] FOREIGN KEY ([WyOO_WypID]) REFERENCES [CDN].[Wyposazenie] ([Wyp_WypID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WyOOWyp]
    ON [CDN].[WyposazenieOsobyOdpowiedzialne]([WyOO_WypID] ASC, [WyOO_DataOd] ASC) WITH (FILLFACTOR = 100);

