CREATE TABLE [CDN].[eSklepFormyPlatnosci] (
    [ESF_ESFId]   INT           IDENTITY (1, 1) NOT NULL,
    [ESF_ESSId]   INT           NOT NULL,
    [ESF_IGFPlId] INT           NULL,
    [ESF_FPlId]   INT           NOT NULL,
    [ESF_Nazwa]   NVARCHAR (50) NOT NULL,
    [ESF_Aktywna] TINYINT       NOT NULL,
    CONSTRAINT [ESF_Primary] PRIMARY KEY CLUSTERED ([ESF_ESFId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ESFESSId] FOREIGN KEY ([ESF_ESSId]) REFERENCES [CDN].[eSklepStanowiska] ([ESS_ESSId]) ON DELETE CASCADE
);

