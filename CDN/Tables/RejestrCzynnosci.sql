CREATE TABLE [CDN].[RejestrCzynnosci] (
    [RUC_RUCID]               INT            IDENTITY (1, 1) NOT NULL,
    [RUC_KategorieOsob]       NVARCHAR (MAX) NOT NULL,
    [RUC_KategorieDanychOs]   NVARCHAR (MAX) NOT NULL,
    [RUC_KategorieOdbiorcow]  NVARCHAR (MAX) NOT NULL,
    [RUC_PlanowanyTermin]     NVARCHAR (MAX) NOT NULL,
    [RUC_OpeZalID]            INT            NULL,
    [RUC_OpeModID]            INT            NULL,
    [RUC_StaZalID]            INT            NULL,
    [RUC_StaModID]            INT            NULL,
    [RUC_TS_Zal]              DATETIME       NOT NULL,
    [RUC_TS_Mod]              DATETIME       NOT NULL,
    [RUC_OpeModKod]           VARCHAR (20)   NOT NULL,
    [RUC_OpeZalKod]           VARCHAR (20)   NOT NULL,
    [RUC_OpeModNazwisko]      NVARCHAR (50)  NOT NULL,
    [RUC_OpeZalNazwisko]      NVARCHAR (50)  NOT NULL,
    [RUC_Nazwa]               NVARCHAR (500) CONSTRAINT [DF_RUC_Nazwa] DEFAULT ('') NOT NULL,
    [RUC_CelPrzetwarzania]    NVARCHAR (MAX) CONSTRAINT [DF_RUC_CelPrzetwarzania] DEFAULT ('') NOT NULL,
    [RUC_InformacjeDodatkowe] NVARCHAR (MAX) CONSTRAINT [DF_RUC_InformacjeDodatkowea] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_RUC_RUCID] PRIMARY KEY CLUSTERED ([RUC_RUCID] ASC) WITH (FILLFACTOR = 100)
);

