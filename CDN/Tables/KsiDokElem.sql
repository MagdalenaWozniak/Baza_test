CREATE TABLE [CDN].[KsiDokElem] (
    [KDE_KDEId]   INT             IDENTITY (1, 1) NOT NULL,
    [KDE_KDNId]   INT             NOT NULL,
    [KDE_LP]      INT             NULL,
    [KDE_Numer]   NVARCHAR (256)  NOT NULL,
    [KDE_Opis]    NVARCHAR (50)   NOT NULL,
    [KDE_DataWys] DATETIME        NOT NULL,
    [KDE_Termin]  DATETIME        NOT NULL,
    [KDE_Kwota1]  DECIMAL (15, 2) NOT NULL,
    [KDE_Kwota2]  DECIMAL (15, 2) NOT NULL,
    [KDE_Kwota3]  DECIMAL (15, 2) NULL,
    [KDE_Kwota]   DECIMAL (15, 2) NOT NULL,
    [KDE_DataOd]  DATETIME        NULL,
    [KDE_DataDo]  DATETIME        NULL,
    [KDE_BOEID]   INT             NULL,
    [KDE_DeEID]   INT             NULL,
    [KDE_KRoID]   INT             NULL,
    CONSTRAINT [KDE_Primary] PRIMARY KEY CLUSTERED ([KDE_KDEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_KDENaglowek] FOREIGN KEY ([KDE_KDNId]) REFERENCES [CDN].[KsiDokNag] ([KDN_KDNId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [KDENaglowek]
    ON [CDN].[KsiDokElem]([KDE_KDNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KDERozrachunek]
    ON [CDN].[KsiDokElem]([KDE_KRoID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KDEDekret]
    ON [CDN].[KsiDokElem]([KDE_DeEID] ASC, [KDE_BOEID] ASC) WITH (FILLFACTOR = 100);

