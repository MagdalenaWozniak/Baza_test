CREATE TABLE [CDN].[SrsCzynnosci] (
    [SrY_SrYId]                  INT              IDENTITY (1, 1) NOT NULL,
    [SrY_SrZId]                  INT              NOT NULL,
    [SrY_Lp]                     INT              NOT NULL,
    [SrY_TwrId]                  INT              NULL,
    [SrY_KatID]                  INT              NULL,
    [SrY_TwrKod]                 NVARCHAR (50)    NOT NULL,
    [SrY_TwrNazwa]               NVARCHAR (255)   NOT NULL,
    [SrY_Opis]                   NVARCHAR (1024)  NOT NULL,
    [SrY_SerwisantTyp]           INT              NOT NULL,
    [SrY_SerwisantId]            INT              NOT NULL,
    [SrY_Zakonczona]             TINYINT          NOT NULL,
    [SrY_Fakturowac]             TINYINT          NOT NULL,
    [SrY_Dokument]               INT              NOT NULL,
    [SrY_Realizacja]             TINYINT          NOT NULL,
    [SrY_PoprzedniaOk]           TINYINT          NOT NULL,
    [SrY_DataWykonania]          DATETIME         NULL,
    [SrY_TerminOd]               DATETIME         NOT NULL,
    [SrY_TerminDo]               DATETIME         NOT NULL,
    [SrY_RezerwujCzas]           TINYINT          NOT NULL,
    [SrY_Przypomnienie]          TINYINT          NOT NULL,
    [SrY_CzasPrzypomnienia]      DATETIME         NOT NULL,
    [SrY_CzasTrwania]            DATETIME         NOT NULL,
    [SrY_TwCNumer]               INT              NOT NULL,
    [SrY_Cena0]                  DECIMAL (17, 4)  NOT NULL,
    [SrY_Rabat]                  DECIMAL (5, 2)   NOT NULL,
    [SrY_CenaNetto]              DECIMAL (17, 4)  NOT NULL,
    [SrY_CenaBrutto]             DECIMAL (17, 4)  NOT NULL,
    [SrY_Ilosc]                  DECIMAL (15, 4)  NOT NULL,
    [SrY_IloscJM]                DECIMAL (15, 4)  NOT NULL,
    [SrY_JM]                     NVARCHAR (20)    NOT NULL,
    [SrY_JMZ]                    NVARCHAR (20)    NOT NULL,
    [SrY_JMPrzelicznikL]         DECIMAL (15, 2)  NOT NULL,
    [SrY_JMPrzelicznikM]         INT              NOT NULL,
    [SrY_WartoscNetto]           DECIMAL (15, 2)  NOT NULL,
    [SrY_WartoscBrutto]          DECIMAL (15, 2)  NOT NULL,
    [SrY_WartoscNettoWylicz]     DECIMAL (19, 6)  NOT NULL,
    [SrY_WartoscBruttoWylicz]    DECIMAL (19, 6)  NOT NULL,
    [SrY_KosztUslugi]            DECIMAL (15, 2)  NOT NULL,
    [SrY_Cena0PLN]               DECIMAL (19, 6)  CONSTRAINT [DF_SrY_Cena0PLN] DEFAULT ((0)) NOT NULL,
    [SrY_CenaNettoPLN]           DECIMAL (19, 6)  CONSTRAINT [DF_SrY_CenaNettoPLN] DEFAULT ((0)) NOT NULL,
    [SrY_CenaBruttoPLN]          DECIMAL (19, 6)  CONSTRAINT [DF_SrY_CenaBruttoPLN] DEFAULT ((0)) NOT NULL,
    [SrY_WartoscNettoPLN]        DECIMAL (23, 10) CONSTRAINT [DF_SrY_WartoscNettoPLN] DEFAULT ((0)) NOT NULL,
    [SrY_WartoscBruttoPLN]       DECIMAL (23, 10) CONSTRAINT [DF_SrY_WartoscBruttoPLN] DEFAULT ((0)) NOT NULL,
    [SrY_Waluta]                 VARCHAR (3)      CONSTRAINT [DF_SrY_Waluta] DEFAULT ('') NOT NULL,
    [SrY_Stawka]                 DECIMAL (5, 2)   CONSTRAINT [DF_SrY_Stawka] DEFAULT ((0)) NOT NULL,
    [SrY_Atr1_DeAId]             INT              NULL,
    [SrY_Atr1_Kod]               VARCHAR (20)     CONSTRAINT [DF_SrY_Atr1_Kod] DEFAULT ('') NOT NULL,
    [SrY_Atr1_Wartosc]           NVARCHAR (100)   CONSTRAINT [DF_SrY_Atr1_Wartosc] DEFAULT ('') NOT NULL,
    [SrY_Atr2_DeAId]             INT              NULL,
    [SrY_Atr2_Kod]               VARCHAR (20)     CONSTRAINT [DF_SrY_Atr2_Kod] DEFAULT ('') NOT NULL,
    [SrY_Atr2_Wartosc]           NVARCHAR (100)   CONSTRAINT [DF_SrY_Atr2_Wartosc] DEFAULT ('') NOT NULL,
    [SrY_Atr3_DeAId]             INT              NULL,
    [SrY_Atr3_Kod]               VARCHAR (20)     CONSTRAINT [DF_SrY_Atr3_Kod] DEFAULT ('') NOT NULL,
    [SrY_Atr3_Wartosc]           NVARCHAR (100)   CONSTRAINT [DF_SrY_Atr3_Wartosc] DEFAULT ('') NOT NULL,
    [SrY_Atr4_DeAId]             INT              NULL,
    [SrY_Atr4_Kod]               VARCHAR (20)     CONSTRAINT [DF_SrY_Atr4_Kod] DEFAULT ('') NOT NULL,
    [SrY_Atr4_Wartosc]           NVARCHAR (100)   CONSTRAINT [DF_SrY_Atr4_Wartosc] DEFAULT ('') NOT NULL,
    [SrY_Atr5_DeAId]             INT              NULL,
    [SrY_Atr5_Kod]               VARCHAR (20)     CONSTRAINT [DF_SrY_Atr5_Kod] DEFAULT ('') NOT NULL,
    [SrY_Atr5_Wartosc]           NVARCHAR (100)   CONSTRAINT [DF_SrY_Atr5_Wartosc] DEFAULT ('') NOT NULL,
    [SrY_FlagaVat]               SMALLINT         CONSTRAINT [DF_SrY_FlagaVat] DEFAULT ((2)) NOT NULL,
    [SrY_Zrodlowa]               DECIMAL (5, 2)   CONSTRAINT [DF_SrY_Zrodlowa] DEFAULT ((0)) NOT NULL,
    [SrY_TwrEan]                 VARCHAR (40)     CONSTRAINT [DF_SrY_TwrEan] DEFAULT ('') NOT NULL,
    [SrY_CenaZCzteremaMiejscami] TINYINT          CONSTRAINT [DF_SrY_CenaZCzteremaMiejscami] DEFAULT ((0)) NOT NULL,
    [SrY_UstawAtrSQL]            INT              CONSTRAINT [DF_SrY_UstawAtrSQL] DEFAULT ((-1)) NOT NULL,
    [SrY_CzasTrwaniaInt]         INT              NULL,
    [SrY_IloscDisp]              DECIMAL (15, 4)  CONSTRAINT [DF_SrY_IloscDisp] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [SrY_Primary] PRIMARY KEY CLUSTERED ([SrY_SrYId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SrYKategoria] FOREIGN KEY ([SrY_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_SrYZlecenia] FOREIGN KEY ([SrY_SrZId]) REFERENCES [CDN].[SrsZlecenia] ([SrZ_SrZId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrYKategoria]
    ON [CDN].[SrsCzynnosci]([SrY_KatID] ASC, [SrY_SrYId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrYZlecenia]
    ON [CDN].[SrsCzynnosci]([SrY_SrZId] ASC, [SrY_Lp] ASC, [SrY_SrYId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrYUsluga]
    ON [CDN].[SrsCzynnosci]([SrY_TwrId] ASC, [SrY_SrYId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrYTwrKod]
    ON [CDN].[SrsCzynnosci]([SrY_SrZId] ASC, [SrY_TwrKod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.SrsCzynnosci_Delete_Trigger ON cdn.SrsCzynnosci FOR DELETE
AS
  SET NOCOUNT ON
  -- usuwanie atrybutów powiązanych z czynnością na zleceniu serwisowym
  IF EXISTS ( SELECT * FROM deleted )
  BEGIN
    DELETE FROM cdn.TraElemAtr WHERE (TrA_TrEId IS NULL OR TrA_TrEId=0) AND TrA_DokTyp=901 AND TrA_DokId IN (SELECT SrY_SrYId FROM deleted)
  END
  SET NOCOUNT OFF
