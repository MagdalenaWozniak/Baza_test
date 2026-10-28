CREATE TABLE [CDN].[PracTeczki] (
    [PRT_PrtId]          INT            IDENTITY (1, 1) NOT NULL,
    [PRT_PraId]          INT            NOT NULL,
    [PRT_DdfId]          INT            NOT NULL,
    [PRT_EteId]          INT            NOT NULL,
    [PRT_DkmId]          INT            NOT NULL,
    [PRT_EteNazwa]       NVARCHAR (256) NOT NULL,
    [PRT_NumerString]    NVARCHAR (31)  NOT NULL,
    [PRT_NumerNr]        INT            NOT NULL,
    [PRT_NumerPelny]     AS             ([CDN].[FN_NUMERPELNY]([PRT_NUMERNR],[PRT_NUMERSTRING])),
    [PRT_DataDok]        DATETIME       NOT NULL,
    [PRT_Tytul]          NVARCHAR (256) NOT NULL,
    [PRT_TytulId]        INT            NOT NULL,
    [PRT_Opis]           NVARCHAR (256) NOT NULL,
    [PRT_NumerObcy]      NVARCHAR (31)  NOT NULL,
    [PRT_DabId]          INT            NULL,
    [PRT_OpeZalId]       INT            NULL,
    [PRT_StaZalId]       INT            NULL,
    [PRT_TS_Zal]         DATETIME       NOT NULL,
    [PRT_OpeModId]       INT            NULL,
    [PRT_StaModId]       INT            NULL,
    [PRT_TS_Mod]         DATETIME       NOT NULL,
    [PRT_OpeModKod]      NVARCHAR (20)  CONSTRAINT [DF_PRT_OpeModKod] DEFAULT ('') NOT NULL,
    [PRT_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_PRT_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [PRT_OpeZalKod]      NVARCHAR (20)  CONSTRAINT [DF_PRT_OpeZalKod] DEFAULT ('') NOT NULL,
    [PRT_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_PRT_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_PRT_PrtId] PRIMARY KEY CLUSTERED ([PRT_PrtId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PRTDdfLink] FOREIGN KEY ([PRT_DdfId]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID]),
    CONSTRAINT [FK_PRTDkmId] FOREIGN KEY ([PRT_DkmId]) REFERENCES [CDN].[DaneKadMod] ([DKM_DkmId]),
    CONSTRAINT [FK_PRTPraLink] FOREIGN KEY ([PRT_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PRTPraLink]
    ON [CDN].[PracTeczki]([PRT_PraId] ASC, [PRT_NumerPelny] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PrtNumerPelny]
    ON [CDN].[PracTeczki]([PRT_NumerPelny] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PRTEteLink]
    ON [CDN].[PracTeczki]([PRT_EteId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PRTDdfLink]
    ON [CDN].[PracTeczki]([PRT_DdfId] ASC) WITH (FILLFACTOR = 100);

