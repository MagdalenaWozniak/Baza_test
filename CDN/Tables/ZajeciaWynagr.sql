CREATE TABLE [CDN].[ZajeciaWynagr] (
    [ZAW_ZawId]                INT             IDENTITY (1, 1) NOT NULL,
    [ZAW_PraId]                INT             NOT NULL,
    [ZAW_KntId]                INT             NOT NULL,
    [ZAW_TwpId]                INT             NOT NULL,
    [ZAW_Sygnatura]            NVARCHAR (20)   NULL,
    [ZAW_DataDecyzji]          DATETIME        NULL,
    [ZAW_Nieaktywne]           TINYINT         NOT NULL,
    [ZAW_BnaId]                INT             NULL,
    [ZAW_RachunekNr]           NVARCHAR (50)   NULL,
    [ZAW_RachunekNr0]          NVARCHAR (50)   NULL,
    [ZAW_IBAN]                 SMALLINT        NOT NULL,
    [ZAW_Nazwa]                NVARCHAR (128)  NULL,
    [ZAW_Opis]                 NVARCHAR (256)  NULL,
    [ZAW_Rodzaj]               TINYINT         NULL,
    [ZAW_Wartosc]              DECIMAL (15, 2) NULL,
    [ZAW_Splacono]             DECIMAL (15, 2) NULL,
    [ZAW_DataOd]               DATETIME        NULL,
    [ZAW_DataDo]               DATETIME        NULL,
    [ZAW_Umowa]                TINYINT         NULL,
    [ZAW_UmowaOgranicz]        TINYINT         NULL,
    [ZAW_UmowaOgraniczKwota]   DECIMAL (15, 2) NULL,
    [ZAW_UmowaOgraniczProcent] DECIMAL (15, 2) NULL,
    [ZAW_Priorytet]            INT             NULL,
    [ZAW_Splacone]             TINYINT         NOT NULL,
    [ZAW_SplaconeCale]         AS              ([cdn].[SplaconeCale]([ZAW_Rodzaj],[ZAW_Wartosc],[ZAW_Splacono],[ZAW_Splacone])),
    [ZAW_OpeZalId]             INT             NULL,
    [ZAW_StaZalId]             INT             NULL,
    [ZAW_TS_Zal]               DATETIME        NOT NULL,
    [ZAW_OpeModId]             INT             NULL,
    [ZAW_StaModId]             INT             NULL,
    [ZAW_TS_Mod]               DATETIME        NOT NULL,
    [ZAW_OpeModKod]            VARCHAR (20)    CONSTRAINT [DF_ZAW_OpeModKod] DEFAULT ('') NOT NULL,
    [ZAW_OpeModNazwisko]       NVARCHAR (50)   CONSTRAINT [DF_ZAW_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [ZAW_OpeZalKod]            VARCHAR (20)    CONSTRAINT [DF_ZAW_OpeZalKod] DEFAULT ('') NOT NULL,
    [ZAW_OpeZalNazwisko]       NVARCHAR (50)   CONSTRAINT [DF_ZAW_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [ZAW_IloscGodzin]          DATETIME        NULL,
    [ZAW_RodzajCzasuPracy]     INT             CONSTRAINT [DF_ZAW_RodzajCzasuPracy] DEFAULT ((0)) NOT NULL,
    [ZAW_ProcWynZgodnyGrupa]   TINYINT         CONSTRAINT [DF_ZAW_ProcWynZgodnyGrupa] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [ZAW_Primary] PRIMARY KEY CLUSTERED ([ZAW_ZawId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ZAWPraLink] FOREIGN KEY ([ZAW_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [ZAWPraLink]
    ON [CDN].[ZajeciaWynagr]([ZAW_PraId] ASC) WITH (FILLFACTOR = 100);

