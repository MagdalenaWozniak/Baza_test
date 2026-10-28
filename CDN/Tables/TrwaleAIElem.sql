CREATE TABLE [CDN].[TrwaleAIElem] (
    [SrTAIE_SrTAIEID]                INT             IDENTITY (1, 1) NOT NULL,
    [SrTAIE_SrTAINID]                INT             NOT NULL,
    [SrTAIE_SrTID]                   INT             NULL,
    [SrTAIE_Lp]                      INT             NOT NULL,
    [SrTAIE_NrInwent]                VARCHAR (20)    NOT NULL,
    [SrTAIE_UniqueNrInwBuster]       AS              (case when [SrTAIE_NrInwent]='' then [SrTAIE_SrTAIEID] else (0) end),
    [SrTAIE_KodKreskowy]             VARCHAR (128)   NOT NULL,
    [SrTAIE_UniqueKodKreskowyBuster] AS              (case when [SrTAIE_KodKreskowy]='' then [SrTAIE_SrTAIEID] else (0) end),
    [SrTAIE_Nazwa]                   NVARCHAR (256)  NOT NULL,
    [SrTAIE_Grupa]                   VARCHAR (20)    NOT NULL,
    [SrTAIE_WartoscPocz]             DECIMAL (15, 2) NOT NULL,
    [SrTAIE_Ilosc]                   INT             NOT NULL,
    [SrTAIE_StanBiez]                INT             NOT NULL,
    [SrTAIE_Roznica]                 AS              ([SrTAIE_Ilosc]-[SrTAIE_StanBiez]),
    CONSTRAINT [SrTAIE_Primary] PRIMARY KEY CLUSTERED ([SrTAIE_SrTAIEID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SrTAIENaglowek] FOREIGN KEY ([SrTAIE_SrTAINID]) REFERENCES [CDN].[TrwaleAINag] ([SrTAIN_SrTAINID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrTAIENaglowek]
    ON [CDN].[TrwaleAIElem]([SrTAIE_SrTAINID] ASC, [SrTAIE_SrTAIEID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrTAIETrwale]
    ON [CDN].[TrwaleAIElem]([SrTAIE_SrTID] ASC, [SrTAIE_SrTAIEID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrTAIENrInwent]
    ON [CDN].[TrwaleAIElem]([SrTAIE_SrTAINID] ASC, [SrTAIE_NrInwent] ASC, [SrTAIE_UniqueNrInwBuster] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrTAIEKodKreskowy]
    ON [CDN].[TrwaleAIElem]([SrTAIE_SrTAINID] ASC, [SrTAIE_KodKreskowy] ASC, [SrTAIE_UniqueKodKreskowyBuster] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrTAIELp]
    ON [CDN].[TrwaleAIElem]([SrTAIE_SrTAINID] ASC, [SrTAIE_Lp] ASC) WITH (FILLFACTOR = 100);

