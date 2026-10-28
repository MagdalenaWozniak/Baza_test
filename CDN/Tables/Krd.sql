CREATE TABLE [CDN].[Krd] (
    [KRD_KrdId]                 INT           IDENTITY (1, 1) NOT NULL,
    [KRD_KntId]                 INT           NULL,
    [KRD_DataOdczytuStatusu]    DATETIME      NULL,
    [KRD_Status]                INT           NULL,
    [KRD_Monitoring]            INT           NULL,
    [KRD_MonitoringConditionId] BIGINT        NULL,
    [KRD_RaportId]              VARCHAR (256) NULL,
    [KRD_Regulamin]             VARCHAR (256) NULL,
    CONSTRAINT [KRD_Primary] PRIMARY KEY CLUSTERED ([KRD_KrdId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Krd2Knt] FOREIGN KEY ([KRD_KntId]) REFERENCES [CDN].[Kontrahenci] ([Knt_KntId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KrdKntId]
    ON [CDN].[Krd]([KRD_KntId] ASC) WITH (FILLFACTOR = 100);

