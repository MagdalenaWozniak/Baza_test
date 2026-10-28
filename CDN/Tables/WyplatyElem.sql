CREATE TABLE [CDN].[WyplatyElem] (
    [WyE_WyEId]        INT             IDENTITY (1, 1) NOT NULL,
    [WyE_WyNId]        INT             NOT NULL,
    [WyE_KatID]        INT             NULL,
    [WyE_Kategoria]    VARCHAR (50)    NOT NULL,
    [WyE_Wartosc]      DECIMAL (15, 2) NOT NULL,
    [WyE_Koszt]        TINYINT         NOT NULL,
    [WyE_Gotowka]      TINYINT         NOT NULL,
    [WyE_Opodatkowany] TINYINT         NOT NULL,
    [WyE_UbEmeryt]     TINYINT         NOT NULL,
    [WyE_UbRentow]     TINYINT         NOT NULL,
    [WyE_UbChorob]     TINYINT         NOT NULL,
    [WyE_UbWypadk]     TINYINT         NOT NULL,
    [WyE_UbZdrowo]     TINYINT         NOT NULL,
    [WyE_Potracenie]   TINYINT         NOT NULL,
    CONSTRAINT [WyE_Primary] PRIMARY KEY CLUSTERED ([WyE_WyEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WyEKategoria] FOREIGN KEY ([WyE_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_WyENaglowek] FOREIGN KEY ([WyE_WyNId]) REFERENCES [CDN].[WyplatyNag] ([WyN_WyNId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [WyEKategoria]
    ON [CDN].[WyplatyElem]([WyE_KatID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WyENaglowek]
    ON [CDN].[WyplatyElem]([WyE_WyNId] ASC, [WyE_WyEId] ASC) WITH (FILLFACTOR = 100);

