CREATE TABLE [CDN].[Wzorce] (
    [WZR_WzrId]          INT             IDENTITY (1, 1) NOT NULL,
    [WZR_Nazwa]          VARCHAR (50)    NOT NULL,
    [WZR_Typ]            INT             NOT NULL,
    [WZR_Opis]           NVARCHAR (256)  NOT NULL,
    [WZR_ZmiennaCur1]    DECIMAL (15, 2) NOT NULL,
    [WZR_ZmiennaCur2]    DECIMAL (15, 2) NOT NULL,
    [WZR_ZmiennaCur3]    DECIMAL (15, 2) NOT NULL,
    [WZR_ZmiennaInt1]    INT             NOT NULL,
    [WZR_ZmiennaInt2]    INT             NOT NULL,
    [WZR_ZmiennaInt3]    INT             NOT NULL,
    [WZR_Rodzaj]         SMALLINT        NOT NULL,
    [WZR_Wzor]           NVARCHAR (256)  NOT NULL,
    [WZR_Dodatkowe]      NVARCHAR (128)  NOT NULL,
    [WZR_Lista]          SMALLINT        NOT NULL,
    [WZR_DataOd]         DATETIME        NOT NULL,
    [WZR_DataDo]         DATETIME        NOT NULL,
    [WZR_OpeZalId]       INT             NULL,
    [WZR_StaZalId]       INT             NULL,
    [WZR_TS_Zal]         DATETIME        NOT NULL,
    [WZR_OpeModId]       INT             NULL,
    [WZR_StaModId]       INT             NULL,
    [WZR_TS_Mod]         DATETIME        NOT NULL,
    [WZR_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_WZR_OpeModKod] DEFAULT ('') NOT NULL,
    [WZR_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_WZR_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [WZR_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_WZR_OpeZalKod] DEFAULT ('') NOT NULL,
    [WZR_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_WZR_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [WZR_Primary] PRIMARY KEY CLUSTERED ([WZR_WzrId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WZRKeyNazwa]
    ON [CDN].[Wzorce]([WZR_Nazwa] ASC) WITH (FILLFACTOR = 100);

