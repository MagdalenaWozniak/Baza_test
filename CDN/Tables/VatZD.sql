CREATE TABLE [CDN].[VatZD] (
    [VaZ_VaZId]                         INT             IDENTITY (1, 1) NOT NULL,
    [VaZ_VaNId]                         INT             NOT NULL,
    [VaZ_TrNId]                         INT             NULL,
    [VaZ_Typ]                           INT             NOT NULL,
    [VaZ_DkNId]                         INT             NOT NULL,
    [VaZ_SumaKwotZdarzen]               DECIMAL (15, 2) NOT NULL,
    [VaZ_SumaKwotRozliczen]             DECIMAL (15, 2) NOT NULL,
    [VaZ_KntNazwa1]                     NVARCHAR (255)  NOT NULL,
    [VaZ_KntNazwa2]                     NVARCHAR (255)  NOT NULL,
    [VaZ_KntNazwa3]                     NVARCHAR (255)  NOT NULL,
    [VaZ_KntNipE]                       NVARCHAR (20)   NULL,
    [VaZ_Dokument]                      NVARCHAR (256)  NOT NULL,
    [VaZ_DataWys]                       DATETIME        NOT NULL,
    [VaZ_Termin]                        DATETIME        NOT NULL,
    [VaZ_RazemNetto]                    DECIMAL (15, 2) NOT NULL,
    [VaZ_RazemVAT]                      DECIMAL (15, 2) NOT NULL,
    [VaZ_RazemBrutto]                   DECIMAL (15, 2) NOT NULL,
    [VaZ_RodzajZakupu]                  INT             NULL,
    [VaZ_Odliczenia]                    INT             NULL,
    [VaZ_Flaga]                         INT             NOT NULL,
    [VaZ_Stawka]                        DECIMAL (15, 2) NOT NULL,
    [VaZ_Netto]                         DECIMAL (15, 2) NOT NULL,
    [VaZ_VAT]                           DECIMAL (15, 2) NOT NULL,
    [VaZ_Brutto]                        DECIMAL (15, 2) NOT NULL,
    [VaZ_KorektaNetto]                  DECIMAL (15, 2) NOT NULL,
    [VaZ_KorektaVat]                    DECIMAL (15, 2) NOT NULL,
    [VaZ_PoprzednioDoRoliczenia]        DECIMAL (15, 2) NULL,
    [VaZ_PoprzednioRozliczono]          DECIMAL (15, 2) NULL,
    [VaZ_DoRoliczeniaNaDzienObliczenia] DECIMAL (15, 2) NULL,
    [VaZ_RoliczonoNaDzienObliczenia]    DECIMAL (15, 2) NULL,
    [VaZ_Bufor]                         INT             CONSTRAINT [DF_VaZ_Bufor] DEFAULT ((0)) NOT NULL,
    [VaZ_VaNId_ZK]                      INT             NULL,
    [VaZ_TerminPlatnosci]               DATETIME        NULL,
    [VaZ_BZdId]                         INT             NULL,
    CONSTRAINT [VaZ_Primary] PRIMARY KEY CLUSTERED ([VaZ_VaZId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_VaZDeklNag] FOREIGN KEY ([VaZ_DkNId]) REFERENCES [CDN].[DeklNag] ([DkN_DkNID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [VaZDokuments]
    ON [CDN].[VatZD]([VaZ_BZdId] ASC, [VaZ_Typ] ASC, [VaZ_VaNId] ASC) WITH (FILLFACTOR = 100);

