CREATE TABLE [CDN].[WyposazeniePowiazania] (
    [WypP_WypPID]      INT             IDENTITY (1, 1) NOT NULL,
    [WypP_WypID]       INT             NULL,
    [WypP_DokumentTyp] INT             NULL,
    [WypP_DokumentID]  INT             NULL,
    [WypP_DataDok]     DATETIME        NULL,
    [WypP_Numer]       NVARCHAR (256)  NULL,
    [WypP_Kwota]       DECIMAL (15, 2) NOT NULL,
    [WypP_Opis]        NVARCHAR (255)  NULL,
    CONSTRAINT [WypP_Primary] PRIMARY KEY CLUSTERED ([WypP_WypPID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WypPDok] FOREIGN KEY ([WypP_WypID]) REFERENCES [CDN].[Wyposazenie] ([Wyp_WypID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WypPDok]
    ON [CDN].[WyposazeniePowiazania]([WypP_WypID] ASC, [WypP_DokumentID] ASC, [WypP_DokumentTyp] ASC, [WypP_Numer] ASC) WITH (FILLFACTOR = 100);

