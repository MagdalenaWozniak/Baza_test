CREATE TABLE [CDN].[DetalTraNag] (
    [DTrN_DTrNID]             INT             IDENTITY (1, 1) NOT NULL,
    [DTrN_TypNB]              TINYINT         NOT NULL,
    [DTrN_DSTrNID]            INT             NOT NULL,
    [DTrN_StanDetalID]        INT             NOT NULL,
    [DTrN_FaId]               INT             NOT NULL,
    [DTrN_MagId]              INT             CONSTRAINT [DF_DTrN_MagId] DEFAULT ((0)) NULL,
    [DTrN_ZwrId]              INT             NULL,
    [DTrN_TypDokumentu]       INT             NOT NULL,
    [DTrN_NumerNr]            INT             NOT NULL,
    [DTrN_NumerString]        VARCHAR (31)    NOT NULL,
    [DTrN_NumerPelny]         VARCHAR (30)    NOT NULL,
    [DTrN_DataDok]            DATETIME        NOT NULL,
    [DTrN_Fiskalna]           TINYINT         NOT NULL,
    [DTrN_PodID]              INT             NULL,
    [DTrN_OdbID]              INT             NULL,
    [DTrN_RazemBrutto]        DECIMAL (15, 2) NOT NULL,
    [DTrN_Rabat]              DECIMAL (5, 2)  NOT NULL,
    [DTrN_StanSynchronizacji] INT             NULL,
    [DTrN_Waluta]             VARCHAR (3)     NOT NULL,
    [DTrN_OsobaOdbierajaca]   NVARCHAR (40)   NULL,
    [DTrN_OpeID]              INT             NOT NULL,
    [DTrN_TS_Zal]             DATETIME        NOT NULL,
    [DTrN_IloscElementow]     INT             NOT NULL,
    [DTrN_IloscPlatnosci]     INT             NOT NULL,
    [DTrN_OptimaId]           INT             NULL,
    [DTrN_FPlId]              INT             NULL,
    [DTrN_Korekta]            TINYINT         NULL,
    [DTrN_PARodzajKor]        INT             CONSTRAINT [DF_DTrN_PARodzajKor] DEFAULT ((0)) NOT NULL,
    [DTrN_StanKorekta]        TINYINT         NULL,
    [DTrN_Opis]               NVARCHAR (1024) CONSTRAINT [DF_DTrN_Opis] DEFAULT ('') NULL,
    [DTrN_TS_Export]          DATETIME        NULL,
    [DTrN_DataRealizacji]     DATETIME        NULL,
    [DTrN_DataPlatnosci]      DATETIME        NULL,
    [DTrN_AdresId]            INT             CONSTRAINT [DF_DTrN_AdresId] DEFAULT ((0)) NOT NULL,
    [DTrN_MagKod]             NVARCHAR (30)   CONSTRAINT [DF_DTrN_MagKod] DEFAULT ('') NOT NULL,
    [DTrN_StawkaNPOO]         TINYINT         CONSTRAINT [DF_DTrN_StawkaNPOO] DEFAULT ((0)) NOT NULL,
    [DTrN_DDfID]              INT             CONSTRAINT [DF_DTrN_DDfID] DEFAULT ((0)) NOT NULL,
    [DTrN_Anulowanie]         TINYINT         CONSTRAINT [DF_DTrN_Anulowanie] DEFAULT ((0)) NOT NULL,
    [DTrN_PlatnikID]          INT             CONSTRAINT [DF_DTrN_PlatnikID] DEFAULT ((0)) NOT NULL,
    [DTrN_SplitPay]           TINYINT         CONSTRAINT [DF_DTrN_SplitPay] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [DTrN_Primary] PRIMARY KEY CLUSTERED ([DTrN_DSTrNID] ASC, [DTrN_StanDetalID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DTrNID]
    ON [CDN].[DetalTraNag]([DTrN_DTrNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DTrNIDPodmiot]
    ON [CDN].[DetalTraNag]([DTrN_PodID] ASC, [DTrN_DTrNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DTrNIDOdbiorca]
    ON [CDN].[DetalTraNag]([DTrN_DTrNID] ASC, [DTrN_OdbID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DTrNIDOperator]
    ON [CDN].[DetalTraNag]([DTrN_DTrNID] ASC, [DTrN_OpeID] ASC) WITH (FILLFACTOR = 100);

