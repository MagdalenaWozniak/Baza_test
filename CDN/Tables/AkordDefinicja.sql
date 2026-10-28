CREATE TABLE [CDN].[AkordDefinicja] (
    [ADF_AdfId]          INT             IDENTITY (1, 1) NOT NULL,
    [ADF_TwpId]          INT             NOT NULL,
    [ADF_Nazwa]          VARCHAR (40)    NOT NULL,
    [ADF_Skrot]          NVARCHAR (40)   NOT NULL,
    [ADF_Jednostka]      NVARCHAR (40)   NOT NULL,
    [ADF_Nieaktywny]     TINYINT         NOT NULL,
    [ADF_Pomniejszenie]  TINYINT         NOT NULL,
    [ADF_Rodzaj]         SMALLINT        NOT NULL,
    [ADF_Godzinowe]      TINYINT         NOT NULL,
    [ADF_Stawka]         DECIMAL (15, 4) NOT NULL,
    [ADF_Progresywny]    TINYINT         NOT NULL,
    [ADF_WgNajwStawki]   TINYINT         NOT NULL,
    [ADF_OpeZalId]       INT             NULL,
    [ADF_StaZalId]       INT             NULL,
    [ADF_TS_Zal]         DATETIME        NOT NULL,
    [ADF_OpeModId]       INT             NULL,
    [ADF_StaModId]       INT             NULL,
    [ADF_TS_Mod]         DATETIME        NOT NULL,
    [ADF_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_ADF_OpeModKod] DEFAULT ('') NOT NULL,
    [ADF_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_ADF_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [ADF_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_ADF_OpeZalKod] DEFAULT ('') NOT NULL,
    [ADF_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_ADF_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [ADF_Primary] PRIMARY KEY CLUSTERED ([ADF_AdfId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ADFTwpId] FOREIGN KEY ([ADF_TwpId]) REFERENCES [CDN].[TypWyplata] ([TWP_TwpId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ADFNazwa]
    ON [CDN].[AkordDefinicja]([ADF_Nazwa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [ADFTwpId]
    ON [CDN].[AkordDefinicja]([ADF_TwpId] ASC) WITH (FILLFACTOR = 100);

