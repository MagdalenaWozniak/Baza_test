CREATE TABLE [CDN].[AwizoTowary] (
    [AWT_AWTId]           INT             IDENTITY (1, 1) NOT NULL,
    [AWT_AWZId]           INT             NOT NULL,
    [AWT_NrZamowienia]    NVARCHAR (35)   NOT NULL,
    [AWT_DataZamowienia]  DATETIME        NOT NULL,
    [AWT_NrOdbiorca]      NVARCHAR (100)  NOT NULL,
    [AWT_TrEId]           INT             NOT NULL,
    [AWT_TwrID]           INT             NOT NULL,
    [AWT_TwrKod]          NVARCHAR (50)   NOT NULL,
    [AWT_TwrNazwa]        NVARCHAR (255)  NOT NULL,
    [AWT_TwrEAN]          NVARCHAR (40)   NOT NULL,
    [AWT_IloscDoSpakuj]   DECIMAL (15, 4) NOT NULL,
    [AWT_IloscZapakowana] DECIMAL (15, 4) NOT NULL,
    [AWT_IloscCalkowita]  DECIMAL (15, 4) NOT NULL,
    [AWT_Jm]              NVARCHAR (20)   NOT NULL,
    [AWT_NrRO]            NVARCHAR (30)   NOT NULL,
    CONSTRAINT [AWT_Primary] PRIMARY KEY CLUSTERED ([AWT_AWTId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AWTAwizo] FOREIGN KEY ([AWT_AWZId]) REFERENCES [CDN].[Awizo] ([AWZ_AWZId]) ON DELETE CASCADE
);

