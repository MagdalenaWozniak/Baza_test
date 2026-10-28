CREATE TABLE [CDN].[GrupyPotracen] (
    [GPR_GprId]                 INT             IDENTITY (1, 1) NOT NULL,
    [GPR_Nazwa]                 NVARCHAR (40)   NOT NULL,
    [GPR_Skrot]                 NVARCHAR (20)   NOT NULL,
    [GPR_KwotaEgzekucji1]       DECIMAL (15, 2) NOT NULL,
    [GPR_KwotaEgzekucji2]       DECIMAL (15, 2) NOT NULL,
    [GPR_KwotaEgzekucji3]       DECIMAL (15, 2) NOT NULL,
    [GPR_KwotaWolna]            DECIMAL (15, 2) NOT NULL,
    [GPR_PropWymiarEtatu]       TINYINT         NOT NULL,
    [GPR_KwotaEgzekucjiZUS]     DECIMAL (15, 2) NOT NULL,
    [GPR_KwotaWolnaZUS]         DECIMAL (15, 2) NOT NULL,
    [GPR_PropWymiarEtatuZUS]    TINYINT         NOT NULL,
    [GPR_Nieaktywna]            TINYINT         NOT NULL,
    [GPR_Standardowy]           SMALLINT        NOT NULL,
    [GPR_Priorytet]             INT             NOT NULL,
    [GPR_OpeZalId]              INT             NULL,
    [GPR_StaZalId]              INT             NULL,
    [GPR_TS_Zal]                DATETIME        NULL,
    [GPR_OpeModId]              INT             NULL,
    [GPR_StaModId]              INT             NULL,
    [GPR_TS_Mod]                DATETIME        NULL,
    [GPR_OpeModKod]             VARCHAR (20)    CONSTRAINT [DF_GPR_OpeModKod] DEFAULT ('') NOT NULL,
    [GPR_OpeModNazwisko]        NVARCHAR (50)   CONSTRAINT [DF_GPR_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [GPR_OpeZalKod]             VARCHAR (20)    CONSTRAINT [DF_GPR_OpeZalKod] DEFAULT ('') NOT NULL,
    [GPR_OpeZalNazwisko]        NVARCHAR (50)   CONSTRAINT [DF_GPR_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [GPR_PropDniZasilku]        TINYINT         CONSTRAINT [DF_GPR_PropDniZasilku] DEFAULT ((0)) NOT NULL,
    [GPR_KwotaWolnaZUS2]        DECIMAL (15, 2) CONSTRAINT [DF_GPR_KwotaWolnaZUS2] DEFAULT ((0)) NOT NULL,
    [GPR_RodzajKwotyWolnejZUS]  TINYINT         CONSTRAINT [DF_GPR_RodzajKwotyWolnejZUS] DEFAULT ((1)) NOT NULL,
    [GPR_KwotaPobranaKonf]      TINYINT         CONSTRAINT [DF_GPR_KwotaPobranaKonf] DEFAULT ((0)) NOT NULL,
    [GPR_KwotaRodzajPotracenia] INT             CONSTRAINT [DF_GPR_KwotaRodzajPotracenia] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [GPR_Primary] PRIMARY KEY CLUSTERED ([GPR_GprId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [GPRNazwa]
    ON [CDN].[GrupyPotracen]([GPR_Nazwa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [GPRPriorytet]
    ON [CDN].[GrupyPotracen]([GPR_Priorytet] ASC) WITH (FILLFACTOR = 100);

