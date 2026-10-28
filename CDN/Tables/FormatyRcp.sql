CREATE TABLE [CDN].[FormatyRcp] (
    [FOR_ForId]             INT            IDENTITY (1, 1) NOT NULL,
    [FOR_Katalog]           NVARCHAR (200) NOT NULL,
    [FOR_Nieaktywny]        TINYINT        NOT NULL,
    [FOR_RodzajImportu]     TINYINT        NOT NULL,
    [FOR_WgObecnosci]       TINYINT        NOT NULL,
    [FOR_Nazwa]             VARCHAR (40)   NOT NULL,
    [FOR_Format]            NVARCHAR (50)  NOT NULL,
    [FOR_Wejscie]           NVARCHAR (8)   NOT NULL,
    [FOR_WejscieDstId]      INT            NULL,
    [FOR_WeWyStrefaPlan]    TINYINT        NOT NULL,
    [FOR_Wyjscie]           NVARCHAR (8)   NOT NULL,
    [FOR_WejscieSluzb]      NVARCHAR (8)   NOT NULL,
    [FOR_WejscieSluzbDstId] INT            NULL,
    [FOR_WyjscieSluzb]      NVARCHAR (8)   NOT NULL,
    [FOR_WeWySStrefaPlan]   TINYINT        NOT NULL,
    CONSTRAINT [FOR_Primary] PRIMARY KEY CLUSTERED ([FOR_ForId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [FORNazwa]
    ON [CDN].[FormatyRcp]([FOR_Nazwa] ASC) WITH (FILLFACTOR = 100);

