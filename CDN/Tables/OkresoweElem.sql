CREATE TABLE [CDN].[OkresoweElem] (
    [OkE_OkEId]        INT             IDENTITY (1, 1) NOT NULL,
    [OkE_OkNId]        INT             NOT NULL,
    [OkE_Lp]           INT             NOT NULL,
    [OkE_KontoWn]      VARCHAR (50)    NOT NULL,
    [OkE_KontoMa]      VARCHAR (50)    NOT NULL,
    [OkE_Dokument]     VARCHAR (30)    NOT NULL,
    [OkE_Kwota]        NVARCHAR (2000) NOT NULL,
    [OkE_KatId]        INT             NULL,
    [OkE_Kategoria]    VARCHAR (50)    NOT NULL,
    [OkE_Warunek]      NVARCHAR (1000) NOT NULL,
    [OkE_Rozrachunki]  INT             NULL,
    [OkE_KwotaWartosc] DECIMAL (15, 2) NULL,
    [OkE_Uwagi]        NVARCHAR (1024) NULL,
    CONSTRAINT [OkE_Primary] PRIMARY KEY CLUSTERED ([OkE_OkEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_OkEKategoria] FOREIGN KEY ([OkE_KatId]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_OkENaglowek] FOREIGN KEY ([OkE_OkNId]) REFERENCES [CDN].[OkresoweNag] ([OkN_OkNId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [OkEKategoria]
    ON [CDN].[OkresoweElem]([OkE_KatId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [OkENaglowek]
    ON [CDN].[OkresoweElem]([OkE_OkNId] ASC, [OkE_Lp] ASC, [OkE_OkEId] ASC) WITH (FILLFACTOR = 100);

