CREATE TABLE [CDN].[StatNag] (
    [StN_StNID]          INT            IDENTITY (1, 1) NOT NULL,
    [StN_Zrodlo]         NVARCHAR (100) NOT NULL,
    [StN_DataEksport]    DATETIME       NULL,
    [StN_DataImport]     DATETIME       NULL,
    [StN_LiczbaSlowEksp] INT            NOT NULL,
    [StN_LiczbaSlowImp]  INT            NOT NULL,
    [StN_LiczbaDokEksp]  INT            NOT NULL,
    [StN_LiczbaDokImp]   INT            NOT NULL,
    [StN_Operator]       INT            NULL,
    [StN_Log]            NVARCHAR (100) NULL,
    CONSTRAINT [StN_Primary] PRIMARY KEY CLUSTERED ([StN_StNID] ASC) WITH (FILLFACTOR = 100)
);

