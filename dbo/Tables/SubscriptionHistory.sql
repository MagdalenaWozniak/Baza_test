CREATE TABLE [dbo].[SubscriptionHistory] (
    [id]                INT              IDENTITY (1, 1) NOT NULL,
    [SubscriptionID]    UNIQUEIDENTIFIER NULL,
    [ScheduleName]      NVARCHAR (260)   NULL,
    [ParameterSettings] VARCHAR (8000)   NULL,
    [DeliverySettings]  VARCHAR (8000)   NULL,
    [DateExecuted]      DATETIME         NULL,
    [ExecuteStatus]     NVARCHAR (260)   NULL,
    [DateCompleted]     DATETIME         NULL,
    [ExecutionTime]     AS               (datediff(second,[DateCompleted],[DateExecuted])),
    CONSTRAINT [PK_Subscription_HistoryS] PRIMARY KEY CLUSTERED ([id] ASC)
);

