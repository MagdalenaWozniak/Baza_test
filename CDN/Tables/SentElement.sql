CREATE TABLE [CDN].[SentElement] (
    [SNEL_SNELID]    INT             IDENTITY (1, 1) NOT NULL,
    [SNEL_SentID]    INT             NOT NULL,
    [SNEL_Lp]        INT             NOT NULL,
    [SNEL_TwrId]     INT             CONSTRAINT [DF_SNEL_TwrId] DEFAULT ((0)) NOT NULL,
    [SNEL_KodCN]     VARCHAR (8)     NOT NULL,
    [SNEL_Ilosc]     DECIMAL (15, 2) NOT NULL,
    [SNEL_JM]        NVARCHAR (20)   NOT NULL,
    [SNEL_Masa]      DECIMAL (15, 2) NOT NULL,
    [SNEL_Opis]      NVARCHAR (2000) NULL,
    [SNEL_Stawka]    DECIMAL (5, 2)  CONSTRAINT [DF_SNEL_Stawka] DEFAULT ((0)) NOT NULL,
    [SNEL_Flaga]     SMALLINT        CONSTRAINT [DF_SNEL_Flaga] DEFAULT ((0)) NOT NULL,
    [SNEL_Zrodlowa]  DECIMAL (5, 2)  CONSTRAINT [DF_SNEL_Zrodlowa] DEFAULT ((0)) NOT NULL,
    [SNEL_KodOdpadu] NVARCHAR (6)    CONSTRAINT [DF_SNEL_KodOdpadu] DEFAULT ('') NOT NULL,
    CONSTRAINT [SNEL_Primary] PRIMARY KEY CLUSTERED ([SNEL_SNELID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SentElementSent] FOREIGN KEY ([SNEL_SentID]) REFERENCES [CDN].[SentZgloszenia] ([Sent_SentID]) ON DELETE CASCADE
);

