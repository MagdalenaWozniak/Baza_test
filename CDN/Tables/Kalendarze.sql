CREATE TABLE [CDN].[Kalendarze] (
    [KAL_KalId]               INT             IDENTITY (1, 1) NOT NULL,
    [KAL_Akronim]             VARCHAR (12)    NOT NULL,
    [KAL_Nazwa]               VARCHAR (40)    NOT NULL,
    [KAL_Opis]                NVARCHAR (64)   NOT NULL,
    [KAL_UwzglWymiarEtatu]    TINYINT         NOT NULL,
    [KAL_NadgodzRozlicz]      TINYINT         NOT NULL,
    [KAL_LiczOdchylkiOdZasad] TINYINT         NOT NULL,
    [KAL_LiczStdDopNadg]      TINYINT         NOT NULL,
    [KAL_LiczStdDopNadgNoc]   TINYINT         NOT NULL,
    [KAL_UwzglDobowWymPlan]   TINYINT         NOT NULL,
    [KAL_ModPlanNB]           TINYINT         NULL,
    [KAL_NormaKalendarz]      TINYINT         NOT NULL,
    [KAL_NormaDobowa]         DATETIME        NOT NULL,
    [KAL_NormaTygodniowa]     DATETIME        NOT NULL,
    [KAL_NadgodzOkres]        INT             NOT NULL,
    [KAL_NadgodzPrzesuniecie] INT             NOT NULL,
    [KAL_NadgodzOpoznienie]   INT             NOT NULL,
    [KAL_Nieaktywny]          TINYINT         CONSTRAINT [DF_KAL_Nieaktywny] DEFAULT ((0)) NOT NULL,
    [KAL_OpeZalId]            INT             NULL,
    [KAL_StaZalId]            INT             NULL,
    [KAL_TS_Zal]              DATETIME        NOT NULL,
    [KAL_OpeModId]            INT             NULL,
    [KAL_StaModId]            INT             NULL,
    [KAL_TS_Mod]              DATETIME        NOT NULL,
    [KAL_EdycjaNocne]         TINYINT         CONSTRAINT [DF_KAL_EdycjaNocne] DEFAULT ((0)) NOT NULL,
    [KAL_NocOd]               DATETIME        CONSTRAINT [DF_KAL_NocOd] DEFAULT ((-2)) NOT NULL,
    [KAL_NocDo]               DATETIME        CONSTRAINT [DF_KAL_NocDo] DEFAULT ((-2)) NOT NULL,
    [KAL_NocLimit]            DATETIME        CONSTRAINT [DF_KAL_NocLimit] DEFAULT ((-2)) NOT NULL,
    [KAL_NocProcent]          DECIMAL (15, 2) CONSTRAINT [DF_KAL_NocProcent] DEFAULT ((0)) NOT NULL,
    [KAL_DoplataZaPraceWNocy] TINYINT         CONSTRAINT [DF_KAL_DoplataZaPraceWNocy] DEFAULT ((0)) NOT NULL,
    [KAL_NocKP130]            TINYINT         CONSTRAINT [DF_KAL_NocKP130] DEFAULT ((0)) NOT NULL,
    [KAL_EdycjaNadgodz]       TINYINT         CONSTRAINT [DF_KAL_EdycjaNadgodz] DEFAULT ((0)) NOT NULL,
    [KAL_Procent50]           DECIMAL (15, 2) CONSTRAINT [DF_KAL_Procent50] DEFAULT ((0)) NOT NULL,
    [KAL_Procent100]          DECIMAL (15, 2) CONSTRAINT [DF_KAL_Procent100] DEFAULT ((0)) NOT NULL,
    [KAL_NadgodzKP130]        TINYINT         CONSTRAINT [DF_KAL_NadgodzKP130] DEFAULT ((0)) NOT NULL,
    [KAL_UwzglStandSwieta]    TINYINT         CONSTRAINT [DF_KAL_UwzglStandSwieta] DEFAULT ((0)) NOT NULL,
    [KAL_PodzialNadgDobTyg]   TINYINT         CONSTRAINT [DF_KAL_PodzialNadgDobTyg] DEFAULT ((0)) NOT NULL,
    [KAL_OpeModKod]           VARCHAR (20)    CONSTRAINT [DF_KAL_OpeModKod] DEFAULT ('') NOT NULL,
    [KAL_OpeModNazwisko]      NVARCHAR (50)   CONSTRAINT [DF_KAL_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [KAL_OpeZalKod]           VARCHAR (20)    CONSTRAINT [DF_KAL_OpeZalKod] DEFAULT ('') NOT NULL,
    [KAL_OpeZalNazwisko]      NVARCHAR (50)   CONSTRAINT [DF_KAL_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [KAL_Bilansowanie]        TINYINT         CONSTRAINT [DF_KAL_Bilansowanie] DEFAULT ((2)) NOT NULL,
    CONSTRAINT [KAL_Primary] PRIMARY KEY CLUSTERED ([KAL_KalId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KALAkronim]
    ON [CDN].[Kalendarze]([KAL_Akronim] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Kalendarze_Delete_Trigger
ON CDN.Kalendarze
FOR DELETE
AS
IF (SELECT KAL_KalId FROM DELETED) = 1 ROLLBACK TRANSACTION
