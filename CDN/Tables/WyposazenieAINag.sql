CREATE TABLE [CDN].[WyposazenieAINag] (
    [WypAIN_WypAINID]       INT             IDENTITY (1, 1) NOT NULL,
    [WypAIN_Bufor]          TINYINT         NOT NULL,
    [WypAIN_DDfID]          INT             NULL,
    [WypAIN_NumerNr]        INT             NOT NULL,
    [WypAIN_NumerString]    VARCHAR (31)    NOT NULL,
    [WypAIN_NumerPelny]     AS              ([CDN].[FN_NUMERPELNY]([WypAIN_NUMERNR],[WypAIN_NUMERSTRING])),
    [WypAIN_DataDok]        DATETIME        NOT NULL,
    [WypAIN_KatID]          INT             NULL,
    [WypAIN_Kategoria]      VARCHAR (50)    NOT NULL,
    [WypAIN_Opis]           NVARCHAR (1024) NOT NULL,
    [WypAIN_OpeZalID]       INT             NULL,
    [WypAIN_StaZalID]       INT             NULL,
    [WypAIN_TS_Zal]         DATETIME        NOT NULL,
    [WypAIN_OpeModID]       INT             NULL,
    [WypAIN_StaModID]       INT             NULL,
    [WypAIN_TS_Mod]         DATETIME        NOT NULL,
    [WypAIN_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_WypAIN_OpeModKod] DEFAULT ('') NOT NULL,
    [WypAIN_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_WypAIN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [WypAIN_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_WypAIN_OpeZalKod] DEFAULT ('') NOT NULL,
    [WypAIN_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_WypAIN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [WypAIN_Primary] PRIMARY KEY CLUSTERED ([WypAIN_WypAINID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WypAINDokDefinicja] FOREIGN KEY ([WypAIN_DDfID]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID]),
    CONSTRAINT [FK_WypAINKategoria] FOREIGN KEY ([WypAIN_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WypAINKategoria]
    ON [CDN].[WyposazenieAINag]([WypAIN_KatID] ASC, [WypAIN_DataDok] ASC, [WypAIN_WypAINID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WypAINDokDefinicja]
    ON [CDN].[WyposazenieAINag]([WypAIN_DDfID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WypAINNumer]
    ON [CDN].[WyposazenieAINag]([WypAIN_NumerString] ASC, [WypAIN_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WypAINNumerPelny]
    ON [CDN].[WyposazenieAINag]([WypAIN_NumerPelny] ASC) WITH (FILLFACTOR = 100);

