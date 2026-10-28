CREATE TABLE [CDN].[DetalTraElem] (
    [DTrE_DTrEID]                   INT             IDENTITY (1, 1) NOT NULL,
    [DTrE_DSTrEID]                  INT             NOT NULL,
    [DTrE_DSTrNId]                  INT             NOT NULL,
    [DTrE_StanDetalId]              INT             NOT NULL,
    [DTrE_ZwrId]                    INT             NULL,
    [DTrE_TwrId]                    INT             NOT NULL,
    [DTrE_Stawka]                   DECIMAL (5, 2)  NOT NULL,
    [DTrE_Flaga]                    SMALLINT        NOT NULL,
    [DTrE_Cena]                     DECIMAL (17, 4) NOT NULL,
    [DTrE_Rabat]                    DECIMAL (5, 2)  NOT NULL,
    [DTrE_CenaPoRabacie]            DECIMAL (17, 4) NOT NULL,
    [DTrE_Waluta]                   VARCHAR (3)     NOT NULL,
    [DTrE_Kaucja]                   TINYINT         NOT NULL,
    [DTrE_Ilosc]                    DECIMAL (15, 4) NOT NULL,
    [DTrE_IloscJM]                  DECIMAL (15, 4) CONSTRAINT [DF_DTrE_IloscJM] DEFAULT ((1)) NOT NULL,
    [DTrE_Jm]                       NVARCHAR (20)   NOT NULL,
    [DTrE_JmCalkowite]              TINYINT         NOT NULL,
    [DTrE_JMPrzelicznikL]           DECIMAL (15, 2) CONSTRAINT [DF_DTrE_JMPrzelicznikL] DEFAULT ((1)) NOT NULL,
    [DTrE_JMPrzelicznikM]           DECIMAL (7)     CONSTRAINT [DF_DTrE_JMPrzelicznikM] DEFAULT ((1)) NOT NULL,
    [DTrE_WartoscBrutto]            DECIMAL (15, 2) NOT NULL,
    [DTrE_Opis]                     NVARCHAR (1024) CONSTRAINT [DF_DTrE_Opis] DEFAULT ('') NULL,
    [DTrE_JMZ]                      NVARCHAR (20)   CONSTRAINT [DF_DTrE_JMZ] DEFAULT ('') NOT NULL,
    [DTrE_UslugaZlozona]            TINYINT         CONSTRAINT [DF_DTrE_UslugaZlozona] DEFAULT ((0)) NOT NULL,
    [DTrE_UslugaZlozonaRecepturaID] INT             CONSTRAINT [DF_DTrE_UslugaZlozonaRecepturaID] DEFAULT ((0)) NOT NULL,
    [DTre_OdwrotneObciazenie]       TINYINT         CONSTRAINT [DF_DTre_OdwrotneObciazenie] DEFAULT ((0)) NOT NULL,
    [DTre_TwCNumer]                 INT             CONSTRAINT [DF_DTre_TwCNumer] DEFAULT ((-1)) NOT NULL,
    CONSTRAINT [DTrE_Primary] PRIMARY KEY CLUSTERED ([DTrE_DTrEID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DTrETraNag] FOREIGN KEY ([DTrE_DSTrNId], [DTrE_StanDetalId]) REFERENCES [CDN].[DetalTraNag] ([DTrN_DSTrNID], [DTrN_StanDetalID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DTrETraNag]
    ON [CDN].[DetalTraElem]([DTrE_DSTrNId] ASC, [DTrE_StanDetalId] ASC, [DTrE_DSTrEID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DTrETowar]
    ON [CDN].[DetalTraElem]([DTrE_TwrId] ASC, [DTrE_DTrEID] ASC) WITH (FILLFACTOR = 100);

