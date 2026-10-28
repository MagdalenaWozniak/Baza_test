CREATE TABLE [CDN].[WyposazenieAIElem] (
    [WypAIE_WypAIEID]                INT             IDENTITY (1, 1) NOT NULL,
    [WypAIE_WypAINID]                INT             NOT NULL,
    [WypAIE_WypID]                   INT             NULL,
    [WypAIE_Lp]                      INT             NOT NULL,
    [WypAIE_NrInwent]                NVARCHAR (20)   NOT NULL,
    [WypAIE_KodKreskowy]             VARCHAR (128)   NOT NULL,
    [WypAIE_UniqueKodKreskowyBuster] AS              (case when [WypAIE_KodKreskowy]='' then [WypAIE_WypAIEID] else (0) end),
    [WypAIE_Nazwa]                   NVARCHAR (50)   NOT NULL,
    [WypAIE_JednostkaMiary]          NVARCHAR (20)   NOT NULL,
    [WypAIE_WartoscZak]              DECIMAL (15, 2) NOT NULL,
    [WypAIE_Ilosc]                   DECIMAL (15, 4) NOT NULL,
    [WypAIE_StanBiez]                DECIMAL (15, 4) NOT NULL,
    [WypAIE_Roznica]                 AS              ([WypAIE_Ilosc]-[WypAIE_StanBiez]),
    CONSTRAINT [WypAIE_Primary] PRIMARY KEY CLUSTERED ([WypAIE_WypAIEID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WypAIENaglowek] FOREIGN KEY ([WypAIE_WypAINID]) REFERENCES [CDN].[WyposazenieAINag] ([WypAIN_WypAINID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WypAIENaglowek]
    ON [CDN].[WyposazenieAIElem]([WypAIE_WypAINID] ASC, [WypAIE_WypAIEID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WypAIEWyposazenie]
    ON [CDN].[WyposazenieAIElem]([WypAIE_WypID] ASC, [WypAIE_WypAIEID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WypAIENrInwent]
    ON [CDN].[WyposazenieAIElem]([WypAIE_WypAINID] ASC, [WypAIE_NrInwent] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WypAIEKodKreskowy]
    ON [CDN].[WyposazenieAIElem]([WypAIE_WypAINID] ASC, [WypAIE_KodKreskowy] ASC, [WypAIE_UniqueKodKreskowyBuster] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WypAIELp]
    ON [CDN].[WyposazenieAIElem]([WypAIE_WypAINID] ASC, [WypAIE_Lp] ASC) WITH (FILLFACTOR = 100);

