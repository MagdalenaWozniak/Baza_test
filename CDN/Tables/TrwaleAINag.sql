CREATE TABLE [CDN].[TrwaleAINag] (
    [SrTAIN_SrTAINID]       INT             IDENTITY (1, 1) NOT NULL,
    [SrTAIN_Bufor]          TINYINT         NOT NULL,
    [SrTAIN_DDfID]          INT             NULL,
    [SrTAIN_NumerNr]        INT             NOT NULL,
    [SrTAIN_NumerString]    VARCHAR (31)    NOT NULL,
    [SrTAIN_NumerPelny]     AS              ([CDN].[FN_NUMERPELNY]([SrTAIN_NUMERNR],[SrTAIN_NUMERSTRING])),
    [SrTAIN_DataDok]        DATETIME        NOT NULL,
    [SrTAIN_KatID]          INT             NULL,
    [SrTAIN_Kategoria]      VARCHAR (50)    NOT NULL,
    [SrTAIN_Opis]           NVARCHAR (1024) NOT NULL,
    [SrTAIN_OpeZalID]       INT             NULL,
    [SrTAIN_StaZalID]       INT             NULL,
    [SrTAIN_TS_Zal]         DATETIME        NOT NULL,
    [SrTAIN_OpeModID]       INT             NULL,
    [SrTAIN_StaModID]       INT             NULL,
    [SrTAIN_TS_Mod]         DATETIME        NOT NULL,
    [SrTAIN_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_SrTAIN_OpeModKod] DEFAULT ('') NOT NULL,
    [SrTAIN_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_SrTAIN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [SrTAIN_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_SrTAIN_OpeZalKod] DEFAULT ('') NOT NULL,
    [SrTAIN_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_SrTAIN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [SrTAIN_Primary] PRIMARY KEY CLUSTERED ([SrTAIN_SrTAINID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SrTAINDokDefinicja] FOREIGN KEY ([SrTAIN_DDfID]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID]),
    CONSTRAINT [FK_SrTAINKategoria] FOREIGN KEY ([SrTAIN_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrTAINKategoria]
    ON [CDN].[TrwaleAINag]([SrTAIN_KatID] ASC, [SrTAIN_DataDok] ASC, [SrTAIN_SrTAINID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrTAINDokDefinicja]
    ON [CDN].[TrwaleAINag]([SrTAIN_DDfID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrTAINNumer]
    ON [CDN].[TrwaleAINag]([SrTAIN_NumerString] ASC, [SrTAIN_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrTAINNumerPelny]
    ON [CDN].[TrwaleAINag]([SrTAIN_NumerPelny] ASC) WITH (FILLFACTOR = 100);

