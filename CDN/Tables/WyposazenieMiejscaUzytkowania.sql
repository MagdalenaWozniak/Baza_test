CREATE TABLE [CDN].[WyposazenieMiejscaUzytkowania] (
    [WyMU_WyMUID] INT            IDENTITY (1, 1) NOT NULL,
    [WyMU_WypID]  INT            NOT NULL,
    [WyMU_DataOd] DATETIME       NULL,
    [WyMU_DataDo] DATETIME       NULL,
    [WyMU_Nazwa]  NVARCHAR (255) NOT NULL,
    CONSTRAINT [WyMUPrimary] PRIMARY KEY CLUSTERED ([WyMU_WyMUID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WyMUWyp] FOREIGN KEY ([WyMU_WypID]) REFERENCES [CDN].[Wyposazenie] ([Wyp_WypID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WyMUWyp]
    ON [CDN].[WyposazenieMiejscaUzytkowania]([WyMU_WypID] ASC, [WyMU_DataOd] ASC) WITH (FILLFACTOR = 100);

