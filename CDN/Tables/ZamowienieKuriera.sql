CREATE TABLE [CDN].[ZamowienieKuriera] (
    [ZAMK_ZAMKID]         INT      IDENTITY (1, 1) NOT NULL,
    [ZAMK_AdresID]        INT      NOT NULL,
    [ZAMK_KurierTyp]      INT      NOT NULL,
    [ZAMK_DataZamowienia] DATETIME NOT NULL,
    CONSTRAINT [ZAMK_Primary] PRIMARY KEY CLUSTERED ([ZAMK_ZAMKID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [ZAMK_AdresID_idx]
    ON [CDN].[ZamowienieKuriera]([ZAMK_AdresID] ASC) WITH (FILLFACTOR = 100);

