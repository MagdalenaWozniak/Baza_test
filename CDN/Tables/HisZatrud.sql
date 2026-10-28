CREATE TABLE [CDN].[HisZatrud] (
    [HZT_HztId]             INT             IDENTITY (1, 1) NOT NULL,
    [HZT_PraId]             INT             NOT NULL,
    [HZT_Nazwa]             NVARCHAR (140)  NOT NULL,
    [HZT_DkmId]             INT             NULL,
    [HZT_StazLata]          INT             NOT NULL,
    [HZT_StazMies]          INT             NOT NULL,
    [HZT_StazDni]           INT             NOT NULL,
    [HZT_StazWliczac]       TINYINT         NOT NULL,
    [HZT_OkresOd]           DATETIME        NULL,
    [HZT_OkresDo]           DATETIME        NULL,
    [HZT_Stanowisko]        NVARCHAR (30)   NOT NULL,
    [HZT_Adres1]            NVARCHAR (60)   NOT NULL,
    [HZT_Adres2]            NVARCHAR (60)   NOT NULL,
    [HZT_Etaty]             TINYINT         NOT NULL,
    [HZT_OpeZalId]          INT             NULL,
    [HZT_StaZalId]          INT             NULL,
    [HZT_TS_Zal]            DATETIME        NOT NULL,
    [HZT_OpeModId]          INT             NULL,
    [HZT_StaModId]          INT             NULL,
    [HZT_TS_Mod]            DATETIME        NOT NULL,
    [HZT_OpeModKod]         VARCHAR (20)    CONSTRAINT [DF_HZT_OpeModKod] DEFAULT ('') NOT NULL,
    [HZT_OpeModNazwisko]    NVARCHAR (50)   CONSTRAINT [DF_HZT_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [HZT_OpeZalKod]         VARCHAR (20)    CONSTRAINT [DF_HZT_OpeZalKod] DEFAULT ('') NOT NULL,
    [HZT_OpeZalNazwisko]    NVARCHAR (50)   CONSTRAINT [DF_HZT_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [HZT_Zbiorczy10]        TINYINT         CONSTRAINT [DF_HZT_Zbiorczy10] DEFAULT ((0)) NOT NULL,
    [HZT_UrlopWypoczynkowy] DECIMAL (15, 4) CONSTRAINT [DF_HZT_UrlopWypoczynkowy] DEFAULT ((0)) NOT NULL,
    [HZT_UrlopNaZadanie]    INT             CONSTRAINT [DF_HZT_UrlopNaZadanie] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [HZT_Primary] PRIMARY KEY CLUSTERED ([HZT_HztId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HZTDkmId] FOREIGN KEY ([HZT_DkmId]) REFERENCES [CDN].[DaneKadMod] ([DKM_DkmId]),
    CONSTRAINT [FK_HZTPraLink] FOREIGN KEY ([HZT_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [HZTPraLink]
    ON [CDN].[HisZatrud]([HZT_PraId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [HZTDkmId]
    ON [CDN].[HisZatrud]([HZT_DkmId] ASC) WITH (FILLFACTOR = 100);

