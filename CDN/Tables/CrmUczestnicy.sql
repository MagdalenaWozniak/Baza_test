CREATE TABLE [CDN].[CrmUczestnicy] (
    [CrU_CrUId]                     INT            IDENTITY (1, 1) NOT NULL,
    [CrU_CrKId]                     INT            NOT NULL,
    [CrU_PodmiotTyp]                SMALLINT       NOT NULL,
    [CrU_PodmiotId]                 INT            NOT NULL,
    [CrU_Organizator]               TINYINT        NOT NULL,
    [CrU_Akronim]                   NVARCHAR (20)  NOT NULL,
    [CrU_Nazwisko]                  NVARCHAR (255) NOT NULL,
    [CrU_AutomatycznePrzypomnienia] TINYINT        CONSTRAINT [DF_CrU_AutomatycznePrzypomnienia] DEFAULT ((0)) NOT NULL,
    [CrU_Email]                     NVARCHAR (127) NULL,
    [CrU_TelefonSms]                VARCHAR (20)   NULL,
    CONSTRAINT [CrU_Primary] PRIMARY KEY CLUSTERED ([CrU_CrUId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [CruCrmKontakty]
    ON [CDN].[CrmUczestnicy]([CrU_CrKId] ASC, [CrU_CrUId] ASC) WITH (FILLFACTOR = 100);

