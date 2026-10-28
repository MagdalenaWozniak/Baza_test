CREATE TABLE [CDN].[VatTab] (
    [VaT_VaTID]        INT             IDENTITY (1, 1) NOT NULL,
    [VaT_VaNID]        INT             NOT NULL,
    [VaT_VaTOrgId]     INT             NULL,
    [VaT_Stawka]       DECIMAL (5, 2)  NOT NULL,
    [VaT_Flaga]        SMALLINT        NOT NULL,
    [VaT_Zrodlowa]     DECIMAL (5, 2)  NOT NULL,
    [VaT_RodzajZakupu] SMALLINT        NOT NULL,
    [VaT_Odliczenia]   SMALLINT        NOT NULL,
    [VaT_Netto]        DECIMAL (15, 2) NOT NULL,
    [VaT_NettoDoVAT]   DECIMAL (15, 2) NOT NULL,
    [VaT_VAT]          DECIMAL (15, 2) NOT NULL,
    [VaT_VATDoVAT]     DECIMAL (15, 2) NOT NULL,
    [VaT_NettoWal]     DECIMAL (15, 2) NOT NULL,
    [VaT_VATWal]       DECIMAL (15, 2) NOT NULL,
    [VaT_KatID]        INT             NULL,
    [VaT_KatOpis]      NVARCHAR (50)   NULL,
    [VaT_Kat2ID]       INT             NULL,
    [VaT_Kat2Opis]     NVARCHAR (50)   NULL,
    [VaT_KolumnaKPR]   TINYINT         NOT NULL,
    [VaT_KolumnaRYC]   TINYINT         NOT NULL,
    [VaT_Lp]           INT             CONSTRAINT [DF_VaT_Lp] DEFAULT ((0)) NOT NULL,
    [VaT_KwotaNKUP]    DECIMAL (15, 2) CONSTRAINT [DF_VaT_KwotaNKUP] DEFAULT ((0)) NOT NULL,
    [VaT_VATNKUP]      DECIMAL (15, 2) CONSTRAINT [DF_VaT_VATNKUP] DEFAULT ((0)) NOT NULL,
    [VaT_StawkaSymbol] NVARCHAR (10)   CONSTRAINT [DF_VaT_StawkaSymbol] DEFAULT ('') NOT NULL,
    CONSTRAINT [VaT_Primary] PRIMARY KEY NONCLUSTERED ([VaT_VaTID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_VaTKategorie] FOREIGN KEY ([VaT_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_VaTKategorie2] FOREIGN KEY ([VaT_Kat2ID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_VaTVatNag] FOREIGN KEY ([VaT_VaNID]) REFERENCES [CDN].[VatNag] ([VaN_VaNID]) ON DELETE CASCADE
);


GO
CREATE CLUSTERED INDEX [VaTVatNag]
    ON [CDN].[VatTab]([VaT_VaNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [VaTKategorie]
    ON [CDN].[VatTab]([VaT_KatID] ASC) WITH (FILLFACTOR = 100);

