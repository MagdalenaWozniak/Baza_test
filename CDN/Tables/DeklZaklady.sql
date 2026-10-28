CREATE TABLE [CDN].[DeklZaklady] (
    [DkZ_DkZID]               INT            IDENTITY (1, 1) NOT NULL,
    [DkZ_NazwaPelna]          NVARCHAR (240) NOT NULL,
    [DkZ_NazwaSkrocona]       NVARCHAR (70)  NOT NULL,
    [DkZ_Nip]                 NVARCHAR (20)  NOT NULL,
    [DkZ_Regon]               VARCHAR (20)   NOT NULL,
    [DkZ_LiczbaZatrudnionych] INT            NOT NULL,
    [DkZ_DataRozpDzial]       DATETIME       NULL,
    [DkZ_Kraj]                NVARCHAR (40)  NOT NULL,
    [DkZ_Wojewodztwo]         NVARCHAR (40)  NOT NULL,
    [DkZ_Powiat]              NVARCHAR (40)  NOT NULL,
    [DkZ_Gmina]               NVARCHAR (40)  NOT NULL,
    [DkZ_KodGminy]            VARCHAR (7)    NOT NULL,
    [DkZ_Ulica]               NVARCHAR (40)  NOT NULL,
    [DkZ_NrDomu]              NVARCHAR (10)  NOT NULL,
    [DkZ_NrLokalu]            NVARCHAR (10)  NOT NULL,
    [DkZ_Miasto]              NVARCHAR (40)  NOT NULL,
    [DkZ_KodP]                VARCHAR (10)   NOT NULL,
    [DkZ_Poczta]              NVARCHAR (40)  NOT NULL,
    [DkZ_Nieaktywny]          TINYINT        NOT NULL,
    [DkZ_UwzgledniajNaCITST]  TINYINT        NOT NULL,
    [DkZ_UwzgledniajNaCITSTA] TINYINT        NOT NULL,
    [DkZ_OpeZalId]            INT            NULL,
    [DkZ_StaZalId]            INT            NULL,
    [DkZ_TS_Zal]              DATETIME       NOT NULL,
    [DkZ_OpeModId]            INT            NULL,
    [DkZ_StaModId]            INT            NULL,
    [DkZ_TS_Mod]              DATETIME       NOT NULL,
    [DkZ_OpeModKod]           VARCHAR (20)   CONSTRAINT [DF_DkZ_OpeModKod] DEFAULT ('') NOT NULL,
    [DkZ_OpeModNazwisko]      NVARCHAR (50)  CONSTRAINT [DF_DkZ_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [DkZ_OpeZalKod]           VARCHAR (20)   CONSTRAINT [DF_DkZ_OpeZalKod] DEFAULT ('') NOT NULL,
    [DkZ_OpeZalNazwisko]      NVARCHAR (50)  CONSTRAINT [DF_DkZ_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [DkZ_Primary] PRIMARY KEY CLUSTERED ([DkZ_DkZID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [DkZNazwaPelna]
    ON [CDN].[DeklZaklady]([DkZ_NazwaPelna] ASC) WITH (FILLFACTOR = 100);

