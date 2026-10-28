CREATE TABLE [CDN].[AutoTrasy] (
    [AuT_AuTID]          INT             IDENTITY (1, 1) NOT NULL,
    [AuT_Kod]            VARCHAR (20)    NOT NULL,
    [AuT_Trasa]          NVARCHAR (1000) NULL,
    [AuT_Cel]            NVARCHAR (50)   NOT NULL,
    [AuT_Dlugosc]        DECIMAL (7, 2)  NOT NULL,
    [AuT_Miasto]         TINYINT         NOT NULL,
    [AuT_OpeZalID]       INT             NULL,
    [AuT_StaZalId]       INT             NULL,
    [AuT_TS_Zal]         DATETIME        NOT NULL,
    [AuT_OpeModID]       INT             NULL,
    [AuT_StaModId]       INT             NULL,
    [AuT_TS_Mod]         DATETIME        NOT NULL,
    [AuT_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_AuT_OpeModKod] DEFAULT ('') NOT NULL,
    [AuT_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_AuT_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [AuT_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_AuT_OpeZalKod] DEFAULT ('') NOT NULL,
    [AuT_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_AuT_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [AuT_Primary] PRIMARY KEY CLUSTERED ([AuT_AuTID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AuTKod]
    ON [CDN].[AutoTrasy]([AuT_Kod] ASC) WITH (FILLFACTOR = 100);

