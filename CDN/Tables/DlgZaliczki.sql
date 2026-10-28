CREATE TABLE [CDN].[DlgZaliczki] (
    [DLZ_DLZId]            INT             IDENTITY (1, 1) NOT NULL,
    [DLZ_DLEId]            INT             NOT NULL,
    [DLZ_Typ]              INT             NULL,
    [DLZ_BZpId]            INT             NULL,
    [DLZ_FPlID]            INT             NULL,
    [DLZ_Dokument]         NVARCHAR (256)  NULL,
    [DLZ_Data]             DATETIME        NULL,
    [DLZ_Waluta]           VARCHAR (3)     NULL,
    [DLZ_KursNumer]        INT             NULL,
    [DLZ_KursL]            DECIMAL (15, 4) NULL,
    [DLZ_KursM]            DECIMAL (5)     NULL,
    [DLZ_KwotaSys]         DECIMAL (15, 2) NULL,
    [DLZ_KwotaWal]         DECIMAL (15, 2) NULL,
    [DLZ_Zrodlo]           INT             CONSTRAINT [DF_DLZ_Zrodlo] DEFAULT ((0)) NOT NULL,
    [DLZ_KwotaRozliczenia] DECIMAL (15, 2) NULL,
    [DLZ_DataDok]          DATETIME        NULL,
    [DLZ_DataKur]          DATETIME        NULL,
    CONSTRAINT [DLZ_Primary] PRIMARY KEY CLUSTERED ([DLZ_DLZId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DlgZaliczkiDlgElem] FOREIGN KEY ([DLZ_DLEId]) REFERENCES [CDN].[DlgElem] ([DLE_DLEId]) ON DELETE CASCADE
);

