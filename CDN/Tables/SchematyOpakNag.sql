CREATE TABLE [CDN].[SchematyOpakNag] (
    [SON_SONId]          INT           IDENTITY (1, 1) NOT NULL,
    [SON_Nieaktywny]     TINYINT       NOT NULL,
    [SON_TS_XL]          DATETIME      NULL,
    [SON_Kod]            VARCHAR (20)  NOT NULL,
    [SON_Nazwa]          NVARCHAR (50) NOT NULL,
    [SON_OpeZalID]       INT           NULL,
    [SON_StaZalId]       INT           NULL,
    [SON_TS_Zal]         DATETIME      NOT NULL,
    [SON_OpeModID]       INT           NULL,
    [SON_StaModID]       INT           NULL,
    [SON_TS_Mod]         DATETIME      NOT NULL,
    [SON_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_SON_OpeModKod] DEFAULT ('') NOT NULL,
    [SON_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_SON_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [SON_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_SON_OpeZalKod] DEFAULT ('') NOT NULL,
    [SON_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_SON_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [SON_Primary] PRIMARY KEY CLUSTERED ([SON_SONId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SONKod]
    ON [CDN].[SchematyOpakNag]([SON_Kod] ASC) WITH (FILLFACTOR = 100);

