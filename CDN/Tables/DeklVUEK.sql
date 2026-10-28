CREATE TABLE [CDN].[DeklVUEK] (
    [DVU_DVUID]          INT             IDENTITY (1, 1) NOT NULL,
    [DVU_ByloJest]       INT             NOT NULL,
    [DVU_ByloJestString] NVARCHAR (4)    NOT NULL,
    [DVU_DkNID]          INT             NOT NULL,
    [DVU_Kraj]           VARCHAR (2)     NOT NULL,
    [DVU_Kwota]          DECIMAL (15, 2) NULL,
    [DVU_LP]             INT             NOT NULL,
    [DVU_NIP]            VARCHAR (255)   NOT NULL,
    [DVU_TT]             INT             NULL,
    [DVU_TTString]       NVARCHAR (3)    NULL,
    [DVU_Typ]            INT             NOT NULL,
    [DVU_ZNumer]         INT             NOT NULL,
    [DVU_NIP2]           VARCHAR (255)   NULL,
    CONSTRAINT [DVU_Primary] PRIMARY KEY CLUSTERED ([DVU_DVUID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DVUDeklNag] FOREIGN KEY ([DVU_DkNID]) REFERENCES [CDN].[DeklNag] ([DkN_DkNID]) ON DELETE CASCADE
);

