CREATE TABLE [CDN].[KsiDokNag] (
    [KDN_KDNId]          INT             IDENTITY (1, 1) NOT NULL,
    [KDN_Typ]            SMALLINT        NOT NULL,
    [KDN_OObID]          INT             NOT NULL,
    [KDN_DDfId]          INT             NULL,
    [KDN_Bufor]          SMALLINT        NOT NULL,
    [KDN_NumerNr]        INT             NOT NULL,
    [KDN_NumerString]    VARCHAR (31)    NOT NULL,
    [KDN_NumerPelny]     AS              ([CDN].[FN_NUMERPELNY]([KDN_NUMERNR],[KDN_NUMERSTRING])),
    [KDN_DataDok]        DATETIME        NOT NULL,
    [KDN_Termin]         DATETIME        NULL,
    [KDN_KontoNumer]     NVARCHAR (255)  NOT NULL,
    [KDN_KontoNumerIdx]  NVARCHAR (255)  NOT NULL,
    [KDN_KontoNazwa]     NVARCHAR (255)  NOT NULL,
    [KDN_AccID]          INT             NULL,
    [KDN_KatID]          INT             NULL,
    [KDN_Kategoria]      VARCHAR (50)    NULL,
    [KDN_FPlID]          INT             NULL,
    [KDN_Waluta]         VARCHAR (3)     NOT NULL,
    [KDN_KursNumer]      INT             NOT NULL,
    [KDN_KursL]          DECIMAL (15, 4) NOT NULL,
    [KDN_KursM]          DECIMAL (5)     NOT NULL,
    [KDN_RazemKwota1]    DECIMAL (15, 2) NOT NULL,
    [KDN_RazemKwotaSys1] DECIMAL (15, 2) NOT NULL,
    [KDN_RazemKwota2]    DECIMAL (15, 2) NOT NULL,
    [KDN_RazemKwotaSys2] DECIMAL (15, 2) NOT NULL,
    [KDN_OdsetkiTyp]     INT             NOT NULL,
    [KDN_OdsetkiStopa]   DECIMAL (7, 2)  NOT NULL,
    [KDN_Opis]           NVARCHAR (254)  NULL,
    [KDN_DekID]          INT             NULL,
    [KDN_PreDekID]       INT             NULL,
    [KDN_OpeZalID]       INT             NULL,
    [KDN_StaZalId]       INT             NULL,
    [KDN_TS_Zal]         DATETIME        NOT NULL,
    [KDN_OpeModID]       INT             NULL,
    [KDN_StaModId]       INT             NULL,
    [KDN_TS_Mod]         DATETIME        NOT NULL,
    [KDN_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_KDN_OpeModKod] DEFAULT ('') NOT NULL,
    [KDN_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_KDN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [KDN_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_KDN_OpeZalKod] DEFAULT ('') NOT NULL,
    [KDN_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_KDN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [KDN_DataKur]        DATETIME        NULL,
    CONSTRAINT [KDN_Primary] PRIMARY KEY CLUSTERED ([KDN_KDNId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_KDNDokDefinicja] FOREIGN KEY ([KDN_DDfId]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KDNPodmiot]
    ON [CDN].[KsiDokNag]([KDN_KontoNumer] ASC, [KDN_Typ] ASC, [KDN_DataDok] ASC, [KDN_KDNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KDNKategoria]
    ON [CDN].[KsiDokNag]([KDN_KatID] ASC, [KDN_Typ] ASC, [KDN_DataDok] ASC, [KDN_KDNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KDNDokDefinicja]
    ON [CDN].[KsiDokNag]([KDN_DDfId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KDNNumer]
    ON [CDN].[KsiDokNag]([KDN_NumerString] ASC, [KDN_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KDNNumerPelny]
    ON [CDN].[KsiDokNag]([KDN_Typ] ASC, [KDN_NumerPelny] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KDNViewOrder]
    ON [CDN].[KsiDokNag]([KDN_DataDok] ASC, [KDN_NumerPelny] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KDNDekret]
    ON [CDN].[KsiDokNag]([KDN_DekID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KDNPreDekret]
    ON [CDN].[KsiDokNag]([KDN_PreDekID] ASC) WITH (FILLFACTOR = 100);

