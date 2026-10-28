CREATE TABLE [CDN].[DeklElem] (
    [DkE_DkEID]        INT             IDENTITY (1, 1) NOT NULL,
    [DkE_DkNID]        INT             NOT NULL,
    [DkE_Numer]        INT             NOT NULL,
    [DkE_WartoscL]     DECIMAL (15, 2) NOT NULL,
    [DkE_WartoscM]     DECIMAL (5)     NOT NULL,
    [DkE_WartoscTekst] NVARCHAR (MAX)  NOT NULL,
    [DkE_Opis]         NVARCHAR (254)  NOT NULL,
    CONSTRAINT [DkE_Primary] PRIMARY KEY CLUSTERED ([DkE_DkEID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DkEDeklNag] FOREIGN KEY ([DkE_DkNID]) REFERENCES [CDN].[DeklNag] ([DkN_DkNID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DkEDeklNag]
    ON [CDN].[DeklElem]([DkE_DkNID] ASC, [DkE_Numer] ASC) WITH (FILLFACTOR = 100);

