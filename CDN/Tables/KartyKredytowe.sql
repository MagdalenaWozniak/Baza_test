CREATE TABLE [CDN].[KartyKredytowe] (
    [KKr_KKrId]    INT           IDENTITY (1, 1) NOT NULL,
    [KKr_Algorytm] SMALLINT      NOT NULL,
    [KKr_Nazwa]    NVARCHAR (20) NOT NULL,
    CONSTRAINT [KKr_Primary] PRIMARY KEY CLUSTERED ([KKr_KKrId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KKrNazwa]
    ON [CDN].[KartyKredytowe]([KKr_Nazwa] ASC) WITH (FILLFACTOR = 100);

