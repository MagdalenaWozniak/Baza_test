CREATE TABLE [CDN].[DlgTrasy] (
    [DLT_DLTId]            INT             IDENTITY (1, 1) NOT NULL,
    [DLT_DLEId]            INT             NOT NULL,
    [DLT_DLDId]            INT             NULL,
    [DLT_MiejsceOdjazdu]   NVARCHAR (127)  NULL,
    [DLT_DataOdjazdu]      DATETIME        NULL,
    [DLT_GodzinaOdjazdu]   DATETIME        NULL,
    [DLT_MiejscePrzyjazdu] NVARCHAR (127)  NULL,
    [DLT_DataPrzyjazdu]    DATETIME        NULL,
    [DLT_GodzinaPrzyjazdu] DATETIME        NULL,
    [DLT_SrodekLokomocji]  NVARCHAR (50)   NULL,
    [DLT_KwotaSys]         DECIMAL (15, 2) NULL,
    [DLT_KwotaWal]         DECIMAL (15, 2) NULL,
    [DLT_Zrodlo]           INT             CONSTRAINT [DF_DLT_Zrodlo] DEFAULT ((0)) NOT NULL,
    [DLT_Wyjazd]           SMALLINT        CONSTRAINT [DF_DLT_Wyjazd] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [DLT_Primary] PRIMARY KEY CLUSTERED ([DLT_DLTId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DlgTrasyDlgElem] FOREIGN KEY ([DLT_DLEId]) REFERENCES [CDN].[DlgElem] ([DLE_DLEId]) ON DELETE CASCADE
);

