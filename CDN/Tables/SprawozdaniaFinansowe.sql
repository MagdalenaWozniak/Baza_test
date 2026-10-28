CREATE TABLE [CDN].[SprawozdaniaFinansowe] (
    [SFS_SFSId]           INT            IDENTITY (1, 1) NOT NULL,
    [SFS_DABId]           INT            NULL,
    [SFS_ConfigDABId]     INT            NULL,
    [SFS_UPODABId]        INT            NULL,
    [SFS_SchemaVersion]   NVARCHAR (11)  NULL,
    [SFS_Active]          INT            CONSTRAINT [DF_SFS_Active] DEFAULT ((1)) NOT NULL,
    [SFS_DateTo]          DATETIME       NULL,
    [SFS_PreparationDate] DATETIME       NULL,
    [SFS_CompanyName]     NVARCHAR (MAX) NULL,
    [SFS_Type]            INT            NULL,
    [SFS_Status]          INT            NULL,
    [SFS_UPODescription]  NVARCHAR (MAX) NULL,
    [SFS_UPOCode]         NVARCHAR (4)   NULL,
    [SFS_ReferenceNumber] NVARCHAR (41)  NULL,
    [SFS_TS_Oblicz]       DATETIME       NULL,
    [SFS_OpeZalID]        INT            NULL,
    [SFS_StaZalId]        INT            NULL,
    [SFS_TS_Zal]          DATETIME       NOT NULL,
    [SFS_OpeModID]        INT            NULL,
    [SFS_StaModId]        INT            NULL,
    [SFS_TS_Mod]          DATETIME       NOT NULL,
    [SFS_OpeModKod]       VARCHAR (20)   CONSTRAINT [DF_SFS_OpeModKod] DEFAULT ('') NOT NULL,
    [SFS_OpeModNazwisko]  NVARCHAR (50)  CONSTRAINT [DF_SFS_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [SFS_OpeZalKod]       VARCHAR (20)   CONSTRAINT [DF_SFS_OpeZalKod] DEFAULT ('') NOT NULL,
    [SFS_OpeZalNazwisko]  NVARCHAR (50)  CONSTRAINT [DF_SFS_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [SFS_Primary] PRIMARY KEY CLUSTERED ([SFS_SFSId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SFSDABId]
    ON [CDN].[SprawozdaniaFinansowe]([SFS_DABId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SFSConfigDABId]
    ON [CDN].[SprawozdaniaFinansowe]([SFS_ConfigDABId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SFSUPODABId]
    ON [CDN].[SprawozdaniaFinansowe]([SFS_UPODABId] ASC) WITH (FILLFACTOR = 100);

