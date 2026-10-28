CREATE TABLE [CDN].[VatTab7] (
    [Va7_Va7ID]        INT             IDENTITY (1, 1) NOT NULL,
    [Va7_VaNID]        INT             NOT NULL,
    [Va7_RokMiesiac]   INT             NOT NULL,
    [Va7_RodzajZakupu] SMALLINT        NOT NULL,
    [Va7_Stawka]       DECIMAL (5, 2)  NOT NULL,
    [Va7_Flaga]        SMALLINT        NOT NULL,
    [Va7_Zrodlowa]     DECIMAL (5, 2)  NOT NULL,
    [Va7_Netto]        DECIMAL (15, 2) NOT NULL,
    [Va7_VAT]          DECIMAL (15, 2) NOT NULL,
    [Va7_Odliczenia]   SMALLINT        CONSTRAINT [DF_Va7_Odliczenia] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [Va7_Primary] PRIMARY KEY NONCLUSTERED ([Va7_Va7ID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Va7Naglowek] FOREIGN KEY ([Va7_VaNID]) REFERENCES [CDN].[VatNag] ([VaN_VaNID]) ON DELETE CASCADE
);


GO
CREATE CLUSTERED INDEX [Va7Naglowek]
    ON [CDN].[VatTab7]([Va7_VaNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [Va7RokMiesiac]
    ON [CDN].[VatTab7]([Va7_RokMiesiac] ASC) WITH (FILLFACTOR = 100);

