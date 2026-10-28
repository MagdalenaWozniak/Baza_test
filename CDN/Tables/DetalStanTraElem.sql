CREATE TABLE [CDN].[DetalStanTraElem] (
    [DSTrE_DSTrEID]        INT             IDENTITY (1, 1) NOT NULL,
    [DSTrE_DSTrNId]        INT             NOT NULL,
    [DSTrE_StornoId]       INT             NOT NULL,
    [DSTrE_Lp]             INT             NOT NULL,
    [DSTrE_ZwrId]          INT             NULL,
    [DSTrE_TwrId]          INT             NOT NULL,
    [DSTrE_TwrNazwa]       NVARCHAR (255)  NOT NULL,
    [DSTrE_TwrEAN]         VARCHAR (40)    NOT NULL,
    [DSTrE_TwrKod]         NVARCHAR (50)   NOT NULL,
    [DSTrE_Stawka]         DECIMAL (5, 2)  NOT NULL,
    [DSTrE_Flaga]          SMALLINT        NOT NULL,
    [DSTrE_Cena]           DECIMAL (15, 2) NOT NULL,
    [DSTrE_Rabat]          DECIMAL (5, 2)  NOT NULL,
    [DSTrE_CenaPoRabacie]  DECIMAL (15, 2) NOT NULL,
    [DSTrE_Kaucja]         TINYINT         NOT NULL,
    [DSTrE_Ilosc]          DECIMAL (15, 4) NOT NULL,
    [DSTrE_Jm]             NVARCHAR (20)   NOT NULL,
    [DSTrE_JmCalkowite]    TINYINT         NOT NULL,
    [DSTrE_JMPrzelicznikL] DECIMAL (15, 2) CONSTRAINT [DF_DSTrE_JMPrzelicznikL] DEFAULT ((1)) NOT NULL,
    [DSTrE_JMPrzelicznikM] DECIMAL (7)     CONSTRAINT [DF_DSTrE_JMPrzelicznikM] DEFAULT ((1)) NOT NULL,
    [DSTrE_Waluta]         VARCHAR (3)     NOT NULL,
    [DSTrE_WartoscBrutto]  DECIMAL (15, 2) NOT NULL,
    CONSTRAINT [DSTrE_Primary] PRIMARY KEY CLUSTERED ([DSTrE_DSTrEID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DSTrETowar] FOREIGN KEY ([DSTrE_TwrId]) REFERENCES [CDN].[DetalStanTowary] ([DSTwr_DSTwrId]),
    CONSTRAINT [FK_DSTrETraNag] FOREIGN KEY ([DSTrE_DSTrNId]) REFERENCES [CDN].[DetalStanTraNag] ([DSTrN_DSTrNID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DSTrETraNag]
    ON [CDN].[DetalStanTraElem]([DSTrE_DSTrNId] ASC, [DSTrE_Lp] ASC, [DSTrE_DSTrEID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DSTrETowar]
    ON [CDN].[DetalStanTraElem]([DSTrE_TwrId] ASC, [DSTrE_DSTrEID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DSTrEZwrot]
    ON [CDN].[DetalStanTraElem]([DSTrE_StornoId] ASC, [DSTrE_DSTrEID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DSTrETwrKod]
    ON [CDN].[DetalStanTraElem]([DSTrE_DSTrNId] ASC, [DSTrE_TwrKod] ASC) WITH (FILLFACTOR = 100);

