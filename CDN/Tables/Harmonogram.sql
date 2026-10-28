CREATE TABLE [CDN].[Harmonogram] (
    [HRM_HrmId]            INT             IDENTITY (1, 1) NOT NULL,
    [HRM_DodId]            INT             NOT NULL,
    [HRM_DkmId]            INT             NOT NULL,
    [HRM_KwotaZadluzenia]  DECIMAL (15, 2) NOT NULL,
    [HRM_DataNaliczenia]   DATETIME        NOT NULL,
    [HRM_Zablokowany]      TINYINT         NOT NULL,
    [HRM_RataKapitalowa]   DECIMAL (15, 2) NOT NULL,
    [HRM_TerminSplaty]     DATETIME        NOT NULL,
    [HRM_SplataKapitalu]   TINYINT         NOT NULL,
    [HRM_RatyKapitalowe]   TINYINT         NOT NULL,
    [HRM_LiczbaRat]        INT             NOT NULL,
    [HRM_NiepelnaRata]     SMALLINT        NOT NULL,
    [HRM_NaliczacOdsetki]  TINYINT         NOT NULL,
    [HRM_Procent]          DECIMAL (15, 2) NOT NULL,
    [HRM_SplataOdsetek]    TINYINT         NOT NULL,
    [HRM_OdsetkiPotracane] SMALLINT        NOT NULL,
    [HRM_Rok]              INT             NOT NULL,
    [HRM_Miesiac]          SMALLINT        NOT NULL,
    [HRM_Uzyty]            TINYINT         NOT NULL,
    [HRM_OpeZalId]         INT             NULL,
    [HRM_StaZalId]         INT             NULL,
    [HRM_TS_Zal]           DATETIME        NOT NULL,
    [HRM_OpeModId]         INT             NULL,
    [HRM_StaModId]         INT             NULL,
    [HRM_TS_Mod]           DATETIME        NOT NULL,
    [HRM_OpeModKod]        VARCHAR (20)    CONSTRAINT [DF_HRM_OpeModKod] DEFAULT ('') NOT NULL,
    [HRM_OpeModNazwisko]   NVARCHAR (50)   CONSTRAINT [DF_HRM_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [HRM_OpeZalKod]        VARCHAR (20)    CONSTRAINT [DF_HRM_OpeZalKod] DEFAULT ('') NOT NULL,
    [HRM_OpeZalNazwisko]   NVARCHAR (50)   CONSTRAINT [DF_HRM_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [HRM_Primary] PRIMARY KEY CLUSTERED ([HRM_HrmId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HRMDkmLink] FOREIGN KEY ([HRM_DkmId]) REFERENCES [CDN].[DaneKadMod] ([DKM_DkmId]),
    CONSTRAINT [FK_HRMDodLink] FOREIGN KEY ([HRM_DodId]) REFERENCES [CDN].[Dodatki] ([DOD_DodId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [HRMDodLink]
    ON [CDN].[Harmonogram]([HRM_DodId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [HRMDkmLink]
    ON [CDN].[Harmonogram]([HRM_DkmId] ASC) WITH (FILLFACTOR = 100);

