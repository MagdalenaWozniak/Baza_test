CREATE TABLE [CDN].[BnkFormatyElem] (
    [BFE_BFEId]           INT             IDENTITY (1, 1) NOT NULL,
    [BFE_BFNId]           INT             NULL,
    [BFE_Poziom]          SMALLINT        NOT NULL,
    [BFE_Lp]              SMALLINT        NOT NULL,
    [BFE_Rodzaj]          SMALLINT        NULL,
    [BFE_Typ]             SMALLINT        NULL,
    [BFE_Wartosc]         NVARCHAR (2048) NULL,
    [BFE_LaczZPoprzednim] SMALLINT        NULL,
    [BFE_Szerokosc]       SMALLINT        NULL,
    [BFE_FormatRachunku]  SMALLINT        NULL,
    [BFE_Wymagane]        SMALLINT        NULL,
    CONSTRAINT [BFE_Primary] PRIMARY KEY CLUSTERED ([BFE_BFEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_BFEFormat] FOREIGN KEY ([BFE_BFNId]) REFERENCES [CDN].[BnkFormatyNag] ([BFN_BFNId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BFEFormat]
    ON [CDN].[BnkFormatyElem]([BFE_BFNId] ASC, [BFE_Poziom] ASC, [BFE_Lp] ASC, [BFE_BFEId] ASC) WITH (FILLFACTOR = 100);

