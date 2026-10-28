CREATE TABLE [CDN].[CfgWartosci] (
    [CFW_CfwId]          INT             IDENTITY (1, 1) NOT NULL,
    [CFW_CfkId]          INT             NOT NULL,
    [CFW_Nazwa]          VARCHAR (32)    NOT NULL,
    [CFW_Typ]            TINYINT         NOT NULL,
    [CFW_Wartosc]        NVARCHAR (4000) NOT NULL,
    [CFW_OpeZalId]       INT             NULL,
    [CFW_StaZalId]       INT             NULL,
    [CFW_TS_Zal]         DATETIME        NULL,
    [CFW_OpeModId]       INT             NULL,
    [CFW_StaModId]       INT             NULL,
    [CFW_TS_Mod]         DATETIME        NULL,
    [CFW_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_CFW_OpeModKod] DEFAULT ('') NOT NULL,
    [CFW_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_CFW_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [CFW_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_CFW_OpeZalKod] DEFAULT ('') NOT NULL,
    [CFW_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_CFW_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [CFW_Primary] PRIMARY KEY CLUSTERED ([CFW_CfwId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CFWCfkLink] FOREIGN KEY ([CFW_CfkId]) REFERENCES [CDN].[CfgKlucze] ([CFK_CfkId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [CFWCfkLink]
    ON [CDN].[CfgWartosci]([CFW_CfkId] ASC, [CFW_Nazwa] ASC) WITH (FILLFACTOR = 100);

